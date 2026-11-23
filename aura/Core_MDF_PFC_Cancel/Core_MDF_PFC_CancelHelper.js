({
    //This is to check if the Cancel button has to be made visible to the user on the claim record
    doInit : function(component, event, helper) {
        var action = component.get("c.isClaimEligibleForCancel");     
        action.setParams({claimId : component.get('v.recordId')});
        action.setCallback(this, function(response){            
            
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var result = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(result.claimEligibleForCancel) && result.claimEligibleForCancel == true){
                    component.set("v.showCancelClaim",result.claimEligibleForCancel);
                }
                else if(result.claimEligibleForCancel == false){
                    if(result.restrictClaimOperator == true){
                        component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Negative_Claim_Error')); 
                    }else{
                        component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Claim_Cannot_Be_Cancelled')); 
                    }                    
                }
            }
            else if(state === "ERROR"){
                console.log("Error: ", response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    //This is to call the Cancel Claim Method
    cancelClaim : function(component, event, helper) {
        var action = component.get("c.cancelClaims");  
        var listOfClaim = component.get('v.recordId');
        action.setParams({claimIdList : listOfClaim});
        action.setCallback(this, function(response){            
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var success = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(success) && success == true){
                    //close other toasts 
                    var errorToast = component.find('errorToast');        
                    $A.util.addClass(errorToast, "slds-hide");
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
            else if(state === "ERROR"){
                console.log("Error: ", response.getReturnValue());
                //close other toasts 
                var successToast = component.find('toast');
                $A.util.addClass(successToast, 'slds-hide');
                
                component.set("v.Spinner",false);
                var errToast = component.find('errorToast');
                component.set("v.errorMsg", response);
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
    
})