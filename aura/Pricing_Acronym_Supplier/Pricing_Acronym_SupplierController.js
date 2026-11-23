({
    doInit: function (component, event, helper) {
        let isExternalUser = component.get("c.isPricingManager");  // NOSONAR
        isExternalUser.setCallback(this, function (response) {
            let state = response.getState();  // NOSONAR
            if (state === "SUCCESS") {
                let rpmUser = response.getReturnValue();  // NOSONAR
                component.set("v.isRPMUser", rpmUser);
                helper.processRecord(component, event, helper, rpmUser);
            } else {
                console.error("Error in getDetails for Communuty User" + JSON.stringify(error));
            }
        });
        $A.enqueueAction(isExternalUser);
    }
});