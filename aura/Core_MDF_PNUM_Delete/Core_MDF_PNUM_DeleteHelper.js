({
    //This is to check if the Delete button has to be made eligible to the user on the Pnum record
    doInit : function(component, event, helper) {
        var action = component.get("c.isAccountUserEligibleForDelete");     
        action.setParams({accountUserId : component.get('v.recordId')});
        action.setCallback(this, function(response){            
            
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var result = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(result) && result == true){
                    component.set("v.showDeleteAccountUser",result);
                }
                else if(result == false){
                    component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_AccountUser_Cannot_Be_Deleted'));                    
                }
            }
            else if(state === "ERROR"){
                console.log("Error: ", response.getError());
                component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_AccountUser_Delete_Error'));                    
            }
            
        });
        $A.enqueueAction(action);
    },
    //This is to call the Delete Account User Method
    deleteAccountUser : function(component, event, helper) {
        
        var action = component.get("c.deleteAccountUsers");  
        var listOfAccountUser = component.get('v.recordId');
        action.setParams({accountUserIdList : listOfAccountUser});
        action.setCallback(this, function(response){            
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var success = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(success) && success == true){
                    //close other toasts 
                    var errorToast = component.find('errorToast');        
                    $A.util.addClass(errorToast, "slds-hide");
                    var cmpTarget = component.find('toast');
                    $A.util.removeClass(cmpTarget, 'slds-hide');   
                    window.setTimeout($A.getCallback(function() {
                        if(component.isValid()) {
                            $A.util.addClass(cmpTarget, "slds-hide");
                        }
                    }), component.get("v.fadeTimeout"));
                    
                    var objName = $A.get("$Label.c.Core_MDF_AccountUserText");
                    var homeEvent = $A.get("e.force:navigateToObjectHome");
                    homeEvent.setParams({
                        "scope": objName
                    });
                    homeEvent.fire();
                }
                
            }
            else if(state === "ERROR"){ 
                console.log("Error: ", response.getReturnValue());
                //close other toasts 
                var successToast = component.find('toast');
                $A.util.addClass(successToast, 'slds-hide');
                
                component.set("v.Spinner",false);
                var errToast = component.find('errorToast');
                component.set("v.errorMsg", response);
                $A.util.removeClass(errToast, 'slds-hide');                                      
                window.setTimeout($A.getCallback(function() {
                    if(component.isValid()) {
                        $A.util.addClass(errToast, "slds-hide");
                    }
                }), component.get("v.fadeTimeout"));
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    /*page refresh after data save*/
    
    isRefreshed: function(component, event, helper) {
        location.reload();
    },/*page refresh after data save*/
    
})