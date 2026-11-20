({
	// IPA2.0 + US TWC4497-1631
	// loadPreviewData: function(component, recordId) {
    //     //This code is before merge - Commented Start
	// 	/*var match = window.location.href.match(/.*id\=(.*)/), id;
	// 	if (match) {
	// 		id = match[1];
	// 	} else {
	// 		throw('The offering preview is missing the required id param.');
	// 	}*/
    //     //This code is before merge - Commented End
	// 	var match = window.location.href.match(/.*recordId\=(.*)/), id;
	// 	if (recordId) {
	// 		id = recordId;
	// 	} else if (match) {
	// 		id = match[1];
	// 	} else {
	// 		throw('The offering preview is missing the required id param.');
	// 	}

	// 	component.set('v.recordId', id);
        
        
	// 	return new Promise(function(resolve, reject) {
	// 	  var action = component.get("c.getPreviewData");
	// 	  action.setParams({ offeringId: id });
	// 	  action.setCallback(this, function(response) {
	// 			var status = response.getState();
	// 			if (status === "SUCCESS") {
	// 				var response = JSON.parse(response.getReturnValue());
	// 				if (component.get('v.debugMode')) {
	// 					console.log('getPreviewData response: ', response);
	// 				}
	// 				component.find('offeringPreview').set('v.data', response);
	// 				component.find('offeringPreview').set('v.breadcrumbData', [
	// 					{ label: $A.get("$Label.c.PMP_Breadcrumbs_Marketplace_Home"), page: 'home' },
	// 					{ label: $A.get("$Label.c.PMP_Breadcrumbs_All_Marketplace"), page: 'search' },
	// 					{ label: $A.get("$Label.c.PMP_Breadcrumbs_All_Products"), page: 'search', searchParams: { type: 'product' } }
	// 				]);
	// 				resolve();
	// 			} else if (status === "ERROR") {
	// 				var errors = response.getError();
	// 				if (errors && errors[0] && errors[0].message) {
	// 					console.error('Error saving form: ' + errors[0].message); reject(errors[0].message);
	// 				} else { reject('Unknown error.'); }
	// 			} else {
	// 				console.error('Unknown error.'); reject('Unknown error.');
	// 			}
	// 	  });
	// 	  $A.enqueueAction(action);
	// 	});
	//   }

})