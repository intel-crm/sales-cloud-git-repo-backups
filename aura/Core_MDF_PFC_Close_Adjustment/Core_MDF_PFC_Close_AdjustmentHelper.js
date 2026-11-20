({
    //This is to check if the Close button has to be made visible to the user on the claim record
    doInit : function(component, event, helper) {
        var action = component.get("c.claimEligibleForClose");     
        action.setParams({claimId : component.get('v.recordId')});
        action.setCallback(this, function(response){            
            
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")
            {
                var result = response.getReturnValue();             
                if(result.hasAccess){
                    
                    if(result.adjustmentClaimType){
                        //PAF
                        if(result.isPAF){                           
                           
                            if(result.restrictClaimWithoutOffset == true){
                                component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Adjustment_WithNoOffset'));
                            }
                            else{
                                component.set("v.showCloseClaim",true);
                            }                            
                        }else{
                            component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Cannot_Close_Claim'));
                        }
                    }
                    else{
                        //Positive claims : [Please conform with Nick for this error message] 
                        component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Close_on_Claim_Error'));
                    }
                    
                }
                else{
                    component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_CloneAccessError'));
                }
                
            }
            else if(state === "ERROR"){                
                component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
            
        });
        $A.enqueueAction(action);
    },
    //This is to call the Close Claim Method
    closeClaim : function(component, event, helper) {
        var action = component.get("c.closeClaims");  
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
                component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
                //component.set("v.errorMsg", response);
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
    
});