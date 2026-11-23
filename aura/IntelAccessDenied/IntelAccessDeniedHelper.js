({
    loadPageContent: function(component, event, helper) {
        var libraryCmp = component.find("signInRedirectLibrary");
		var strSite = libraryCmp.whichSite();
        
        var sitearray = JSON.parse($A.get("$Label.c.PMP_SSO_Access_Denied_Message"));
        var jsonErrorLines = sitearray[strSite];
		component.set("v.lstLines", jsonErrorLines);
        component.set("v.blShowError", true);
    },

    /* US519636 */
    /* Forwarding to original page only works if the URL cookie is set.
     * This is set in Head Markup of the site.  If forwarding is not needed,
     * such as for Leads community, do not implement the Head Markup code */
    redirectPage: function(component, event, helper) {
        var libraryCmp = component.find("signInRedirectLibrary");

		var strSite = libraryCmp.whichSite();
        
		var enableLoginRedirect = '0';
        
        /* Feature toggle shared with MP Header */
        if(strSite == 'Marketplace') {
        	enableLoginRedirect = $A.get("$Label.c.PMP_SSO_MP_IGHF_Login_Redirect");
        } else if (strSite == 'Leads') {
            enableLoginRedirect = $A.get("$Label.c.PMP_SSO_Leads_IGHF_Login_Redirect");
        } else {
            return;
        }

        var loginFlag = false;
        if(enableLoginRedirect != '0') {
            loginFlag = true;
        }

        console.log('window.location.href: ' + window.location.href);
		//Do not run login when in Builder
        if((window.location.href.indexOf('livepreview') == -1)) {
            if(loginFlag == true) {
                libraryCmp.setSSOAttemptCookie(strSite);
                
                var redirectCookieName = libraryCmp.getCookieSetupInfo(strSite, 'AddressCookie');
                var redirectURL = libraryCmp.getRedirectCookie(redirectCookieName);
                
                if(redirectURL != "") {
                    var strADPage = libraryCmp.getCookieSetupInfo(strSite, 'AccessDeniedPage');
                    if(redirectURL.indexOf(strADPage) === -1) {
                        component.set("v.blShowError", false);
                        window.location=redirectURL;
                    }
                }
            }
        }
    },
})