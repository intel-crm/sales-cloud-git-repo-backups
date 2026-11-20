({
    handleToggleOpen : function(component, event, helper) {
        console.log('handle togggle open');
        component.set('v.open', !component.get('v.open'));
        // [Hemanta] Cancel the default toggle action on the event
        event.preventDefault();
    }
})