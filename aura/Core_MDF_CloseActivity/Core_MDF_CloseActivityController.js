({
  // method called on click of inactivate account button
  doInit: function(component, event, helper) {
    helper.incloseactivity(component, event, helper);
  },
  activityEligibiltyForClose: function(component, event, helper) {
    helper.activityEligibiltyForClose(component, event, helper);
  },
  closeModel: function(component, event, helper) {
       var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get('v.recordId'),
              "slideDevName": "detail"
            });
            navEvt.fire();
    $A.get("e.force:closeQuickAction").fire();
  }
});