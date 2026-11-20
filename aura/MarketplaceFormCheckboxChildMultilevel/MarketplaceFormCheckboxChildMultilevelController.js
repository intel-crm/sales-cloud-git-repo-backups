({

  doInit : function(component, event, helper) {
    helper.expandedRefresh(component, helper);
  },

  handleChange: function(component, event, helper) {
    if (typeof component.get('v.onchange') != 'function') return;
    setTimeout($A.getCallback(function() {
      component.get('v.onchange')(component);
    }));
  },

  handleToggleSection: function(component, event, helper) {
    if (!component.get('v.collapsible')) return;
    if (typeof component.get('v.ontogglesection') != 'function') return;
    setTimeout($A.getCallback(function() {
      component.get('v.ontogglesection')(component);
    }));
  },

  handleClearFilter: function(component, event, helper) {
    if (typeof component.get('v.onclearfilter') != 'function') return;
    setTimeout($A.getCallback(function() {
      component.get('v.onclearfilter')(component);
    }));
  },

  handleSelectFilter: function(component, event, helper) {
    if (typeof component.get('v.onselectfilter') != 'function') return;
    setTimeout($A.getCallback(function() {
      component.get('v.onselectfilter')(component);
    })); 
  },
  handleExpandedChange: function(component, event, helper) {
    helper.expandedRefresh(component, helper);
  },

})