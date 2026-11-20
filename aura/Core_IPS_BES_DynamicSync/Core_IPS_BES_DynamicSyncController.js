({

	init : function(component, event, helper) {
        
        const action = component.get("c.dynamicSyncFromLightning");
        const recordId=component.get('v.recordId');
        action.setParams({
                    recordId:recordId
                });
        
        action.setCallback(this, function(response) {
            
            const state = response.getState();
            var mufinal = response.getReturnValue();
            if (mufinal === 'yes') {
            	alert('Processing');

            } 
            else if(mufinal === 'no') {
                alert(' No chnages on backend System');

            }


            

        });
       $A.get("e.force:closeQuickAction").fire();

        $A.enqueueAction(action);

		
	}

})