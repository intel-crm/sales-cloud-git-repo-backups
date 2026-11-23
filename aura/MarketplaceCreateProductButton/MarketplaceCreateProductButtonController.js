({
    doInit : function(component, event, helper){
        var action = component.get("c.getCreateOfferingAccess");
        action.setCallback(this, function(response){
            var hasCreateOfferingAccess = response.getReturnValue();
            component.set("v.showCreateOfferingButton",hasCreateOfferingAccess);
            console.log('createoffButton---->',component.get("v.showCreateOfferingButton"));
        });
        $A.enqueueAction(action);
    },
    
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
                    objectApiName: 'PMP_Partner_Offering__c',
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
    }
})