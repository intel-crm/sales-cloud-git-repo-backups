({
    onInit : function(component, event, helper) {
        helper.getChecklistResults(component, helper, "", "");
    },
    //This method gets the Non-Compliant Review Results from the DB
    getChecklistResults: function (component, helper) {
        var caseId =component.get("v.recordId");
        helper.callServer(component, "c.getChecklistResults", (response) => { component.set('v.checklistResults', response); }, {caseRecord : caseId});
    },
    callServer: function (component, method, callback, params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // pass returned value to callback function
                callback.call(this, response.getReturnValue());
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})