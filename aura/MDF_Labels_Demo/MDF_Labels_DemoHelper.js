({
    getLabel : function(component) {
        var action = component.get("c.getLabels");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                component.set("v.labelsMap", response.getReturnValue());
                var value = component.get("v.labelsMap");
                console.log(JSON.stringify(value));
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    } ,

})