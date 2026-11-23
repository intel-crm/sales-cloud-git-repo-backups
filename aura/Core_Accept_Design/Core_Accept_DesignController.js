({
	doInit : function(component, event, helper) {
        console.log("Entry");
        component.set("v.LexSpinner", true);
		var action = component.get("c.updateAcceptDesign");
        action.setParams({
            "designId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            console.log("execute "+response.getState());
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.alertMessage", response.getReturnValue());
            }else{
                console.log("Error on updating Design "+response.getError());
            }
             component.set("v.LexSpinner", false);
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
	},
    
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
})