({
	doInit : function(component, event, helper) {
	component.find("mySpinner").set("v.class", "slds-show");
    var action = component.get("c.createQuote");    
    var opportunityId = component.get("v.recordId");
	
     		action.setCallback(this, function(response) {
			let state = response.getState();
            let returnValue = response.getReturnValue();
         	            if (component.isValid()) {
                if (state === "SUCCESS") {
                    //component.set("v.messageNotification", returnValue.messageResult);
                    component.set("v.isSuccess", "true");
                    //component.set("v.newRecordId", returnValue.quoteId);
                    component.find("mySpinner").set("v.class", "slds-hide");
                }
            }
        });
        console.log(opportunityId);      

    action.setParams({
        "opportunityId":opportunityId
    });
    // Queue this action to send to the server
    $A.enqueueAction(action);
    }

})