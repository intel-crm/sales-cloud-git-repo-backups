({
    doInit: function (component, event, helper) {
        var claimId = component.get("v.recordId");
        component.set("v.claimId", claimId);
        helper.validateUser(component, claimId);
    },

    closeConfirmationPopup: function (component, event, helper) {
        if(component.get("v.isCustomComp")){
            let closeModalEvent = component.getEvent("closeModalEvent");
            closeModalEvent.fire();
        }
        else{
            $A.get("e.force:closeQuickAction").fire();
        }
    },

    submitForPICReview: function (component, event, helper) {
        var claimId = component.get("v.claimId");
        helper.submitForPICReviewProcess(component, claimId);
    }
})