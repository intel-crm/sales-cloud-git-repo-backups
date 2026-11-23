({
    checkUserPermission : function(component, event, helper) {
        var action = component.get("c.isUserEligibiletoCancel");
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){ 
                var wrapInst = response.getReturnValue();
                if(wrapInst.isUserEligibleToCancel){
                    component.set("v.isUserEligible",true);
                }
                else{
                    component.set("v.exceptionNotAvailableForCancellation",true);
                    component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_CloneAccessError"));
                }     
            }
        });
        $A.enqueueAction(action);
    },
    
    checkExceptionEligibilityForCancellation : function(component, event, helper){
        var action2 = component.get("c.checkExceptionEligibility");
        action2.setParams({"exceptionId" : component.get("v.recordId")});
        action2.setCallback(this, function(response){
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){ 
                var wrapInst = response.getReturnValue();
                component.set("v.wrapperClassVar",wrapInst);
                component.set("v.isUserEligible",false);
                if(wrapInst.isDenied){
                    component.set("v.exceptionNotAvailableForCancellation",true);
                    component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_CancelExceptionInDeniedStateError"));
                }
                else if(wrapInst.isCancelled || wrapInst.isSubmitterCancellingApproved ){
                    component.set("v.exceptionNotAvailableForCancellation",true);
                    component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_SubmitterCancellingApprovedStateError"));
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.Core_MDF_CancelException_Success_Title"),
                        type: 'success',
                        message: $A.get("$Label.c.Core_MDF_CancelException_Success_Message")
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    setTimeout(function(){window.location.reload();},1000);
                }
            }
        });
        $A.enqueueAction(action2);
    },
})