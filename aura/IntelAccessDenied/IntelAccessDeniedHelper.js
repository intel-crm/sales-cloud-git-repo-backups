({
    loadPageContent: function(component, event, helper) {
      var libraryCmp = component.find("ssoLibrary");
		  var site = libraryCmp.whichSite();  
      var sitearray = JSON.parse($A.get("$Label.c.PMP_SSO_Access_Denied_Message"));
      var jsonErrorLines = sitearray[site];
		  component.set("v.lstLines", jsonErrorLines);
      component.set("v.blShowError", true);
    },

    /* US519636 */
    /* Forwarding to original page only works if the URL cookie is set.
     * This is set in Head Markup of the site.  If forwarding is not needed,
     * such as for Leads community, do not implement the Head Markup code */
    redirectPage: function(component, event, helper) {
      var libraryCmp = component.find("ssoLibrary");
      
      var site = libraryCmp.whichSite();
      if (!site) {
        return;
      }

      // Exit if no settings returned
      var ssoSettings = libraryCmp.getSSOSettings(site);
      if (!ssoSettings) {
        return;
      }

      var loginFlag = ssoSettings.ighf.loginRedirect !== '0';

		  //Do not run login when in Builder
      if (window.location.href.indexOf('livepreview') === -1 && loginFlag) {
        libraryCmp.setSSOAttemptCookie(site);
        
        var redirectCookieName = libraryCmp.getCookieInfo('AddressCookie', site);
        var redirectURL = libraryCmp.getCookieValue(redirectCookieName);
        
        if(redirectURL != "") {
          var strADPage = libraryCmp.getCookieInfo('AccessDeniedPage', site);
          if (redirectURL.indexOf(strADPage) === -1) {
              component.set("v.blShowError", false);
              window.location=redirectURL;
          }
        }
      }
    },
})