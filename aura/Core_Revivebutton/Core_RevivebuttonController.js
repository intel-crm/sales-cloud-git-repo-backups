({
	doInit : function(component, event, helper) {
        var action = component.get("c.updateLead");
        action.setParams({
            "leadId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.alertMessage", response.getReturnValue());
                  $A.get("e.force:refreshView").fire();
            }else{
                console.log("An error has occurred while updating lead "+response.getError());
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
	}
		
	
})