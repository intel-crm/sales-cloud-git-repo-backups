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

})