({

    doInit: function (component, event, helper) {
        helper.initializeWindowResizeEventHandler(component);
        let action = component.get("c.getUserPemissionSets");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({ userId: userId });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                response.getReturnValue().forEach(item => {
                    
                    if((item.PermissionSet.Name).includes('PSG')) {
                        component.set("v.isPSG",true);
                        
                    }
                    if((item.PermissionSet.Name).includes('Tender')){
                        component.set("v.isPSG",false);
                        
                    }
            	});
            }else {
                console.log("Error in loading ");
            }
        });
		$A.enqueueAction(action);
    }
       
    
    
})