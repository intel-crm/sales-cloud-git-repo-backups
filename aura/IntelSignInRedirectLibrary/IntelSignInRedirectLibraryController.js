({
    whichSite : function(component, event, helper) {
        return helper.whichSite();
	},
    
    getRedirectCookie : function(component, event, helper) {
        return helper.getRedirectCookie(component, event, helper);
	},

	setSSOAttemptCookie : function(component, event, helper) {
        return helper.setSSOAttemptCookie(component, event, helper);
	},
    
    checkSSOAttempt : function(component, event, helper) {
        return helper.checkSSOAttempt(component, event, helper);
	},
    
    getCookieSetupInfo : function(component, event, helper) {
        return helper.getCookieSetupInfo(component, event, helper);
	},
})