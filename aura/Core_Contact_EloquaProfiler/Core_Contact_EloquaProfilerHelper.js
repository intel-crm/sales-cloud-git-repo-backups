({
	getUserDetails : function(component, event, helper) {
        component.set("v.isLoaded", false);
		var action = component.get("c.getUserSessionData");
        //set function param
        debugger;
        var i = component.get("v.recordId");
        //var j = component.get("v.sObjectName");
        action.setParams({
               rId : i 
            
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			debugger;
			if (state === "SUCCESS") {
				component.set("v.data", response.getReturnValue());
                var SAHost = $A.get("$Label.c.Core_EloquaProfiler");
        		component.set("v.urlParams", SAHost+component.get("v.data"));
               
            }
			else if(state === "INCOMPLETE") {

			}
			else if(state === "ERROR") {

			}
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.isLoaded", true);
                }), 10000
            );
		});
		$A.enqueueAction(action);
	},
})