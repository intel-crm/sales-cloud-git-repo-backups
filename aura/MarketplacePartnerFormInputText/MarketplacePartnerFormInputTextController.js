({

  doInit : function(component, event, helper) {
    if (component.get('v.valueType') == 'default') {
      helper.setInitialValue(component, helper);
    } else if (component.get('v.valueType') == 'complex') {
      helper.setInitialComplexValue(component, helper);
    }
    
    if(component.get("v.required") && !component.get("v.value")) {
        component.set("v.valid", false);
    } else {
      component.set("v.valid", true);
    }

    if (component.get('v.maxLength')) {
        
      component.find("input").set('v.maxlength', component.get('v.maxLength'));
    }
    if (component.get('v.minLength')) {
      component.find("input").set('v.minlength', component.get('v.minLength'));
    }
    helper.updateForm(component);
  },

  handleBlur : function(component, event, helper) {
    if (component.get('v.subType') == 'email') {
      helper.processInput(component, helper);
    }
  },

	handleChange : function(component, event, helper) {
    if (component.get('v.valueType') == 'complex') {
      helper.setComplexValue(component, helper);
    }
    if (component.get('v.subType') == 'email') {
      helper.processInputWithoutReport(component, helper);
    } else {
      helper.processInput(component, helper);
    }
	}

})