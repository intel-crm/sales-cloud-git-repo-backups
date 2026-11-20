({
	doInit: function (component, event, helper) {
        //console.log('inside connected call back '+userId);
        
        let action = component.get("c.getUserPemissionSets");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({ userId: userId });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                response.getReturnValue().forEach(item => {
                    if((item.PermissionSet.Name).includes('Tender')){
                        component.set("v.isTender",true);
                        
                    }
            	});
            }else {
                console.log("Error in loading ");
            }
        });
		$A.enqueueAction(action);
	   
    },
    
})