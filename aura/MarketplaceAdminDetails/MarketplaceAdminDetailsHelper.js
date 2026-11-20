({
    /*Get Admin Details on init*/
	getAdminDetails : function(component,helper) {
        // Remove all admin review and select admin UI data
        // component.set("v.offerinStatusList", []);
        // component.set("v.admins", []);
        // component.set("v.loggedInAdmin", '');
        // component.set("v.selectedAdmin", '');
        // component.set("v.selectedOfferingStatus", '');
        // component.set("v.showRetiredComments", false);
        // component.set("v.RetiredComments", '');
        // // Hide the admin review tab if a controlling attribute exists
        // if(component.set) {
        //     component.set("v.showAdminReviewTab", false);
        //     component.set("v.showAdminSection", false);
        // }
    },
    
    /*Show/Hide Modal*/
    // handlerToggleModal:function(component,helper){
    //     component.set("v.isOpen",!component.get("v.isOpen"));  
    // },
    
    /*Update changed details to offering (OfferingStatus, Admin)*/
    // handlerSaveAdminChanges:function(component,event, helper){
    //     component.set('v.showSpinner', true);//Added for US535344,making showSpinner attribute as true to display the spinner when submit button is clicked.
    //
	//	var comments;
    //     
    //     if(component.get('v.showRetiredComments')){
    //         comments = component.find('comments').get('v.value');
    //     }
    //     
    //     helper.callServer(component,
    //                       "saveAdminDetails",
    //                       {"offeringId": component.get('v.offeringId'),
    //                        "selectedAdmin":component.get('v.selectedAdmin'),
    //                        "selectedOfferingStatus":component.get('v.selectedOfferingStatus'),
	//   						"retiredComments": comments
    //                       }).then( 
    //         function(response){
    //             if(response=="saved" || response=="PendingLead"){
    //                 
    //                 if(response=="PendingLead" && component.get('v.selectedOfferingStatus')=="Retired"){
    //                    alert("Warning: Retired offerings can’t be revived and are retried permanently.Before retiring this offering, verify there are no open leads"); 
    //                 }
    //                 var toastEvent = $A.get("e.force:showToast");
    //                 if(toastEvent){
    //                     
    //                     toastEvent.setParams({
    //                         "title":$A.get("$Label.c.PMP_Success"),
    //                         "message":$A.get("$Label.c.PMP_offering_Updated_successfully"),
    //                         "type":"success"
    //                         
    //                     });
    //                 }
    //                 var urlEvent = $A.get("e.force:navigateToURL");
    //    				urlEvent.setParams({ "url": "/pmp-partner-offering/PMP_Partner_Offering__c" });
    //    				urlEvent.fire();
    //                 component.set('v.showSpinner', false);//Added for US535344,making showSpinner attribute as false to remove the spinner once the response from server is received. 
    //             }
    //             else if(response=='videoProcesssing'){
    //                 var toastEvent = $A.get("e.force:showToast");
    //                 if(toastEvent){
    //                     
    //                     toastEvent.setParams({
    //                         "title":$A.get("$Label.c.PMP_Error"),
    //                         
    //                         "type":"error"
    //                     });
    //                     component.set('v.showSpinner', false);
    //                 }
    //             }
    //             
    //             else
    //             {
    //                 var toastEvent = $A.get("e.force:showToast");
    //                 if(toastEvent){
    //                     toastEvent.setParams({
    //                         "title":$A.get("$Label.c.PMP_Error"),
    //                         "message":$A.get("$Label.c.PMP_Offering_not_saved"),
    //                         "type":"error",
    //                         "mode":"dismissible"
    //                     });
    //                 }    
    //             }
    //             
    //             if(toastEvent){
    //                 toastEvent.fire();
    //             }                
    //         });
    // },
})