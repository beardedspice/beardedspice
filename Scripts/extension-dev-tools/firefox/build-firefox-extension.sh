#!/bin/bash
# Copyright 2013 Rob Wu <gwnRob@gmail.com> (https://robwu.nl/)
# Last modified 30 dec 2013
# 
# 1. Runs cfx xpi (on failure, exit immediately)
# 2. Writes minVersion/maxVersion if update.rdf is found in the current directory.
# 3. Signs the xpi file.
# 
# Environment variables:
# XPIPEM    = Path to PEM file that contains the certificates and private key.
#
# Depends on:
# - addon-sdk
# - 7-Zip
# - xpisign


if [ $# == 0 ] ; then
    echo "Usage: $0 path/to/firefox-addon/"
    exit 1
fi
cd "$1" || exit 2

# To get greadlink, use  brew install coreutils
[ "$(uname)" == "Darwin" ] && { shopt -s expand_aliases; alias readlink=greadlink; }

curdir="$( cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )/" && pwd )"

DEFAULT_XPIPEM="${curdir}/codesigning.pem"
# If environment variable is not set, use default PEM file:
[ -z "${XPIPEM}" ] && [ -f "${DEFAULT_XPIPEM}" ] && XPIPEM="${DEFAULT_XPIPEM}"

echo "Building Firefox add-on"
if type cfx > /dev/null 2>/dev/null ; then
    sdkout=$(cfx xpi)
else
    # Addon SDK not activated yet. Assume that the add-on SDK is installed to /opt/addon-sdk
    sdkout=$(cd /opt/addon-sdk && source bin/activate && cd - && cfx xpi)
fi

if [ -z "${sdkout}" ] ; then
    echo "Failed to run 'cfx xpi'. Did you set up the environment using addon-sdk?"
    echo "See https://addons.mozilla.org/en-US/developers/docs/sdk/latest/dev-guide/tutorials/installation.html"
    exit 7
fi

if [[ "${sdkout}" =~ [a-z0-9_\-]+\.xpi ]] ; then
    XPI="${BASH_REMATCH[0]}"
else
    echo "${sdkout}"
    echo "Cannot find xpi file name in output! Stopping now."
    exit 8
fi


# Copy minVersion / maxVersion if install.rdf was specified.
if [ -f install.rdf ] ; then
    echo "Backing up previous version of install.rdf"
    mv install.rdf install.rdf.bak

    echo "Reading minVersion and maxVersion from install.rdf"
    minVersionPattern='\s*<em:minVersion>[^<]+<\/em:minVersion>'
    maxVersionPattern='\s*<em:maxVersion>[^<]+<\/em:maxVersion>'
    minVersion=$(awk "/${minVersionPattern}/" install.rdf.bak)
    maxVersion=$(awk "/${maxVersionPattern}/" install.rdf.bak)

    echo "Getting install.rdf from xpi"
    7z x "${XPI}" install.rdf > /dev/null

    echo "Updating minVersion and maxVersion in install.rdf"
    sed -E "s#${minVersionPattern}#${minVersion}#" -i install.rdf
    sed -E "s#${maxVersionPattern}#${maxVersion}#" -i install.rdf

    echo "Updating install.rdf in the xpi"
    7z d "${XPI}" install.rdf > /dev/null
    7z a "${XPI}" install.rdf > /dev/null

    echo "Done!"
    echo "Version $(grep -Pow '[0-9.]+(?=<\/em:version)' install.rdf)"
    echo "minVersion ${minVersion}"
    echo "maxVersion ${maxVersion}"
else
    echo "install.rdf not found. Did not change minVersion / maxVersion."
fi

if [ ! -f "${XPIPEM}" ] ; then
    if [ -z "${XPIPEM}" ] ; then
        echo "XPI not signed because PEM file is not set (environment variable XPIPEM= )"
    else
        echo "XPI not signed because pem file not found (${XPIPEM})."
    fi
    exit
fi


# Sign it!
echo "Going to sign ${XPI} using ${XPIPEM}..."
mv {,unsigned-}"${XPI}"
if xpisign -k "${XPIPEM}" "unsigned-${XPI}" "${XPI}" ; then
    rm "unsigned-${XPI}"
else
    mv {unsigned-,}"${XPI}"
    echo "Failed to sign ${XPI}"
    exit 9
fi
