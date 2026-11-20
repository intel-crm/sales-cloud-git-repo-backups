({

  doInit : function(component, event, helper) {
    component.set('v.handleChange', $A.getCallback(function(cmp,id) {
        if(!cmp.get('v.isChildRequired') || cmp.get('v.isL3Selected')){
            component.set('v.touched', true);
      		component.set('v.forceShowError', false);
        } 
       
        
      console.log(cmp.get('v.radio.label')); 
      // IPA2.0 + US TWC4497-1631
        // if(component.get('v.apiName')=="offering"){  
      	// 	component.set('v.errorMessage',$A.get("$Label.c.PMP_SubCategory_Level3_ErrorMessage").replace('{0}', cmp.get('v.radio.label')));  
        // 	component.set('v.isL3Selected',cmp.get('v.isL3Selected'));
        // }
              
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