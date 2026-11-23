({
   doinit: function(component, event, helper) {
var record = component.get("v.recordId");
      var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": record,
    });
    navEvt.fire();
       
   }
})