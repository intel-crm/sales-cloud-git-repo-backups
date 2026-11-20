({
    //This helper function is used to fetch claim record type
    fetchRecordTypeDevName: function (component, event, helper) {
        var action = component.get("c.fetchClaimRecordType");
        action.setParams({
            'stageClaimRecordId': component.get("v.recordId")
        });
        action.setCallback(this, function(res) {
            var stateVal = res.getState();
            console.log('response '+res.getReturnValue());
            if (stateVal === "SUCCESS" && res.getReturnValue() != null) {
                component.set("v.claimRecordTypeDevName",res.getReturnValue());                
            }
        });
        $A.enqueueAction(action);
    } 
})