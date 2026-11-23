({
     SearchHelper: function(component, event , userId) {
     var action = component.get("c.fetchContactbyEmail");
     var searchKeyWord = (component.get("v.searchKeyword")).trim();
         //alert(searchKeyWord);
     action.setParams({
     	'searchKeyWord': searchKeyWord,
        'userId': userId
     });
     action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            var storeResponse = response.getReturnValue();
            var cmpTargetCreateConBtn = component.find('creatContactBtn');
            var cmpTargetEntitlementBtn = component.find('entitlementLoaderBtn');
             
             //Start : Clearing the entitlements grid
             try{
                 var compEvent =  $A.get("e.c:Core_Contact_Ent_Event"); 
                 //var compEvent = component.getEvent("loadEntitlementEvent");
                 var contactRecordId = component.get("v.contactRecId");
                 compEvent.setParams({'contactId' : contactRecordId, 'isClearEntitlements': true});  //'0033D00000W6A5YDEVCCPV'
                 console.log(compEvent);
                 compEvent.fire(); 
             }catch(error){
                 console.log(error);
             }
             //Start : Clearing the entitlements grid

            // if storeResponse size is 0 ,display no record found message on screen.
            if (storeResponse.length == 0) {
                component.set("v.infoMessage", true);
                component.set("v.recordFound", false);
                component.set("v.recordNotFound", true);
                
                

                /*$A.util.addClass(cmpTargetCreateConBtn, 'displayCmp');
                $A.util.removeClass(cmpTargetCreateConBtn, 'hideCmp');
                $A.util.addClass(cmpTargetEntitlementBtn, 'hideCmp');
                $A.util.removeClass(cmpTargetEntitlementBtn, 'displayCmp');*/
            } else {
                component.set("v.infoMessage", false);
                var contactIdReturned = storeResponse[0].contact.Id;
                //console.log("contactIdReturned = "+ contactIdReturned);
                if(contactIdReturned != null){
                 	component.set("v.contactRecId", contactIdReturned);
                    //console.log(component.get("v.contactRecId"));
                    component.set("v.recordNotFound", false);
                    component.set("v.recordFound", true);
                }
                
                /*$A.util.addClass(cmpTargetEntitlementBtn, 'displayCmp');
                $A.util.removeClass(cmpTargetEntitlementBtn, 'hideCmp');
                $A.util.addClass(cmpTargetCreateConBtn, 'hideCmp');
                $A.util.removeClass(cmpTargetCreateConBtn, 'displayCmp');*/
            }
             // set numberOfRecord attribute value with length of return value from server
             component.set("v.numberOfRecord", storeResponse.length);
             // set searchResult list with return value from server.
             component.set("v.searchResult", storeResponse);
         }
         else{
             console.log('error');
         }
     });
     $A.enqueueAction(action);
     
     }, 
     loadEntitlementsHelperFunc : function(component){
        console.log('loadEntitlementsHelperFunc'); 
        try{
            var compEvent =  $A.get("e.c:Core_Contact_Ent_Event"); 
            var contactRecordId = component.get("v.contactRecId");
            console.log('contactRecordId = '+ contactRecordId);
            compEvent.setParams({'contactId' : contactRecordId, 'isClearEntitlements': false});
            console.log(compEvent);
            compEvent.fire(); 
        }catch(error){
            console.log(error);
        }
    },   
})