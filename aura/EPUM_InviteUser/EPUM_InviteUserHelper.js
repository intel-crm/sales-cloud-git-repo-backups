({
	fetchPicklistValues : function(component, event, helper) {
        console.log("in helper");
		var action = component.get("c.fetchContactPickListValues");
        action.setParams({
            'searchedEmail': component.get("v.searchedEmail")
        });
        action.setCallback(this, function(response) {
            console.log("in callback fetchPicklistValues");
            console.log("in fetchPicklistValues ", response.getState());
            var state = response.getState();
            var returnValue = response.getReturnValue() 
            component.set("v.isLoading","false");
            console.log("in fetchPicklistValues response", JSON.stringify(response.getReturnValue()));
            if(state = "SUCCESS") {
                component.set("v.countryPicklistValues", returnValue.lstCountryValues);
                component.set("v.preferredLanguagePicklistValues", returnValue.lstPreferredLanguageValues);
                //component.find("contactform1").set("v.value", "German");
                //component.set("v.newContact.Core_Preferred_Language__c", "DEU")
                window.setTimeout(
                    $A.getCallback( function() {
                        //component.find("contactform1").set("v.value", "ENG");
                        component.set("v.newContact.Core_Preferred_Language__c", "ENG")
                    }),500);
            }
            
        });
        $A.enqueueAction(action);
	},
    
    createContact : function(component, event, helper) {
        var action = component.get("c.createContact")
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({
            'con': component.get("v.newContact"),
            'loggedInUserId': userId
        });
        action.setCallback(this, function(response) {
            console.log("in createContact", response.getState());
            console.log("in createContact ReturnValue", response.getReturnValue());
            component.set("v.isLoading","false");
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state == "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue.status == "success") {
                    component.set("v.showModal","false");
                    toastEvent.setParams({
                        'title': 'Success!',
                        'type': 'success',
                        'mode': 'dismissable',
                        'message': returnValue.message
                    });
                    toastEvent.fire();
                } else {
                    component.set("v.errMessage",returnValue.message);
                    toastEvent.setParams({
                        'title': 'Error!',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': returnValue.message
                    });
                    //toastEvent.fire(); 
                }
            }
            
        });
        $A.enqueueAction(action);
    }
})