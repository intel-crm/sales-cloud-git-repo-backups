({
	doInit : function(component, event, helper) {
		var action = component.get("c.getBannerText");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() == null){
                    $A.util.addClass(component.find("text"), "slds-hide");
                }else{
                    component.set("v.bannerText", response.getReturnValue());
                }
            }else{
                console.log("Error on fetching banner text "+response.getError());
            }
        });
        $A.enqueueAction(action);
	}
})