({
	doInit : function(component, event, helper) {
		var action = component.get("c.ApproveDesign");
         component.set("v.LexSpinner", true);
        action.setParams({
            "DDRrecordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==="SUCCESS"){
                component.set("v.alertMessage", response.getReturnValue());
               
            }else{
                console.log("Error on updating DDR "+response.getError());
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