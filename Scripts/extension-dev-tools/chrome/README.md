Copyright Rob Wu <rob@robwu.nl> (https://robwu.nl/)
Last modified: 16 August 2014

## Files

- `crx.bash` - Bash source that defines functions prefixed with "crx".
- `launch-chrome-extensions-on-startup/` - Extension that opens `chrome://extensions/` on startup
- `master_preferences` - Put this file near your Chromium executable if you want to override the
   default profile settings. Some notable preferences:
   * `"distribution.suppress_first_run_bubble = true` disables the first run search bubble.
   * `extensions.ui.developer_mode = true` enables developer mode for extensions.
   * and others (prompt to download instead of saving automatically, less network traffic by
     disabling search suggestions, DNS prefetching, etc.)

## Bash commands
```
crx             Create a Chrome extension in the current directory (if not existent).
crx [name]      Create a Chrome extension with a given name in the current directory,
                and changes current directory to the directory containing the new
                extension.

crxshow         Show whether profile directory for current instance exists.
crxtest         Starts Chrome, loading the Chrome extension from current path.
                After running crxtest once, the extension path will be remembered.
                If you want to reset this value, use __CRX_PWD=
crxdel          Deletes temporary profile.
crxget [arg...] Extracts the CRX file or extension ID from the arguments and download
                the CRX file as [original name or extension ID].crx.
                After saving the file, a command that extracts the downloaded [name].crx
                file(s) to a directory called [name] is shown.
```
