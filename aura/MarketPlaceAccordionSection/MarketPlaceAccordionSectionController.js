({

  doInit : function(component, event, helper) {
    if(typeof component.get('v.openOnInit') != 'undefined') {
      component.set('v.open', component.get('v.openOnInit'));
    }
  },

  handleToggleOpen : function(component, event, helper) {
    var isOpen = !component.get('v.open'), callback = component.get('v.ontoggle');
    if (callback && typeof callback == 'function') {
      callback(component.get('v.name'), isOpen);
    }
    component.set('v.open', isOpen);
  },

  ignoreParentClick : function(component, event, helper) {
    event.stopPropagation();
  },
  
  handleCheckbox : function(component, event, helper) {
    if (component.get('v.isCheckboxChecked')) {
      component.set('v.open', true);
    }
    if (typeof component.get('v.checkboxCallback') == 'function') {
      window.setTimeout($A.getCallback(function() {
        component.get('v.checkboxCallback')();
      }))
    }
  }

})