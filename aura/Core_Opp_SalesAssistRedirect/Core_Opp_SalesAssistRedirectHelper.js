({
	updatecheckbox : function(component, event, helper) {
		var action = component.get("c.enableSalesAssistCheckBox");
        var navService = component.find("navService");
        debugger;
        var sURL = window.location.href;
        var OppId = sURL.split('recordId=')[1];
        
        action.setParams({
              OppId : OppId
        });
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            var msg = response.getReturnValue();
            //alert(state);
            //alert(msg);
            //if the call is successful and data is received. 
            if (state === "SUCCESS") {
                if(msg!=null && msg !=''){
                    //alert('error'+msg);
                }
                var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: OppId,
                    objectApiName: "Opportunity",
                    actionName: 'view'
            }
        }
        navService.navigate(pageReference); 
                component.set("v.spinner",false);
            }
            else if(state === "INCOMPLETE") {
                // Call was incomplete log an error
               
            }
			else if(state === "ERROR") {
                if(msg!=null){
                    //alert('error'+msg);
                }
            }
        });
        $A.enqueueAction(action);
	}
})