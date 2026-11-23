({
	doInit : function(component, event, helper) {
		component.set("v.loaded", false);
        var action = component.get("c.initializeProductRisk");
        action.setParams({
            "oppId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result != null){
                    helper.fetchPicklistValues(component, "Core_Risk_Reason__c", "riskReason");
                    helper.fetchPicklistValues(component, "Core_Risk_Priority__c", "riskPriority");
                    helper.fetchPicklistValues(component, "Core_Risk_Status__c", "riskStatus");
                    component.set("v.productAtRiskList", response.getReturnValue());
                }else{
                    
                }
                component.set("v.loaded", true);
            }else{
                console.log("Error on fetching product risk details : "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
	}
})