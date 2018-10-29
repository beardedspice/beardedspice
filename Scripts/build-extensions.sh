#!/bin/bash

#  build-extensions.sh
#  BeardedSpice
#
#  Created by Roman Sokolov on 08.01.2018.
#  Copyright © 2018 GPL v3 http://www.gnu.org/licenses/gpl.html

echo "================================================="
echo "Build browser extensions..."
echo "================================================="
echo " "
execdir="$( cd "$( dirname "$0" )/" && pwd )"
/bin/bash "${execdir}/prepare-extensions.sh" build
echo " "
echo "Build Safari browser extension..."
echo "-------------------------------------------------"
CERTDIR="${BS_SAFARI_EXTENSION_CERTS}" /bin/bash  "$execdir/extension-dev-tools/safari/build-safari-extension.sh" ./build/BeardedSpice.safariextension
