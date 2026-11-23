({
    doInit : function(component, event, helper) {
    	console.log("in controller");
        component.set("v.newContact.Email",component.get("v.searchedEmail").trim())
        component.set("v.isLoading","true");
        helper.fetchPicklistValues(component, event, helper);
    },
    
	showModal: function(component, event, helper) {
       component.set("v.showModal",!component.get("v.showModal"));
	},
    
    submitDetails: function(component, event, helper) {
        var allValid = component.find('contactForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            //alert('All form entries look valid. Ready to submit!');
            helper.createContact(component, event, helper)
            component.set("v.isLoading","true");
        } else {
            //alert('Please update the invalid form entries and try again.');
        }
    }
})