({
    checkManualCreateClaim : function(component, escRecord) { 
        var action = component.get("c.getEscalationFields");
        var escRecord = component.get("v.recordId");       
        // Setting the parameters to send to the apex controller method
        action.setParams({
            escRecord : escRecord
        });
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){ 
                var doNotAutoCreateClmUnchkd = response.getReturnValue();
                
                if(doNotAutoCreateClmUnchkd){
                    component.set("v.chkbox",true);
                    component.set("v.usrNotEligible",false);
                }
                else{
                    component.set("v.chkbox",false);
                }     
            }
        }),
        $A.enqueueAction(action);
    },
    checkPermissionToCreateClaim : function(component, event, helper) {
        var action = component.get("c.isUserEligibletoCreateClaim");
        //to make the server response cacheable
        action.setStorable();
        action.setCallback(this, function(response){
            component.set("v.renderModal",true);
            
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){ 
                var spn = component.set("v.Spinner", false); 
                var chkPerm = response.getReturnValue();
                if(chkPerm){
                    component.set("v.isUserEligible",true);
                }
                else{
                    component.set("v.isUserEligible",false);
                    component.set("v.showErr",true);
                }     
            }            
        });
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