({
    handleCreateNewRecord : function(component, event, helper) {
        var action = component.get("c.createRecord");
        action.setCallback(this, function(response) {
            var recordId = response.getReturnValue();

            var pageReference = {
                type: "standard__namedPage",
                attributes: {
                    "pageName": "offering-create"
                },
                state: {
                    "recordId": recordId
                }
            };
			/*            
            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    recordId: recordId,
                    objectApiName: 'PMP_Offering__c',
                    actionName: "view"
                }
            };
            */
            
            component.find("navService").generateUrl(pageReference)
            .then(function(url) {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({ url: url });
                urlEvent.fire();
            }).catch(function(error) {
                console.log('Error: ' + error);
            });
        });
        $A.enqueueAction(action);
    },
    handleNextStep : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/s/pmp-partner-offering/PMP_Partner_Offering__c/00B0n000000zKq0EAE"
        });
        urlEvent.fire();
    }
})