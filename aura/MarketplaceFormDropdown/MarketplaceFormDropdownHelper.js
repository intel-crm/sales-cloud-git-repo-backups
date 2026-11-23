({

    setInitialValue: function(component, helper) {
        var valid = true,
            value = component.get('v.value'),
            options = component.get('v.options') || [];
		console.log('value##',value);
        console.log('options',options);
        if (component.get('v.allowMultipleOptions')) {
            
            var values = [];
            options.forEach(function(opt) {
                if (opt.selected) values.push(opt.value);
            });
            component.set('v.multiValues', values);
            window.setTimeout($A.getCallback(function() {
                component.set('v.options', options);
                helper.setValueForMultiple(component, helper);
            }));
            helper.resetMultiplePlaceholder(component);
            if (component.get('v.required') && !component.get('v.multiValues').length) {
                valid = false;
            }
        } else {

            var selected = options.find(function(opt) {
                return opt.selected;
            });
            if (selected) {
                value = selected.value;
                component.set('v.value', value);
            } else {
                if (component.get('v.hidePlaceholder') && !value) {
                    value = component.get('v.options')[0].value;
                    component.set('v.value', value);
                }
                if (component.get('v.required') && !value) {
                    valid = false;
                }
            }
            component.set('v._value', value);
            component.set('v.valid', valid);
            // window.setTimeout($A.getCallback(function() {
                helper.updateForm(component);
            // }), 5000);

        }
    },

    resetMultiplePlaceholder: function(component) {
        var defaultLabel = "No Preference";
        
        var selected = component.get('v.options').filter(function(opt) {
            return opt.selected;
        });
        
        if(selected.length > 0){
        	var label = (selected.length) + ' option' + (selected.length == 1 ? '' : 's') + ' selected'; // TODO custom labels
        	component.set('v.placeholder', label);
        }else if(selected.length == 0 && component.get('v.isLeadGen'))
            component.set('v.placeholder', defaultLabel);
        else{
             component.set('v.placeholder', 'No options selected');
         }
        
    

    },

    setValueForMultiple: function(component, helper) {
        var options = component.get('v.options');
        var values = options.filter(function(opt) {
                return opt.selected;
            })
            .map(function(opt) {
                return opt.value;
            });
        
    
        component.set('v.multiValues', values);
        if (values.length || component.get('v.value') != undefined) {
          component.set('v.value', component.get('v.isPicklist') ? values.join(';') : values);
        }
        component.set('v.multipleDropdownOpen', false);
        component.set('v.touched', true);
        var valid = true;
        if (component.get('v.required') && !values.length) valid = false;
        component.set('v.valid', valid);
        helper.resetMultiplePlaceholder(component);
        // window.setTimeout($A.getCallback(function() {
            helper.updateForm(component);
        // }), 5000);
    },
    
    showErrorMessage : function(component, helper) {
        if (!component.get('v.allowMultipleOptions')) {
            component.find("dropdown").showHelpMessageIfInvalid();
        } else {
            var showError = component.get('v.required') && component.get('v.multiValues').length == 0;
            component.set('v.forceShowError', showError);
        }
    },

})