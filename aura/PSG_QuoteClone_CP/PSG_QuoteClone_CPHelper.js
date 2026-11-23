({
    
    quoteTypeCheck: function(component, event, helper){
        
    },
    
    cloneQuote: function (component, event, helper) {
        let cloneAction = component.get("c.doClone");
		let quoteType = component.get("v.quotetype");
        cloneAction.setParams(
            {
                sObjectId: component.get("v.recordId"),
                action: "clone",
				quoteTypeTochange : quoteType
            }
        );
        cloneAction.setCallback(this, function (response) {
            let state = response.getState();
            let returnValue = response.getReturnValue();
            console.log('inside clone action '+state);
            console.log('inside clone action1 '+returnValue);
            if (component.isValid()) {
                if (state === "SUCCESS") {
                    component.set("v.messageNotification", returnValue.messageResult);
                    component.set("v.isSuccess", returnValue.isSuccess);
                    component.set("v.newRecordId", returnValue.quoteId);
                    component.find("mySpinner").set("v.class", "slds-hide");
                }
            }
        });

        $A.enqueueAction(cloneAction);
    }
})