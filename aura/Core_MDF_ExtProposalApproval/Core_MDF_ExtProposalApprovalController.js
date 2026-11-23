({
	doInit: function (component, event, helper) {
    helper.loadApprovalFlowAction(component, event, helper);
  },
  
  approvalAction: function (component, event, helper) {
	var btnvalue = event.getSource().get("v.label");
	component.set('v.btnValue',btnvalue);
    if (btnvalue == $A.get("$Label.c.Core_MDF_Retail_Approve")) {
      component.set('v.commentType', $A.get("$Label.c.Core_MDF_IPA_Proposal_Approval"));      
    } else if (btnvalue == $A.get("$Label.c.Core_MDF_Retail_Reject")) {
      component.set('v.commentType', $A.get("$Label.c.Core_MDF_IPA_Proposal_Rejection"));      
    }
	component.set('v.showApprovalCommentSection', true);
	
  },
  // Function called on click of Cancel or "X" on the layout 
    closeModal: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
  callApprovalProcessAndUpdateField : function (component, event, helper) {
      component.set("v.disablebuttonName",true);
      component.set("v.loadSpinner",true);
	  helper.onClickButton(component, component.get("v.recordId"), component.get("v.btnValue"));
      $A.get("e.force:closeQuickAction").fire();
  }
})