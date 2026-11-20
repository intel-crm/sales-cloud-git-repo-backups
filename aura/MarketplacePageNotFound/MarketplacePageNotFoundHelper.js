({
	getAllButtons : function(component, event, helper) {
        
        let action = component.get("c.getButtons");
        let langCode = $A.get("$Locale.langLocale");
        action.setParams({ langCode: langCode });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.buttons", response.getReturnValue());
            }
            else if(state === "INCOMPLETE") {
                console.log("Incomplete request");
            } else if(state === "ERROR") {
                    var errors = response.getError();
                    if(errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
	}
})