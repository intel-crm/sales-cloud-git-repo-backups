({
  checkSSOAttempt : function(component, event, helper) {
    var ssoLibrary = helper.getSSOLibrary(component);
    var params = event.getParam("arguments");
    return ssoLibrary.checkSSOAttempt(params.siteName);
  },
    
  getCookieSetupInfo : function(component, event, helper) {
    var ssoLibrary = helper.getSSOLibrary(component);
    var params = event.getParam("arguments");
    return ssoLibrary.getCookieInfo(params.siteAttribute, params.siteName);
  },

  getRedirectCookie : function(component, event, helper) {
    var ssoLibrary = helper.getSSOLibrary(component);
    var params = event.getParam("arguments");
    return ssoLibrary.getCookieValue(params.cookieName);
	},

	getSSOSettings : function(component, event, helper) {
    var ssoLibrary = helper.getSSOLibrary(component);
    var params = event.getParam("arguments");
    return ssoLibrary.getSSOSettings(params.siteName);
  },
    
  setSSOAttemptCookie : function(component, event, helper) {
    var ssoLibrary = helper.getSSOLibrary(component);
    var params = event.getParam("arguments"); 
    return ssoLibrary.setSSOAttemptCookie(params.siteName);
	},
    
  whichSite : function(component, event, helper) {
    var ssoLibrary = helper.getSSOLibrary(component);
    return ssoLibrary.whichSite();
	},
})