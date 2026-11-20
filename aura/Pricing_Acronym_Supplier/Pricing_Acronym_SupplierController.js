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
        
        const isPricingAgentEligible = component.get("c.isPAAEligible");
            isPricingAgentEligible.setParams({ quoteLine: component.get("v.quoteLine") });
            isPricingAgentEligible.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS" && component.isValid()) {
                    component.set("v.isPricingNotEligible", response.getReturnValue());
                }
            });
        $A.enqueueAction(isPricingAgentEligible);
        
        //isRPMPAlphaUser call
            let isRPMAlphaUser = component.get("c.isPricingManagerAlpha"); 
            isRPMAlphaUser.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    component.set("v.isRPMUserAlpha", response.getReturnValue());
                    helper.processAIStatus(component, event, helper, isRPMAlphaUser);
                }
            });
            $A.enqueueAction(isRPMAlphaUser);
        }
});