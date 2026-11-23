({
    doInit : function(component, event, helper){
      console.log('Record Id from parent -->', component.get("v.recordId"));
    },
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },
    handleChildEvent : function(component, event, helper) {
        var dataFromChild = event.getParam("alertMessages");
        console.log('dataFromChild -->',dataFromChild);
    }
})