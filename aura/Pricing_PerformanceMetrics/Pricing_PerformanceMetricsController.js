({
	doinit: function (component, event, helper) {
		const recordId = component.get('v.recordId');
		const showQuoteLineDetailAction = component.get('c.showQuoteLineDetail');
		showQuoteLineDetailAction.setParams({
			quoteLineId: recordId,
		});
		showQuoteLineDetailAction.setCallback(this, function (response) {
			component.set('v.isStandardQuoteLine', response.getReturnValue());
		});
		$A.enqueueAction(showQuoteLineDetailAction);

		const isReadOnlyPLayout = component.get('c.isReadOnlyPageLayout');
		isReadOnlyPLayout.setParams({
			recordId: recordId,
		});
		isReadOnlyPLayout.setCallback(this, function (response) {
			component.set('v.isReadOnly', response.getReturnValue());
		});
		$A.enqueueAction(isReadOnlyPLayout);

		if (component.get('v.isCalledFromParent')) {
			//parameters from QuoteLineDetails Component
			component.set('v.picklistValues', component.get('v.picklistValues'));
			helper.getPerformanceMetrics(component, recordId);
			component.set('v.hasCreateAccessPf', component.get('v.hasCreateAccessPf'));
			component.set('v.hasUpdateAccessPf', component.get('v.hasUpdateAccessPf'));
			component.set('v.hasDeleteAccessPf', component.get('v.hasDeleteAccessPf'));
		} else {

			const action = component.get('c.getPickListValues');
			action.setParams({
				objectType: 'Pricing_Performance_Metric__c',
				selectedField: 'Pricing_Performance_Metric_Nm__c',
			});			
			action.setCallback(this, function (response) {
				const pklist = response.getReturnValue();
				component.set('v.picklistValues', pklist);
				helper.getPerformanceMetrics(component, recordId);
			});
			$A.enqueueAction(action);

			const checkHasCreateAccess = component.get('c.isCreateable');
			checkHasCreateAccess.setCallback(this, function (response) {
				component.set('v.hasCreateAccess', response.getReturnValue());
			});
			$A.enqueueAction(checkHasCreateAccess);

			const checkHasUpdateAccess = component.get('c.isUpdateable');
			checkHasUpdateAccess.setCallback(this, function (response) {
				component.set('v.hasUpdateAccess', response.getReturnValue());
			});
			$A.enqueueAction(checkHasUpdateAccess);

			const checkHasDeleteAccess = component.get('c.isDeletable');
			checkHasDeleteAccess.setCallback(this, function (response) {
				component.set('v.hasDeleteAccess', response.getReturnValue());
			});
			$A.enqueueAction(checkHasDeleteAccess);
		}
	},

	add: function (component, event, helper) {
		const addRec = {
			sobjectType: 'Pricing_Performance_Metric__c',
			Id: '',
			Pricing_Performance_Metric_Nm__c: '',
			Pricing_Weighting_Pct__c: '',
			Pricing_Intel_SKU_Performance_Nbr__c: '',
			Pricing_Comp_SKU_Performance_Nbr__c: '',
			Pricing_Other_Nm__c: '',
		};
		const existingRecords = component.get('v.records');
		existingRecords.push(addRec);
		component.set('v.records', existingRecords);
		if (component.get('v.records').length > 0) {
			component.set('v.saveButtonShow', true);
		} else {
			component.set('v.saveButtonShow', false);
		}
	},

	remove: function (component, event, helper) {
		const indexPosition = event.target.name;
		const existingRecords = component.get('v.records');
		if (existingRecords[indexPosition].Id === '') {
			existingRecords.splice(indexPosition, 1);
			component.set('v.records', existingRecords);
		} else {
			helper.deletePerformanceMetrics(
				component,
				existingRecords[indexPosition].Id
			);
			existingRecords.splice(indexPosition, 1);
			component.set('v.records', existingRecords);
			const toastEvent = $A.get('e.force:showToast');
						toastEvent.setParams({
							title: 'Message',
							message: 'Record deleted successfully',
							duration: ' 3000',
							key: 'info_alt',
							type: 'success',
							mode: 'pester',
						});
						toastEvent.fire();
		}
		if (component.get('v.records').length > 0) {
			component.set('v.saveButtonShow', true);
		} else {
			component.set('v.saveButtonShow', false);
		}
	},

	save: function (component, event, helper) {
		component.set('v.isDisabled', true);
		const quoteLineId = component.get('v.recordId');
		const existingRecords = component.get('v.records');
		const validRecords = [];
		if (helper.validateRequired(component, event)) {
			for (let i = 0; i < existingRecords.length; i++) {
					validRecords.push(existingRecords[i]);
			}
			component.set('v.records', validRecords);
			component.set('v.rows', validRecords.length);
			if (validRecords.length > 0) {
				const action = component.get('c.savePerformanceMetrics');
				action.setParams({
					inprec: validRecords,
					quoteLineId: quoteLineId,
				});
				action.setCallback(this, function (response) {
					const state = response.getState();
					if (state === 'SUCCESS' || state === 'DRAFT') {
						component.set('v.isDisabled', false);
						helper.getPerformanceMetrics(component, quoteLineId);
						const toastEvent = $A.get('e.force:showToast');
						toastEvent.setParams({
							title: 'Message',
							message: 'Records saved successfully',
							duration: ' 3000',
							key: 'info_alt',
							type: 'success',
							mode: 'pester',
						});
						toastEvent.fire();
					} else if (state === 'ERROR' || state === 'WARNING') {
						component.set('v.isDisabled', false);
						const toastEvent = $A.get('e.force:showToast');
						toastEvent.setParams({
							title: 'Message',
							message: 'No Records saved successfully',
							duration: ' 3000',
							key: 'info_alt',
							type: 'error',
							mode: 'pester',
						});
						toastEvent.fire();
					}
				});
				$A.enqueueAction(action);
			}
		}
	},
});