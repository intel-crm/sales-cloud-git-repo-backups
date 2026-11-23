({
	doInit: function (component, event, helper) {
        console.log("***Inside DoInit func.!");
        
        var action = component.get('c.sendEmailNotification'); 
        
        action.setParams({
            "quoteId" : component.get('v.recordId') 
        });
        $A.enqueueAction(action);
    }
})