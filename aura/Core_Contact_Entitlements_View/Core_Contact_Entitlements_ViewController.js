({
	init: function (component, event, helper) {
    	/*component.set('v.columns', [
            {label: 'Entitlement Name', fieldName: 'opportunityName', type: 'text'},
        ]);*/     
	},
    
    saveEntBtn: function (component, event, helper) {
        /*try{
            var initialEntitlementStatus = component.get("v.entitlementStatusAttr");
        	console.log('initialEntitlementStatus = '+ JSON.stringify(initialEntitlementStatus));
            console.log('event source v.value = '+ event.getSource().get("v.value"));
            console.log('event source = '+ event.getSource());
            console.log('event.target = '+ event.target);
        }catch(error){
            console.log(error);
        }*/
        component.set("v.recordNotFound", false);
        
    },
    
    displayEntitlements: function (component, event, helper) {
		
        var contactId = event.getParam("contactId");
        var isClearEntitlements = event.getParam("isClearEntitlements");
        
        component.set('v.contactIdStr', contactId);
        console.log('displayEntitlements : contactId = '+ contactId);
        console.log('displayEntitlements : isClearEntitlements = '+ isClearEntitlements);
        helper.loadEntitlements(component, event, contactId, isClearEntitlements); 
        
        /*if (srcValue == '' || srcValue == null) {

        } else {
            // call helper method
            //helper.loadEntitlements(component, event, contactId);
        }*/
        
    },
    
    saveEntitlementChanges: function(component, event, helper) {
        component.set("v.recordNotFound", true);
        var contactId =  component.get('v.contactIdStr');
        helper.saveEntitlements(component, event, contactId); 
    }
})