({
	callAuraMethodHelper : function(component,callerComponent,controllerMethod,
                              actionParameters,successCallBack) {
        var action = component.get("c.getDataUtility");
        action.setParams(actionParameters);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var res = JSON.parse(JSON.stringify(response
                    .getReturnValue()));
                successCallBack(callerComponent, response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                }
            } else {
                console.log(response);
            } 
        });
        $A.enqueueAction(action);
		
	}
})