({
	handleClick : function(component, event, helper) {
        var paramName = component.get("v.recordId");
		 var action = component.get("c.updateReport");
        action.setParams({ recId : paramName });
        
        $A.enqueueAction(action);
	}
})