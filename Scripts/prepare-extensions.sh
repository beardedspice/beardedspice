#!/bin/bash

#  prepare-extensions.sh
#  BeardedSpice
#
#  Created by Roman Sokolov on 08.01.2018.
#  Copyright © 2018 GPL v3 http://www.gnu.org/licenses/gpl.html

echo "================================================="
echo "Prepare browser extensions..."
echo "================================================="

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
