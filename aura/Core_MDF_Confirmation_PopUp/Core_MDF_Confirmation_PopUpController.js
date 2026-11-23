({
	doInit : function(component, event, helper) {
        //var objectName = component.get('v.sObjectName');
        //alert('confirmation popup objectName : '+objectName);
        /*
        if(objectName == 'Campaign'){
            component.set('v.showDialog', true);
            component.set('v.message', 'Are you sure you want to submit this campaign for Approval.');
        }
        */
        //var recId = component.get('v.recordId');
        //alert('confirmation popup recId : '+recId);
        
    },
    handleConfirmNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showDialog', false);
    },
    handleConfirmYes : function(component, event, helper) {
        console.log('Yes');
        component.set('v.showDialog', false);
        component.set('v.isProcessing', true);
        var action = component.get("c.processConfirmation");  
        var objectName = component.get('v.objectName');
        var recordId = component.get('v.recordId');
        var actionName = component.get('v.actionName');
        
        action.setParams({objectName:objectName, recordId:recordId, action:actionName});
        action.setCallback(this, function(response){            
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set('v.isProcessing', false);
                var responseMsg = response.getReturnValue();
                //responseMsg = 'Error---';
                console.log("confirmation popup - Response: ", responseMsg);
                
                if(responseMsg == 'Success'){
                    location.reload();
                }else{
                    component.set('v.isError', true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": responseMsg,
                        "type":"error"
                    });
                    toastEvent.fire();
                }
            }
            else if(state === "ERROR"){
                console.log("Error: ", response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    }
})