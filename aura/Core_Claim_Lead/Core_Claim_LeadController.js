({
	doInit : function(component, event, helper) {
        component.set("v.isSpinner",true);
        var action = component.get("c.verifyOwner");
        action.setParams({
            "leadId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var msgString = $A.get("$Label.c.Core_Msg_For_Claim");
            var listOfMsg = [];
            listOfMsg = msgString.split(",");
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                
                    component.set("v.popupMsg", result);
               
            }else{
                component.set("v.popupMsg", listOfMsg[2]);
                console.log("Error on verifying owner "+JSON.stringify(response.getError()));
            }
            component.set("v.isSpinner",false);
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
	},
    
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})