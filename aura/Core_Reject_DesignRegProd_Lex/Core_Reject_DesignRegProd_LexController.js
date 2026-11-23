({
	doInit : function(component, event, helper) {
		var action = component.get("c.rejectDesignReg");
        action.setParams({
            "drId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.alertMessage", response.getReturnValue());
            }else{
                console.log("Error on updating Design Registration "+response.getError());
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
	}
})