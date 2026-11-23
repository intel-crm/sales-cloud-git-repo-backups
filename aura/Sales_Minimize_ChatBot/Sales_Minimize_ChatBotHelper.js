({
    eventHandler: function(component, eventName, eventData) {
        // case switch on Live Agent events and handle appropriately
        switch(eventName) {
            case "prechatState":
                component.set("v.message", "What should I help you with?");
                break;
            case "chatState":
                component.set("v.message", "Chatting with: " + eventData.agentName);
                break;
            default:
                component.set("v.message", eventData.label);
                break;
                         }
    }
});