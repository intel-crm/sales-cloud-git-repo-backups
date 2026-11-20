({
	doInit : function(component, event, helper) {
        
		var action = component.get("c.sendMail");
        var emailLogId = component.get("v.recordId");
        
        action.setParams({
            fromComponent : true,
            recordId : emailLogId
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