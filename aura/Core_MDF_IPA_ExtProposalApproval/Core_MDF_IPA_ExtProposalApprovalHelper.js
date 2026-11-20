({
    loadApprovalFlowAction: function (component, event, helper) {
        var result;
        var recId = component.get("v.recordId");
        var action = component.get("c.loadCampRecord");        
        action.setParams({cmpId: recId});
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
            if (response.getState() == "SUCCESS" && result != null) {
                component.set('v.externalUser', result.userPermissionsPowerPartner);
                
                if (result.userPermissionsPowerPartner){
                    component.set('v.buttonToBeVisible', true);
                } 
                else {
                    component.set('v.buttonToBeVisible', false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    //Function that will called on click of the button
    onClickButton: function (component, cmpId, btnType)
    {
        if (btnType == $A.get("$Label.c.Core_MDF_Retail_Approve") || btnType == $A.get("$Label.c.Core_MDF_Retail_Reject")){
            var aprAction = component.get("c.approveRejectProposal");
            aprAction.setParams({
                "buttonName":btnType,
                "cmpId":cmpId,
                "approvalComments" : component.get("v.approvalComments")
            })
            aprAction.setCallback(this, function (response) {
                var stateSave = response.getState();
                if(stateSave === "SUCCESS"){
                    var msgTxt = '';
                    var returnValue = response.getReturnValue();
                    //Added IF-else condition as part of defect DE120404 fix
                    if(returnValue == true){
                        if (btnType == $A.get("$Label.c.Core_MDF_Retail_Approve")) {
                            msgTxt = $A.get("$Label.c.Core_MDF_Campaign_was_approved"); //'Campaign was approved' //                      
                        }  
                        else if (btnType == $A.get("$Label.c.Core_MDF_Retail_Reject")) {
                            msgTxt = $A.get("$Label.c.Core_MDF_Campaign_was_rejected");   //'Campaign was rejected' //                    
                        }
                        this.toastMessage($A.get("$Label.c.Core_MDF_Success"),$A.get("$Label.c.Core_MDF_Success"),msgTxt);
                    }else{
                        msgTxt = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"); //If failed to approve or Reject because of any exception in backend
                        this.toastMessage($A.get("$Label.c.Core_MDF_Error"),$A.get("$Label.c.Core_MDF_Error"),msgTxt); 
                    }
                    
                    component.set('v.showApprovalCommentSection', false);
                    console.log('msgTxt:' + msgTxt);
                    //this.toastMessage($A.get("$Label.c.Core_MDF_Success"),$A.get("$Label.c.Core_MDF_Success"),msgTxt);
                    this.windowTimeOut();
                    component.set("v.loadSpinner",false); 
                }      
            });    
            $A.enqueueAction(aprAction);
        }
    },
    toastMessage : function(toastTitleLabel,toastTypeLabel,toastMessageLabel){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: toastTitleLabel,
            type: toastTypeLabel,
            message: toastMessageLabel
        });
        toastEvent.fire();
    },
    windowTimeOut : function(){
        window.setTimeout(
            $A.getCallback(function () {
                window.location.reload();
            }), 1000
        );
    }
})