({
    doInit : function(component, event, helper) {
        debugger;
        var toBeRedirected = $A.get("$Label.c.CustomerDisclaimerRedirectInd");
        if(toBeRedirected == 'true'){
            helper.redirectUserToTnCPage(component);
        }
        
    }
})