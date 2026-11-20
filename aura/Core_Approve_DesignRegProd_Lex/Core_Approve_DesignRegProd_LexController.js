({
	doInit : function(component, event, helper) {
        component.set("v.LexSpinner", true);
		var action = component.get("c.approveDesignReg");
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
            component.set("v.LexSpinner", false);
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
	},

    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },
})