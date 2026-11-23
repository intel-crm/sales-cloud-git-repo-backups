({	
    //This is to check weather user has access to create and Edit claim
    doInit : function(component, event, helper) {
        debugger;
    	const action = component.get("c.isClaimEligibleForClone");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(component.isValid() && state === "SUCCESS")
            {
            	const permission = response.getReturnValue();
            	//If user doesnot have access through error
            	if(!$A.util.isUndefinedOrNull(permission) && permission.hasAccessToCloneClaim == true){
                   if(permission.program == 'Intel Partner Alliance' && permission.hasRestrictedStatusToCreateClaim) {
                        component.set("v.accessErrorMsg", $A.get('$Label.c.Core_MDF_Validate_CreateClaim_InProgress_Error'));
                    }
                    else if(permission.isAssociatedPFRNotDeclined){             

              		    component.set("v.hasCloneAccess", permission.hasAccessToCloneClaim);
                    }
                    else{
                        component.set("v.accessErrorMsg", $A.get('$Label.c.Core_MDF_RestrictClaimCreationOnDeclined'));
                    }
           	 	}
           		else if(permission.hasAccessToCloneClaim == false){
                	component.set("v.accessErrorMsg", $A.get('$Label.c.Core_MDF_CloneAccessError'));
            	}
           }
           else if(state === "ERROR"){
                component.set("v.accessErrorMsg", $A.get('$Label.c.Core_MDF_CloneAccessError'));
            }
        });
        $A.enqueueAction(action);
  },                       
})