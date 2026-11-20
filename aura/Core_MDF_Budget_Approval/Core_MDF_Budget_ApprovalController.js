({
    doInit: function (component, event, helper) {
        console.log('Custom Approve/Reject Component');
        helper.call(component.get("c.loadBudgetecord"), {
            budgetId: component.get("v.recordId")
        }).then(function (result) {
            console.log('result--> ', result);
            if(result.isCustomPermissionAssigned &&  result.isBudgetApprover){
                component.set('v.buttonToBeVisible', true);
                component.set('v.budgetMapInstance', result);
            }
        }).catch(function (error) {
            console.log('error--> ', error);
            let applicationErrorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
            helper.toastMessage($A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_Error"), applicationErrorMessage);
        });
    },

    approvalAction: function (component, event, helper) {
        var btnvalue = event.getSource().get("v.label");
        console.log('btnvalue--> ', btnvalue);
	    component.set('v.btnValue',btnvalue);
        if (btnvalue == $A.get("$Label.c.Core_MDF_Retail_Approve")) {
            component.set('v.commentType', 'Approve Budget');    
        } else if (btnvalue == $A.get("$Label.c.Core_MDF_Retail_Reject")) {
            component.set('v.commentType', 'Reject Budget');     
        }
        component.set('v.showApprovalCommentSection', true);
    },

    closeModal: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },

    //Function that will called on click of the save button
    callApprovalProcessAndUpdateField : function (component, event, helper) {
        component.set("v.loadSpinner", true);
        console.log('budgetId--> ', component.get("v.recordId"));
        var mapInstance = {};
        mapInstance = component.get("v.budgetMapInstance");
        var btnValue = component.get("v.btnValue");
        mapInstance.btnAction = btnValue;
        mapInstance.btnActionComment = component.get("v.approvalComments");
        console.log('mapInstance--> ', mapInstance);

        helper.call(component.get("c.approveRejectBudget"), {
            mapValues: mapInstance
        }).then(function (result) {
            component.set("v.loadSpinner", false);
            console.log('approveRejectBudgetresult--> ', result);
            var msgTxt = '';
            component.set("v.showApprovalCommentSection", false);
            if(result == 'SUCCESS'){
                if (btnValue == 'Approve') {
                    msgTxt = 'Budget was approved';
                }  
                else if (btnValue == 'Reject') {
                    msgTxt = 'Budget was rejected';
                }
                helper.toastMessage($A.get("$Label.c.Core_MDF_Success"), 'success', msgTxt);
                helper.windowTimeOut();
            } else if (result == 'FAILED'){
                var msg = 'User cannot Approve the Budget Anymore.';
                helper.toastMessage($A.get("$Label.c.Core_MDF_Error"),$A.get("$Label.c.Core_MDF_Error"),msg);
                helper.windowTimeOut(); 
            } else {
                let applicationErrorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                helper.toastMessage($A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_Error"), applicationErrorMessage);
                helper.windowTimeOut();
            }
        }).catch(function (error) {
            console.log('error--> ', error);
            let applicationErrorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
            helper.toastMessage($A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_Error"), applicationErrorMessage);
        });
        $A.get("e.force:closeQuickAction").fire();
    }     
})