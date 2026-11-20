({
    fetchClaimRecord : function(component){
        //this.isInternalAuditUser(component);
        var action;
        if(component.get("v.isClone")){
            action = component.get("c.prepareCloneData");    
        }else{
            action = component.get("c.fetchClaimById");  
        }
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(result) {
            var state = result.getState();         
            
            if (state === "SUCCESS" && result.getReturnValue() != null && result.getReturnValue().claimObj != null && ((result.getReturnValue().activityBudgetType != 'Co-Engineering' && result.getReturnValue().countryMap != null) || (result.getReturnValue().activityBudgetType == 'Co-Engineering'))) {
                var claimObject = result.getReturnValue().claimObj; 
                var countryNameMap = result.getReturnValue().countryMap;
                var activitySubType = result.getReturnValue().activitySubTypeMap;
                var activityBudgetType = result.getReturnValue().activityBudgetType;

                if(countryNameMap != null && countryNameMap != undefined) {
                    for (let index in countryNameMap) {
                        if (!$A.util.isUndefinedOrNull(index) && !$A.util.isUndefinedOrNull(countryNameMap[index])) {
                            component.set("v.activityCountriesMap", ({ key: index, value: countryNameMap[index] }));
                    }
                }
                }
                if(activitySubType != null && activitySubType != undefined) {
                    for (let index2 in activitySubType) {
                        if (!$A.util.isUndefinedOrNull(index2) && !$A.util.isUndefinedOrNull(activitySubType[index2])) {
                            component.set("v.activitySubTypesMap", ({ key: index2, value: activitySubType[index2] }));
                        }
                    }
                }
                if(!$A.util.isUndefinedOrNull(activityBudgetType)) {
                    component.set("v.activityBudgetType", activityBudgetType);
                }
                component.set("v.simpleNewClaim",claimObject);
                     component.set("v.claimDetailsOnLoad", JSON.parse(JSON.stringify(claimObject)));
            }

        });
        $A.enqueueAction(action);
    },
  
})