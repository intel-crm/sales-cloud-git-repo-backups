({
	doInit : function(component, event, helper) {
        
		var action = component.get("c.sendInviteEmail");
        var regRequestId = component.get("v.recordId");
        
        action.setParams({
            regRequestID : regRequestId           
        });
        action.setCallback(this, function(data){
            var state= data.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result = data.getReturnValue();
                component.set('v.message',result);
       		}
            else{
                var error = 'Error has occured'
                component.set('v.message',error);
                
            }
        });
        
         $A.enqueueAction(action);
	}
})