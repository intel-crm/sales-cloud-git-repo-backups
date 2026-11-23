({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.submitRetry");
        action.setParams({ logRecordId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({ "type":"success", "message": "Job retry has been submitted."});
                resultsToast.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                setTimeout(function(){window.location.reload();},1000);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({ "type":"error", "message": +errors[0].message});
                        resultsToast.fire();
                        console.log("Error message: " + errors[0].message);
                        
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get('v.recordId'),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }
                } 
            }
        });
        $A.enqueueAction(action);
    },
})