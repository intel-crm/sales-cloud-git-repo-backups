({
	init : function(component, event, helper) {
		var action = component.get("c.isEVSuccess");
        var regId = component.get("v.recordId");
        
        action.setParams({
            regRequestID : regId
        });
        action.setCallback(this, function(data){
            var state= data.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result = data.getReturnValue();                
                component.set('v.isEVSuccess',result);
                console.log(result);
                if(result == true){
                    component.set('v.message',$A.get("$Label.c.PRM_SendInvite_Confirmation"));
                }else{
                    component.set('v.message',$A.get("$Label.c.PRM_RetriggerEV_Confirmation"));
                }                
                component.set('v.showConfirmDialog',true);
            }
            else{
                var error = 'Error has occured'
                component.set('v.message',error);
            }
        });
         $A.enqueueAction(action);
	},
    
    retriggerEmail:function(component) {
		var isEVSuccess = component.get('v.isEVSuccess');
        if(isEVSuccess == true){
            this.sendInviteEmail(component);
        }else{
            this.retriggerEV(component);
        }
	},
    
    retriggerEV : function(component) {
		var action = component.get("c.Retrigger_EV");
        var regId = component.get("v.recordId");
        
        action.setParams({
            endDate : null,
            LoginID : null,
            BizOrgType : null,
            fromComponent : true,
            regRequestId : regId
        });
        action.setCallback(this, function(data){
            var state= data.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result = data.getReturnValue();
                component.set('v.statusMessage',result);                
            }
            else{
                var error = 'Error has occured'
                component.set('v.statusMessage',error);
            }
            var cmpTarget = component.find('statusMessageDiv');
            $A.util.addClass(cmpTarget, 'setHeight');
            component.set('v.showConfirmDialog',false);
        });
         $A.enqueueAction(action);
	},
    
    sendInviteEmail : function(component) {
		var action = component.get("c.sendInviteEmail");
        var regRequestId = component.get("v.recordId");
        
        action.setParams({
            regRequestID : regRequestId           
        });
        action.setCallback(this, function(data){
            var state= data.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result = data.getReturnValue();
                component.set('v.statusMessage',result);                
       		}
            else{
                var error = 'Error has occured'
                component.set('v.statusMessage',error);                
            }
            var cmpTarget = component.find('statusMessageDiv');
            $A.util.addClass(cmpTarget, 'setHeight');
            component.set('v.showConfirmDialog',false);
        });
        
        $A.enqueueAction(action);
	},
})