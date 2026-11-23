({
    setUserLangLocale: function(component, event, helper) {
        var userLangLocale = $A.get("$Locale.langLocale");
        
        switch (userLangLocale)
        {
            case "ja":
                userLangLocale = "ja_JP";
                break;
            case "fr":
                userLangLocale = "fr_FR";
                break;
            case "de":
                userLangLocale = "de_DE";
                break;
            case "ko":
                userLangLocale = "ko_KR";
                break;
            case "es":
                userLangLocale = "es_ES";
                break;
            case "it":
                userLangLocale = "it_IT";
                break;
            case "ru":
                userLangLocale = "ru_RU";
                break;
        }      

        window.INTELNAV = window.INTELNAV || {};
        window.INTELNAV.renderSettings = {version:"2.0 - 03/12/2017 08:00:00",textDirection:"ltr",culture:userLangLocale,OutputId:"default"};

        //************ Do not allow authenticated users to switch to another language
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        if(!($A.util.isEmpty(userId) || $A.util.isUndefined(userId))){
            INTELNAV.dashboard = "";
        }
    },
    
    /* Initial redirect if successful SSO is detected from the IGHF header */
    redirectSSO: function(component, event, helper) {
		var libraryCmp = component.find("signInRedirectLibrary");

        var strSite = libraryCmp.whichSite();
        
		var enableLoginRedirect = '0';
        var enableLogoutRedirect = '0';
        var SSOLoginUrl = '';
        var SSOLogoutUrl = '';
        
        if(strSite == 'Marketplace') {
        	enableLoginRedirect = $A.get("$Label.c.PMP_SSO_MP_IGHF_Login_Redirect");
            enableLogoutRedirect = $A.get("$Label.c.PMP_SSO_MP_IGHF_Logout_Redirect");
            SSOLoginUrl = $A.get("$Label.c.PMP_SSO_MP_Login_URL");
            SSOLogoutUrl = $A.get("$Label.c.PMP_SSO_MP_Logout_URL");
        } else if (strSite == 'Leads') {
            enableLoginRedirect = $A.get("$Label.c.PMP_SSO_Leads_IGHF_Login_Redirect");
            enableLogoutRedirect = $A.get("$Label.c.PMP_SSO_Leads_IGHF_Logout_Redirect");
            SSOLoginUrl = $A.get("$Label.c.PMP_SSO_Leads_Login_URL");
            SSOLogoutUrl = $A.get("$Label.c.PMP_SSO_Leads_Logout_URL");
        } else {
            return;
        }

        var loginFlag = false;
        if(enableLoginRedirect != '0') {
            loginFlag = true;
        }

        var logoutFlag = false;
        if(enableLogoutRedirect != '0') {
            logoutFlag = true;
        }
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        var cookiename = 'SMSESSION';
        var cookieres = "";
   		cookieres = libraryCmp.getRedirectCookie(cookiename);
        if(cookieres == "") {
            cookieres = 'SMSessionNotExist';
        }

        var isADPage = this.isAccessDeniedPage(libraryCmp, strSite);
        var wasSSOAttempted = libraryCmp.checkSSOAttempt(strSite);
        
        if(loginFlag == true
           && userId == undefined
           && cookieres != 'SMSessionNotExist'
           && isADPage == false
           && wasSSOAttempted == false) {
            var relayStateParam = '?RelayState=';
            var subPath = window.location.pathname;
            var encodedUrl = encodeURIComponent(subPath);
            var redirectUrl = SSOLoginUrl+relayStateParam+encodedUrl;
            window.location=redirectUrl;
        } else if(logoutFlag == true
                  && userId != undefined
                  && cookieres == 'SMSessionNotExist') {
            if((window.location.href.indexOf('commeditor') > -1) || (window.location.href.indexOf('view=editor') > -1)){
            } else {
                window.location = SSOLogoutUrl;
            }
        }
    },
    
    /* US519636 */
    isAccessDeniedPage: function(libraryCmp, strSite) {
  		var isADPage = false;
        var strHref = window.location.href;

        var strADPage = libraryCmp.getCookieSetupInfo(strSite, 'AccessDeniedPage');
        if(strHref.indexOf(strADPage) >= 0) {
            isADPage = true;
        }
        
        return isADPage;
	},
})