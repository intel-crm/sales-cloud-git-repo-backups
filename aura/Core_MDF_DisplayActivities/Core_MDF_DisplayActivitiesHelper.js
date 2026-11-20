({
    checkUserType : function(component, event, helper) {        
        
        const action = component.get("c.checkUserType");
        action.setParams({isProposalBased: component.get("v.isProposalBased")});
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){ 
                
                const wrapInst = response.getReturnValue();
                if(wrapInst.isInternalUser){
                    component.set("v.isInternalUser",true);
                }else{
                    component.set("v.isInternalUser",false);
                }
                
                if(wrapInst.activityEditAccess){
                    component.set("v.isActivityEditable",true);
                }else{
                    component.set("v.isActivityEditable",false);
                }
                
                if(wrapInst.claimCreateAccess){
                    component.set("v.isClaimCreatable",true);
                }else{
                    component.set("v.isClaimCreatable",false);
                }

                if(wrapInst.hasIPAAccountManagerPS){
                component.set("v.hasIPAAccountManagerPS",true);
                }else{
                    component.set("v.hasIPAAccountManagerPS",false);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getActivitiesList : function(component, event, helper) {
        
        const recId = component.get("v.recordId");
        const action = component.get("c.getActivityRecords");
        let activityList = [];
        
        action.setParams({recordId: recId});
        action.setCallback(this, function(response){

            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){
                activityList = response.getReturnValue();
            }            
            if(activityList != null && activityList.length > 0){
                component.set("v.programName", activityList.Core_MDF_Program__c);
                component.set("v.pfrList",activityList); 
                component.set("v.isPFRAvailable",true); 
            }
            
        });
        $A.enqueueAction(action);
    },
    /*isAccountBasedMethod : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.isAccountBased");
        var acctbsdind;
        action.setParams({recordId: recId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                // component.set('v.isAccountBasd', response.getReturnValue());
                console.log('acct BAsed' +response.getReturnValue());
                acctbsdind = response.getReturnValue();
            }
        });
        $A.enqueueAction(action);
        console.log('####'+acctbsdind);
        return acctbsdind;
    },*/
    isProposalBasedMethod : function(action, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            if(params){
                action.setParams(params);
            }
            action.setCallback(this, function(a){
                if(a.getState() == "SUCCESS"){
                    resolve(a.getReturnValue());
                } else {
                    reject(a.getError());
                }
           });
           $A.enqueueAction(action);
        }));
    }
})