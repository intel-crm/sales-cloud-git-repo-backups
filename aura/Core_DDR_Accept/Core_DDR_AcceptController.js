({
	doInit : function(component, event, helper) {
        console.log('Event from Parent -->',component.get("v.lowTouchORHighTouch"));
        console.log('Event from Parent -->',component.get("v.recordId"));
        var highOrLow;
		let action = component.get("c.ApproveDesign");
         component.set("v.LexSpinner", true);
        if(component.get("v.lowTouchORHighTouch") == "AcceptHighTouch"){
            highOrLow = $A.get("$Label.c.DDR_Intel_Support_Status_High");
        }else{
            highOrLow = $A.get("$Label.c.DDR_Intel_Support_Status_Low");
        }
       
        action.setParams({
            "DDRrecordId" : component.get("v.recordId"),
            "highTouchOrLowTouch":highOrLow
        });
        action.setCallback(this, function(response){
            console.log('Record id -->', component.get("v.recordId"));
            let state = response.getState();   // NOSONAR
            let returnValue = response.getReturnValue();   // NOSONAR
            if(state ==="SUCCESS"){
                component.set("v.alertMessage", returnValue.messageNotification);               
                var childEvent = component.getEvent("childEvent");
                childEvent.setParams({ "alertMessages": returnValue.messageNotification });
                childEvent.fire();
                
                //component.get("v.childEvent").setParams({ "alertMessages": returnValue.messageNotification }).fire();
            }else{
                console.log("Error on updating DDR "+response.getError());
            }
             component.set("v.LexSpinner", false);
        });
        $A.enqueueAction(action);
	},
    
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
})