// Saves constants to chrome.storage.sync.
(function () {
    chrome.storage.local.set({
        "nativeMesssageAppId": "${BS_NATIVE_MESSAGING_CONNECTOR_BUNDLE_ID}"
    });
    console.log("(Beardie Controller) global constants updated");
})();
