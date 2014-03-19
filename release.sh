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

VOL_NAME="${APP_NAME}-${VERSION}"   # volume name will be "SuperCoolApp-1.0.0"
DMG_TMP="${VOL_NAME}-temp.dmg"
DMG_FINAL="${VOL_NAME}.dmg"         # final DMG name will be "SuperCoolApp-1.0.0.dmg"

CWD=`pwd`
RESOURCE_DIR="${CWD}/BeardedSpice"
BUILD_DIR="${CWD}/build/Release"
STAGING_DIR="${CWD}/build/packaged"      # we copy all our stuff into this dir

DMG_BACKGROUND_IMG_NAME="beard.png"

echo 'Cleaning.'
# clear out any old data
rm -rf "${STAGING_DIR}" "${DMG_TMP}" "${DMG_FINAL}"

echo 'Building.'
# build the project

xcodebuild -workspace BeardedSpice.xcworkspace -scheme BeardedSpice -configuration Release

echo 'Copying to staging directory.'
# copy over the stuff we want in the final disk image to our staging dir
mkdir -p "${STAGING_DIR}"
cp -rpf "${BUILD_DIR}/${APP_NAME}.app" "${STAGING_DIR}"

pushd "${STAGING_DIR}"

# . perform any other stripping/compressing of libs and executables

popd

# clean up
echo 'Cleaning up.'
rm -rf "${DMG_TMP}"
rm -rf "${STAGING_DIR}"

echo 'Done.'

exit
