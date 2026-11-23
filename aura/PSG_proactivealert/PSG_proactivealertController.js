({
    doInit : function(component, event, helper) {
        var action = component.get("c.createProactiveAlert");
         action.setParams({
            dpaId : component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('storeSucess'+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse'+storeResponse);
                component.set("v.showcmp", storeResponse);
                console.log('Alert'+storeResponse);
                
            }else{
                var errors = response.getError();
                console.log("Error message: " + errors[0].message);
            }
        });
        $A.enqueueAction(action);
        console.log(action);
    }
})