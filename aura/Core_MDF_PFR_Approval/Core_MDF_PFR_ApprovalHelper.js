({
    loadApprovalFlowAction: function (component, event, helper) {
        var result;
        //alert(component.get("v.recordId"));
        var action = component.get("c.loadPFRRecord");
        action.setParams({
        "pfrId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
            if (result != null) {
                component.set('v.externalUser', result.userPermissionsPowerPartner);
                
                if (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review' && result.pfrInstance.Core_MDF_Region_cd__c.includes('EMEA') &&
                    !result.approverAssigned && !result.userPermissionsPowerPartner) {
                    component.set('v.buttonName', $A.get("$Label.c.Core_MDF_Retail_SubmitForApproval"));
                    component.set('v.buttonValue', 'Submit for Approval');
                    component.set('v.buttonToBeVisible', true);
                }       
                else if (result.userPermissionsPowerPartner && result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Approval'
                        && result.approverAssigned) {
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonToBeVisible', true);
                } 
                else {
                    component.set('v.buttonToBeVisible', false);
                }
                component.set('v.pfrMapInstance', result.pfrMapInstance);
            }
        });
            $A.enqueueAction(action);
    },

    //Function to validate the approval comments heave been entered or not
    checkApprovalComment: function (component, pfrId, btnType) 
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: $A.get("$Label.c.Core_MDF_Error"),
            type: 'error',
            message: $A.get("$Label.c.Core_MDF_Approval_Comment_Error") // Please provide a comment
        });
        toastEvent.fire();

    },

    //Function that will called on click of the button
    onClickButton: function (component, pfrId, btnType)
    {
            // Throw error only when rejection happens and comments are blank or empty or null
            if (btnType == $A.get("$Label.c.Core_MDF_Activity_Decline_Nm") && component.get("v.approvalComments") != null && $A.util.isEmpty(component.get("v.approvalComments").trim()))
            {
                 component.set("v.disablebuttonName",false);
                this.toastMessage($A.get("$Label.c.Core_MDF_Error"),$A.get("$Label.c.Core_MDF_Error"),$A.get("$Label.c.Core_MDF_Approval_Comment_Error"));
            }
            else{
                if (btnType == $A.get("$Label.c.Core_MDF_Retail_Approve") || btnType == $A.get("$Label.c.Core_MDF_Activity_Decline_Nm")) {
                        var mapInstance = component.get("v.pfrMapInstance");
                        var mapStatusInstance = component.get("v.statusMapInstance");

                        mapStatusInstance['Approval Action Comment'] = btnType; //component.get("v.approvalComments");
                        mapInstance[pfrId] = mapStatusInstance;
                        var aprAction = component.get("c.approveRejectActivity");
                        aprAction.setParams({
                        "mapValues": mapInstance,
                        "approvalComments" : component.get("v.approvalComments")
                        })

                        aprAction.setCallback(this, function (response) {
                            var stateSave = response.getState();
                            if(stateSave === "SUCCESS"){
                                var msgTxt = '';
                                if (btnType == $A.get("$Label.c.Core_MDF_Retail_Approve")) {
                                    msgTxt = $A.get("$Label.c.Core_MDF_Activity_Approved");
                                }  
                                else if (btnType == $A.get("$Label.c.Core_MDF_Activity_Decline_Nm")) {
                                    msgTxt = $A.get("$Label.c.Core_MDF_Activity_Decline_Msg");
                                } 
                            this.toastMessage($A.get("$Label.c.Core_MDF_Success"),$A.get("$Label.c.Core_MDF_Success"),msgTxt);
                            this.windowTimeOut();
                        }      
                        });    
                        $A.enqueueAction(aprAction);
                    }
                    else if (btnType == 'Submit for Approval') {

                        var pfrIDs = [];
                        pfrIDs.push(component.get("v.recordId"));

                        var action = component.get("c.submitForApproval");
                        action.setParams({
                        "pfrIds": pfrIDs
                        })
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                
                                this.toastMessage($A.get("$Label.c.Core_MDF_SuccessToastTitle"),$A.get("$Label.c.Core_MDF_Success"),$A.get("$Label.c.Core_MDF_Activity_SubmittedForApproval"));
                                this.windowTimeOut();
                            }
                        });
                        $A.enqueueAction(action);
                    }
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
            }), 3000
        );
    }
})