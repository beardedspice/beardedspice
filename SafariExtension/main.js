(function() {
    
    if (window != top) {
        return;
    }

debugger;

    const SOCKET_TIMEOUT = 1000; //milleseconds
    const RECONNECT_TIMEOUT = 10000; //milleseconds

    var socket = null;
    var strategyName = null;
    var strategy = null;
    var timeoutObject = null;

    this.URL = window.location.href;
    this.title = window.document.title == "" ? window.location.href : window.document.title;

    var _clean = function(){
        if (socket) {
            delete socket;
        }
        socket = null;

        if (timeoutObject) {
            clearTimeout(timeoutObject);
        }
        timeoutObject = null;

        strategyName = null;
        strategy = null;
    }

    var _send = function (obj) {
        if (socket) {
            socket.send(JSON.stringify(obj));
        }
    };
    var _sendOk = function() { _send({'result':true})};

    var logError = function (ex) {
        if (typeof console !== 'undefined' && console.error) {
            console.error('Error in BeardedSpice script');
            console.error(ex);
        }
    };

    var handleMessage = function(event) {
        console.log(event.name);
        console.log(event.message);
        if (event.name == 'accepters') {
            accept(event.message);
        }
        else if (event.name == 'port') {
            connect(event.message["result"]);
        }
        else if (event.name == 'frontmost') {
            _send(event.message);
        }
    };
    
    document.addEventListener("DOMContentLoaded", function(event) {
        
        console.info("BeardedSpice Script Injected.");
        safari.self.addEventListener("message", handleMessage);
        safari.extension.dispatchMessage("accepters");
    });

    var accept = function (accepters) {

        console.info("(BeardedSpice) Accepters run.");
        try {
            eval(accepters.bsJsFunctions);
            bsJsFunctions();
            var strategies = accepters.strategies;
            Object.getOwnPropertyNames(strategies).find(function(val) {
                eval(strategies[val]);
                if (bsAccepter()) {
                    strategyName = val;
                    console.info("(BeardedSpice) Strategy found: " + strategyName + ".");
                    return true;
                }
                return false;
            });
            if (strategyName) {
                safari.extension.dispatchMessage("port");
            }
        } catch (ex) {
            logError(ex);
        }

    };

    var reconnect = function(event) {
        console.info("(BeardedSpice) Attempt to reconnecting.");

        _clean();
        safari.extension.dispatchMessage("accepters");
    };

    var connectTimeout = function(event) {

        _clean();
        timeoutObject = setTimeout(reconnect, RECONNECT_TIMEOUT);
    };

    var connect = function(port) {

        // Create WebSocket connection.
        var url = 'wss://localhost:'+port;
        console.info("(BeardedSpice) Try connect to '" + url + "'");

        socket = new WebSocket(url);

        // Connection opened
        socket.addEventListener('open', function (event) {
            console.info("(BeardedSpice) Socket open.");

            clearTimeout(timeoutObject);
            timeoutObject = null;
            socket.send(JSON.stringify({'strategy':strategyName}));
        });

        // Listen for messages
        socket.addEventListener('message', function (event) {
            console.log('(BeardedSpice) Message from server ', event.data);
            try {

                if (strategy) {

                    console.log('(BeardedSpice) Strategy command obtained.');

                    if (event.data == 'title') {
                        var title = window.document.title == "" ? window.location.href : window.document.title;
                        _send({'result': title});
                    }
                    else if (event.data == 'frontmost') {
                        //sending request to extension
                        safari.extension.dispatchMessage(event.data);
                    }
                    else if (event.data == 'toggle') {
                        strategy.toggle();
                        _sendOk();
                    }
                    else if (event.data == 'pause') {
                        strategy.pause();
                        _sendOk();
                    }
                    else if (event.data == 'next') {
                        strategy.next();
                        _sendOk();
                    }
                    else if (event.data == 'previous') {
                        strategy.previous();
                        _sendOk();
                    }
                    else if (event.data == 'favorite') {
                        strategy.favorite();
                        _sendOk();
                    }
                    else if (event.data == 'trackInfo') {
                        _send(strategy.trackInfo());
                    }
                    else if (event.data == 'isPlaying') {
                        _send({'result':strategy.isPlaying()});
                    }
                    else {
                        console.error('(BeardedSpice) Strategy command not found.');
                        _send({'result':false});
                    }
                }
                else {

                    try{

                        eval('var ' + event.data + ';');
                        if (BSStrategy) {
                            console.log('(BeardedSpice) Strategy obtained.');
                            console.log(BSStrategy);
                            strategy = BSStrategy;
                            _sendOk();
                        }
                    } catch (ex) {
                        logError(ex);
                        _send({'result':false});
                    }

                }
            } catch (ex) {
                _send({'result':false});
            }
        });

        var onSocketDisconnet = function (event) {
            console.log('(BeardedSpice) onSocketDisconnet');
            if (timeoutObject == null) {
                timeoutObject = setTimeout(reconnect, RECONNECT_TIMEOUT);
            }
        };

        socket.addEventListener('close', onSocketDisconnet);
        socket.addEventListener('error', onSocketDisconnet);

        timeoutObject = setTimeout(connectTimeout, SOCKET_TIMEOUT);
    };
})();
