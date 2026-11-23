({
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        cmp.set("v.optionValue",changeValue);   
    },
    onNext:function(component, event, helper) {
        var optVal = component.get("v.optionValue");
        if(optVal!=null){
            var evt = $A.get("e.force:navigateToComponent");        
            var recId = component.get("v.recordId");
            evt.setParams({
                componentDef:"c:salesOrderCloning",
                componentAttributes: {    
                    "recordId" : component.get("v.recordId"),
                    "selectval" : optVal
                }
            });
            evt.fire();    
        }
    },
    handleCloseModal : function(component, event, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Order"
        });
        homeEvt.fire();
    }
})