({
    doInit : function(component, event, helper) { 
        helper.isProposalBasedMethod(component.get("c.isAccountBased"), {
            recordId: component.get("v.recordId")
        }).then(function (res) {
            console.log('####'+res);
            if( res == true){
                component.set("v.isProposalBased",false);
            }
            else{
                component.set("v.isProposalBased",true);
                helper.checkUserType(component, event, helper);
                helper.getActivitiesList(component, event, helper);
            }
        });
    },
    handleToastEvent :function(component, event, helper){
        
        const toastMessage = event.getParam("message");        
        const campaignMessage = $A.get("$Label.c.Core_MDF_CampaignSaveToast");//Campaign
        const campaignSavedMessage = $A.get("$Label.c.Core_MDF_CampaignToast");//has been saved
        const campaignApproved = $A.get("$Label.c.Core_MDF_Campaign_was_approved");
        const campaignRejected = $A.get("$Label.c.Core_MDF_Campaign_was_rejected");
        const campaignCancelled = $A.get("$Label.c.Core_MDF_Campaign_has_been_cancelled");
        
        if((toastMessage.includes(campaignMessage) && toastMessage.includes(campaignSavedMessage)) ||
           toastMessage.includes(campaignApproved) ||
           toastMessage.includes(campaignRejected) ||
           toastMessage.includes(campaignCancelled)){            
            $A.enqueueAction(component.get("c.doInit"));            
        }
    },
    callCreateEditPFR : function(component, event, helper){
        
        const pfrId = event.getSource().get("v.value");
        component.set("v.requestId",pfrId);        
        component.set("v.CheckEdit",true);        
    },
    
    callCreateEditActivity : function(component, event, helper){
        
        const pfrId = event.getSource().get("v.value");
        component.set("v.requestId",pfrId);        
        component.set("v.CheckEditActivity",true);        
    },
    callCreatePFC : function(component, event, helper){
        
        const pfrId = event.getSource().get("v.value");
        component.set("v.requestId",pfrId);        
        component.set("v.CheckClaimCreate",true);        
    },
    closeModal: function(component, event, helper) {
        
        const homeEvent = $A.get("e.force:navigateToSObject");
        
        const campaignId = component.get("v.recordId");
        homeEvent.setParams({
            "recordId": campaignId,
            "slideDevName": "detail"
        });
        homeEvent.fire();
    },
})