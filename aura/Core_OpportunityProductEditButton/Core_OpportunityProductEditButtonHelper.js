({
	getFieldSetFormDetails : function(component, event, helper) {
        component.set("v.isLoading",false);
        var recId = component.get("v.recordId");
        console.log('Inside helper')
        console.log('Recordid helper is:'+recId)
        var action = component.get("c.getFormFieldsAndSectionLabel");
         action.setParams({

            "recordId" : recId

        });
        
        action.setCallback(this, function(response) {
			
            console.log("The response is:"+response)
            
             var state = response.getState();
            if(state == 'SUCCESS') {
                var res = response.getReturnValue();
               console.log('The res is:'+ JSON.stringify(res));

               component.set("v.formValues", res); 
            }
        });
        $A.enqueueAction(action);

    },
    
})