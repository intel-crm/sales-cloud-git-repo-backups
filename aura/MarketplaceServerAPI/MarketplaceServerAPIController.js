({
	callServer : function(component, event, helper) {
        console.log("MAPIC");
    var params = event.getParam('arguments');
		return helper.callServer(component,
      params.auraMethodName,
      params.params,
      params.returnRawResponse
    );
	}
})