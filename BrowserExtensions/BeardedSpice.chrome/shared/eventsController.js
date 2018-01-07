var BSEventResponder = {
  listenRequest: function (callback) { // analogue of chrome.extension.onRequest.addListener
    document.addEventListener("BSEventClient-query", function(event) {
      var node = event.target;
      if (!node || node.nodeType != Node.TEXT_NODE)
        return;

      var doc = node.ownerDocument;
      callback(event.detail, doc, function(response) {

        var event = new CustomEvent("BSEventClient-response", {
          detail: response,
          "bubbles":true, 
          "cancelable":false
        });
        return node.dispatchEvent(event);
      });
    }, false, true);
  },
 
  // callback function example
  callback: function(request, sender, callback) {

    return callback({"result": true});
  }
}

BSEventResponder.listenRequest(function(request, sender, callback){

//   console.log("(BeardedSpice) BSEventResponder get request.");
//   console.log(request);
//   console.log(sender);

  switch (request.name) {
    case "accept":
      if (BSAccepters && BSAccepters.evaluate()) {
        return callback({"strategyName": BSAccepters.strategyName});
      }
      return callback({"result": false});
    case  "checkAccept":
      return callback({"result": BSAccepters && BSAccepters.strategyAccepterFunc && BSAccepters.strategyAccepterFunc()});
    case "checkStrategy":
      return callback({result: (typeof(BSStrategy) !== "undefined")});
    case "command":
      return callback(BSUtils.strategyCommand(BSStrategy, request.args));
    default:
      return callback({"result": false});
  }
});

console.info("(BeardedSpice) BSEventResponder init.");
