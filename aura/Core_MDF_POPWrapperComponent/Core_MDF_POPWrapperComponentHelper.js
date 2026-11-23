({  //check the user access to upload and manage documents and fetch the audit document details
    checkUserAccessAndFetchAuditDocDetails : function(component, claimId) {
        var action = component.get("c.getAuditDocumentDetailsWrapper");
        let partnerFundReqId; //anushya TWC3117-14374
        console.log("partnerFundReqId===",partnerFundReqId);
        action.setParams({
            recordId: claimId,
            outComeBasedFlag : false
        }); //anushya added 2nd as extra parameter TWC3117-14374
        action.setCallback(this, function(res) {
            var state = res.getState();
            if(state.toLowerCase() === "success") {
                let auditDocWrapper = res.getReturnValue();
                component.set("v.enableDocumentUploadSection", auditDocWrapper.enableDocumentUploadSection);
                component.set("v.disableDocumentUploadSection", auditDocWrapper.disableDocumentUploadSection);
                component.set("v.claimDetails", auditDocWrapper.pfcRec);
                component.set("v.existingAuditDocuments", auditDocWrapper.documentList);
                component.set("v.isOutcomeBasedAccountBasedAct", auditDocWrapper.isOutcomeBased); // Ajinkya TWC3117-16656

                //check for IPA Program - to display POP required information
                let claimdetails = auditDocWrapper.pfcRec;
                if(Object.keys(claimdetails).length > 0) {
                    component.set("v.isLegacyClaim", claimdetails.Core_MDF_Legacy_Claim_Ind__c);
                    if(claimdetails.Core_MDF_Program__c.toLowerCase() === $A.get("$Label.c.Core_MDF_IPA_Program_Name").toLowerCase()) {
                        component.set("v.actyPOPDescReq", true);
                    }
                    //added cogtm check - ajinkya
                    if(claimdetails.Core_MDF_Program__c.toLowerCase() === $A.get("$Label.c.Core_MDF_Co_GTM_program_name").toLowerCase()){
                       	component.set("v.isCoGtm", true)
                    }
                    component.set("v.programName",claimdetails.Core_MDF_Program__c);
                }
                component.set("v.isThirdPartyClaim", auditDocWrapper.isThirdPartyClaim);
                console.log("wrapper", auditDocWrapper);

            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: $A.get(
                        "$Label.c.Core_MDF_ApplicationErrorMessage"
                    ),
                    duration: "5000",
                    key: "info_alt",
                    type: "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})