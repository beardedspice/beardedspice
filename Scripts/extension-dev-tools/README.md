This repository contains tools to ease the development and deployment
of browser extensions. Most tools are shell scripts (Bash) or functions,
directly usable on Linux and Mac.

If you're using Windows, you need to install [Cygwin](http://www.cygwin.com/)
or [Gnu On Windows](https://github.com/bmatzelle/gow/wiki).

Author: Rob Wu <gwnRob@gmail.com> (https://robwu.nl/).  
Website: https://github.com/Rob--W/extension-dev-tools

# Usage
The documentation for each browser can be found in the separate subdirectories.

The easiest way to integrate this set of tools in your environment is by adding
the following line to your `.bashrc`:

    source path/to/extension-dev-tools/bashrc

## Chrome
- See `chrome/README.md` for details.

## Firefox
- Quick start: Create a file or symlink at `firefox/codesigning.pem`
- See `firefox/README.md` for details.

## Safari
- Quick start: Create a directory or symlink at `safari/certs`
- See `safari/README.md` for details.

## Opera
## Internet Explorer

## Maxthon
- See `maxthon/README.md` for details.
