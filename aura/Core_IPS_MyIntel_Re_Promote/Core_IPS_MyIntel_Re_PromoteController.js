({
	init : function(component, event, helper) {
        
        const action = component.get("c.retryCallFromLightning");
        const recordId=component.get('v.recordId');
        action.setParams({
                    recordId:recordId
                });
        
        action.setCallback(this, function(response) {
            
            const state = response.getState();
            const mufinal = response.getReturnValue();
            if (state === "SUCCESS") {
            console.log(state);
            } 
            else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire(); 
		
	}
})