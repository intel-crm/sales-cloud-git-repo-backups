({
    setUserLangLocale: function(component, event, helper) {
        var libraryCmp = component.find("ssoLibrary");
        var intelLanguage = libraryCmp.getCookieValue("PrefLangIETF");
        var userLangLocale = '';

        if (intelLanguage) {
            userLangLocale = intelLanguage;
        } else {
            userLangLocale = $A.get("$Locale.langLocale");
            switch (userLangLocale)
            {
              case "de":
                userLangLocale = "de_DE";
                break;
              case "en_GB":
                userLangLocale = "en_UK";
                break;
              case "en_SG":
                userLangLocale = "en_XA";
                break;
              case "es":
                userLangLocale = "es_ES";
                break;
              case "es_MX":
                userLangLocale = "es_XL";
                break;
              case "fr":
                userLangLocale = "fr_FR";
                break;
              case "in":
                userLangLocale = "id_ID";
                break;
              case "it":
                userLangLocale = "it_IT";
                break;
              case "ja":
                userLangLocale = "ja_JP";
                break;
              case "ko":
                userLangLocale = "ko_KR";
                break;
              case "pl":
                userLangLocale = "pl_PL";
                break;
              case "ru":
                userLangLocale = "ru_RU";
                break;
              case "th":
                userLangLocale = "th_TH";
                break;
              case "tr":
                userLangLocale = "tr_TR";
                break;  
              case "vi":
                userLangLocale = "vi_VN";
                break;
            }
        }

        window.INTELNAV = window.INTELNAV || {};
        window.INTELNAV.renderSettings = {
          version: "2.0 - 03/12/2017 08:00:00",
          textDirection: "ltr",
          culture: userLangLocale,
          OutputId: "default"
        };

        //************ Do not allow authenticated users to switch to another language
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        if(!($A.util.isEmpty(userId) || $A.util.isUndefined(userId))){
          if (window.INTELNAV.dashboard && window.INTELNAV.dashboard.languageSelector) {
            window.INTELNAV.dashboard.languageSelector = '';
          }
        }
    },
    
    /* Initial redirect if successful SSO is detected from the IGHF header */
    redirectSSO: function(component, event, helper) {
      var signInLibrary = component.find("ssoLibrary");
      
      let enableLoginRedirect = '0';
      let enableLogoutRedirect = '0';
      let SSOLoginUrl = '';
      let SSOLogoutUrl = '';

      // Get the site/community
      var site = signInLibrary.whichSite();
      if (!site) {
        return;
      }

      var ssoSettings = signInLibrary.getSSOSettings(site);
      if (ssoSettings) {
        enableLoginRedirect = ssoSettings.ighf.loginRedirect;
        enableLogoutRedirect = ssoSettings.ighf.logoutRedirect;
        SSOLoginUrl = ssoSettings.ighf.loginUrl;
        SSOLogoutUrl = ssoSettings.ighf.logoutUrl;
      } else {
        return;
      }

      var smSessionCookie = signInLibrary.getCookieValue('SMSESSION') || 'SMSessionNotExist';
      var isADPage = this.isAccessDeniedPage(signInLibrary, site);
      var loginFlag = enableLoginRedirect !== '0';
      var logoutFlag = enableLogoutRedirect !== '0';
      var userId = $A.get('$SObjectType.CurrentUser.Id');
      var wasSSOAttempted = signInLibrary.checkSSOAttempt(site);
      
      if (loginFlag === true && userId === undefined && smSessionCookie !== 'SMSessionNotExist' && isADPage === false && wasSSOAttempted === false) {
        // Force the user to login page
        var encodedUrl = encodeURIComponent(window.location.pathname);
        var redirectUrl = SSOLoginUrl + '?RelayState=' + encodedUrl;
        window.location = redirectUrl;
      } else if (logoutFlag === true && userId !== undefined && smSessionCookie === 'SMSessionNotExist'
      && !(window.location.href.indexOf('commeditor') > -1 || window.location.href.indexOf('view=editor') > -1)) {
        // Force to logout
        window.location = SSOLogoutUrl;
      }
    },
    
      
    /* US519636 */
    isAccessDeniedPage: function(libraryCmp, site) {
  		var isADPage = false;
      var strHref = window.location.href;

      var strADPage = libraryCmp.getCookieInfo('AccessDeniedPage', site);
      if(strHref.indexOf(strADPage) >= 0) {
          isADPage = true;
      }
      
      return isADPage;
	},
})