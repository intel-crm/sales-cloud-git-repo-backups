({
    //This helper function is used to save claim data 
    saveClaim: function (component) {
        if (component.get("v.Spinner") == false) {
            component.set("v.Spinner", true);
        }
        var action = component.get("c.saveClaim");       
        action.setParams({
            "claim": component.get("v.simpleNewClaim"),
            "auditDocList": component.get("v.auditDocument")
        });
        action.setCallback(this, function (saveResult) {
            if (saveResult.getReturnValue() != null && !saveResult.getReturnValue().startsWith('Exception')) {
                component.set("v.Spinner", false);
                // Success! Prepare a toast UI message
                //changes for EDit claim - start
                var successMessage;
                var successTitle;
                if (component.get("v.isClaimEdit")) {
                    successTitle = $A.get("$Label.c.Core_MDF_SuccessUpdateMsgTitle");
                    successMessage = $A.get("$Label.c.Core_MDF_SuccessUpdateMsg");
                } else {
                    successTitle = $A.get("$Label.c.Core_MDF_SuccessMsgTitle");
                    successMessage = $A.get("$Label.c.Core_MDF_SuccessMsg");
                }
                //changes for EDit claim - end
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": 'success',
                    "title": successTitle,
                    "message": successMessage,
                    "mode": 'sticky'
                });
                
                //navigate to detail page
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": saveResult.getReturnValue()
                });
                navEvt.fire();
                //page reload-only in edit case
                if (component.get("v.isClaimEdit")) {
                    setTimeout(function(){window.location.reload();},2000);
                }
                resultsToast.fire();
                
            }
            else if (saveResult.getState() === "ERROR" || (saveResult.getReturnValue() != null && saveResult.getReturnValue().startsWith('Exception'))) {
                // Call the function to Handle the Server Exceptions                
                this.displayErrorMessageEvent(component,event,helper,saveResult.getReturnValue());
                component.set("v.Spinner", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //This function used to create event and pass to parent component, to check which buton clicked
    buttonActionClickedEvent : function(component,event,helper,action){
        // Create the new event
        var actionEvent = component.getEvent("ManageButtonEvent");
        // Populate the event with the step
        actionEvent.setParams({
            "buttonClicked" : action
        });
        // Fire the event
        actionEvent.fire();   
    },
    
    //This function used to create event and pass to parent component, to display error message
    displayErrorMessageEvent : function(component,event,helper,errorMessage){
        // Create the new event
        var actionEvent = component.getEvent("DisplayErrorMessageEvent");
        // Populate the event with the step
        actionEvent.setParams({
            "errorMsg" : errorMessage
        });
        // Fire the event
        actionEvent.fire();   
    },    
})