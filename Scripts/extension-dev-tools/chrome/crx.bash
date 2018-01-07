# (c) 2013 - 2014 Rob Wu <rob@robwu.nl>
# Exports several functions to ease Chrome extension development
#
# crx - Bootstraps Chrome extension if not existent
# crxshow - Show whether profile directory for current instance exists.
# crxtest - Starts Chrome, loading the Chrome extension from current path or parent
# crxdel - Deletes temporary profile
# crxget - Download and optionally suggest to extract a CRX file from the CWS or elsewhere
#
# Global variables
# __CRX_CHROMIUM_BIN        - Name of Chromium executable
# __CRX_EXTRA_EXTENSIONS    - Comma-separated list of extensions to be loaded
# __CRX_PROFILE             - Path to temp profile dir
# __CRX_PWD                 - Path to extension dir
# 


# If chromium is not found within the path, but google-chrome is, use it.
__CRX_CHROMIUM_BIN=chromium
if ! type "chromium" >/dev/null 2>/dev/null; then
    if ! type "google-chrome" >/dev/null 2>/dev/null; then
        __CRX_CHROMIUM_BIN=google-chrome
    fi
fi

# Chrome extension that provides quick access to chrome://extensions/
__CRX_EXTRA_EXTENSIONS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/launch-chrome-extensions-on-startup"

crx() {
    if [ $# -ne 0 ] ; then
        if [ -e "$*" ] ; then
            if [ ! -e "$*/manifest.json" ] ; then
                echo "$* already exists. Did not create crx files."
                return
            else
                echo "$*/manifest.json already found."
            fi  
        else
            if [ "$*" == "${PWD##*/}" ] ; then
                echo "Did not create directory or crx files, because the current directory has the same name"
                return
            fi
            echo "Created directory $*"
            mkdir "$*"
        fi
        echo "Changed directory to $*"
        cd "$*"
    fi
    if [ -e manifest.json ] ; then
        echo "manifest.json already found"
    else
        echo '{
    "name": "Name ",
    "version": "1",
    "manifest_version": 2,
    "background": {
        "scripts": ["background.js"],
        "persistent": true
    },
    "content_scripts": [{
        "run_at": "document_idle",
        "js": ["contentscript.js"],
        "matches": ["<all_urls>"]
    }],
    "browser_action": {
        "default_title": ""
    },
    "permissions": [
        "tabs",
        "<all_urls>"
    ],
    "web_accessible_resources": [
    ]
}' > manifest.json
        touch background.js
        touch contentscript.js
        echo "Created manifest.json, background.js and contentscript.js"
    fi
    __CRX_PWD=${PWD}
}
__get_crx_profile_path() {
    if [ ! -d "${__CRX_PWD}" ] ; then
        local path=${PWD}
        while [[ -n "${path}" && ! -e "${path}/manifest.json" ]] ; do
            path=${path%/*}
        done
        if [ -z "${path}" ] ; then
            echo "manifest.json not found in current or parent directory!"
            return 1
        fi
        __CRX_PWD=${path}
    fi
    if [ -z "${__CRX_PROFILE}" ] ; then
        # /tmp/CRX.prof-ABCDEF-BASENAMENOSPACE
        __CRX_PROFILE=/tmp/CRX.prof-$(echo "${__CRX_PWD}" | md5sum | cut -c 1-6 )-$(basename "${__CRX_PWD// /}")
    fi
}
crxshow() {
    __get_crx_profile_path || return
    if [ -e "${__CRX_PROFILE}" ] ; then
        # Show command for launching Chrome manually
        echo "${__CRX_CHROMIUM_BIN} --user-data-dir=${__CRX_PROFILE}"
    else
        echo "${__CRX_PROFILE} not found"
    fi
}
crxtest() {
    __get_crx_profile_path || return
    local command="cd \"${__CRX_PWD}\" && ${__CRX_CHROMIUM_BIN} --user-data-dir=\"${__CRX_PROFILE}\" \
--load-extension=\"${__CRX_EXTRA_EXTENSIONS},.\" $(printf '%q ' "$@")"
    echo "( ${command} )"
    bash -c "${command}"
}
crxdel() {
    __get_crx_profile_path
    if [[ -d "${__CRX_PROFILE}" ]] ; then
        if [[ "${__CRX_PROFILE}" =~ "/tmp/" ]] ; then
            rm -r "${__CRX_PROFILE}" && echo "# Removed \"${__CRX_PROFILE}\""
        else
            echo "# Run the following command"
            echo "# rm -r ${__CRX_PROFILE}"
        fi
    else
        echo "# \$__CRX_PROFILE is not a directory"
    fi
    __CRX_PWD=
    __CRX_PROFILE=
}


# Download and extract crx file from the CWS for a given URL
crxget() {
    # Some OS-specific values. Doesn't really matter if we only want to inspect the source
    local arch=
    local os=
    # See https://github.com/Rob--W/crxviewer/blob/master/src/chrome-platform-info.js
    case "$(uname)" in
        Darwin)
            os=mac
            ;;
        *WIN*)
            os=win
            ;;
        # Nope, no android
        # Nope, no cros
        *BSD)
            os=openbsd
            ;;
        *)
            # Default to Linux
            os=Linux
    esac

    if [ "$(getconf LONG_BIT)" = "64" ] ; then
        arch="x86-64"
    else
        arch="x86-32"
    fi

    local nacl_arch="$arch"
    for arg in "$@" ; do
        local dl_url=
        local filename=
        local url_without_questionmark="${arg%%\?*}"
        if [[ "$url_without_questionmark" == *.crx ]] ; then
            dl_url="$arg"
            # Last part
            filename="${url_without_questionmark##*/}"
        else
            local cws_id="$(echo "$arg" | grep -oP '\b[a-p]{32}\b' )"
            if [ -n "$cws_id" ] ; then
                # Assume that we got a CWS URL
                # See https://github.com/Rob--W/crxviewer/blob/master/src/cws_pattern.js
                dl_url="https://clients2.google.com/service/update2/crx?response=redirect"
                dl_url+="&os=$os"
                dl_url+="&arch=$arch"
                dl_url+="&nacl_arch=$nacl_arch"
                dl_url+="&prod=chromiumcrx"
                dl_url+="&prodchannel=unknown"
                dl_url+="&prodversion=31.0.1609.0"
                dl_url+="&x=id%3D$cws_id"
                dl_url+="%26uc"
                filename="$cws_id.crx"
            fi
        fi

        if [ -n "$dl_url" ] ; then
            if [ -e "$filename" ] ; then
                echo "$filename already exists, skipping download of $dl_url"
            else
                curl -L "$dl_url" -o "$filename"
                # Do not use wget because it hangs on 204
                #wget "$dl_url" -O "$filename"
                if [ ! -e "$filename" ] ; then
                    # Taken down, behind login, etc.
                    echo "Cannot download $dl_url"
                fi
            fi
        fi
    done

    cat <<'HERE'
# To extract all downloaded crx files, run the following commands:
for f in *.crx ; do
    if [ -e "${f%.crx}" ] ; then
        echo "${f%.crx} already exists. Skipping extraction of $f"
    else
        unzip "$f" -d "${f%.crx}"
        rm -r "${f%.crx}/_metadata"
    fi
done
HERE
}
