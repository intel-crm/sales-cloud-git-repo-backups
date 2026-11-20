({
	doInit : function(component, event, helper) {
		var action = component.get("c.updateTeleQualifiedLead");
        action.setParams({
            "leadId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==="SUCCESS"){
                component.set("v.alertMessage","Lead Status has been updated successfully");
            }else{
                console.log("Error on updating Lead "+response.getError());
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
	},
    
   
})