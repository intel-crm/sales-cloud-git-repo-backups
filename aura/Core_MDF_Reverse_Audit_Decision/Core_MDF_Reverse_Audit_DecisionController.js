({
    reverseAuditCheck : function(component, event, helper){
        component.set('v.showConfirmDialog', true);
    },
    /*
    handleConfirm : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },
    
    handleConfirmYes : function(component, event, helper) {
        console.log('Yes');
        component.set('v.showConfirmDialog', false);
        component.set('v.isProcessing', true);
        var action = component.get('c.reverseAudit');
        $A.enqueueAction(action);
    },
     
    handleConfirmNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
    },
    
    reverseAudit : function(component, event, helper) {
        component.set('v.isProcessing', true);
        var action = component.get("c.processAuditReverse");  
        var caseId = component.get('v.recordId');
        action.setParams({caseId : caseId});
        action.setCallback(this, function(response){            
            var state = response.getState();
            component.set('v.isProcessing', false);
            if(component.isValid() && state === "SUCCESS"){
                var responseMsg = response.getReturnValue();
                console.log("Response: ", responseMsg);
                //$A.get('e.force:refreshView').fire();
                var toDoReverseAudit = response.getReturnValue();
                if(responseMsg == 'Success'){
                    location.reload();
                }else{
                    component.set('v.isError', true);
                    //component.set('v.errorMsg', responseMsg);
                    
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
    },
    
    reverseAuditCheck : function(component, event, helper) {
        var action = component.get("c.checkReverseAuditCondition");  
        var caseId = component.get('v.recordId');
        console.log("recordIdInParent", caseId);
        action.setParams({caseId : caseId});
        action.setCallback(this, function(response){            
            var state = response.getState();
            component.set('v.isProcessing', false);
            if(component.isValid() && state === "SUCCESS"){
                var responseMsg = response.getReturnValue();
                console.log("Response: ", responseMsg);
                var toDoReverseAudit = response.getReturnValue();
                if(responseMsg == 'Success'){
                    //location.reload();
                    var actionConfirm = component.get('c.handleConfirm');
        			$A.enqueueAction(actionConfirm);
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
        
    },
    doInit : function(component, event, helper) {}
    */
})