#!/bin/bash
# clean up the previous installation so we can test it again.

killall BeardedSpice
# Remove files
sudo rm -f ~/Library/Preferences/com.beardedspice.BeardedSpice.plist
sudo rm -rf ~/Library/Application\ Support/BeardedSpice
sudo rm -rf /Applications/BeardedSpice.app

# Reboot the notifications service so it realizes that the app is gone
sudo killall usernoted

echo \# BeardedSpice has been uninstalled