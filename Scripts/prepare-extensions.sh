#!/bin/bash

#  prepare-extensions.sh
#  BeardedSpice
#
#  Created by Roman Sokolov on 08.01.2018.
#  Copyright © 2018 BeardedSpice. All rights reserved.

echo "================================================="
echo "Prepare browser extensions..."
echo "================================================="
echo " "
echo "Prepare Safari browser extension..."
echo "-------------------------------------------------"
rm -Rf ./build/BeardedSpice.safariextension
mkdir -pv ./build/BeardedSpice.safariextension
cp -v ./safari/* ./build/BeardedSpice.safariextension/
cp -vR ./sharedFiles/shared ./build/BeardedSpice.safariextension/shared
cp -v ./sharedFiles/icon/Icon-32.png ./build/BeardedSpice.safariextension/
cp -v ./sharedFiles/icon/Icon-64.png ./build/BeardedSpice.safariextension/
cp -v ./sharedFiles/icon/Icon-128.png ./build/BeardedSpice.safariextension/
cp -v ./sharedFiles/icon/Icon.png ./build/BeardedSpice.safariextension/
devIdPath="${BS_SAFARI_EXTENSION_CERTS}/developer_id.txt"
BS_SAFARI_DEVELOPER_ID=$( cat "${devIdPath}" )
if [ ! $? == 0 ]; then
echo "Can't obtain developer id from '${devIdPath}'"
exit 1
fi

echo "Developer ID is '${BS_SAFARI_DEVELOPER_ID}'"
echo "Apply env vars to Info.plist"
Template=$( cat ./build/BeardedSpice.safariextension/Info.plist | sed "s/\"/\\\\\"/g" )
eval "echo \"$Template\"" > ./build/BeardedSpice.safariextension/Info.plist || exit 1

echo "Done"

echo " "
echo "Prepare Google Chrome browser extension..."
echo "-------------------------------------------------"
rm -Rf ./build/BeardedSpice.chrome
mkdir -pv ./build/BeardedSpice.chrome
cp -v ./chrome/* ./build/BeardedSpice.chrome/
cp -vR ./sharedFiles/shared ./build/BeardedSpice.chrome/shared
cp -vR ./sharedFiles/icon ./build/BeardedSpice.chrome/icon

echo "Apply env vars to manifest.json"
Template=$( cat ./build/BeardedSpice.chrome/manifest.json | sed "s/\"/\\\\\"/g" )
eval "echo \"$Template\"" > ./build/BeardedSpice.chrome/manifest.json || exit 1

echo "Done"

if [ ! "$1" == "build" ]; then
echo " "
echo "-------------------------------------------------"
echo "Reveal in Finder"
echo "-------------------------------------------------"
ABSOLUTE_PATH=$(cd ./build; pwd)
APPLESCRIPTFOROPENFOLDER="
tell application \"Finder\"
activate
reveal (\"${ABSOLUTE_PATH}/\" as POSIX file)
end tell
"

echo "$APPLESCRIPTFOROPENFOLDER" | osascript
fi
