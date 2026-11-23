({
    getSpecialistGroupList : function(component) {
        var userLangCode = $A.get("$Locale.langLocale");
		var action = component.get("c.getSpecialistGroupListData");
        action.setParams({
            'pageType':component.get('v.pageType'),
            langCode : userLangCode
        });
		action.setCallback(this, function(response) {
			var status = response.getState();
			if (status === "SUCCESS") {
				var returnValue = response.getReturnValue();
				component.set('v.listing', returnValue);
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