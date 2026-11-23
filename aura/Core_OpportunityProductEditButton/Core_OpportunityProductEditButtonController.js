({
	doInit : function(component, event, helper) {
		console.log('Aura Component Loaded');
        helper.getFieldSetFormDetails(component, event, helper);
	},
    
    handleSuccess : function(component, event, helper) {
        component.set("v.showEditField",false);
    },
    handleEdit : function(component, event, helper) {
        component.set("v.showEditField",false);
    },
    handleSaveButtonClick : function(component, event, helper) {
        component.set("v.isLoading",true);
        
        var toastEvent = $A.get("e.force:showToast");
        evnt.setParams({
            title : 'Success',
            message : 'Record is saved successfully',
            variant : 'Success',
            mode : 'dismissable'
        });
        evnt.fire();
    },
    handleCancelButtonClick : function(component, event, helper) {
        component.set("v.showEditField",false);
         $A.get("e.force:closeQuickAction").fire()
    },
    fireCancelEvent : function(component, event, helper) {
        component.set("v.showEditField",false);
        console.log('Inside firecancel event');
         $A.get("e.force:closeQuickAction").fire();
    },
    handleClick : function(component, event, helper) {
        
    }
    
    
})