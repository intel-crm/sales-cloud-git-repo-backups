({

	getCategories : function(component) {
		 component.set('v.loading', true);
        var userLangCode = $A.get("$Locale.langLocale");
		 var action = component.get("c.getCategoryData");
        action.setParams({
            searchType:component.get('v.searchType'),
            langCode: userLangCode
        	
        });
		 action.setCallback(this, function(response) {
		 	var status = response.getState();
		 	if (status === "SUCCESS") {
		 		var searchCategories = response.getReturnValue();
				 // map return value to searchFilters expected format
				 
		 		component.set('v.listing', searchCategories);
                
		 		component.set('v.loading', false);
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