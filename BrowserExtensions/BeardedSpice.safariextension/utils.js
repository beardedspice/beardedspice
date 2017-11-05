
var BSUtils = {

    injectExtScript: function(script) {
        
        var injected = document.createElement("script");
        injected.setAttribute("type", "text/javascript");
        injected.setAttribute("src", safari.extension.baseURI + script);
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
        //debugger;
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
