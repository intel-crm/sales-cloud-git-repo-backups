({
    retriggerAGSIdnetity : function(component, event, helper) {
        var action =component.get("c.getExistingContDetails");
        var acrRecordId =component.get("v.recordId");
        
        action.setParams({
            acrId : acrRecordId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result=[];
                component.set("v.contactMap",response.getReturnValue());
                var responseMap=new Map();  
                responseMap=component.get("v.contactMap");
                var conId;
                for (var key in responseMap){
                    conId = key;
                    console.log("key: " + key + ", value: " + responseMap[key]);
                    component.set("v.contactId",key); 
                    component.set('v.isEnterpriseIdexists',responseMap[key]);
                    console.log("key: " + component.get("v.contactId") + ", value: " + component.get("v.isEnterpriseIdexists"));                    
                }               
                var EnterpriseId =component.get('v.isEnterpriseIdexists');
                if(EnterpriseId == true){
                    component.set('v.message',$A.get("$Label.c.PRM_Enterprise_Id_Exist"));
                    component.set('v.hideConfirmButton',false);
                }else{
                    component.set('v.hideConfirmButton',true);
                    component.set('v.message',$A.get("$Label.c.PRM_RetriggerEV_Confirmation"));
                }                
                component.set('v.showConfirmDialog',true);
            }else{
                var error = 'Error has occured'
                component.set('v.message',error);
            }
        });
        $A.enqueueAction(action);
    },
    
    createAGSIdentity : function(component, event, helper) {
        var action =component.get("c.createIdentityInAGSSync");
        var conId =component.get("v.contactId");
        action.setParams({
            contactId : conId
        });
        action.setCallback(this,function(response){
      	var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                
            }else{
                var error = 'Error has occured'
                component.set('v.message',error);
            }
        });
        $A.enqueueAction(action);
        window.location.reload();
    },
})