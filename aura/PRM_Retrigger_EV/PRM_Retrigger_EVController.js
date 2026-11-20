({
    doInit : function(component, event, helper) {
		helper.init(component, event, helper);
	},    	
    
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    
    handleCancelButton: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    handleConfirmButton: function (component, event, helper) {
        helper.retriggerEmail(component);
    }
})