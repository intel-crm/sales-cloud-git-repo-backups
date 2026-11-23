({
    handleSave: function(component, event, helper) {
        var action = component.get("c.saveData");
        // Add any necessary parameters to the action

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success
            } else if (state === "ERROR") {
                // Handle errors
            }
        });

        $A.enqueueAction(action);
    }
})