({
    
     /*entitlementStatus: {},*/
    
     loadEntitlements: function(component, event , contactId, isClearEntitlements) {
         	
         	var entitlementStatus = {};
         
            console.log('contactId = '+ contactId);
         	console.log('isClearEntitlements = '+ isClearEntitlements);
            var spinner = component.find("mySpinner");
         	var entTableDiv = component.find("entitlementTableDiv");
            //console.log('spinner = '+ JSON.stringify(spinner));
            $A.util.removeClass(spinner, "slds-hide");
            $A.util.addClass(spinner, "slds-show");
         	
         	if(!isClearEntitlements){
                var action = component.get("c.fetchContactEntitlements");
                action.setParams({
                    'contactId': contactId
                });
                action.setCallback(this, function(response) {
                     var state = response.getState();
                     if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();
                        console.log(response); 
                        console.log('loadEntitlements > storeResponse '+ JSON.stringify(storeResponse)); 
                        //var cmpTargetCreateConBtn = component.find('creatContactBtn');
            
                        // if storeResponse size is 0 ,display no record found message on screen.
                        if (storeResponse.length == 0) {
                            //$A.util.addClass(cmpTargetCreateConBtn, 'displayCmp');
                           
                        } else {// response has successfully arrived
                            console.log('loadEntitlements > storeResponse.auraProcessingMessage = ' + JSON.stringify(storeResponse.auraProcessingMessage));
                            if(storeResponse.auraProcessingMessage.isSuccess){
                                component.set("v.contactEntitlementList", storeResponse.lstPartnerEntWrapper);
                                /*try{
                                    $(storeResponse.lstPartnerEntWrapper).each(function(index, elem){
                                		console.log('elem = '+ JSON.stringify(elem));
                                        
                                        if(elem.selected != null){
                                        	entitlementStatus[elem.name] = true;
                                        }else{
                                            entitlementStatus[elem.name] = false;
                                        }
                                	});
                                    console.log('entitlementStatus '+ JSON.stringify(entitlementStatus));
                                    component.set("v.entitlementStatusAttr", entitlementStatus);
                                }catch(error){
                                    console.log(error);
                                }*/
                                
                                $A.util.addClass(entTableDiv, "slds-show");
                                $A.util.removeClass(entTableDiv, "slds-hide");
                            }else{
                                component.set("v.errorMessageStr", storeResponse.auraProcessingMessage.errorMsg);
                            }
                            $A.util.addClass(spinner, "slds-hide");
                            $A.util.removeClass(spinner, "slds-show");
                            //component.set("v.recordNotFound", false);
    
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
    
    saveEntitlements: function(component, event , contactId) {
		console.log('saveEntitlements = '+ JSON.stringify(component.get("v.contactEntitlementList")));
        var spinner = component.find("mySpinner");
        var ceList = component.get("v.contactEntitlementList");
        
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
        
        var action = component.get("c.saveContactEntitlements");
             action.setParams({
                'cpEWrapperList': ceList,
                'contactId': contactId
             });
             action.setCallback(this, function(response) {
                 var state = response.getState();
                 if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    
                    //var cmpTargetCreateConBtn = component.find('creatContactBtn');
        
                    // if storeResponse size is 0 ,display no record found message on screen.
                    if (storeResponse.length == 0) {
                        //$A.util.addClass(cmpTargetCreateConBtn, 'displayCmp');
                       
                    } else {// response has successfully arrived
                        console.log('saveEntitlements response = '+ JSON.stringify(storeResponse)); 
                        this.loadEntitlements(component, event , contactId); 
                        $A.util.addClass(spinner, "slds-hide");
            			$A.util.removeClass(spinner, "slds-show");
                        //component.set("v.contactEntitlementList", storeResponse);
                        
                    }

                 }
             });
             $A.enqueueAction(action);
    }
})