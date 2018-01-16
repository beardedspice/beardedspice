// Saves options to chrome.storage.sync.
function save_options() {
    var controllerPort = document.getElementById('controllerPort').value;
    chrome.storage.local.set({
        "controllerPort": controllerPort
    }, function() {
        window.close();
    });
}

function restore_options() {
    // Use default value color = 'red' and likesColor = true.
    chrome.storage.local.get({
        "controllerPort": '8008'
    }, function(items) {
        document.getElementById('controllerPort').value = items.controllerPort;
    });
}
document.addEventListener('DOMContentLoaded', restore_options);
document.getElementById('save').addEventListener('click',
    save_options);