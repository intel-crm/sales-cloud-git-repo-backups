({
	setSoulutionButtonVisibility: function(component, event, helper) {
		var action = component.get("c.getSoulutionButtonVisibility");
        action.setCallback(this, function(response){
            component.set("v.showSolutionButton", response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})