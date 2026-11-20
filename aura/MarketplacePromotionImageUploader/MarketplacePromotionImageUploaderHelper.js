({
	getPromotionLanguageOptions: function(component,event,helper){
        return new Promise($A.getCallback(function(resolve,reject){
            var action = component.get("c.getPromotionLanguageOptions");
            
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    component.set("v.languageOptions", returnValue);
                    component.set("v.language",returnValue[0].value);
                    
                    resolve();
                } else if (status === "INCOMPLETE") {
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
        }));
    }
})