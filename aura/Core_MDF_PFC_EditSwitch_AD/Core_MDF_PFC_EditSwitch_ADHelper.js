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
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var claimObject = a.getReturnValue();                
                component.set("v.simpleNewClaim",claimObject);
            }
        });
        $A.enqueueAction(action);
    }
})