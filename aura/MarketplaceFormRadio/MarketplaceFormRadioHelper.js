({
    
    setValue: function(component, helper, id) {
        var options = component.get('v.options'),
            valueType = component.get('v.valueType'),
            value, valid = typeof id != 'undefined', selected = [];

        var recurse = function(opts, uncheck) {
            var checkParent = false;
            opts.forEach(function(opt) {
                if (uncheck) opt.isSelected = false;
                if (opt.value == id) {
                    opt.isSelected = true;
                    if (opt.children && opt.children.length) {
                        if (component.get('v.requireAllLevels')) valid = false;
                    }
                } else {
                    opt.isSelected = recurse(opt.children || []);
                }
                if (opt.isSelected) {
                    checkParent = true;
                    selected.push(opt);
                }
            });
            return checkParent;
        }

        recurse(options);

        if (valueType == 'default') {
            value = id;
        }

        if (valueType == 'picklist') {
            value = selected.map(function(v) { return v.value; }).join(';');
        }

        if (valueType == 'complex') {
            value = selected.map(function(v) {
                return Object.assign({ id: v.value }, v.additionalValues);
            });
        }

        component.set('v.options', options);
        helper.setInputValue(component, helper, value, valid);
    },

    setInitialValue : function(component, helper) {
        console.log('options-->insidesetinitial'+component.get('v.options'));
        var options = component.get('v.options'),
            valueType = component.get('v.valueType'),
            value, valid = false, selected = [];
        if(options.length>0){
            component.set("v.showLabel",true);
        }else{
            component.set("v.showLabel",false);
        }
        var recurse = function(opts) {
            var isSelected = false;
            opts.forEach(function(opt) {
                if (opt.isSelected) {
                    selected.push(opt);
                    isSelected = true;
                    valid = true;
                }
              //  console.log('opt:->'+opt.children.length);
                if (opt.children && opt.children.length) {
                    if (valueType == 'default') {
                        throw('Radio Input Error: radio w/ hierarchy cannot have a valueType of "default"');
                    }
                    isSelected = recurse(opt.children);
                    if (!isSelected && component.get('v.requireAllLevels')) valid = false;
                }
            });
            return isSelected;
        }
        recurse(options);

        if (valueType == 'default') {
            value = selected[0];
            if (value) component.set('v.value', value);
        }

        if (valueType == 'picklist') {
            value = selected.map(function(v) { return v.value; }).join(';');
            if (value.length) component.set('v.value', value);
        }

        if (valueType == 'complex') {
            value = selected.map(function(v) {
                return Object.assign({ id: v.value }, v.additionalValues);
            });
            if (value.length) component.set('v.value', value);
        }

        if (component.get("v.required") && !valid) {
            component.set("v.valid", false);
        } else {
            component.set("v.valid", true);
        }
        helper.setInputValue(component, helper, value, valid);
    },

     setInputValue : function(component, helper, value, valid) {
        var oldValue = component.get('v.value');
        if (value.length) component.set('v.value', value);
        if (component.get("v.required") && !valid) {
            component.set("v.valid", false);
        } else {
            component.set("v.valid", true);
        }
        helper.updateForm(component);
    },
    
    update : function(component, helper) {
        if (component.get("v.required") && !component.get("v.value")) {
            component.set("v.valid", false);
        } else {
            component.set("v.valid", true);
        }
        component.set('v.touched', true);
        helper.updateForm(component);
    },
    
    showErrorMessage : function(component, helper) {
        var showError = !component.get('v.valid');
        component.set('v.forceShowError', showError);
    },

})