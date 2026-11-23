({
    //This is to check if the Cancel button has to be made visible to the user on the claim record
    doInit : function(component, event, helper) {
        var action = component.get("c.isClaimEligibleForCancel");
        action.setParams({claimId : component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var result = response.getReturnValue();
                // New functionality: determine whether cancellation reason is mandatory
                if (!$A.util.isUndefinedOrNull(result)) {
                    component.set("v.reasonRequired", result.requiresCancellationReason == true);
                    component.set("v.isSuperClaimOnHold", result.isSuperClaimOnHold == true);
                }
                if(!$A.util.isUndefinedOrNull(result.claimEligibleForCancel) && result.claimEligibleForCancel == true){
                    component.set("v.showCancelClaim",result.claimEligibleForCancel);
                }
                else if(result.claimEligibleForCancel == false){
                    if(result.restrictClaimOperator == true){
                        //This action is not allowed on an Adjustment
                        component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Negative_Claim_Error')); 
                    }else if(result.claimHasRecovery == true){
                        //Claim cannot be cancelled if partial recovery is done
                        component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Partial_Recovery_Claim')); 
                    }else if(result.claimSelectedForAudit == true){
                        //Claim cannot be cancelled if it is selected for Backend review
                        component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Audit_Claim_Cannot_Be_Cancelled'));
                    }else{
                        //Claim Cannot Be Cancelled
                        component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Claim_Cannot_Be_Cancelled')); 
                    }                  
                }
            }
            else if(state === "ERROR") {
                this.handleServerExceptions(component, response);
            }
        });
        $A.enqueueAction(action);
    },

    //This is to call the Cancel Claim Method
    cancelClaim : function(component, event, helper, cancellationReason) {
        var action = component.get("c.cancelClaimsWithReason");
        var listOfClaim = component.get('v.recordId');
        action.setParams({claimIdList : listOfClaim, cancellationReason : cancellationReason});
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
                }else{
                	this.handleServerExceptions(component,response);
                }
            }
            else if(state === "ERROR"){
                this.handleServerExceptions(component,response);
            }  
            
        });
        $A.enqueueAction(action);
    },

    /* Page refresh after data save */
    isRefreshed: function(component, event, helper) {
        location.reload();
    },

    // This function is used to show server-side exceptions
    handleServerExceptions: function(component, response) {
        // Error! Show validation message through a toast UI message
        // Close other toasts
        var successToast = component.find('toast');
        $A.util.addClass(successToast, 'slds-hide');

        // Show error toast
        var errToast = component.find('errorToast');
        $A.util.removeClass(errToast, "slds-hide");
        component.set("v.Spinner", false);

        // Display a specific validation message or a generic application error
        if(response.getError() != null) {
            if(response.getError().length > 0 && JSON.stringify(response.getError()[0].pageErrors) != null) {
                var error = JSON.stringify(response.getError()[0].pageErrors[0]);
                if (error != null && (error.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION') || error.includes('INVALID_FIELD_FOR_INSERT_UPDATE'))){
                    component.set("v.errorMsg", response.getError()[0].pageErrors[0].message);
                }
            }else{
                component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        }

        // Auto-hide error toast after 5 seconds
        window.setTimeout($A.getCallback(function() {
            if(component.isValid()) {
                $A.util.addClass(errToast, "slds-hide");
            }
        }), component.get("v.fadeTimeout"));
    }
})