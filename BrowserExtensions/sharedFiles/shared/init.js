var checkInjectAlready = document.querySelector('#X_BeardedSpice_InjectAlready');
if (checkInjectAlready != null) {
    console.log("(BeardedSpice eventsController) Script already injected!");
}
else {
    BSUtils.injectExtScript("shared/utils.js");
    BSUtils.injectExtScript("shared/eventsController.js");
}

