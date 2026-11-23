({

  doInit: function (component, event, helper) {
    helper.loadApprovalFlowAction(component, event, helper);
  },
  approvalAction: function (component, event, helper) {
    //alert(event.getSource().get("v.value"));
    helper.onClickButton(component, component.get("v.recordId"), event.getSource().get("v.value"));
  },
  closeModel: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  }
})