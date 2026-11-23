({
	/*doInit : function(component, event, helper) {
        component.set("v.isSpinner",true);
        var action = component.get("c.updateStatusAndReviewedByRep");
        action.setParams({
            "inquiryId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                
                    component.set("v.popupMsg", result);
               
            }
            component.set("v.isSpinner",false);
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
    },
    
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },*/
	
})