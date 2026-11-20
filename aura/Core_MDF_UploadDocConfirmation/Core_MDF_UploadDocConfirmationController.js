({
    firePopSubmitEvent : function(cmp, event,helper) { 
        var popSubmitEvent = cmp.getEvent("popSubmitEvent"); 
        popSubmitEvent.fire(); 
    },
    firePopCloseEvent : function(cmp, event,helper) { 
        var popCloseEvent = cmp.getEvent("popCloseEvent"); 
        popCloseEvent.fire(); 
    }
})