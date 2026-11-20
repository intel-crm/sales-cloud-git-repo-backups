({
    checkUserPermission : function(component, event, helper) {
        var action = component.get("c.isUserEligibiletoCancel");
        action.setParams({"recordId" : component.get("v.recordId")});
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
        component.set("v.showSpinner",true);
        var action2 = component.get("c.checkExceptionEligibility");
        action2.setParams({"exceptionId" : component.get("v.recordId")});
        action2.setCallback(this, function(response){
            component.set("v.showSpinner",false);
            if(response.getState() == "SUCCESS"){
                if(response.getReturnValue() != null){ 
                var wrapInst = response.getReturnValue();
                //var exid = component.get("v.recordId");
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
                /*else if(wrapInst.isSubmitterCancellingApproved){
                    component.set("v.exceptionNotAvailableForCancellation",true);
                    component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_SubmitterCancellingApprovedStateError"));
                }*/
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
        }
            else if(response.getState() == 'ERROR'){ 
                var fieldErrors;
                var pageErrors;
                var message;
                var error;
                var err = action2.getError();
                if(err[0] != null && err[0] != undefined){
                    pageErrors = err[0].pageErrors;
                    message = err[0].message;
                }
                if (message == null) {
                    if (pageErrors != null && pageErrors != undefined && pageErrors.length > 0) {
                        if(pageErrors[0].statusCode == 'FIELD_CUSTOM_VALIDATION_EXCEPTION'){
                            error = JSON.stringify(pageErrors[0].message); 
                        }
                        else{
                            error = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"); 
                        }
                    } 
                } 
                else{
                    error = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"); 
                }
                if(error != null && error != undefined && error != ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        type: 'Error',
                        message: error,
                        mode: 'sticky',
                    });
                    toastEvent.fire(); 
                }
            }
        });
        $A.enqueueAction(action2);
    },
})