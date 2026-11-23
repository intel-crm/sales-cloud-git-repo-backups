({	
    //This is to check weather user has access to create and Edit claim
    doInit : function(component, event, helper) {
    	var action = component.get("c.isClaimEligibleForClone");     	
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")
            {
            	var permission = response.getReturnValue();
            	//If user doesnot have access through error
            	if(!$A.util.isUndefinedOrNull(permission) && permission == true){                
              		 component.set("v.hasCloneAccess", permission);
           	 	}
           		else if(permission == false){
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