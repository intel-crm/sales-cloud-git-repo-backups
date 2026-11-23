({
	fetchPicklistValues : function(component, fieldApiName, elementId) {
        var noValue = component.get("v.noneValue");
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "objName": "Core_Product_Risk__c",
            "fld": fieldApiName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    opts.push(noValue);
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push(allValues[i]);
                    }
                    component.set("v."+elementId, opts);
                }
            }
        });
        $A.enqueueAction(action);
    },
})