({
	doInit: function (component, event, helper) {
    helper.loadApprovalFlowAction(component, event, helper);
  },
  
  approvalAction: function (component, event, helper) {
	  const btnvalue = event.getSource().get("v.label");
	  component.set('v.btnValue',btnvalue);

    const isCampaign = component.get("v.recordId").startsWith('701');
    if (btnvalue == $A.get("$Label.c.Core_MDF_Retail_Approve")) {
      component.set('v.commentType', isCampaign ? $A.get("$Label.c.Core_MDF_IPA_Proposal_Approval") : 'Approve Claim');    
    } else if (btnvalue == $A.get("$Label.c.Core_MDF_Retail_Reject")) {
      component.set('v.commentType', isCampaign ? $A.get("$Label.c.Core_MDF_IPA_Proposal_Rejection") : 'Reject Claim'); 
      component.set('v.hasUserClickedOnReject',true);     
    }
    component.set('v.showApprovalCommentSection', true);  
  },

  //To set terminalRejectionInd based on user input
  onPermanenetRejectCheck: function(component,event,helper){
    const isChecked = event.getSource().get("v.checked");
    component.set("v.terminalRejectionInd",isChecked);
  },

  //When a user clicks on 'No' on permanent decline confirmation pop-up
  onClickofNo: function(component, event) {
    component.set("v.showDeclinePopupInd", false);
 },

 //When a user clicks on 'Yes' on permanent decline confirmation pop-up
 onClickOfYes: function(component, event,helper) {
    const campIds = new Array();
    let isClaimAssociated;
    const recId = component.get("v.recordId");
    campIds.push(recId);
    const action = component.get("c.isActiveClaimAssociated");
    action.setParams({cmpClaimAssocList: campIds});
    action.setCallback(this, function (response) {
      isClaimAssociated = response.getReturnValue();
      if(isClaimAssociated){
        const msgTxt =  $A.get("$Label.c.Core_MDF_Restrict_Terminal_Rejection_On_Active_Claim_Association");
        helper.toastMessage($A.get("$Label.c.Core_MDF_Error"),$A.get("$Label.c.Core_MDF_Error"),msgTxt);
      }
      else{
        helper.callApprovalProcessAndUpdateField(component, event, helper);
      }
      helper.windowTimeOut();
      component.set("v.loadSpinner",true);
    });
    $A.enqueueAction(action);
    
 },

  // Function called on click of Cancel or "X" on the layout 
    closeModal: function(component, event, helper) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
  

  //To render confirmation pop-up for terminal rejection or call normal approval process
  callApprovalProcessOrPermDeclinePopup : function(component, event, helper){
    const terminalRejectionInd = component.get("v.terminalRejectionInd");
    const hasUserClickedOnReject = component.get("v.hasUserClickedOnReject");
    if(hasUserClickedOnReject && terminalRejectionInd){
        component.set("v.showDeclinePopupInd", terminalRejectionInd);
    }
    else{
      helper.callApprovalProcessAndUpdateField(component, event, helper);
    }
  },


  getMessage: function (component, event, helper) {
    let approvalComments = event.getSource().get("v.value");
    const textAreaComp = component.find("approvalComments");
    if(approvalComments.length > 1000) {
      textAreaComp.setCustomValidity("only 1000 characters are allowed");
    } else {
      textAreaComp.setCustomValidity("");
    }
    textAreaComp.reportValidity();
  }
})