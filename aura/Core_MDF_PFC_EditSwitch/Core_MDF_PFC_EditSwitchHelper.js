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
            if (state === "SUCCESS" && result.getReturnValue() != null && result.getReturnValue().claimObj != null && result.getReturnValue().countryMap != null){
                var claimObject = result.getReturnValue().claimObj; 
                var countryNameMap = result.getReturnValue().countryMap;
                for(let index in countryNameMap){
                    if(!$A.util.isUndefinedOrNull(index) && !$A.util.isUndefinedOrNull(countryNameMap[index])){
                       component.set("v.activityCountriesMap", ({key:index, value:countryNameMap[index]}));
                    }
                }
                component.set("v.simpleNewClaim",claimObject);
            }
        });
        $A.enqueueAction(action);
    }
})