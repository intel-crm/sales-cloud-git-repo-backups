({

  doInit : function(component, event, helper) {
    // bug fix ... if v.body is aura:iteration of AccordionSections
    setTimeout($A.getCallback(function() {
      helper.setAttributes(component);
    }, 5));
  },

})