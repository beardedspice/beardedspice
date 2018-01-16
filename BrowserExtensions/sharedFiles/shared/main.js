//PREVENTS LOG OUTPUT
//    console.log = function(){};

const DELAY_TIMEOUT = 500; // milleseconds
const RECONNECT_TIMEOUT = 10000; //milleseconds

var socket = null;
var controlPort = 8008;
var clientsPort = 0;
var timeoutObject = null;
var previousTab = null;
var previousTabOnNewWindow = null;
var wasActivated = false;

var _clean = function() {
    socket = null;
    clientsPort = 0;

    if (timeoutObject) {
        clearTimeout(timeoutObject);
    }
    timeoutObject = null;
}

var _send = function(obj) {
    try {

        if (socket) {
            socket.send(JSON.stringify(obj));
            console.log("(BeardedSpice Control) Socket send:" + JSON.stringify(obj));
        }
    } catch (ex) {
        logError(ex);
        socket.close();
    }
};
var _sendOk = function() {
    _send({ 'result': true })
};

var logError = function(ex) {
    if (typeof console !== 'undefined' && console.error) {
        console.error('Error in BeardedSpice Control script');
        console.error(ex);
    }
};

var resetAllTabs = function() {
    console.log("(BeardedSpice Control) Reset all tabs.");
    BSUtils.forEachTabs(tab => {
        BSUtils.sendMessageToTab(tab, "reconnect", { 'result': true });
    });
};

function reconnect(event) {
    console.info("(BeardedSpice Control) Attempt to reconnecting.");

    _clean();
    connect(controlPort);
};

function connect(port) {

    // Create WebSocket connection.
    var url = 'wss://localhost:' + port;

    console.info("(BeardedSpice Control) Try connect to '" + url + "' with ports pool: " + controlPort);

    socket = new WebSocket(url);

    // Connection opened
    socket.addEventListener('open', function(event) {
        console.info("(BeardedSpice Control) Socket open.");
        if (timeoutObject) {
            clearTimeout(timeoutObject);
            timeoutObject = null;
        }
        // send accepters request after timeout
        setTimeout(function() {
            BSUtils.storageGet("hostBundleId", value => {
                if (!value || value == "") {
                    // If bundleId current app is not defined, we attempt to receive from BeardedSpice Controller
                    console.log('(BeardedSpice Control) Sending pairing request');
                    _send({ "request": "hostBundleId" });
                }
                _send({ 'request': 'accepters' });
            });
        }, DELAY_TIMEOUT);
    });

    // Listen for messages
    socket.addEventListener('message', function(event) {
        console.log('(BeardedSpice Control) Message from server ', event.data);
        try {

            var obj = JSON.parse(event.data);
            if (obj['accepters']) {
                //got accepters
                BSUtils.storageSet("accepters", obj['accepters'], () => {
                    _send({ 'request': 'port' });
                });
            } else if (obj['port']) {
                //got clients port
                clientsPort = obj['port'];
                _sendOk();
                // Send new port to tabs
                resetAllTabs();
            } else if (obj['strategiesChanged']) {
                _send({ 'request': 'accepters' });
            } else if (obj['controllerPort']) {
                _sendOk();
                var port = obj['controllerPort'];
                if (port != "" && parseInt(port)) {
                    BSUtils.storageSet("controllerPort", port);
                }
            } else {
                console.error('(BeardedSpice Control) response not found.');
                throw "(BeardedSpice Control) response not found.";
            }
        } catch (ex) {
            logError(ex);
            _send({ 'result': false });
            socket.close();
        }
    });

    var onSocketDisconnet = function(event) {
        console.log('(BeardedSpice Control) onSocketDisconnet');
        _clean();
        timeoutObject = setTimeout(reconnect, RECONNECT_TIMEOUT);
    };

    socket.addEventListener('close', onSocketDisconnet);

    // timeoutObject = setTimeout(connectTimeout, SOCKET_TIMEOUT);
}

function respondToMessage(theMessageEvent) {
    var activated = function(callback) {
        BSUtils.frontmostTab(theMessageEvent.target, val => {
            callback(wasActivated && val);
        });
    };
    if (BSUtils.checkThatTabIsReal(theMessageEvent.target)) {
        console.log('(BeardedSpice Control) respondToMessage event: ' + theMessageEvent.name + ' target: ' + theMessageEvent.target.title);
        try {

            //request accepters
            switch (theMessageEvent.name) {
                case "accepters":
                    BSUtils.storageGet("accepters", value => {
                        BSUtils.sendMessageToTab(theMessageEvent.target, "accepters", value);
                    });
                    break;
                case "port":
                    // request port
                    BSUtils.sendMessageToTab(theMessageEvent.target, "port", { 'result': clientsPort });
                    break;
                case "frontmost":
                    BSUtils.frontmostTab(theMessageEvent.target, val => {
                        BSUtils.sendMessageToTab(theMessageEvent.target, "frontmost", { 'result': val });
                    });
                    break;
                case "isActivated":
                    activated(val => {
                        BSUtils.sendMessageToTab(theMessageEvent.target, "isActivated", { 'result': val });
                    });
                    break;
                case "bundleId":
                    BSUtils.storageGet("hostBundleId", value => {
                        BSUtils.sendMessageToTab(theMessageEvent.target, "bundleId", { 'result': value });
                    });
                    break;
                case "serverIsAlive":
                    if (socket && clientsPort) {
                        BSUtils.sendMessageToTab(theMessageEvent.target, "reconnect", { 'result': true });
                    }
                    break;
                case "activate":
                    BSUtils.getActiveTab(tab => {
                        previousTab = tab;
                        BSUtils.getActiveTab(tab => {
                            previousTabOnNewWindow = tab;
                            if (!previousTabOnNewWindow || previousTab === previousTabOnNewWindow) {
                                previousTabOnNewWindow = null;
                            }
                            BSUtils.setActiveTab(theMessageEvent.target, true, () => {
                                wasActivated = true;
                                BSUtils.sendMessageToTab(theMessageEvent.target, "activate", { 'result': true });
                            });
                        }, theMessageEvent.target);
                    });
                    break;
                case "hide":
                    activated(val => {
                        if (val) {
                            if (previousTabOnNewWindow) {
                                BSUtils.setActiveTab(previousTabOnNewWindow, false);
                            }
                            if (previousTab) {
                                BSUtils.setActiveTab(previousTab, true);
                            }
                        }
                        previousTab = null;
                        wasActivated = false;
                        BSUtils.sendMessageToTab(theMessageEvent.target, "hide", { 'result': true });
                    });
                    break;
                case "pairing":
                    BSUtils.storageSet("hostBundleId", theMessageEvent.message.bundleId, () => {
                        BSUtils.sendMessageToTab(theMessageEvent.target, "pairing", { 'result': true });
                    });
                    break;
                default:

            }
        } catch (ex) {
            logError(ex);
            socket.close();
        }
    }
}

// Add listeners

BSUtils.handleMessageFromTabs(respondToMessage);

// Global events listeners
if (typeof safari !== "undefined" && safari && safari.extension && safari.extension.settings) {
    // change preferences value
    safari.extension.settings.addEventListener("change", function(event) {
        if (event.key == "controllerPort") {
            controlPort = event.newValue;
            socket.close();
        }
    }, false);
} else if (typeof chrome !== "undefined" && chrome && chrome.storage) {
    // change preferences value
    chrome.storage.onChanged.addListener(function(changes, namespace) {
        if (namespace == "local" && changes.controllerPort) {
            controlPort = changes.controllerPort.newValue;
            socket.close();
        }
    }, false);
}

// Start connection to BeardedSpice app
BSUtils.storageGet("controllerPort", value => {
    controlPort = parseInt(value) || 8008;
    connect(controlPort);
});