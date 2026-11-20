({
	doInit : function(component, event, helper) {
		var action = component.get("c.validateLeadRecord");
        action.setParams({
            leadRecordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.Status == "Rejected"){
                    component.set("v.isRejected", true);
                    component.set("v.isUnclaimed", false);
                }else if(result.Core_Lead_State__c == 'Unclaimed' && result.Core_Lead_Status__c == 'New'){
                    component.set("v.isUnclaimed", true);
                    component.set("v.isRejected", false);
                }else{
                    component.set("v.isRejected", false);
                    component.set("v.isUnclaimed", false);
                }
            }else{
                console.log("Error on validating lead record "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
	}
})