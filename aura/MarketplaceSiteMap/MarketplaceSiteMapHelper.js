({
	fetchCategories : function(component, helper) {
		
        var userLangCode = $A.get("$Locale.langLocale");
        var action = component.get("c.getAllCategories");
        
        action.setCallback(this, function(response){
            var status = response.getState();
            if (status === "SUCCESS") {
                var returnValue = response.getReturnValue();
                
               
                var childCats = [];
                for(var key in returnValue){
                    
                    childCats.push(...returnValue[key]);
                }
                
                component.set('v.catChilds', childCats);
                component.set('v.isDataReady', true);
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
	}
})