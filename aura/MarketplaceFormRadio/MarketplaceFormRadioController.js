({

  doInit : function(component, event, helper) {
    component.set('v.handleChange', $A.getCallback(function(id) {
      component.set('v.touched', true);
      component.set('v.forceShowError', false);
      helper.setValue(component, helper, id);
    }));
    helper.setInitialValue(component, helper);
  },

  handleSearch : function(component, event, helper) {
    var q = component.get('v.searchTerm').toLowerCase();
    var options = component.get('v.options').map(function(opt) {
      opt.highlight = q && opt.label.toLowerCase().match(q) ? true : false;
      if (opt.children && opt.children.length) {
        opt.children = opt.children.map(function(op) {
          op.highlight = q && op.label.toLowerCase().match(q) ? true : false;
          return op;
        });
      }
      return opt;
    });
    component.set('v.options', options);
  }

})