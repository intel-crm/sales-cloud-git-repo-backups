({
    fetchIPARecordType: function(component) {
        var action = component.get("c.getIPARecordType");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('IPA Record Type result:', result);
                
                if (result && result.recordTypeId && result.recordTypeName && result.recordTypeDeveloperName) {
                    // Set IPA record type data
                    component.set("v.selrecordtype", result.recordTypeId);
                    component.set("v.selrecordtypeName", result.recordTypeName);
                    component.set("v.selrecordtypeDeveloperName", result.recordTypeDeveloperName);
                    component.set("v.recordTypesFetched", true);
                    
                } else {
                    this.showToast("Error", "Invalid IPA record type data received", "error");
                    component.set("v.showNewButton", false);
                }
                
            } else {
                component.set("v.showNewButton", false);
                component.set("v.recordTypesFetched", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type,
                duration: 5000
            });
            toastEvent.fire();
        } 
    }
})