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
        }
        component.set('v.forceShowError', false);
      }));
      helper.setInitialValue(component, helper);
    },


    handleTopLevelChange : function(component, event, helper) {
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

    handleToggleOpen : function(component, event, helper) {
      var i = event.currentTarget.dataset.idx;
      if (!i) i = event.target.dataset.idx;
      helper.toggleAccordion(component, helper, i);
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