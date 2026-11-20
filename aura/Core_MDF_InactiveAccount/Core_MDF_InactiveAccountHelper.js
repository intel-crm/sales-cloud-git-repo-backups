({
    //This method will check whether User is eligible for inactivation.
    checkUserPermission : function(component, event, helper) {
        const action = component.get("c.isUserEligibiletoInactivate");
        action.setCallback(this, function(response){  
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null){
				if(response.getReturnValue()){
                    component.set("v.isUserEligible",true);
                }
				else{
                    component.set("v.isAccountNotEligibleForInactivation",true);
                	component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_UserPermissionToInactivate"));
             	}     
           }
        });
        $A.enqueueAction(action);
    },
    
    //This method is used to check differect account validations
    checkAccountEligibiltyForInactivation : function(component, event, helper) {
        const action2 = component.get("c.isAccountEligibileForInactivation");
        action2.setParams({"accId" : component.get("v.recordId")});
        action2.setCallback(this, function(response){
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){ 
                const wrapInst = response.getReturnValue();
                //var accntid = component.get("v.recordId");
                component.set("v.isUserEligible",false);
                component.set("v.wrapperClassVar",wrapInst);
				component.set("v.countOfClaimRecords",wrapInst.claimCount);
                component.set("v.countOfActivityRecords",wrapInst.activityCount);
                component.set("v.countOfCampaignRecords",wrapInst.campaignCount);
                
                if(wrapInst.isTopVirtualNode){
                    component.set("v.isAccountNotEligibleForInactivation",true);
                    component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_Account_is_Top_Virtual_Node"));
                }
                else if(wrapInst.isDeactivated){
                    component.set("v.isAccountNotEligibleForInactivation",true);
                    component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_Account_is_already_Deactivated"));
                }
                else if(wrapInst.isAutoTransferAccount || wrapInst.hasAllocation || wrapInst.hasActiveClaims || wrapInst.hasBankmappings || wrapInst.hasActivities || wrapInst.hasOpenEscalationRecords || wrapInst.hasCampaigns){
                    component.set("v.isAccounthasActiveTransac",true);
                    if(wrapInst.isAutoTransferAccount){
                        component.set("v.accountIsAutoTransferAccount",$A.get("$Label.c.Core_MDF_Account_is_used_as_Auto_Transfer_Account"));
                    }
                    if(wrapInst.hasAllocation){
                        component.set("v.accounthasAllocation",$A.get("$Label.c.Core_MDF_Account_has_allocations")); 
                    }
                    if(wrapInst.hasActiveClaims){
                        component.set("v.accounthasActiveClaim",$A.get("$Label.c.Core_MDF_Account_has_active_claims"));  
                    }
                    if(wrapInst.hasActivities){
                        component.set("v.accounthasActivities",$A.get("$Label.c.Core_MDF_Account_has_activities"));
                    }
                    if(wrapInst.hasBankmappings){
                        component.set("v.accounthasBankMapping",$A.get("$Label.c.Core_MDF_Account_is_mapped_to_Bank"));  
                    }
                    if(wrapInst.hasOpenEscalationRecords){
                        component.set("v.accounthasOpenEscalations",$A.get("$Label.c.Core_MDF_Account_has_open_escalations"));
                    }
                    if(wrapInst.hasCampaigns){
                        component.set("v.accounthasCampaigns",$A.get("$Label.c.Core_MDF_Account_has_Campaigns"));
                    }   
                }
                else{
                    const toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.Core_MDF_InactAccount_Success_Toast_Title"),
                        type: 'success',
                        message: $A.get("$Label.c.Core_MDF_InactAccount_Success_Toast_Message")
                    });
                    toastEvent.fire();
                    const navEvt = $A.get("e.force:navigateToSObject");
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