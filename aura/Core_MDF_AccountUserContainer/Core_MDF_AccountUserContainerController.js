({
	doInit : function(component, event, helper) {            
   	},
    
    // Function Called on the load of the component
    checkObjectPermission: function(component, event, helper) {            
        var action = component.get("c.isAccountUserEligibleForCreateEdit");     	
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")
            {
            	var permission = response.getReturnValue();
                
            	//If user has access set permission
            	if(!$A.util.isUndefinedOrNull(permission) && permission == true){                
              		 component.set("v.hasAccess", permission);
           	 	}
                //If user doesn't have access display error message
           		else{
                	component.set("v.accessErrorMsg", $A.get('$Label.c.Core_MDF_CloneAccessError')); //This user does not have permission to perform this action	
            	}         	
           }
            //For other issue throw Application Error message
           else{
                component.set("v.accessErrorMsg", $A.get('$Label.c.Core_MDF_AccountUser_Delete_Error')); //Application Error Occurred. Please contact help desk.	
            }
        });
        $A.enqueueAction(action);
	}
    
})