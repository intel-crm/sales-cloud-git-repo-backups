({
    updateAccountRequestField: function(component, event, helper) {
        var accountId = component.get("v.accountRequestId");
        
        var action = component.get("c.updateAccountRequestField");
        action.setParams({
            "accountRequestId": accountRequestId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Optionally, handle success
            } else {
                // Optionally, handle error
            }
        });
        $A.enqueueAction(action);
    }
})