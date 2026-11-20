({
  doInit : function(component, event, helper) {

  },
  handleChange : function(component, event, helper) {
    if (component.get('v.active') && component.get('v.renderOnFirstOpen')) {
      component.set('v.renderOnFirstOpen', false);
    }
  }
})