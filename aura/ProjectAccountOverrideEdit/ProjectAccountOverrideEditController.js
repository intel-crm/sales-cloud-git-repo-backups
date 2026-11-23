({
    initComponent : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('@@@@@@ ' + recordId);
        var editEvent = $A.get("e.force:editRecord");
        editEvent.setParams({
            "recordId": recordId
        });
        console.log('before fire');
        editEvent.fire();
        console.log('after fired')
    },

    handleEditSuccess : function(component, event, helper) {
        console.log('Record edited successfully:', component.get("v.recordId"));
        // Additional logic can be added here if needed
    }
})