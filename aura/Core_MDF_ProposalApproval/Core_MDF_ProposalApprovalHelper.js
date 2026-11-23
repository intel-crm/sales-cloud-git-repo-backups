({
    loadApprovalFlowAction: function (component, event, helper) {
        let result;
        const recId = component.get("v.recordId");
        const action = component.get("c.loadCampRecord");        
        action.setParams({cmpId: recId});
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
            
            if (response.getState() == "SUCCESS" && result != null) {
                console.log('RESULT-->', result);
                console.log('isExternalManager-->', result.isExternalManager);
                component.set('v.externalUser', result.userPermissionsPowerPartner);
                component.set('v.isPriceReviewer', result.isPriceReviewer);
                component.set('v.isLegalReviewer', result.isLegalReviewer);
                component.set('v.isL2Approver', result.isL2Approver);
                component.set('v.isBusinessApprover',result.isBusinessApprover);  //Aditya
                component.set('v.isL1Approver',result.isL1ProposalApprover);
                component.set('v.isL2MarketingApprover',result.isL2ProposalMarketingApprover);
                component.set('v.isL2SalesApprover',result.isL2ProposalSalesApprover);
                component.set('v.isUserPORApprover',result.isUserPORApprover);
                component.set('v.isInternalProposalManager',result.isInternalProposalManager);
                component.set('v.isExternalManager',result.isExternalManager);
                component.set('v.isUserPORApprover',result.isPORApprover);
                component.set('v.piwitmId',result.piwitmGlb);
                component.set('v.isTechnicalApprover',result.isTechnicalApprover);
                component.set('v.isExternalClaimSubmitter',result.isExternalClaimSubmitter);
                component.set('v.isInternalClaimSubmitter',result.isInternalClaimSubmitter);
                component.set('v.isAccountManagerApprover',result.isAccountManagerApprover); //Swati -IPA Claim
                component.set('v.isActiveClaimExist',result.isActiveClaimExist);
                console.log("isActiveClaimExist from Wrapper",result.isActiveClaimExist);
                if (result.userPermissionsPowerPartner || result.isPriceReviewer||result.isL1ProposalApprover||result.isL2ProposalMarketingApprover
                    || result.isL2ProposalSalesApprover|| result.isPORApprover||result.isInternalProposalManager||result.isExternalManager||result.isLegalReviewer||result.isL2Approver||result.isBusinessApprover||result.isTechnicalApprover||result.isExternalClaimSubmitter||result.isInternalClaimSubmitter
                    ||result.isAccountManagerApprover //Swati -IPA Claim
                ){
                    component.set('v.buttonToBeVisible', true);  
                } 
                else {
                    component.set('v.buttonToBeVisible', false); 
                }

                if (result.campaignRecord != null) {
                    const campaignRecord = result.campaignRecord;
                    component.set("v.programName", campaignRecord.Core_MDF_Program__c);
                    if(component.get('v.buttonToBeVisible') && !$A.util.isUndefinedOrNull(campaignRecord)) {
            
                        const totalcampaignCost = campaignRecord.Core_MDF_Total_Campaign_Cost_Amt__c;
                        const campStatus = campaignRecord.Status;
                        if(totalcampaignCost === 0 && campStatus === 'Pending Review') {
                            component.set("v.hideApproveButtonForL1orL2", true);
                            //component.set("v.hideApproveButtonForL2", true);
                        } else {
                            component.set("v.hideApproveButtonForL1orL2", false);
                            //component.set("v.hideApproveButtonForL2", false);
                        }
                    }
                }
            }
            
        });
        $A.enqueueAction(action);
    },

    //Function that will called on click of the button
    onClickButton: function (component, cmpId, btnType)
    {   
        console.log('onclick calllllled');
        console.log('btnType-->'+btnType);
        console.log('piwitmId-> '+component.get('v.piwitmId'));       
        
        if (btnType == $A.get("$Label.c.Core_MDF_Retail_Approve") || btnType == $A.get("$Label.c.Core_MDF_Retail_Reject") || $A.get("$Label.c.Core_MDF_Activity_Recall_Nm")){
            console.log('piwitmId-> '+component.get('v.piwitmId'));
            const aprAction = component.get("c.approveRejectProposal");
            aprAction.setParams({
                "buttonName":btnType,
                "cmpId":cmpId,
                "approvalComments" : component.get("v.approvalComments"),
                "piwitmId" : component.get('v.piwitmId'),
                "terminalRejectionInd" : component.get("v.terminalRejectionInd")
            })
            aprAction.setCallback(this, function (response) {
                console.log("response checking another user error: ",response);
                const stateSave = response.getState();
                if(stateSave === "SUCCESS"){
                    let msgTxt = '';
                    const returnValue = response.getReturnValue();

                    const isCampaign = component.get("v.recordId").startsWith('701');

                    console.log('returnValue -- > ', returnValue);
                    //Added IF-else condition as part of defect DE120404 fix
                    if(returnValue.isSuccess == true){
                        if (btnType == $A.get("$Label.c.Core_MDF_Retail_Approve")) {
                            msgTxt = isCampaign ? $A.get("$Label.c.Core_MDF_Campaign_was_approved") : 'Claim was approved'; 
                            //'Campaign was approved' OR 'Claim was approved' //                   
                        }  
                        else if (btnType == $A.get("$Label.c.Core_MDF_Retail_Reject")) {
                            if (isCampaign) {
                                const terminalRejectionInd = component.get("v.terminalRejectionInd");
                                msgTxt = terminalRejectionInd ? $A.get("$Label.c.Core_MDF_Campaign_was_declined") : $A.get("$Label.c.Core_MDF_Campaign_was_rejected");
                                //'Campaign was declined' OR 'Campaign was rejected' //       
                            } else {
                                msgTxt = 'Claim was rejected';  // 'Claim was rejected'
                            }         
                        }
                        else if (btnType == $A.get("$Label.c.Core_MDF_Activity_Recall_Nm")) {   
                            // const programName = component.get("v.programName");  
                            // if(isCampaign) {
                            //     if (programName == $A.get("$Label.c.Core_MDF_Co_GTM_Technical_program_name")) {
                            //         msgTxt = $A.get("$Label.c.Core_MDF_CampaignRecallSucessMsg");//'Campaign has been recalled successfully';
                            //     } else {
                            //         msgTxt = $A.get("$Label.c.Core_MDF_CampaignRecallMsg"); //'Proposal was recalled' // - for IPA
                            //     }  
                            // } else {
                            //     msgTxt = 'Claim has been recalled successfully';
                            // }

                            const programName = component.get("v.programName");  
                            msgTxt = isCampaign ? (programName == $A.get("$Label.c.Core_MDF_Co_GTM_Technical_program_name") ? $A.get("$Label.c.Core_MDF_CampaignRecallSucessMsg") : $A.get("$Label.c.Core_MDF_CampaignRecallMsg")) : $A.get("$Label.c.Core_MDF_ClaimRecallSucessMsg");
           
                        }
                        this.toastMessage($A.get("$Label.c.Core_MDF_Success"),$A.get("$Label.c.Core_MDF_Success"),msgTxt);
                    }else{
                        if(btnType == $A.get("$Label.c.Core_MDF_CampaignRecallError")){
                            msgTxt = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                        }else{
                            //msgTxt = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"); //If failed to approve or Reject because of any exception in backend
                            msgTxt = returnValue.isExternalUser == true ? $A.get("$Label.c.Core_MDF_ApplicationErrorMessage") : returnValue.returnMessage;
                        }
                        if(returnValue.isExternalUser == true){
                            this.toastMessage($A.get("$Label.c.Core_MDF_Error"),$A.get("$Label.c.Core_MDF_Error"),msgTxt);
                        }else{
                            this.toastMessage($A.get("$Label.c.Core_MDF_Error"),returnValue.type,msgTxt);
                        }
                    }
                    component.set('v.showApprovalCommentSection', false);
                    console.log('msgTxt:' + msgTxt);
                    //this.toastMessage($A.get("$Label.c.Core_MDF_Success"),$A.get("$Label.c.Core_MDF_Success"),msgTxt);
                    this.windowTimeOut();
                    component.set("v.loadSpinner",false); 
                }  else {
                    const applicationErrorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                    component.set("v.loadSpinner",false);
                    component.set("v.showApprovalCommentSection", false);
                    this.toastMessage($A.get("$Label.c.Core_MDF_Error"),$A.get("$Label.c.Core_MDF_Error"),applicationErrorMessage);
                } 
            });    
            $A.enqueueAction(aprAction);
        }
    },

    //Method to call approval process
    callApprovalProcessAndUpdateField : function (component, event, helper) {
        
        component.set("v.disablebuttonName",true);
        component.set("v.loadSpinner",true);
        this.onClickButton(component, component.get("v.recordId"), component.get("v.btnValue"));
        $A.get("e.force:closeQuickAction").fire();
      },

    toastMessage : function(toastTitleLabel,toastTypeLabel,toastMessageLabel){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: toastTitleLabel,
            type: toastTypeLabel,
            message: toastMessageLabel
        });
        toastEvent.fire();
    },
    windowTimeOut : function(){
        window.setTimeout(
            $A.getCallback(function () {
                window.location.reload();
            }), 3000
        );
    }
})