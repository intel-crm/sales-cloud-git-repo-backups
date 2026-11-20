({

  processInput : function(component, helper) {
    var valid = component.find("input").reportValidity();
		component.set('v.valid', valid);
    component.set('v.touched', true);
    helper.updateForm(component);
  },

  processInputWithoutReport : function(component, helper) {
    var valid = component.find("input").checkValidity();
		component.set('v.valid', valid);
    component.set('v.touched', true);
    helper.updateForm(component);
  },

  setInitialValue : function(component, helper) {
    // set initial value if textValue exists
    if (component.get('v.textValue')) component.set('v.value', component.get('v.textValue'));
    component.set('v._value', component.getReference('v.value'));
  },

  setInitialComplexValue : function(component, helper) {
    var initialValue = component.get('v.textValue');
    component.set('v._value', initialValue || '');
    if (initialValue) helper.setComplexValue(component, helper);
  },

  setComplexValue : function(component, helper) {
    /*component.set('v.value', Object.assign({},
      component.get('v.additionalValues') || {},
      { value: component.get('v._value') }
    ));*/

    var additionalValues = component.get('v.additionalValues');
    var newValue = {};
    for(var key in additionalValues){
      if(additionalValues.hasOwnProperty(key)){
        newValue[key] = additionalValues[key];
      }
    }
    newValue.value = component.get('v._value');
    component.set('v.value', newValue);
  },

})