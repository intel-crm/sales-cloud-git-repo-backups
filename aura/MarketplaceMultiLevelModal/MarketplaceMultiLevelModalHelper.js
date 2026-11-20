({

	close: function(component, event, helper) {
        var onclose = component.get('v.onclose');
        if (typeof onclose === 'function') {
            onclose(component, event, helper);
        }
        event.preventDefault();
    },

})