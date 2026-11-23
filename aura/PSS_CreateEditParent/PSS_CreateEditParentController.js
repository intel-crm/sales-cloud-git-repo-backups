//IPA2.0: US-TWC729-7976
({
	myAction : function(component, event, helper) {
		
	}
})
// ({
// 	doInit: function (component, event, helper) {
// 		const action = component.get('c.getSolutionDataAura');
// 		action.setParams({ 'solRecordId': recordId });
// 		action.setCallback(this, function (response) {

// 			let solutionDataCheck;
// 			const state = response.getState();

// 			if (state === 'SUCCESS') {
// 				solutionDataCheck = response.getReturnValue();
// 				if (solutionDataCheck.isRedirect) {
// 					window.parent.location.href = $A.get('$Label.c.PMP_Marketplace_Community_URL') + '/solution-detail-page?recordId=' + recordId;
// 				} else {
// 					component.set('v.loadCreateEditPage', true);
// 				}
// 				helper.hideSpinner(component, event);
// 			} else if (state === 'INCOMPLETE') {
// 				helper.hideSpinner(component, event);
// 			} else if (state === 'ERROR') {
// 				helper.hideSpinner(component, event);
// 			}
// 		});

// 		$A.enqueueAction(action);
// 	}
// })