({
    
	getUserAccess : function(component, event, helper) {
		var action = component.get("c.getObjectAccess");
        action.setParams({
            "ObjectName":component.get("v.objectName")});
        // Call back method
        action.setCallback(this, function(response) {
            
            var responseValue = response.getReturnValue(); 
            component.set("v.hasObjectAccess",responseValue);
            
        });
        
        // Enqueue Action
        $A.enqueueAction(action);
	}
})