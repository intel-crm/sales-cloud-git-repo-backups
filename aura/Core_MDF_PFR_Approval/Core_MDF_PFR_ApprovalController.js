({

  doInit: function (component, event, helper) {
    //alert('inside approval doint');
    helper.loadApprovalFlowAction(component, event, helper);
  },
  
  approvalAction: function (component, event, helper) {
	var btnvalue = event.getSource().get("v.value");
	component.set('v.btnValue',btnvalue);
    if (btnvalue == $A.get("$Label.c.Core_MDF_Retail_Approve")) {
      component.set('v.commentType', 'Approval Comment')
      component.set('v.isApprovalCommentsRequired', false); // Approval Comment Not Mandatory
    } else if (btnvalue == $A.get("$Label.c.Core_MDF_Activity_Decline_Nm")) {
      component.set('v.commentType', 'Decline Comment')
      component.set('v.isApprovalCommentsRequired', true); // Rejection Comment Mandatory
    } else { 
      component.set('v.commentType', 'Comment')
    }
	component.set('v.isSaveDisable', true);
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
	  helper.onClickButton(component, component.get("v.recordId"), component.get("v.btnValue"));
      $A.get("e.force:closeQuickAction").fire();
  }
})