({
    cloneQuote: function (component, event, helper) {
        let changedValue = component.get("v.quoteType");
        let cloneAction = component.get("c.doClone");   // NOSONAR
        cloneAction.setParams({
                sObjectId: component.get("v.recordId"),
                quoteType: changedValue
            });
        cloneAction.setCallback(this, function (response) {
            let state = response.getState();   // NOSONAR
            //let returnValue = response.getReturnValue();   // NOSONAR
            if (component.isValid()) {
                if (state === "SUCCESS") {
                    let returnValue = response.getReturnValue(); 
                    component.set("v.messageNotification", returnValue.messageResult);
                    component.set("v.isSuccess", returnValue.isSuccess);
                    component.set("v.newRecordId", returnValue.quoteId);
                    component.find("mySpinner").set("v.class", "slds-hide");
                }
                else if (state === 'ERROR'){
                    let returnValue = response.getReturnValue(); 
                    component.set("v.messageNotification", returnValue != null || returnValue != undefined ? returnValue.messageResult : 'Error occurred while processing the request. Please try again.');
                    component.set("v.isSuccess", returnValue != null || returnValue != undefined ? returnValue.isSuccess : false);
                    component.find("mySpinner").set("v.class", "slds-hide");
                }
            }
        });

        $A.enqueueAction(cloneAction);
    }
})