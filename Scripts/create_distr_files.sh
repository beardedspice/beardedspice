#!/bin/bash

# Script may run only in Xcode environment.
# Usage: create_distr_files.sh

#You must define EVARs in Project Build Settings
#  BS_FOR_PUBLISH_PATH="/path/to/folder/where/output/files/will/be/inserted"
#  BS_DISTRIBUTE_BASE_URL="https://github.com/user/project/raw/branch"
#  BS_APPCAST_NAME="name_of_appcast.xml"
#  BS_RELEASE_NOTES_NAME="release_notes_file_name_without_extension"
#  BS_UPDATER_PRIVATE_KEY_FILE="path/to/file/with/private/key/for/signing/update"

ARCHIVE_PRODUCTS=$( /usr/bin/find "${HOME}/Library/Developer/Xcode/Archives/" -name "${PROJECT_NAME}*.xcarchive" | sort -nr | /usr/bin/sed -n 1p )
if [ ! "${ARCHIVE_PRODUCTS}" ]; then
    echo "Can't get ${PROJECT_NAME} archive. You must create project archive before."
    exit 1
fi

ARCHIVE_PRODUCTS="${ARCHIVE_PRODUCTS}/Products"
TMP_DIR="${BS_FOR_PUBLISH_PATH}/tmp"

### Prepare temp directory

rm -Rf "${TMP_DIR}"
mkdir "${TMP_DIR}"
if [ $? != 0 ]; then
echo "Can't create temp directory!"
exit 1
fi
mkdir "${TMP_DIR}/releases"
if [ $? != 0 ]; then
echo "Can't create temp directory!"
exit 1
fi
###


SCRIPT_PATH=$( dirname ${0} )
SCRIPT_RESOURCES="$SCRIPT_PATH/Resources"


# Create ZIP file


cp -HRfp "${ARCHIVE_PRODUCTS}/Applications/${PROJECT_NAME}.app" "${TMP_DIR}/"
if [ $? != 0 ]; then
    echo "Can't copy Application"
    exit 1
fi

APP="${TMP_DIR}/${PROJECT_NAME}.app"

plist=${APP}/Contents/Info.plist

# build number
buildnum=$( defaults read "${plist}" CFBundleVersion )
if [ $? != 0 ]; then
echo "No build number in $plist"
exit 2
fi

# version number
version=$( defaults read "${plist}" CFBundleShortVersionString )
if [ $? != 0 ]; then
echo "No version number in $plist"
exit 2
fi

DISTRIB_ZIP_NAME="${PROJECT_NAME}-${version}.zip"

cd "${TMP_DIR}"
zip -q -r --symlinks "releases/${DISTRIB_ZIP_NAME}" "${PROJECT_NAME}.app"
if [ $? != 0 ]; then
echo "Can't create ZIP file"
exit 2
fi

# Save current release notes to notes.db
Notes=$( cat "${SCRIPT_PATH}/Release-Notes-EN.txt" | sed "s/^/<li>/
s/$/<\/li>/" )
IFS=$'\n'
for note in $Notes; do
HTML_NOTES_ITEM_AS_LI="${HTML_NOTES_ITEM_AS_LI} ${note}"
done
sqlite3 "${SCRIPT_RESOURCES}/notes.db" "insert or replace into version_notes (version, release_date, notes) values ('${version}', datetime('now'), '${HTML_NOTES_ITEM_AS_LI}')"

# Release Notes
HTML_BASEURL="${BS_DISTRIBUTE_BASE_URL}"

Template=$( cat ${SCRIPT_RESOURCES}/notes.htmlTemplate | sed "s/\"/\\\\\"/g" )
VersionTemplate=$( cat ${SCRIPT_RESOURCES}/notes.version.htmlTemplate | sed "s/\"/\\\\\"/g" )

# Create English release notes
Notes=$( sqlite3 "${SCRIPT_RESOURCES}/notes.db" "select version, notes from version_notes order by release_date DESC limit ${BS_RELEASE_NOTES_VERSIONS_LIMIT}" )
IFS=$'\n'
for note in $Notes; do
IFS='|' read -r HTML_VERSION HTML_VERSION_NOTES <<< "${note}"
eval "versionNotes=\"$VersionTemplate\""
HTML_VERSIONS_NOTES="${HTML_VERSIONS_NOTES}
${versionNotes}"
done

HTML_TITLE="BeardedSpice updated!"
eval "echo \"$Template\"" > "${TMP_DIR}/${BS_RELEASE_NOTES_NAME}-en.html"

# Create Appcast
XML_BASEURL="${BS_DISTRIBUTE_BASE_URL}"
XML_APP_VERSION_TITLE="Version ${version}"
XML_RELEASE_TIME=$( LANG=C;/bin/date -u +"%a, %d %b %Y %H:%M:00 +0000" )
XML_DISTRIBUTE_URL="${BS_DISTRIBUTE_BASE_URL}/releases/${DISTRIB_ZIP_NAME}"
XML_DISTRIB_LENGTH=$( stat -f "%z" "${TMP_DIR}/releases/${DISTRIB_ZIP_NAME}" )
XML_DISTRIB_BUILD="${buildnum}"
XML_DISTRIB_VERSION="${version}"
XML_RELEASE_NOTES="${BS_RELEASE_NOTES_NAME}"
XML_APPCAST_NAME="${BS_APPCAST_NAME}"
## getting signature
XML_SIGNATURE=$( "${SCRIPT_RESOURCES}/sign_update.sh" "${TMP_DIR}/releases/${DISTRIB_ZIP_NAME}" "${BS_UPDATER_PRIVATE_KEY_FILE}" )
if [ $? != 0 ]; then
echo "Can't create signuture for ${TMP_DIR}/releses/${DISTRIB_ZIP_NAME}"
exit 2
fi


Template=$( cat ${SCRIPT_RESOURCES}/appcast.xmlTemplate | sed "s/\"/\\\\\"/g" )

eval "echo \"$Template\"" > "${TMP_DIR}/${BS_APPCAST_NAME}"

########## Clear ###########
rm -fR "${APP}"

########## Move To BASE #########

mv -f "${TMP_DIR}/releases/"* "${BS_FOR_PUBLISH_PATH}/releases"
cp -f "${BS_FOR_PUBLISH_PATH}/releases/${DISTRIB_ZIP_NAME}" "${BS_FOR_PUBLISH_PATH}/releases/${PROJECT_NAME}-latest.zip"
rm -fR "${TMP_DIR}/releases"
mv -f "${TMP_DIR}/"* "${BS_FOR_PUBLISH_PATH}"
rm -fR "${TMP_DIR}"
