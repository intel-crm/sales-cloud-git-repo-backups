({
    doInit: function(component, event, helper) {
        const SubmitForApproval = $A.get("$Label.c.PCC_SubmitforApproval");
        const ProductNotAvailable = $A.get("$Label.c.PCC_ProductsMessage");
        const dRSubmissionMsg = $A.get("$Label.c.PCC_DRSubmitMessage");
        const dRExceptionMsg = "There is an issue processing the record. Please raise a support ticket."; 
    
        component.set("v.SubmitForApprovalValue", SubmitForApproval);
        component.set("v.ProductNotAvailableValue", ProductNotAvailable);
        component.set("v.dRSubmissionMsgValue", dRSubmissionMsg);
        component.set("v.dRExceptionMsgValue", dRExceptionMsg);

        const action = component.get("c.productsAvailableonDr");
        action.setParams({
            recId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const productsAvailable = response.getReturnValue();
                component.set("v.showWarning", !productsAvailable);

                if (productsAvailable) {
                    component.set("v.showSubmit", true);
                }
            } else {
                // Handle error
                component.set("v.showException", true);
                console.error("Error fetching product availability.");
            }
        });
        $A.enqueueAction(action);
    },

    handleYesClick: function(component, event, helper) {
        const action = component.get("c.logictochangestatus");
        component.set("v.disableButton", true);
        action.setParams({
            recId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
               // $A.get("e.force:refreshView").fire();
                window.location.reload();
                this.showToast("Record Status successfully changed","Record successfully Submitted","success");
               
            } else {
                // Handle error
                console.error("Error changing record status.");
                component.set("v.showException", true);
                component.set("v.showSubmit", false);
                component.set("v.showWarning", false);
                this.showToast("Error while changing Record Status", "Error while changing Record Status", "failure");
            }
        });
        $A.enqueueAction(action);
      //  $A.get("e.force:refreshView").fire();
        setTimeout(() => {
                    console.log("Refreshing view");
                    $A.get("e.force:refreshView").fire();
                }, 2000);
    },
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },

    showToast: function(title, message, type) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
})