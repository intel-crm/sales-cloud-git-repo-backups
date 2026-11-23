({
	fireComponentEvent : function(component, event, helper) {
        var cmpEvent1 = component.getEvent("compEvt");
        cmpEvent1.setParams({
            "message" : "A component event fired me::)" });
        cmpEvent1.fire();
		
	}
})