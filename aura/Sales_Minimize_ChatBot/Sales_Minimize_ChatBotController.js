({
    init: function(component, event, helper) {
        component.find("minimizedAPI").registerEventHandler(helper.eventHandler.bind(helper, component));
    }
});