({
    doInit: function (component, event, helper) {
        console.log('inside DPA Clone');
		component.set("v.isFinal", false);
        component.find("mySpinner").set("v.class", "slds-show");
       helper.cloneDpa(component);
    },
    goBackLink: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
	
     navigateToRecord: function (component, event, helper) {
        let navService = component.find("navService");
        let pageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.newRecordId"),
                "actionName": "view"
            }
        }

        navService.generateUrl(pageReference)
            .then($A.getCallback(function (url) {
                console.log('success: ' + url);
                window.open(url, '_blank');
            }),
                $A.getCallback(function (error) {
                    console.log('error: ' + error);
                }));
    }
})