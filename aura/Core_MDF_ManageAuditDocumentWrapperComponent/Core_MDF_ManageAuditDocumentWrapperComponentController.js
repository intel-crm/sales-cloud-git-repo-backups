({  //This method is executed on click of 'Close' Button or 'X'(close Icon) -- claim detail page/bulk claim
    closeManageAuditDocPopup: function (component, event, helper) {
        helper.detectChangesOnAuditDocumentList(component);
    },
    //This method is executed on click of Submit from manage audit document wrapper popup
    handleClickOnSubmit: function (component, event, helper) {
        helper.checkForNewlyUploadedOrEditedAuditDocuments(component, event, helper);
    },    
    //This method is executed on click of close from document submission confirmation popup(Non-legacy)
    handlePopCloseEvent: function (component, event, helper) {
        component.set("v.switchClaimStatusToPICPending", false);
        component.set("v.isDocSubmissionPopupVisible", false);
    },
    //This method is executed on click of Submit from document submission confirmation popup(Non-Legacy)
    handlePopSubmitEvent: function (component, event, helper) {
        //let isClaimEligibleForPICReview = component.get("v.isClaimEligibleForPICReview");
        let isBulkClaim = component.get("v.isBulkClaim");
        //If - Bulk claim, else - claim detail page
        if (isBulkClaim) {
            component.set("v.isDocSubmissionPopupVisible", false);
            let auditDocumentList = component.get("v.auditDocumentList");
            let thirdPartyWrapper = component.get("v.thirdPartyWrapper");
            let bulkPOPUploadEvent = component.getEvent("bulkPOPUploadEvent");
            bulkPOPUploadEvent.setParams({ auditDocumentList: auditDocumentList, thirdPartyWrapper: thirdPartyWrapper });
            bulkPOPUploadEvent.fire();
        } else {
            helper.insertOrUpdateAuditDocuments(component);
        }
    },
    //This method is executed on click of yes from submit for PIC popup
    updateClaimStatusToPICPending: function (component, event, helper) {
        component.set("v.switchClaimStatusToPICPending", true);
        helper.checkForPOPDocSubmissionRequired(component);
    },

    //This method is executed on click of No from submit for PIC popup
    closePICConfirmationPopup: function (component, event, helper) {
        component.set("v.switchClaimStatusToPICPending", false);
        helper.insertOrUpdateAuditDocuments(component);
    },

    //This method is executed on click of Ok from close confirmation modal
    closeManageAuditDocPopupFromCloseConfModal: function (component, event, helper) {
        component.set("v.showCloseConfirmationPopup", false);
        component.set("v.openManageAuditDocPopup", false);
        component.set("v.disableSubmitButton", true);
    },
    //This method is executed on click of cancel from close confirmation modal
    reopenManageAuditDocPopup: function (component, event, helper) {
        component.set("v.showCloseConfirmationPopup", false);
    },

    //This method is executed when a third party event is fired from Core_MDF_ManageAuditDocument_Revamp
    handle3rdPartyPOPEvent: function (component, event, helper) {
        let thirdPartyWrapper = event.getParam("passData");
        console.log(" event is3rdPartyPOP", thirdPartyWrapper);
        component.set("v.thirdPartyWrapper", thirdPartyWrapper);
    },

    //This method is executed when a disable submit button event is fired from Core_MDF_ManageAuditDocument_Revamp
    handleSubmitButtonEvent: function (component, event, helper) {
        let auditDocumentListToInsertOrUpdate = event.getParam("auditDocumentListToInsertOrUpdate");
        let disableSubmitButton = event.getParam("disableSubmitButton");
        component.set("v.auditDocumentListToInsertOrUpdate", auditDocumentListToInsertOrUpdate);
        component.set("v.disableSubmitButton", disableSubmitButton);
    },

    // Roshan - Tactics POC
    handleBackToBulkTactics: function (component, event, helper) {
        component.set("v.showConfirmationPopupForPIC", false);
        component.set("v.isDocSubmissionPopupVisible", false);
        component.set("v.showCloseConfirmationPopup", false);
        component.set("v.openManageAuditDocPopup", false);

        let bulkPOPBackEvent = component.getEvent("bulkPOPUploadBackEvent");
        bulkPOPBackEvent.fire();
    }
    
})