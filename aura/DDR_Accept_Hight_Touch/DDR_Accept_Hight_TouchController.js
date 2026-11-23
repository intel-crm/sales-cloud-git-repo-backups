({
    doInit : function(component, event, helper){
      console.log('Record Id from parent -->', component.get("v.recordId"));
    },
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },
    handleChildEvent : function(component, event, helper) {
        /*var dataFromChild = event.getParam("alertMessages");
        console.log('dataFromChild -->',dataFromChild);*/
    },
    handleHighTouch: function(component, event, helper) {
        // Show the confirmation message when High Touch is clicked
        component.set("v.showConfirmation", true);
    },
    handleOk: function(component, event, helper) {
        // Perform the High Touch action here.
        // For example, you can call a helper function to handle the action.
        //helper.performHighTouchAction(component); // Make sure to implement this helper function.

        // Close the confirmation message after performing the action.
        component.set("v.showConfirmation", true);
        component.set("v.processOk", true);
    },
    handleCancel: function(component, event, helper) {
        // Close the confirmation message without performing the High Touch action.
        component.set("v.showConfirmation", true);
        $A.get("e.force:closeQuickAction").fire();
    }
})