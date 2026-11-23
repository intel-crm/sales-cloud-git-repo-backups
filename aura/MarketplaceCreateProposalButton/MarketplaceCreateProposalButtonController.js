({
    doInit: function(component, event, helper) {
        helper.setSoulutionButtonVisibility(component, event, helper);
    },
    
    /*handleCreateNewRecord : function(component, event, helper) {
        var action = component.get("c.createRecord1");
        action.setCallback(this, function(response) {
            var recordId = response.getReturnValue();
            
            var pageReference = {
                type: "standard__namedPage",
                attributes: {
                    "pageName": "Proposal-create"
                },
                state: {
                    "recordId": recordId
                }
            }; */
            
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
            
          /*  component.find("navService").generateUrl(pageReference)
            .then(function(url) {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({ url: url });
                urlEvent.fire();
            }).catch(function(error) {
                console.log('Error: ' + error);
            });
        });
        $A.enqueueAction(action);
    } */
    
    gotoURL : function (component, event, helper) {
        
	/*var urlEvent = $A.get("e.force:navigateToURL");
	urlEvent.setParams({ "url": "https://crmdevipam-intelcloudcrm.cs36.force.com/imp/s/create-edit-solution" });   // Pass your community URL
	urlEvent.fire();*/
        component.set("v.redirectToLWC", true);
       // $A.get('e.force:refreshView').fire();
        //var selectedValue = event.getParam('pickValue');
        //alert("current value: " + event.getParam("selectedValue"));
       // component.set("v.redirectToLWC",event.getParam('pickValue'));
       // alert("current value: " + event.getParam("pickValue"));
       // var eventData = event.getParam('pickValue');
       // component.set("v.selectedPartner",eventData);
       // component.set("v.redirectToLWC", true);
    }
    
   /* handleForceRefreshViewForLWC: function(component, event, helper) {
        component.find("refreshBroker").refresh();
    },

    forceRefreshView: function(component, event, helper) {
        let refresh = $A.get('e.force:refreshView');
        if (refresh) refresh.fire();
    }*/
    
})