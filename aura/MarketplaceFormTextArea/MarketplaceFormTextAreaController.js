({

  doInit : function(component, event, helper) {
    if(component.get("v.required") && !component.get("v.value")) {
        component.set("v.valid", false);
    } else {
      component.set("v.valid", true);
    }
    helper.updateForm(component);
  },

	handleChange : function(component, event, helper) {
    var valid = component.find("input").reportValidity();
		component.set('v.valid', valid);
    component.set('v.touched', true);
    helper.updateForm(component);
	}

})