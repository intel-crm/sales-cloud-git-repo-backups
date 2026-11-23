({
  
    doInit: function(component, event, helper) {
        helper.setInitialValue(component, helper);
        
        if (component.get('v.fieldName') == 'PMP_Company_Id__c' && component.get('v.apiName')=='offering' && !component.get('v.value')) {
      	  window.localStorage.setItem('hideSaveCompany', true);    
      	}
        
     /* if(window.localStorage.getItem('hideSaveCompany')){
         component.set('v.touched', false); 
      }*/
        
     /* if (component.get('v.label') == $A.get("$Label.c.PMP_Sub_Category") && !component.get('v.value')) { 
         component.set('v.valid', false); 
      }  */  
    },

    handleClick : function(component, event, helper) {
      // this is called in the div onclick to ensure that the first value
      // gets set when the hidePlaceholder is set to false
      if (!component.get('v.value') && component.get('v._value')) {
        component.set('v.value', component.get('v._value'));
        var valid = component.find("dropdown").checkValidity();
        component.set('v.touched', true);
        component.set('v.valid', valid);
        helper.updateForm(component);
      }
    },

    handleUpdate: function(component, event, helper) {
      helper.resetMultiplePlaceholder(component);
      // make sure placeholder value is right if it is updated
      
    },
    
     /*Gireesh:US378991: edit offering visibility */
    selectedValuesChange:function(component, event, helper) {

        if((event.getParam("oldValue")=='Partner Content'||event.getParam("oldValue")=='Intel Only Content')
           && (event.getParam("value")=='Public Content')
          ){
            helper.updateForm(component,'public');
            
        }
        else{
            helper.updateForm(component,'nonPublic');
        }
    },
    
    handleChange : function(component, event, helper) {
        var valid, newValue = component.get('v._value');
      component.set('v.value', newValue);
      valid = component.find("dropdown").checkValidity();
      component.set('v.touched', true);
      component.set('v.valid', valid);
        
      if (component.get('v.fieldName') == 'PMP_Company_Id__c' && component.get('v.apiName')=='offering' && component.get('v.touched') && component.get('v.valid')) {
        window.localStorage.setItem('hideSaveCompany', false);  
      }    
      helper.updateForm(component);
    },

    handleRemovePill : function(component, event, helper) {
      var pill = event.currentTarget.dataset.val;
      var options = component.get('v.options');
        options.forEach(function(opt) {
	if (opt.value == pill) opt.selected = false;
	});
      component.set('v.options', options);
      var values = component.get('v.multiValues');
      values.splice(values.indexOf(pill), 1);
      component.set('v.multiValues', values);
      helper.resetMultiplePlaceholder(component);
      component.set('v.touched', true);
      component.set('v.value', component.get('v.isPicklist') ? values.join(';') : values);
      helper.updateForm(component);
    },

    handleToggleMultipleDropdown : function(component, event, helper) {
      component.set('v.multipleDropdownOpen', !component.get('v.multipleDropdownOpen'));
      if (!component.get('v.multipleDropdownOpen')) component.set('v.touched', true);
    },

    handleOpenMultipleDropdown : function(component, event, helper) {
      component.set('v.multipleDropdownOpen', true);
    },

    handleCloseMultipleDropdown : function(component, event, helper) {
      component.set('v.touched', true);
      component.set('v.multipleDropdownOpen', false);
    },

    handleSelectMultipleOption: function(component, event, helper) {
        var data = event.currentTarget.dataset,
            options = component.get('v.options');
        options[data.idx].selected = !options[data.idx].selected;
        component.set('v.options', options);
        helper.setValueForMultiple(component, helper);
    },
    

    preventBlur : function(component, event, helper) {
      event.preventDefault();
    }

})