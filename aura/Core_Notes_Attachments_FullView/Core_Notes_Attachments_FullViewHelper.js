({
	getAccountDetails : function(component, event, helper) {
		var action = component.get("c.fetchAccountDetails");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.accRecord", response.getReturnValue());
            }else{
                console.log("Error on fetching account details "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
	}
})