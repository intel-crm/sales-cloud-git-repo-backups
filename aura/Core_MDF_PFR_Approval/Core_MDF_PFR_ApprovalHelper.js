({
    loadApprovalFlowAction: function (component, event, helper) {
        var result;

        var action = component.get("c.loadPFRRecord");
        action.setParams({
            "pfrId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
            //alert(JSON.stringify(result));
            if (result != null) {
                component.set('v.externalUser', result.userPermissionsPowerPartner);
                if (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review' && result.pfrInstance.Core_MDF_Region_cd__c.includes('EMEA') &&
                    !result.approverAssigned && !result.userPermissionsPowerPartner) {
                    //alert('inside');
                    component.set('v.buttonName', $A.get("$Label.c.Core_MDF_Retail_SubmitForApproval"));
                    component.set('v.buttonValue', 'Submit for Approval');
                    component.set('v.buttonToBeVisible', true);
                } else if (result.userPermissionsPowerPartner && result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Approval') {
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                } else {
                    component.set('v.buttonToBeVisible', false);
                }
                component.set('v.pfrMapInstance', result.pfrMapInstance);
            }
        });
        $A.enqueueAction(action);
    },
    onClickButton: function (component, pfrId, btnType) {
        //alert(btnType);
        if (btnType == 'Approve' || btnType == 'Reject') {
            var mapInstance = component.get("v.pfrMapInstance");
            var mapStatusInstance = component.get("v.statusMapInstance");

            mapStatusInstance['Approval Action Comment'] = btnType;
            mapInstance[pfrId] = mapStatusInstance;
            var aprAction = component.get("c.approveRejectActivity");
            aprAction.setParams({
                "mapValues": mapInstance
            })
            $A.enqueueAction(aprAction);

            aprAction.setCallback(this, function (response) {
                var state = response.getState();
                var approvalStatus = false;
                if (state === "SUCCESS") {
                    approvalStatus = response.getReturnValue();
                    var msgTxt = '';
                    if (btnType == 'Approve') {
                        msgTxt = $A.get("$Label.c.Core_MDF_Activity_Approved");
                    } else {
                        msgTxt = $A.get("$Label.c.Core_MDF_Activity_Rejected");
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.Core_MDF_SuccessToastTitle"),
                        type: 'success',
                        message: msgTxt
                    });
                    toastEvent.fire();

                    window.setTimeout(
                        $A.getCallback(function () {
                            window.location.reload();
                        }), 3000
                    );
                }
            });

        } else if (btnType == 'Submit for Approval') {

            var pfrIDs = [];
            pfrIDs.push(component.get("v.recordId"));

            var action = component.get("c.submitForApproval");
            action.setParams({
                "pfrIds": pfrIDs
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                var callApprovalSuccess = false;
                if (state === "SUCCESS") {
                    callApprovalSuccess = response.getReturnValue();

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.Core_MDF_SuccessToastTitle"),
                        type: 'success',
                        message: $A.get("$Label.c.Core_MDF_Activity_SubmittedForApproval")
                    });
                    toastEvent.fire();

                    window.setTimeout(
                        $A.getCallback(function () {
                            window.location.reload();
                        }), 3000
                    );
                }
            });
            $A.enqueueAction(action);
        }
    }
})