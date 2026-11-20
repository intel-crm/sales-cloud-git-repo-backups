({

	handleChange : function(component, event, helper) {
        /*[POC]added by raj to remove error once the L3 is selected */
        if(component.get('v.name') && (component.get('v.name')).includes('__child')){
            component.set('v.isL3Selected', true);
            component.set('v.errorMessage','please select a value');
        }
        else{
            component.set('v.isL3Selected', false);
        }
        /*End*/
		var callback = component.get('v.onchange');
		if (typeof callback == 'function') {
			callback(component,component.get('v.radio.value'));
		}
	}

})