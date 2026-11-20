({
    doInit: function (component, event, helper) {
        const recordId = component.get("v.recordId");
        const str = recordId.substring(0, 15);
        component.set("v.recordId", str);
        
    },

    closeWindow: function (component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    }
})