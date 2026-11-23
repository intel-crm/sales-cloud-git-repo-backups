({
    doInit : function(component, event, helper) {
        console.log('doInit called');
        var contactRecord = {
            Id: '0033F0000073M9eQAE',
            Name: 'prem test cpu'
        }
        console.log('contactRecord '+contactRecord);
        component.set("v.selectedContact", contactRecord);
        console.log(' Name '+component.get("v.selectedContact").Name);
    },
    
	handleContactChange : function(component, event, helper) {
		console.log('handleContactChange called');
        
	},
    
    handleFalse: function(component, event, helper) {
        console.log('handleFalse called');
    },
    handleTrue: function(component, event, helper) {
        console.log('handleTrue called');
    }
})