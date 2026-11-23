({
    doInit : function(component, event, helper) {
         helper.checkManualCreateClaim(component, helper);
         helper.checkPermissionToCreateClaim(component, event, helper);
         helper.checkCreateClaim(component, helper);
        }, 
})