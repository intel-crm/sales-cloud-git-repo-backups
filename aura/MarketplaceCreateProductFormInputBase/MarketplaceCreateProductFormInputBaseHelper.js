({
    
    updateForm : function(component, refreshOption) {
        // refreshOption can be undefined, SAVE, or REFRESHONLY
        if (typeof component.get('v.updateFormCallback') === 'function') {
            component.get('v.updateFormCallback')(component, refreshOption);
          //  console.log('refreshOptionhelper-->' +refreshOption);
        } else {
            console.warn('Callback not set.', component.get('v.updateFormCallback'), component.getName());
        }
    },
    
    showErrorMessage : function(component, helper) {
    throw new TypeError(component.getLocalId() + '#showErrorMessage function needs to be overwritten in the input component');
    },
    
})