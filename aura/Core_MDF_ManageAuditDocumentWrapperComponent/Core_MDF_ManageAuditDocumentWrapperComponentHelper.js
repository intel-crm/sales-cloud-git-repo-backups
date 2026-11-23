({  /** This method is called on click of submit from manage audit document wrapper popup
    * Non-Legacy/Legacy(Doc submisison is mandated for legacy in case of PIC Pending and Paid and PIC Pending statuses) 
    -> If all the mandatory document types are submitted and any change on the audit document list
    (on upload of new doc/change in document types of existing documents), then 'checkForPOPDocSubmissionRequired' is executed
    * If all the amandatory document types are not submitted, on click of submit 'Please Upload mandatory Document Types' toast message is displayed
    */    
    checkForNewlyUploadedOrEditedAuditDocuments: function (component, event, helper) {
        component.set("v.spinner", true);
        let manageAuditComponent = component.find("manageAuditComponent");
        let existingAuditDocuments = component.get("v.existingAuditDocuments");
        console.log('existingAuditDocuments-insertOrUpdateAuditDocuments', existingAuditDocuments);
        let auditDocumentList;
        if (manageAuditComponent != null) {
            // Audit Document List
            auditDocumentList = manageAuditComponent.get("v.auditDocument");
            component.set("v.auditDocumentList", auditDocumentList);
            //Indicates Third Party claim
            let isThirdPartyClaim = manageAuditComponent.get("v.isThirdPartyClaim");
            component.set("v.isThirdPartyClaim", isThirdPartyClaim);
            //isClaimEligibleForPICReview -> true when the claim is any of the following statuses - resubmission required, pending documents, paid and pending documents, paid and resubmission required
            let isClaimEligibleForPICReview = manageAuditComponent.get("v.isClaimEligibleForPICReview");
            component.set("v.isClaimEligibleForPICReview", isClaimEligibleForPICReview);
            //Aditya
            // let isOutComeBased = manageAuditComponent.get("v.isOutComeBased");
			// component.set("v.isOutComeBased", isOutComeBased);
            let isOutcomeBasedAccountBasedAct = manageAuditComponent.get("v.isOutcomeBasedAccountBasedAct");
            component.set("v.isOutcomeBasedAccountBasedAct", isOutcomeBasedAccountBasedAct);
            console.log("isOutcomeBasedAccountBasedAct==>", isOutcomeBasedAccountBasedAct)
            //isDocSubmissionMandatory - true for non legacy claims and legacy claims(with only PIC Pending and paid and PIC Pending status)
            let isDocSubmissionMandatory = manageAuditComponent.get("v.isDocSubmissionMandatory");
            component.set("v.isDocSubmissionMandatory", isDocSubmissionMandatory);
            //isAllMandatoryDocumentTypesSubmitted - true when all the mandatory document types are selected for the claims with isDocSubmissionMandatory as true
            let isAllMandatoryDocumentTypesSubmitted = manageAuditComponent.get("v.isAllMandatoryDocumentTypesSubmitted");
            component.set("v.isAllMandatoryDocumentTypesSubmitted", isAllMandatoryDocumentTypesSubmitted);

            /** If is executed , when doc submission is mandatory but not all the mandatory document type proofs are submitted
             *  else if is executed, when a document is newly uploaded/existing doc is edited
             */
            if (isDocSubmissionMandatory && !isAllMandatoryDocumentTypesSubmitted && manageAuditComponent.get("v.auditDocumentDetailsWrapper") != null && manageAuditComponent.get("v.auditDocumentDetailsWrapper.enableDocumentUploadSection")) {
                component.set("v.spinner", false);
                //this.displayToastMesage($A.get("$Label.c.Core_MDF_Mandatory_Document_Types_Error_Message"), "Error");
                this.displayToastMesage("from wrapper component", "Error");
                console.log("isDocSubmissionMandatory", isDocSubmissionMandatory);
                console.log("isAllMandatoryDocumentTypesSubmitted", isAllMandatoryDocumentTypesSubmitted);
                console.log("auditDocumentDetailsWrapper null check", manageAuditComponent.get("v.auditDocumentDetailsWrapper"));
				console.log("enableDocumentUploadSection", manageAuditComponent.get("v.auditDocumentDetailsWrapper.enableDocumentUploadSection"))
            } else if (component.get("v.auditDocumentListToInsertOrUpdate").length > 0) {
                //component.set("v.auditDocumentListToInsertOrUpdate", auditDocumentListToInsertOrUpdate);
                this.isClaimEligibleForPICReview(component);
            }
        }
    },

    //This method is to display 'Submit for PIC' popup conditionally
    isClaimEligibleForPICReview: function (component) {
        component.set("v.spinner", true);
        let isClaimEligibleForPICReview = component.get("v.isClaimEligibleForPICReview");
        let isAllMandatoryDocumentTypesSubmitted = component.get("v.isAllMandatoryDocumentTypesSubmitted");
        if (isClaimEligibleForPICReview) {
            if (isAllMandatoryDocumentTypesSubmitted) {
                component.set("v.showConfirmationPopupForPIC", true);
                component.set("v.spinner", false);
            } else {
                this.checkForPOPDocSubmissionRequired(component);
            }
        } else {
            this.checkForPOPDocSubmissionRequired(component);
        }
    },

    //To display the document submission confirmation popup on click of yes from 'Submit for PIC' for Non-Legacy claims
    checkForPOPDocSubmissionRequired: function (component) {
        let isDocSubmissionMandatory = component.get("v.isDocSubmissionMandatory");
        let isLegacyClaim = component.get("v.isLegacyClaim");        
        if (isDocSubmissionMandatory) {
            if (!isLegacyClaim) {
                component.set("v.showConfirmationPopupForPIC", false);
                component.set("v.isDocSubmissionPopupVisible", true);
                component.set("v.spinner", false);
            } else {
                this.insertOrUpdateAuditDocuments(component);
            }

        } else {
            this.insertOrUpdateAuditDocuments(component);
        }
    },


    //To upsert the audit documents
    insertOrUpdateAuditDocuments: function (component) {
        component.set("v.showConfirmationPopupForPIC", false);
        component.set("v.isDocSubmissionPopupVisible", false);
        component.set("v.spinner", true);
        let auditDocumentListToInsertOrUpdate = component.get("v.auditDocumentListToInsertOrUpdate");
        let switchClaimStatusToPICPending = component.get("v.switchClaimStatusToPICPending");
        let action = component.get("c.insertAuditDocumentAndContentDocumentLink");
        action.setParams({
            auditDocumentListToInsertOrUpdate: auditDocumentListToInsertOrUpdate,
            recordId: component.get("v.recordId"),
            switchClaimStatusToPICPending: switchClaimStatusToPICPending,
        });

        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state.toLowerCase() === "success") {
                component.set("v.isDocSubmissionPopupVisible", false);
                component.set("v.openManageAuditDocPopup", false);
                component.set("v.spinner", false);                
                this.displayToastMesage($A.get("$Label.c.Core_MDF_Manage_Document_Submit_Success_Message"), "Success");
                $A.get('e.force:refreshView').fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    recordId: component.get("v.recordId"),
                });
                navEvt.fire();
            } else {
                console.log("Error in  insertOrUpdateAuditDocuments - Core_MDF_ManageAuditDocumentWrapperComponentHelper", res.getError());
                component.set("v.spinner", false);
                this.displayToastMesage($A.get("$Label.c.Core_MDF_ApplicationErrorMessage"), "Error");
            }
        });
        $A.enqueueAction(action);
    },

    /* 1. Detects the changes on the existing audit document list and also finds the newly uploaded audit document
    * 2. If there is any new document/changes in existing audit document found, show the close confirmation popup before closing the manage audit document wrapper popup
    * 3. If there is no change, then set the flag 'openManageAuditDocPopup' to false, to close the manage audit doc wrapper popup
    */
    detectChangesOnAuditDocumentList: function (component) {
        let disableSubmitButton = component.get("v.disableSubmitButton");
        if (!disableSubmitButton) {
            component.set("v.showCloseConfirmationPopup", true);
        } else {
            component.set("v.openManageAuditDocPopup", false);
        }
    },

    //To display the application error/Success toast messages
    displayToastMesage: function (message, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            duration: 5000,
            key: "info_alt",
            type: type
        });
        toastEvent.fire();
    }
})