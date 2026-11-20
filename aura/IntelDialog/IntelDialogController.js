({

	closeModal : function(component, event, helper) {
		if (typeof component.get('v.onclose') === 'function') {
			component.get('v.onclose')(false);
		}
	},

	handleCancelAction : function(component, event, helper) {
		if (typeof component.get('v.onclose') === 'function') {
			component.get('v.onclose')(false);
		}
	},

	handleConfirmAction : function(component, event, helper) {
		if (typeof component.get('v.onclose') === 'function') {
			component.get('v.onclose')(true);
		}
	}

})