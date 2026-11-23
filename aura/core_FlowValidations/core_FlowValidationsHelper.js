({
    showToast : function(component, event, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": 'You encountered some errors when trying to save this record',
            "message": message,
            "type": type,
            "duration": 1000,
            "mode": "dismissible",
        });
        toastEvent.fire();
		
    },
    refresh : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        
    }
})