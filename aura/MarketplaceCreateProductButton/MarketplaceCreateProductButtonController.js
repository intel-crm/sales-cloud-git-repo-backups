({
    // IPA2.0 + US TWC4497-1631 

    // doInit : function(component, event, helper){
    //      //URL Navigation Check Starts : Pranjal 
    //      var actionNavigation = component.get("c.isSafeURLNavigation");  
    //      actionNavigation.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var access = response.getReturnValue();
    //             if(access){
    //                 var action = component.get("c.getCreateOfferingAccess");
    //                 action.setCallback(this, function(response){
    //                     var hasCreateOfferingAccess = response.getReturnValue();
    //                     component.set("v.showCreateOfferingButton",hasCreateOfferingAccess);
    //                     console.log('createoffButton---->',component.get("v.showCreateOfferingButton"));
    //                 });
    //                 $A.enqueueAction(action);
    //             }
    //             else {
    //                 helper.navigateToErrorPage(component,helper);
    //             }
    //             //URL Navigation Check ends : Pranjal 
    //         }
    //     });
    //     $A.enqueueAction(actionNavigation);
    // },
    
    // handleCreateNewRecord : function(component, event, helper) {
    //     var action = component.get("c.createRecord");
    //     action.setCallback(this, function(response) {
    //         var recordId = response.getReturnValue();
            
    //         var pageReference = {
    //             type: "standard__namedPage",
    //             attributes: {
    //                 "pageName": "offering-create"
    //             },
    //             state: {
    //                 "recordId": recordId
    //             }
    //         };
            
    //         /*            
            
    //         let pageReference = {
    //             type: "standard__recordPage",
    //             attributes: {
    //                 recordId: recordId,
    //                 objectApiName: 'PMP_Partner_Offering__c',
    //                 actionName: "view"
    //             }
    //         };
    //             */
            
    //         component.find("navService").generateUrl(pageReference)
    //         .then(function(url) {
    //             var urlEvent = $A.get("e.force:navigateToURL");
    //             urlEvent.setParams({ url: url });
    //             urlEvent.fire();
    //         }).catch(function(error) {
    //             console.log('Error: ' + error);
    //         });
    //     });
    //     $A.enqueueAction(action);
    // }
})