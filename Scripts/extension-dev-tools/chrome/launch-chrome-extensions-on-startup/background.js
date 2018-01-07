/* globals chrome, console */
'use strict';

// Not working when running chromium --load-extension=PWD
chrome.runtime.onStartup.addListener(showChromeExtensions);

chrome.runtime.onInstalled.addListener(function(details) {
    if (details.reason == 'install')
        showChromeExtensions();
});
chrome.browserAction.onClicked.addListener(showChromeExtensions);

var TAB_NOT_FOUND = -1;
function reduceChromeExtensionsTabId(tabId, tab) {
    return tabId == TAB_NOT_FOUND && /^chrome:\/\/extensions/.test(tab.url) ? tab.id : tabId;
}
function showChromeExtensions() {
    chrome.tabs.query({}, function(tabs) {
        var tabId = tabs.reduce(reduceChromeExtensionsTabId, TAB_NOT_FOUND);
        if (tabId != TAB_NOT_FOUND) {
            chrome.tabs.update(tabId, {
                active: true
            });
            return;
        }
        chrome.tabs.create({
            url: 'chrome://extensions/'
        });
    });
}
