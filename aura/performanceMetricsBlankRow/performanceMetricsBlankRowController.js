({
    doInit: function (component) {
        const pickListValue = component.find('schType').get('v.value');
        component.set('v.disabled', pickListValue !== 'Other');
    },
    onChange: function (component, event, helper) {
        const pickListValue = component.find('schType').get('v.value');
        if (pickListValue !== 'Other') {
            component.set('v.disabled', true);
        } else {
            component.set('v.disabled', false);
        }
    },
});