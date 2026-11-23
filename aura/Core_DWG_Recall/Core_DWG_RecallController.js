({
    doInit : function(component, event, helper) {
        var action= component.get("c.CheckRecallDWGValidations");
        action.setParams({
             "DWGId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var responseval=response.getReturnValue();
                component.set("v.alertMessage", response.getReturnValue());
                console.log('alertmesg',responseval);
              if(responseval==null){
                   component.set("v.IsPopUpOpen", true);
                }
                 // $A.get('e.force:refreshView').fire();
            }                       
            else{
                console.log("An error has occurred while updating lead "+response.getError());
            }
              //component.set("v.Spinner",false);
        });
        $A.enqueueAction(action);
        //$A.get("e.force:refreshView").fire();
       // $A.get("e.force:closeQuickAction").fire();
        
    },
    handleSave : function(component, event, helper) {
		 var action= component.get("c.UpdateDWG");
        action.setParams({
             "DWGId" : component.get("v.recordId"),
             "RecallReason" : component.get("v.RecallReason")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                 $A.get("e.force:refreshView").fire();
                 component.set("v.alertMessage", response.getReturnValue());
                 
            }                       
            else{
                console.log("An error has occurred while updating lead "+response.getError());
            }
              //component.set("v.Spinner",false);
        });
        $A.enqueueAction(action);
        //$A.get("e.force:refreshView").fire();
       // $A.get("e.force:closeQuickAction").fire();
       
	},
     cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})