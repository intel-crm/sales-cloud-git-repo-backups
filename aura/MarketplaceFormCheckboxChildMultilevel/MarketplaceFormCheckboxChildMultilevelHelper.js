({

    focus: function(component, helper) {
        if (component.get('v.checkbox.subType') == 'text') {
            if (component.find('textInput')) {
            component.find('textInput').find('input').focus();
            }
        } else if (component.get('v.checkbox.subType') == 'text') {
            if (component.find('RadioInput')) {
            component.find('RadioInput').find('input')[0].focus();
            }
        } else {
            if (component.find('checkboxInput')) {
            component.find('checkboxInput').focus();
            }
        }
    },
    
    // on expanded section change check whether current checkbox is set to be expanded or not
    expandedRefresh: function(component, helper) {
        if (!component.get('v.collapsible')) return;

        var expandedSections = component.get('v.expandedSections') || [];
        if (component.getLocalId() == 'checkbox') {
          var checkboxValue = component.get('v.checkbox.value');
          component.set('v.isExpanded', expandedSections.indexOf(checkboxValue)>-1);
        }
    }

})