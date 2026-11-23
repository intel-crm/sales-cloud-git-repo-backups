({
    // This function is called from doInit and used to weather claim is on Manual hold or not?
    doInit: function (component) {
        var action = component.get("c.getClaimAndHoldDeatils");
        action.setParams({claimId : component.get('v.recordId')});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue() != null)
            {
                var result = response.getReturnValue();
                if (!$A.util.isUndefinedOrNull(result)) 
                {
                    //Claim Status: which is not applicable to put claim on Hold
                    var claimStatus = ($A.get("$Label.c.Core_MDF_Status_Not_Allowed_Manual_Hold")).split(";");
                    //has access
                    if(result.hasAccess==true){
                        //check claim type
                        if(($A.get("$Label.c.Core_MDF_Claim_Adjustment_Type"))==(result.claimObj.Core_MDF_Type_Txt__c))
                        {
                            component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Negative_Claim_Error'));
                        }
                        else{
                            //check status					
                            if(!(claimStatus.includes(result.claimObj.Core_MDF_Status__c)))                        
                            {                                
                                if(result.isPartner== true){
                                    component.set("v.isPartner",true);
                                    //Member Hold 
                                    if(result.claimObj.Core_MDF_Member_Manual_Hold_Ind__c ==false ){
                                        component.set("v.manuallyHoldClaim",true);
                                    }
                                }
                                else{
                                    component.set("v.isPartner",false);
                                    //Intel Hold 
                                    if(result.claimObj.Core_MDF_Intel_Manual_Hold_Ind__c ==false){
                                        component.set("v.manuallyHoldClaim",true);                                            
                                    }
                                }                               
                                // If Claim is already on Manual Hold
                                if(result.claimObj.Core_MDF_Status__c == "Hold")
                                { 
                                    component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Claim_Cannot_Be_Hold'));
                                } 
                                
                            }
                            else{
                                component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Claim_Cannot_be_on_Hold_Status'));
                            }
                            
                        }
                    }
                    else
                    { 
                        component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_No_Permission')); 
                    }
                }
            } 
            else if (state === "ERROR" || response.getReturnValue() == null) {
                this.handleServerExceptions(component, response.getReturnValue()); 
            }
        });
        $A.enqueueAction(action);
    },
    
    //Update Hold indicator and comments to claim object 
    updateClaimHoldDeatils : function(component) {
        if (component.get("v.Spinner") == false){
            component.set("v.Spinner", true);
        }       
        
        var action = component.get("c.updateClaimOnManualHold");  		        
        action.setParams({
            'claimId': component.get('v.recordId'),
            'holdComments': component.get('v.holdComments')
        });
        
        action.setCallback(this, function(response){ 
            if(component.isValid() && response.getState() == "SUCCESS"){
                component.set("v.Spinner", false);
                
                if(!$A.util.isUndefinedOrNull(response.getReturnValue()) && response.getReturnValue() == true){                 
                    // Success! Prepare a toast UI message
                    // Hide error Modal
                    var errorToastModal = component.find('errorToast');
                    $A.util.addClass(errorToastModal, "slds-hide");  
                    var cmpTarget = component.find('toast');
                    $A.util.removeClass(cmpTarget, 'slds-hide');   
                    window.setTimeout($A.getCallback(function() {
                        if(component.isValid()) {
                            $A.util.addClass(cmpTarget, "slds-hide");
                        }
                    }), component.get("v.fadeTimeout"));
                    $A.get('e.force:refreshView').fire();
                }
                
            }
            else if (response.getState() === "ERROR" || response.getReturnValue() == null) {               
                //this.handleServerExceptions(component, response.getReturnValue()); 
                //close other toasts 
                var successToast = component.find('toast');
                $A.util.addClass(successToast, 'slds-hide');                
                component.set("v.Spinner",false);
                var errToast = component.find('errorToast');
                component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
                $A.util.removeClass(errToast, 'slds-hide');                                      
                window.setTimeout($A.getCallback(function() {
                    if(component.isValid()) {
                        $A.util.addClass(errToast, "slds-hide");
                    }
                }), component.get("v.fadeTimeout"));
                
            }
            
        });           
        
        
        $A.enqueueAction(action);
    },
    
    /*page refresh after data save*/    
    isRefreshed: function(component, event, helper) {
        location.reload();
    },/*page refresh after data save*/
    
    handleServerExceptions: function(component, returnValue) {
        
        // Error! Show Validation message through a toast UI message
        // Show error Modal
        var errorToastModal = component.find('errorToast');
        $A.util.removeClass(errorToastModal, "slds-hide");
        component.set("v.isError", true);
        component.set("v.Spinner", false);
        var exceptionerrors = returnValue;
        
        // check if exceptionerrors is null or not
        if (exceptionerrors != null && 
            (exceptionerrors.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION') || 
             exceptionerrors.includes('INVALID_FIELD_FOR_INSERT_UPDATE'))) {
            // process the error message here
            // if its validation error message
            var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf(',') + 1);
            var errorMsg = splittedMessage.substring(0, splittedMessage.indexOf(":"));
            component.set("v.errorMsg", errorMsg);    
        } else {
            // show general error message
            var genericMsg = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
            component.set("v.errorMsg", genericMsg);
        }
        
        
        //Auto hide error modal after 4sec
        window.setTimeout($A.getCallback(function () {
            if (component.isValid()) {
                $A.util.addClass(errorToastModal, "slds-hide");
            }
        }), 4000);
        component.set("v.isSaveDisabled", false);
    },
    
    
    
    
})