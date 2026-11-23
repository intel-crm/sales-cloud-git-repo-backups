({
    //This method will get details of users in group
    getDetailsOfUsersInGroup : function(component, event, helper) {   
        if (!component.get("v.Spinner")){
            component.set("v.Spinner", true);
        } 
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getUserDetails");
        action.setParams({"userId" : userId,
            "internalAuditRecId": component.get("v.recordId")
                         });
        action.setCallback(this, function(response){  
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null){ 
                component.set("v.Spinner", false);                
                if(!response.getReturnValue()){                    
                    component.set("v.isStandardUser",true);
                }
                else{                    
                    //component.set("v.isLinkGenerated",true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        type: 'success',
                        message: 'Downloaded Successfully and attached in Files in Related Tab'
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    setTimeout(function(){window.location.reload();},1000);
                }                
            }
        });
        $A.enqueueAction(action);
    }
})