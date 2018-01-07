# Link this file in your .bashrc
# Example: Add the following line (without #) at the end of your .bashrc:
# source path/to/this/bin/bashrc

pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null

# Load crx* functions for Chrome extension development
source "chrome/crx.bash"

alias build-safari-extension="$PWD/safari/build-safari-extension.sh"
alias build-firefox-extension="$PWD/firefox/build-firefox-extension.sh"
alias mxpack="$PWD/maxthon/mxpack.py"

popd >/dev/null
