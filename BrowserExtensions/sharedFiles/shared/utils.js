//PREVENTS LOG OUTPUT
//console.log = function(){};

var BSUtils = {

    sendMessageToGlobal: function (name, message) {
        console.log("(BeardedSpice) sendMessageToGlobal (name: " + name + ", message: " + message + ").");
        if (typeof safari !== "undefined" && safari && safari.self && safari.self.tab) {
            safari.self.tab.dispatchMessage(name, message);
        }
        else if (typeof chrome !== "undefined" && chrome && chrome.runtime) {
            chrome.runtime.sendMessage({"name": name, "message": message});
        }
    },

    handleMessageFromGlobal: function (callback) {

        if (typeof safari !== "undefined" && safari && safari.self && safari.self.tab) {
            safari.self.addEventListener("message", callback);
        }
        else if (typeof chrome !== "undefined" && chrome && chrome.runtime) {
            chrome.runtime.onMessage.addListener(
              function(request, sender) {
                if (! sender.tab) {
                    callback(request);
                }
                return false;
              }); 
        }
    },

    sendMessageToTab: function (tab, name, message) {

        if (typeof safari !== "undefined" && tab && tab.page) {
            tab.page.dispatchMessage(name, message);
        }
        else if (typeof chrome !== "undefined" && chrome && chrome.tabs && tab && tab.id) {
            chrome.tabs.sendMessage(tab.id, {"name": name, "message": message});
        }
    },

    handleMessageFromTabs: function (callback) {

        if (typeof safari !== "undefined" && safari && safari.application) {
            safari.application.addEventListener("message",callback,false);
        }
        else if (typeof chrome !== "undefined" && chrome && chrome.runtime) {
            chrome.runtime.onMessage.addListener(
              function(request, sender) {
                if (sender.tab) {
                    callback(request);
                }
                return false;
              }); 
        }
    },

    injectExtScript: function(script) {
        
        var injected = document.createElement("script");
        injected.setAttribute("type", "text/javascript");
        var src = "";
        if (typeof safari !== "undefined" && safari && safari.extension) {
            src = safari.extension.baseURI + script;
        }
        else if (typeof chrome !== "undefined" && chrome && chrome.extension) {
            src = chrome.extension.getURL(script);
        }

        injected.setAttribute("src", src);
        (document.head || document.documentElement).appendChild(injected);
        console.log('(BeardedSpice) injectExtScript: ' + safari.extension.baseURI + script);
    },

    injectScript: function(script) {
        
        var injected = document.createElement("script");
        injected.setAttribute("type", "text/javascript");
        injected.textContent =  script;
        (document.head || document.documentElement).appendChild(injected);
        console.log('(BeardedSpice) injectScript');
    },

    injectAccepters: function(code, parameters) {
        
        var injected = document.createElement("script");
        injected.setAttribute("type", "text/javascript");
        injected.textContent =  "var bsParameters = " + JSON.stringify(parameters) + ";"  
                                + "var BSAccepters = {"
                                + "    strategyName: null,"
                                + "    strategyAccepterFunc: null,"

                                + "    evaluate: function () {"
                                + "     var strategyName = null;"
                                + "     var strategyAccepterFunc = null;"
                                +       code
                                +       "this.strategyName = strategyName;"
                                +       "this.strategyAccepterFunc = strategyAccepterFunc;"
                                +       "return strategyName && (strategyName.length > 0);"
                                +     "}"
                                + "};"
                                ;
        (document.head || document.documentElement).appendChild(injected);
        console.log('(BeardedSpice) injectAccepters');
    },

    strategyCommand: function (strategy, command) {
        console.log('(BeardedSpice) strategyCommand:');
        console.log(strategy);
        console.log(command);
         
        var okResult = {'result': true};
        try {

            if (strategy) {

                console.log('(BeardedSpice) Strategy command obtained.');

                if (command == 'title') {
                    var title = window.document.title == "" ? window.location.href : window.document.title;
                    return {'result': title};
                }
                else if (command == 'toggle') {
                    strategy.toggle();
                    return okResult;
                }
                else if (command == 'pause') {
                    strategy.pause();
                    return okResult;
                }
                else if (command == 'next') {
                    strategy.next();
                    return okResult;
                }
                else if (command == 'previous') {
                    strategy.previous();
                    return okResult;
                }
                else if (command == 'favorite') {
                    strategy.favorite();
                    return okResult;
                }
                else if (command == 'trackInfo') {
                    return strategy.trackInfo();
                }
                else if (command == 'isPlaying') {
                    return {'result':strategy.isPlaying()};
                }
                else {
                    console.error('(BeardedSpice) Strategy command not found.');
                    return {'result':false};
                }
            }
        } catch (ex) {
            return {'result':false};
        }

    }
};
