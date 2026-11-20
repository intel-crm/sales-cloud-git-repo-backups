({
    handleClose: function (component, event, helper) {
        console.log('##rec'+component.get("v.recordId"));
    $A.get("e.force:refreshView").fire();
    $A.get("e.force:closeQuickAction").fire();
    }
});