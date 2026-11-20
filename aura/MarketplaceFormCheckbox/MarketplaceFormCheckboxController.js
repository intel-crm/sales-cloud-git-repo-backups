({
    doInit : function(component, event, helper) {
      var _textDebounceTimer;
      component.set('v.handleChange', $A.getCallback(function(cmp) {
          
        if (cmp.getLocalId() == 'childTextInput') {
          clearTimeout(_textDebounceTimer);
          if (cmp.get('v.touched')) { // PREVENTS infinite loop
            _textDebounceTimer = setTimeout(function() {
              var checkboxValue = cmp.get('v.value') || '';
              helper.setValue(component, helper, cmp.get('v.refId'), checkboxValue);
              component.set('v.touched', true);
            }, 250);
          }
        } else if (cmp.getLocalId() == 'childRadio') {
          if (cmp.get('v.touched') && cmp.get('v.value')) { // PREVENTS infinite loop
            helper.setValue(component, helper, cmp.get('v.refId'), cmp.get('v.value'));
            component.set('v.touched', true);
          }
        } else if (cmp.getLocalId() == 'checkbox') {
            var value = cmp.get('v.checkbox.value'), checkboxValue = cmp.get('v.checkbox.checked');
            helper.setValue(component, helper, value, checkboxValue);
            component.set('v.touched', true);
            //--POC PSG -----
            /*As soon as any checkbox option is clicked, this call back function executes,
             * Below, we are checking if the checkbox fieldName is Availability and pricing
             * and the fieldName of the checkbox is ContactForPricing, if contact for pricing is selected
             * the Price field should be disabled, this is done by firing an event and handling it in
             * MarketplaceCreateProductsForm component's JS controller.
             
             */
            if(cmp.get('v.checkbox.fieldName') == $A.get("$Label.c.PMP_ContactForPrice") && cmp.get('v.checkbox.checked')){
               console.log('insideTOggle');
                var requiredInputToggle = component.getEvent("requiredInputToggle");
                var toggleFieldName = $A.get("$Label.c.PMP_AvailabilityAndPricing_Price");
            	requiredInputToggle.setParams({"isMandatory" : false,
                                       "fieldName" : toggleFieldName});
            	requiredInputToggle.fire();
               }
            else if(cmp.get('v.checkbox.fieldName') == $A.get("$Label.c.PMP_ContactForPrice") && !cmp.get('v.checkbox.checked')){
                var requiredInputToggle = component.getEvent("requiredInputToggle");
                var toggleFieldName = $A.get("$Label.c.PMP_AvailabilityAndPricing_Price");
            	requiredInputToggle.setParams({"isMandatory" : true,
                                       "fieldName" : toggleFieldName});
            	requiredInputToggle.fire();
               }
            //POC End-------
        }
        component.set('v.forceShowError', false);
      }));
      helper.setInitialValue(component, helper);
    },


    handleTopLevelChange : function(component, event, helper) {
      if (component.get('v.accordionType') == 'childAccordin'){
            var options = component.get('v.checkboxes');
            var i = 0;
            options.forEach(function (opt) {
              if(opt.checked){
                i++;
              }
            });
            if(i==options.length){
              component.set('v.regionsSelectedAll',true);
            }else{
              component.set('v.regionsSelectedAll',false);
            }
        }      
      setTimeout($A.getCallback(function() {
        var value = event.getSource().get('v.name');
        var checkboxValue = event.getSource().get('v.checked')
        helper.setValue(component, helper, value, checkboxValue);
        component.set('v.touched', true);
        component.set('v.forceShowError', false);  
        if (checkboxValue) {
          var idx, checkboxes = component.get('v.checkboxes');
          var c = checkboxes.find(function(cbox) {
            return cbox.value == value;
          });
          idx = checkboxes.indexOf(c);
          helper.toggleAccordion(component, helper, idx, true);
        }
      }));
    },

    handleRegionChangeAll: function (component, event, helper) {

      setTimeout($A.getCallback(function() {
        
        var checkboxValue = component.find('selectAllRegionCheckbox').get('v.checked');
       
        var options = component.get('v.checkboxes');
        options.forEach(function (opt) {
          helper.setValue(component, helper, opt.value, checkboxValue);
          var idx, checkboxes = options;
            var c = checkboxes.find(function(cbox) {
              return cbox.value == opt.value;
            });
            idx = checkboxes.indexOf(c);
          if (checkboxValue) {
            helper.toggleAccordion(component, helper, idx, true);
          }
       });
       
       if (checkboxValue) {
          component.set('v.touched', true);
          component.set('v.forceShowError', false);
          component.set('v.valid', true); 
        }else{
          component.set('v.touched', false);
          component.set('v.forceShowError', true);
          component.set('v.valid', false); 
        }
      }));
    
    },

     handleToggleOpen : function(component, event, helper) {	
      component.set("v.spinnerIndex", parseInt(event.currentTarget.dataset.idx,10));	
      var i = event.currentTarget.dataset.idx; 	
      if (!i) i = event.target.dataset.idx;	
        //ashish changes for US673458 	
      window.setTimeout(function(){	
          helper.toggleAccordion(component, helper, i);  	
        });   	
       	
    },	
    
    
    ignoreParentClick : function(component, event, helper) {
      event.stopPropagation();
    },

    handleSearch : function(component, event, helper) {
      var t = component.get('v._debounceSearchTimer'), minChars = 2;
      window.clearTimeout(t);
      if (!component.get('v.searchString')) {
        helper.search(component, helper);
      } else {
        component.set('v._searching', component.get('v.searchString').length >= minChars);
        t = window.setTimeout($A.getCallback(function() {
          helper.search(component, helper);
        }), 500);
      }
      component.set('v._debounceSearchTimer', t);
    },

    handleSearchKeydown : function(component, event, helper) {
      if (event.keyCode == 13) {
        event.preventDefault();
        event.stopPropagation();
        if (component.get('v._searching')) {
          component.set('v._scrollToResult', true);
        } else {
          helper.scrollToFirstResult(component, helper);
        }
      }
    }

  })