({
    doInit : function(component, event, helper) {

        var action = component.get("c.shouldShowRRBanner");

        action.setParams({
            recordId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {

            if(response.getState() === "SUCCESS") {

                component.set(
                    "v.showBanner",
                    response.getReturnValue()
                );
            }
        });

        $A.enqueueAction(action);
    }
})