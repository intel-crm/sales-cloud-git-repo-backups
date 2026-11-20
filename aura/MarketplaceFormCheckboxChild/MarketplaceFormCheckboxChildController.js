({

  doInit : function(component, event, helper) {
    
  },

  handleChange: function(component, event, helper) {
    if (typeof component.get('v.onchange') != 'function') return;
    setTimeout($A.getCallback(function() {
    	component.get('v.onchange')(component);
    }));
  },
  
  handleChangeSelected : function(component, event, helper) {
    
  },

})