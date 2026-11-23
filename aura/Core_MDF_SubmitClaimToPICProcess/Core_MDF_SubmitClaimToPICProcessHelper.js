({  //validate user with claim submitter permissions, check the claim status and documents availability(in order to submit the claim for PIC Review Process)
    validateUser: function (component, claimId) {
        component.set("v.spinner", true);
        var action = component.get("c.getClaimAndUserDetails");
        action.setParams({
            claimId: claimId
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var wrapper = res.getReturnValue();
                component.set("v.isValidClaimUser", wrapper.isValidClaimUser);
                component.set("v.isClaimEligibleForPIC", wrapper.isClaimEligibleForPIC);
                component.set("v.AreDocsAvailable", wrapper.AreDocsAvailable);
                component.set("v.spinner", false);
            } else {
                component.set("v.spinner", false);
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.fireToastEvent(errorMessage, "5000", "error");
            }
        });
        $A.enqueueAction(action);
    },
    //update claim status from resubmission required/paid and resubmission required to pic pending/paid and pic pending
    submitForPICReviewProcess: function (component, claimId) {
        component.set("v.spinner", true);
        var action = component.get("c.updateClaimStatus");
        action.setParams({
            claimId: claimId
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner", false);
                var message = $A.get("$Label.c.Core_MDF_Submit_For_PIC_ToastMessage");
                this.fireToastEvent(message, "3000", "success");

                //Roshan - close popup explicitly
                if (component.get("v.isCustomComp")) {
                    component.getEvent("closeModalEvent").fire();
                }
                
                setTimeout(() => {
                    window.location.reload();
                }, 5000);
            } else {
                component.set("v.spinner", false);
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.fireToastEvent(errorMessage, "5000", "error");
            }
        });
        $A.enqueueAction(action);
    },



    //common toast event to handle success and error scenarios
    fireToastEvent: function (message, duration, type) {
        $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            duration: duration,
            key: "info_alt",
            type: type
        });
        toastEvent.fire();
    }
})