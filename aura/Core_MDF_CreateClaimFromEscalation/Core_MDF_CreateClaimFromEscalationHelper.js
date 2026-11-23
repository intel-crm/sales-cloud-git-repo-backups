({
    
    checkUserAccess: function(component,event,helper){
      var action = component.get("c.getEscalationFields");
        var escRecord = component.get("v.recordId");  
        console.log('esc record is '+escRecord);
        action.setParams({
            escRecord : escRecord
        }); 
        action.setCallback(this, function(response){
            
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){
                
                var result = response.getReturnValue();
                component.set("v.Spinner", false); 
                var chkPerm = result.usrHasPer;
                if(chkPerm){
                    component.set("v.renderModal",true);
                    component.set("v.isUserEligible",true);
                }else{
                    component.set("v.renderModal",true);
                    component.set("v.showErr",true);
                    component.set("v.isUserEligible",false);
                }
                if(result.caseReviewEsc && result.mysteryShopperUser){
                    component.set("v.isUserEligible",false);
                    component.set("v.showErr",true);
                }else if(result.doNotAutoCreateClaim){
                    component.set("v.chkbox",true);
                    component.set("v.usrNotEligible",false);
                }
                else{                    
                    component.set("v.chkbox",false);
                } 
                component.set("v.programName",result.programName);
            }
        }),
        $A.enqueueAction(action);
    },
    
    checkCreateClaim : function(component, event, helper) {
        var action = component.get("c.checkEscLateClaimCreation");
        var escRecord = component.get("v.recordId");  
        console.log('esc record is'+escRecord);
        action.setParams({
            RecordId : escRecord
        });
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){ 
                var createClaimError = response.getReturnValue();
                
                if(createClaimError == 'SUCCESS'){
                    component.set("v.canCreateClaim",true);
                }
                else{
                    component.set("v.claimCreationError",createClaimError);
                    component.set("v.canCreateClaim",false);
                }
            }
        }),
        $A.enqueueAction(action);
    }

})