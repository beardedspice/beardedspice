#!/bin/bash

# by Andy Maloney
# http://asmaloney.com/2013/07/howto/packaging-a-mac-os-x-application-using-a-dmg/

set -e

# make sure we are in the correct dir when we double-click a .command file
dir=${0%/*}
if [ -d "$dir" ]; then
  cd "$dir"
fi

# set up your app name, version number, and background image file name
APP_NAME="BeardedSpice"
VERSION="0.1.0"

# you should not need to change these
APP_EXE="${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

VOL_NAME="${APP_NAME} ${VERSION}"   # volume name will be "SuperCoolApp 1.0.0"
DMG_TMP="${VOL_NAME}-temp.dmg"
DMG_FINAL="${VOL_NAME}.dmg"         # final DMG name will be "SuperCoolApp 1.0.0.dmg"

CWD=`pwd`
RESOURCE_DIR="${CWD}/BeardedSpice"
BUILD_DIR="${CWD}/build/Release"
STAGING_DIR="${CWD}/build/packaged"      # we copy all our stuff into this dir

DMG_BACKGROUND_IMG_NAME="beard.png"
DMG_BACKGROUND_IMG="${RESOURCE_DIR}/${DMG_BACKGROUND_IMG_NAME}"

# Check the background image DPI and convert it if it isn't 72x72
_BACKGROUND_IMAGE_DPI_H=`sips -g dpiHeight ${DMG_BACKGROUND_IMG} | grep -Eo '[0-9]+\.[0-9]+'`
_BACKGROUND_IMAGE_DPI_W=`sips -g dpiWidth ${DMG_BACKGROUND_IMG} | grep -Eo '[0-9]+\.[0-9]+'`

if [ $(echo " $_BACKGROUND_IMAGE_DPI_H != 72.0 " | bc) -eq 1 -o $(echo " $_BACKGROUND_IMAGE_DPI_W != 72.0 " | bc) -eq 1 ]; then
   echo "WARNING: The background image's DPI is not 72.  This will result in distorted backgrounds on Mac OS X 10.7+."
   echo "         I will convert it to 72 DPI for you."

   _DMG_BACKGROUND_TMP="${DMG_BACKGROUND_IMG%.*}"_dpifix."${DMG_BACKGROUND_IMG##*.}"

   sips -s dpiWidth 72 -s dpiHeight 72 ${DMG_BACKGROUND_IMG} --out ${_DMG_BACKGROUND_TMP}

   DMG_BACKGROUND_IMG="${_DMG_BACKGROUND_TMP}"
fi

echo 'Cleaning.'
# clear out any old data
rm -rf "${STAGING_DIR}" "${DMG_TMP}" "${DMG_FINAL}"

echo 'Building.'
# build the project
xcodebuild

echo 'Copying to staging directory.'
# copy over the stuff we want in the final disk image to our staging dir
mkdir -p "${STAGING_DIR}"
cp -rpf "${BUILD_DIR}/${APP_NAME}.app" "${STAGING_DIR}"

pushd "${STAGING_DIR}"

# strip the executable
echo "Stripping ${APP_EXE}."
strip -u -r "${APP_EXE}"

# compress the executable if we have upx in PATH
#  UPX: http://upx.sourceforge.net/
if hash upx 2>/dev/null; then
   echo "Compressing (UPX) ${APP_EXE}."
   upx -9 "${APP_EXE}"
fi

# . perform any other stripping/compressing of libs and executables

popd

# tr NOTE: because our app is sub 1m right now, I just hard code the image size to be 1M. Once
# our app grows, remove the commented section, and add $SIZE to the hdiutil call.

# figure out how big our DMG needs to be
#  assumes our contents are at least 1M!
#SIZE=`du -sh "${STAGING_DIR}" | sed 's/\([0-9\.]*\)M\(.*\)/\1/'`
#SIZE=`echo "${SIZE} + 1.0" | bc | awk '{print int($1+0.5)}'`

#if [ $? -ne 0 ]; then
#   echo "Error: Cannot compute size of staging dir"
#   exit
#fi

echo 'Creating .dmg.'
# create the temp DMG file
hdiutil create -srcfolder "${STAGING_DIR}" -volname "${VOL_NAME}" -fs HFS+ \
      -fsargs "-c c=64,a=16,e=16" -format UDRW -size 1M "${DMG_TMP}"

# mount it and save the device
DEVICE=$(hdiutil attach -readwrite -noverify "${DMG_TMP}" | \
         egrep '^/dev/' | sed 1q | awk '{print $1}')

sleep 2

# add a link to the Applications dir
echo "Add link to /Applications in ${VOL_NAME}."
pushd /Volumes/"${VOL_NAME}"
ln -fs /Applications
popd

echo "Adding background image. ${DMG_BACKGROUND_IMG}"
# add a background image
mkdir -p /Volumes/"${VOL_NAME}"/.background
cp "${DMG_BACKGROUND_IMG}" /Volumes/"${VOL_NAME}"/.background/

# tr TODO: these are invalid for our app. FIXITFIXITFXIT
# tell the Finder to resize the window, set the background,
#  change the icon size, place the icons in the right position, etc.
echo 'Moving everything to proper location.'
echo '
   tell application "Finder"
     tell disk "'${VOL_NAME}'"
           open
           set current view of container window to icon view
           set toolbar visible of container window to false
           set statusbar visible of container window to false
           set the bounds of container window to {400, 100, 920, 440}
           set viewOptions to the icon view options of container window
           set arrangement of viewOptions to not arranged
           set icon size of viewOptions to 72
           set background picture of viewOptions to file ".background:'${DMG_BACKGROUND_IMG_NAME}'"
           set position of item "'${APP_NAME}'.app" of container window to {160, 205}
           set position of item "Applications" of container window to {360, 205}
           close
           open
           update without registering applications
           delay 2
     end tell
   end tell
' | osascript

sync

# unmount it
hdiutil detach "${DEVICE}"

# now make the final image a compressed disk image
echo "Creating compressed image."
hdiutil convert "${DMG_TMP}" -format UDZO -imagekey zlib-level=9 -o "${DMG_FINAL}"

# clean up
echo 'Cleaning up.'
rm -rf "${DMG_TMP}"
rm -rf "${STAGING_DIR}"

echo 'Done.'

exit
