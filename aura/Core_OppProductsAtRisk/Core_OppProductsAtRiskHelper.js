({
    /*this is reusable function to get the picklist values*/
    fetchPicklistValues : function(component, fieldApiName, elementId) {
        var noValue = component.get("v.noneValue");
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "objName": "OpportunityLineItem",
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
    
    /*function is used to get the dependent picklist values*/
    fetchFieldDependency : function(component, controllingField, dependentField){
        var action = component.get("c.getFieldDependencies");
        action.setParams({
            objectName : "OpportunityLineItem",
            controllingField : controllingField,
            dependentField : dependentField,
            noValue : component.get("v.noneValue")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.depnedentFieldMap", result);
            }
        });
        $A.enqueueAction(action);
    }
})