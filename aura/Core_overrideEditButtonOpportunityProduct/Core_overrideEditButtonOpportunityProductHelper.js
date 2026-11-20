({
	checkUserProfile: function(component, event, helper) {
        const rid = component.get("v.recordId");
        var action = component.get("c.getLoggedInUserType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userType = response.getReturnValue();                
                if(userType === 'PowerPartner'){
                    $A.get("e.force:closeQuickAction").fire();
                    const editRecordEvent = $A.get("e.force:editRecord");
                    editRecordEvent.setParams({
                        recordId: rid
                    });
                    editRecordEvent.fire();
                } else{
                    component.set("v.isPartnerProfile", false);
                }
                component.set("v.isModalOpen", true);
            }
        });
        $A.enqueueAction(action);        
    },
    
    helperMethod : function() {
		
	}
})