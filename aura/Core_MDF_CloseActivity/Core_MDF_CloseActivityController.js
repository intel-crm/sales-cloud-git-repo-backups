({
  // method called on click of inactivate account button
  doInit: function(component, event, helper) {
    helper.incloseactivity(component, event, helper);
  },
  activityEligibiltyForClose: function(component, event, helper) {
    helper.activityEligibiltyForClose(component, event, helper);
  },
  closeModel: function(component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  }
});