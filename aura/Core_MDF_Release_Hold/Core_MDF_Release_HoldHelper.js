({
    //This method will check whether User has permission or not.
    fetchUserAndClaimDetails : function(component, event, helper){
        var action = component.get("c.fetchClaimHoldDetails");
        action.setParams({"pfcId" : component.get("v.recordId")});
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null){
                var wrapInst = response.getReturnValue();
                component.set("v.pfcRecord",wrapInst.pfc);
                if(wrapInst.exceptionDetails == null){
                    if(wrapInst.hasAccess){
                        if (this.notEligibleForRelease(component, event, helper)){ 
                            component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_ReleaseHold_ClaimCantBeReleased"));
                        }
                        else{
                            component.set("v.isUserEligibleToReleaseHold",true);
                            component.set("v.wrapperClassVar",wrapInst);
                            if(wrapInst.loggedInUserType==($A.get("$Label.c.Core_MDF_ReleaseHold_PartnerUserType"))){
                                component.set("v.isPartnerUser",true);
                            }
                            if(wrapInst.loggedInUserType==($A.get("$Label.c.Core_MDF_ReleaseHold_StandardUserType"))){
                                component.set("v.isStandardUser",true);
                            }
                        }
                    }
                    else{
                        component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_ReleaseHold_NoUserPermission"));
                    }
                }else{
                    component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
                }
            }
        });
        $A.enqueueAction(action);
    },

    
    //This method will be called when Internal user clicks on Proceed button to release Claim from Criteria or Manual Hold
    releaseHold : function(component, event, helper) {
        if (!component.get("v.Spinner")){
            component.set("v.Spinner", true);
        } 
        if(component.get('v.isPartnerUser')){
            component.set("v.pfcRecord.Core_MDF_Member_Manual_Hold_Ind__c",false);
        }
        if(component.get('v.isStandardUser')){
            if(component.get("v.isCriteriaChecked")){
            component.set("v.pfcRecord.Core_MDF_Criteria_Hold_Ind__c",false);
        	}
            
        	if(component.get("v.isIntManualChecked")){
            	component.set("v.pfcRecord.Core_MDF_Intel_Manual_Hold_Ind__c",false);
        	}

        	if(component.get("v.isMemManualChecked")){
            	component.set("v.pfcRecord.Core_MDF_Member_Manual_Hold_Ind__c",false);
        	}
        }
        var action = component.get("c.releaseHoldFromClaim");
        action.setParams({ 
            "pfclaim": component.get('v.pfcRecord'),
            "previousMembHold": component.get("v.wrapperClassVar.isOnMembManualHold"),
            "previousIntHold": component.get("v.wrapperClassVar.isOnIntManualHold"),
            "previousCriteriaHold": component.get("v.wrapperClassVar.isOnCriteriaHold")
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" && response.getReturnValue() == null){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.c.Core_MDF_SuccessMsgTitle"),
                    type: 'success',
                    message: $A.get("$Label.c.Core_MDF_ReleaseHold_ClaimSuccessfullyReleasedByIntel")
                });
                toastEvent.fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                setTimeout(function(){window.location.reload();},1000);
            }else{
                component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        });
        $A.enqueueAction(action);       
    },
    
    notEligibleForRelease : function(component, event, helper){
        var statusNotEligibleForReleaseHold = ($A.get("$Label.c.Core_MDF_ReleaseHold_ClaimStatusNotForReleasingHold")).split(";");
        if(statusNotEligibleForReleaseHold != null){
            if (statusNotEligibleForReleaseHold.includes(component.get("v.pfcRecord.Core_MDF_Status__c"))){
                return true;
            }
            else{
                return false;
            } 
        }
    }
})