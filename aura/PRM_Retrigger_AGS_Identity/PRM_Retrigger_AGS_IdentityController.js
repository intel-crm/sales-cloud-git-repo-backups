({
	doInit : function(component, event, helper) {
		helper.retriggerAGSIdnetity(component, event, helper);
	},
    
    handleConfirmButton :function(component,event,helper){
        helper.createAGSIdentity(component, event, helper);
    },
    
    handleCancelButton : function(component,event,helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
    
})