({
	callServerFromReduxAction : function(component, event, helper) {
    var params = event.getParam('arguments');
		return helper.callServerFromReduxAction(component, params.component || component,
      params.auraMethodName,
      params.params,
      params.returnSFObject
    );
	}
})