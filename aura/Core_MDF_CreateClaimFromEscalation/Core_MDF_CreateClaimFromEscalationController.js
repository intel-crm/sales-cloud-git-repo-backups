({
    doInit : function(component, event, helper) {
          
            helper.checkCreateClaim(component, helper);
            helper.checkUserAccess(component,event,helper);
         
        }, 
})