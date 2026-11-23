({
    saveEntitlements : function(component,event,sContactId) {
        console.log('saveEntitlements = '+ JSON.stringify(component.get("v.lstContactEntitlements")));
        var spinner = component.find("mySpinner");
       
        var ceList = component.get("v.lstContactEntitlements");
        console.log(ceList)
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");        
        
        var action = component.get("c.saveContactEntitlements");
        action.setParams({
            'lstContactEntWrapper': ceList,
            'sContactIdStr' : sContactId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                } else {// response has successfully arrived
                    console.log('hiding table');
                    console.log('saveEntitlements response = '+ JSON.stringify(storeResponse)); 
                    this.loadEntitlements(component, event,sContactId); 
                    $A.util.addClass(spinner, "slds-hide");
                    $A.util.removeClass(spinner, "slds-show");
                    
                }
            }
        });
        $A.enqueueAction(action);
    },
    loadEntitlements: function(component, event ,sContactIdStr,isReloadEntitlement) {
        
        //var sContactIdStr = component.get("v.sContactIdStr");
        var spinner = component.find("mySpinner");
        var entTableDiv = component.find("entitlementTableDiv");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
        if(!isReloadEntitlement){
        //if(true){
       		console.log('sContactIdStr =='+sContactIdStr);
            var action = component.get("c.fetchContactEntitlements");
            action.setParams({
                "sContactIdStr" : sContactIdStr
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    console.log(response); 
                    console.log('loadEntitlements > storeResponse '+ JSON.stringify(storeResponse)); 
                    
                    // if storeResponse size is 0 ,display no record found message on screen.
                    if (storeResponse.length == 0) {
                    } else {// response has successfully arrived
                        console.log('loadEntitlements > storeResponse.auraProcessingMessage = ' + JSON.stringify(storeResponse.auraProcessingMessage));
                        if(storeResponse.auraProcessingMessage.isSuccess){
          /**Agam*/
                var entitlementsList = storeResponse.lstContactEntWrapper;
                var entitlementsLists = [];
                            entitlementsLists.push({
                                entitlementNameStr : 'Partner Admin Delegate',
                                isSelected : false
                            });
                            
                for(i = 0; i < entitlementsList.length; i++) {
                    
                     if(entitlementsList[i].entitlementNameStr == "Partner Admin Delegate" ){
                               // entitlementsLists[0].isSelected = true;
                  //console.log(entitlementsList[i].entitlementNameStr)
                         for(j = 0; j < entitlementsList.length; j++)
                              if(entitlementsList[j].entitlementNameStr != "Partner Admin Delegate" && entitlementsList[j].entitlementNameStr != "Employee"){
                                  entitlementsList[j].readOnly=true;
                         }
                         entitlementsLists[0].isSelected = entitlementsList[i].isSelected;
                         
                     }else{
                         entitlementsLists.push({
                                entitlementNameStr : entitlementsList[i].entitlementNameStr,
                                isSelected : entitlementsList[i].isSelected
                            }); 
                     }
                         
                }
       // component.set("v.lstContactEntitlements", entitlementsList);
        /**Agam*/
        console.log('am working'+JSON.stringify(entitlementsLists));

component.set("v.lstContactEntitlements", entitlementsLists);
                          //  component.set("v.lstContactEntitlements", storeResponse.lstContactEntWrapper);
                            
                            $A.util.addClass(entTableDiv, "slds-show");
                            $A.util.removeClass(entTableDiv, "slds-hide");
                        }else{
                            console.log('I am in else');
                            component.set("v.errorMessageStr", storeResponse.auraProcessingMessage.errorMsg);
                        }
                        $A.util.addClass(spinner, "slds-hide");
                        $A.util.removeClass(spinner, "slds-show");
                    }
                }
            });
            $A.enqueueAction(action);
        }else{
                console.log('else block');
                $A.util.addClass(spinner, "slds-hide");
                $A.util.removeClass(spinner, "slds-show");
                $A.util.addClass(entTableDiv, "slds-hide");
                $A.util.removeClass(entTableDiv, "slds-show");
                component.set("v.recordNotFound", true);
            }
    },
    
})