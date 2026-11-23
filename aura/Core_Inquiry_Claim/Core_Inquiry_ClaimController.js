({
	/*doInit : function(component, event, helper) {
        component.set("v.Spinner",true);
        console.log('I am in do Init');
        var action= component.get("c.UpdateOwnertoClaimedOwner");
        action.setParams({
            "inquiryId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.alertMessage", response.getReturnValue());
                  $A.get("e.force:refreshView").fire();
            }else{
                console.log("An error has occurred while updating lead "+response.getError());
            }
              component.set("v.Spinner",false);
        });
        $A.enqueueAction(action);
    },
  cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },*/
})