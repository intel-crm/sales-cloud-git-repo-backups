({
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
                }     
            }
        });
        $A.enqueueAction(action);
    },
})