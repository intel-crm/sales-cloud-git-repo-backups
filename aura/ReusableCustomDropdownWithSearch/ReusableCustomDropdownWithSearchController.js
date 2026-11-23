({
	fromAccountToChange:function(component, event, helper) {
    	let selectedFromAcc = event.getParam('selectedSObject');
        component.set("v.fromSelectedValue",selectedFromAcc);
	},
    
    methodEnabled:function(component, event, helper) {
        component.set("v.disableTransferAmount",false);
    },
    methodDisabled:function(component, event, helper) {
        component.set("v.disableTransferAmount",true);
    }
})