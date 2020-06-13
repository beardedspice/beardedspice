//PREVENTS LOG OUTPUT
//console.log = function(){};

console.log("(BeardedSpice) Start injection script");

(function() {

    if (window != window.top) {
        console.log(window.top);
        console.log("(BeardedSpice) Injection script stopped, because iframe");
        return;
    }
    console.log("(BeardedSpice) Injection script running on top window");

    var checkInjectAlready = document.querySelector('#X_BeardedSpice_InjectAlready');
    if (checkInjectAlready != null) {
        console.log("(BeardedSpice) Script already injected!");
         return;
    }
 
    var injected = document.createElement("div");
    injected.setAttribute("id", "X_BeardedSpice_InjectAlready");
    injected.setAttribute("style", "display: none");
    (document.body || document.documentElement).appendChild(injected);
 
    var checkPairingPage = document.querySelector('#X_BeardedSpice_Browser_BundleId');
    if (checkPairingPage != null) {
        console.log("(BeardedSpice) Detected pairing page");
        BSUtils.sendMessageToGlobal("pairing", { "bundleId": checkPairingPage.textContent });
        var messageEl = document.querySelector('#message');

        var messagePairing = (document.querySelector('#messagePairing') &&
                document.querySelector('#messagePairing').textContent) ||
            "Pairing with BeardedSpice App...";

        var messageSuccess = (document.querySelector('#messageSuccess') &&
                document.querySelector('#messageSuccess').textContent) ||
            "BeardedSpice App paired.";

        var messageFailure = (document.querySelector('#messageFailure') &&
                document.querySelector('#messageFailure').textContent) ||
            "BeardedSpice App pairing failure.";

        if (messageEl != null) {
            messageEl.textContent = messagePairing;
            checkPairingPage.textContent = "false";
            var pairingInterval = setInterval(function() {
                clearInterval(pairingInterval);
                if (checkPairingPage.textContent == "true") {
                    messageEl.textContent = messageSuccess;
                } else {
                    messageEl.textContent = messageFailure;
                }
            }, 3000);
        }

        BSUtils.handleMessageFromGlobal(function(event) {
            console.log("(BeardedSpice) Pairing result obtained");
            if (event.name == "pairing" && event.message.result) {
                checkPairingPage.textContent = "true";
            }
        });

        return;
    }

    var injected = document.createElement("script");
    injected.setAttribute("type", "text/javascript");
    injected.textContent = "eval(\"var injected = document.createElement(\\\"div\\\");injected.setAttribute(\\\"id\\\", \\\"BSCheckCSPDiv\\\"); injected.setAttribute(\\\"style\\\", \\\"display: none\\\"); (document.body || document.documentElement).appendChild(injected);\");";
    (document.head || document.documentElement).appendChild(injected);

    var checkInjected = document.querySelector('#BSCheckCSPDiv');
    var noCSP = checkInjected != null;
    var bundleId = null;

    try {

        injected.parentNode.removeChild(injected);
        checkInjected.parentNode.removeChild(checkInjected);
    } catch (ex) {

    }

    if (!noCSP) {
        console.warn("(BeardedSpice) Message for Developers: Page under CSP. You have access to DOM objects only!");
    }

    var state = {
        current: { val: 0, str: "init" },
        init: { val: 0, str: "init" },
        reconnecting: { val: 1, str: "reconnecting" },
        accepted: { val: 2, str: "accepted" },
        strategyRequested: { val: 3, str: "strategyRequested" },
        ready: { val: 4, str: "ready" },
        inCommand: { val: 5, str: "inCommand" },
        connecting: { val: 6, str: "connecting" },
        disconnected: { val: 7, str: "disconnected" },
        set: function(st) {
            this.current = st;
            if (this.inCommandIntervalId) {
                clearInterval(this.inCommandIntervalId);
                this.inCommandIntervalId = null;
            }
            if (st.val == state.inCommand.val) {
                    console.log("(BeardedSpice) inCommand timeout ran");
                this.inCommandIntervalId = setInterval(() => {
                    console.log("(BeardedSpice) inCommand timeout reached");
                    state.set(state.ready);
                }, 2000);
            }
            console.log("(BeardedSpice) Set State to \"" + this.current.str + "\"");
        },
        inCommandIntervalId: null
    }

    var socket = null;
    var strategyName = null;
    var strategy = null;

    var bsParameters = {
        'URL': window.location.href,
        'title': window.document.title == "" ? window.location.href : window.document.title
    };


    // Handle message from Global Extension Page
    var handleMessage = function(event) {
        console.log(event.name);
        console.log(event.message);
        if (event.name === 'serverIsAlive' 
            || event.name === 'reconnect') {
            
            if (handleMessage.intervalId) {
                clearInterval(handleMessage.intervalId);
                console.log("Cleared interval: " +handleMessage.intervalId);
                handleMessage.intervalId = null
            }
            if (event.message["result"]) {
                if (event.name === 'reconnect') {
                    reconnect(event);
                }
                else {
                    serverIsAlive(event);
                }
                return;
            }
            else {
               handleMessage.intervalId = setInterval(function() {
                   BSUtils.sendMessageToGlobal(event.name);
               },
               10000);
           }
       }
       switch (state.current.val) {
            case state.init.val:
            case state.reconnecting.val:
                if (event.name === 'accepters') {
                    accept(event.message);
                }
                break;
            case state.connecting.val:
                if (event.name === 'bundleId') {
                    bundleId = event.message;
                    _send(event.message);
                }
                break;
            case state.accepted.val:
                if (event.name === 'port') {
                    connect(event.message["result"]);
                }
                break;
            case state.inCommand.val:
                switch (event.name) {
                    case 'bundleId':
                        bundleId = event.message;
                    case 'frontmost':
                    case 'activate':
                    case 'hide':
                    case "isActivated":
                        _send(event.message);
                        state.set(state.ready);
                        break;
                    default:
                }
                break;
            default:
        }
    };

    var _clean = function() {
        socket = null;
        strategyName = null;
        strategyAccepterFunc = null;
        strategy = null;
        state.set(state.init);
    }

    var _send = function(obj) {
        try {

            if (socket) {
                socket.send(JSON.stringify(obj));
                console.log("(BeardedSpice) Socket send:" + JSON.stringify(obj));
            }
        } catch (ex) {
            logError(ex);
            socket.close();
        }
    };
    var _sendOk = function() { _send({ 'result': true }) };

    var logError = function(ex) {
        if (typeof console !== 'undefined' && console.error) {
            console.error('Error in BeardedSpice script');
            console.error(ex);
        }
    };

    var accept = function(accepters) {

        if (!accepters ||
            !(state.current.val == state.init.val ||
                state.current.val == state.reconnecting.val)) {
            return;
        }

        console.info("(BeardedSpice) Accepters run.");

        try {
            var code = accepters.bsJsFunctions +
                "bsJsFunctions();" +
                "var strategies = " + accepters.strategies + ";" +
                "Object.getOwnPropertyNames(strategies).find(function(val) {" +
                "eval(strategies[val]);" +
                "if (bsAccepter()) {" +
                "strategyName = val;" +
                "strategyAccepterFunc = bsAccepter;" +
                "console.info(\"(BeardedSpice) Strategy found: \" + strategyName + \".\");" +
                "return true;" +
                "}" +
                "return false;" +
                "});";


            if (noCSP) {
                BSUtils.injectAccepters(code, bsParameters);
                console.log("(BeardedSpice) Accepters run: before delayedFunc.");
                var intervalId = null;
                var delayedFunc = function() {
                    BSEventClient.sendRequest({ "name": "accept" }, function(response) {
                        console.log("(BeardedSpice) Accepters run: func delayedFunc.");

                        strategyName = response.strategyName;
                        if (strategyName) {
                            state.set(state.accepted);
                            BSUtils.sendMessageToGlobal("port");
                        } else {
                            state.set(state.init);
                        }
                    });
                    if (intervalId) {
                        clearInterval(intervalId);
                    }
                }
                intervalId = setInterval(delayedFunc, 1000);
                console.log("(BeardedSpice) Accepters run: after setTimeout");
            } else {
                eval(code);
                console.log("(BeardedSpice) Accepters run: on CSP");
                if (strategyName) {
                    state.set(state.accepted);
                    BSUtils.sendMessageToGlobal("port");
                } else {
                    state.set(state.init);
                }
            }

        } catch (ex) {
            logError(ex);
        }

    };

    var serverIsAlive = function(event) {
        console.info("(BeardedSpice) Attempt to connecting on new port.");
        state.set(state.accepted);
        BSUtils.sendMessageToGlobal("port");
    };

    var reconnect = function(event) {

        if (state.current.val === state.reconnecting.val) {
            return;
        }

        console.info("(BeardedSpice) Attempt to reconnecting.");

        state.set(state.reconnecting);
        if (socket) {
            socket.close();
        }
        _clean();

        BSUtils.sendMessageToGlobal("accepters");
    };

    // var connectTimeout = function(event) {

    //     console.log("(BeardedSpice) Connection timeout.");
    //     var _socket = socket;
    //     _clean();
    //     _socket.close();
    // };

    var connect = function(port) {

        if (state.current.val !== state.accepted.val) {
            return;
        }

        var onSocketDisconnet = function(event) {
            console.info('(BeardedSpice) onSocketDisconnet');

            if (state.current.val === state.reconnecting.val) {
                return;
            }
            state.set(state.disconnected);

            //sending request to extension
            BSUtils.sendMessageToGlobal('serverIsAlive');
        };

        if (port == 0) {
            console.info("(BeardedSpice) Port not specified.");
            onSocketDisconnet();
            return;
        }

        state.set(state.connecting);

        // Create WebSocket connection.
        var url = 'wss://localhost:' + port;
        console.info("(BeardedSpice) Try connect to '" + url + "'");

        socket = new WebSocket(url);

        // Connection opened
        socket.addEventListener('open', function(event) {
            console.info("(BeardedSpice) Socket open.");
        });

        socket.addEventListener('close', onSocketDisconnet);

        // Listen for messages
        socket.addEventListener('message', function(event) {
            console.log('(BeardedSpice) Message from server ', event.data);
            console.log('(BeardedSpice) State: ' + state.current.str);
                                
            switch (state.current.val) {
                case state.connecting.val:
                    if (event.data == "bundleId") {
                        if (bundleId != null) { // if we hold localy bundleId, return it
                            _send(bundleId);
                            break;
                        }
                        //sending request to extension
                        BSUtils.sendMessageToGlobal(event.data);
                        break;
                    }
                    if (event.data == "standalone") {
                        _send({"standalone": BSUtils.isStandalone()});
                        break;    
                    }
                    if (event.data == "ready") {
                        _send({ 'strategy': strategyName });
                        state.set(state.strategyRequested);
                    }
                    break;
                case state.strategyRequested.val:
                    if (noCSP) {
                        BSUtils.injectScript(event.data);
                        BSEventClient.sendRequest({ "name": "checkStrategy" }, function(response) {

                            if (response.result) {
//                                BSUtils.injectExtScript("shared/utils.js");
                                state.set(state.ready);
                                _sendOk();
                            }
                        });
                    } else {

                        try {
                            eval('var ' + event.data + ';');
                            if (BSStrategy) {
                                console.log('(BeardedSpice) Strategy obtained.');
                                console.log(BSStrategy);
                                strategy = BSStrategy;
                                state.set(state.ready);
                                _sendOk();
                            }
                        } catch (ex) {
                            logError(ex);
                            _send({ 'result': false });
                        }
                    }
                    break;
                    //Main Command Loop
                case state.ready.val:
                    try {
                        try {
                            var obj = JSON.parse(event.data);
                            if (obj.realBundleId != null) {
                                bundleId = obj.realBundleId;
                                console.log("(BeardedSpice) Real Bundle ID set on: %s", bundleId);
                                _sendOk();
                                break;
                            }
                        } catch (ex) { 
                            console.log("(BeardedSpice) try simple command");
                        }
                        state.set(state.inCommand);
                        switch (event.data) {
                            case "settingsChanged":
                                //sending request to extension and are not waiting of a response
                                _send({'result': true});
                                BSUtils.sendMessageToGlobal(event.data);
                                state.set(state.ready);
                                break;
                            case "bundleId":
                                if (bundleId != null) { // if we hold localy bundleId, return it 
                                    _send(bundleId);
                                    state.set(state.ready);
                                    break;
                                }
                            case "frontmost":
                            case "activate":
                            case "hide":
                            case "isActivated":
                                //sending request to extension
                                BSUtils.sendMessageToGlobal(event.data);
                                break;
                            default:
                                if (noCSP) {
                                    BSEventClient.sendRequest({ "name": "command", "args": event.data }, function(response) {
                                        _send(response);
                                        state.set(state.ready);
                                    });
                                } else {
                                    _send(BSUtils.strategyCommand(strategy, event.data));
                                    state.set(state.ready);
                                }
                        }
                    } catch (ex) {
                        logError(ex);
                        _send({ 'result': false });
                    }
                    break;
                default:
            }
        });
    };

    var onUrlChangedBy = function(event) {
        console.log("(BeardedSpice) onUrlChangedBy");

        bsParameters.URL = window.location.href;

        if (strategyName) {
            //strategy was loaded
            //check strategy validity
            if (noCSP) {
                BSEventClient.sendRequest({ "name": "checkAccept" }, function(response) {
                    console.log("(BeardedSpice) checkAccept run: %o", response);

                    if (response["result"]) {
                        //do nothing
                        return;
                    }
                    reconnect();
                });
                return;
            } else {
                if (strategyAccepterFunc()) {
                    //do nothing
                    return;
                }
            }
        }
        reconnect();
    }

    window.addEventListener("popstate", function(event) {
        console.log("(BeardedSpice) onPopstate.");
        setTimeout(function() {
            if (bsParameters.URL != window.location.href) {
                return onUrlChangedBy(event);
            }
        }, 1);
    }, true);

    window.addEventListener("click", function(event) {
        console.log("(BeardedSpice) onClick");
        setTimeout(function() {
            if (bsParameters.URL != window.location.href) {
                return onUrlChangedBy(event);
            }
        }, 1);
    }, true);

    console.info("BeardedSpice Script Injected.");

    BSUtils.handleMessageFromGlobal(handleMessage);

    BSUtils.sendMessageToGlobal("accepters");

})();
