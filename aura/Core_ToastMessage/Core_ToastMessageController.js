({
    refreshView :  function(component, event, helper) {
       
        var artId =component.get('v.recordId');
        var rtnVal;
        debugger;
        //  alert('the record id is--->'+artId );
        var action = component.get("c.getCheckBox");
        action.setParams({ "artId" : artId  });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (state === "SUCCESS"){
                rtnVal= response.getReturnValue();
                debugger;
                component.set("v.isOpen",rtnVal);
                debugger;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    title: "Warning!",
                    type: 'error',
                    duration:'20000',
                    message: $A.get("$Label.c.Core_Opportunity_Team_member_toast_message")
                });
                debugger;
                if(rtnVal == true){
                    debugger;
                   toastEvent.fire();
                    var action = component.get("c.setcheckfalse");
                    action.setParams({ "artId" : artId  });
                    action.setCallback(this, function(response) {
                        var state = response.getState(); //Checking response status
                        if (state === "SUCCESS"){
                            
                        }
                    });
                    $A.enqueueAction(action);
                }
            
            }
        });
        $A.enqueueAction(action);
        
    }
})