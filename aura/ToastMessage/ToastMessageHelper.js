({
    showToast : function(component, event, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": type,
            "duration": 10,
            "mode": "dismissible",
        });
        toastEvent.fire();
		
    },
    refresh : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        
    }
})