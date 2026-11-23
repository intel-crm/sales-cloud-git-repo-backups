({

	handleChange : function(component, event, helper) {
		var callback = component.get('v.onchange');
		if (typeof callback == 'function') {
			callback(component.get('v.radio.value'));
		}
	}

})