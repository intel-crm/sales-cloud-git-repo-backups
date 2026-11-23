({
	doInit : function(component, event, helper) {
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
                if(result == true){
                    component.set("v.popupMsg", listOfMsg[0]);
                }else{
                    component.set("v.popupMsg", listOfMsg[1]);
                }
            }else{
                component.set("v.popupMsg", listOfMsg[2]);
                console.log("Error on verifying owner "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
	},
    
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    waiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "block";
    },
    
    doneWaiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "none";
    },
})