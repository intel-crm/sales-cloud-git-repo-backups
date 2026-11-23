({
    doInit : function(component, event, helper) {
        var action = component.get("c.isEligible");     
        action.setParams({recordId : component.get('v.recordId')});
        action.setCallback(this, function(response){            
            
            var state = response.getState();
            var error = response.getError();
            console.log('state', state);
            if(component.isValid() && state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result.vatEligibleforUpdate', result.vatEligibleforUpdate);
                console.log('result.userEligibletoUpdate', result.userEligibletoUpdate);
                if(!$A.util.isUndefinedOrNull(result.vatEligibleforUpdate) && !$A.util.isUndefinedOrNull(result.userEligibletoUpdate))
                {
                    if(result.vatEligibleforUpdate == true && result.userEligibletoUpdate == true){
                    component.set("v.showVatFiles",true);
                    }  
                    else if(result.vatEligibleforUpdate == false){
                    component.set('v.eligibilityErrorMsg', $A.get('$Label.c.Core_MDF_action_not_applicable')); 
                    } 
                    else if(result.userEligibletoUpdate == false){
                     component.set('v.eligibilityErrorMsg', $A.get('$Label.c.Core_MDF_insufficient_access_error'));       
                    }
                }
            }
            else if(state === "ERROR"){
                console.log('Error::',error[0].message);
                component.set("v.eligibilityErrorMsg", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        });
        $A.enqueueAction(action);
    }
})