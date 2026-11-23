({
    /**
    	This utility library was developed for US519636
    */
    
    /** Identify which community site this is by the URL
    * Returns the site name based on the URL stored in PMP_SSO_Site_Identifier
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	* @return {String} The site name as a string.
  	*/
    whichSite: function() {
        var strHref = window.location.href;
        
        var sitearray = JSON.parse($A.get("$Label.c.PMP_SSO_Site_Identifier"));
        
        var strSite = '';
        for(var i = 0; i < sitearray.length; i++) {
            if(strHref.indexOf(sitearray[i].URL) >= 0) {
                strSite = sitearray[i].Site;
                break;
            }
        }
        console.log('whichSite: ' + strSite);
        return strSite;
    },

    /** Get attributes used for cookie processing which are stored in PMP_SSO_Cookies.
    * This is a wrapper on getCookieInfo
    * Returns the attribute value based on the site name
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	* @return {String} The attribute value as a string.
  	*/
    getCookieSetupInfo: function(component, event, helper) {
        var params = event.getParam("arguments");
		return this.getCookieInfo(params.siteName, params.siteAttribute);
    },

    /** Get attributes used for cookie processing which are stored in PMP_SSO_Cookies
    * Returns the attribute value based on the site name
   	* String strSite: Name of the site.
   	* String strName: Name of the attribute.
  	* return {String}: The attribute value as a string.
  	*/
    getCookieInfo: function(strSite, strName) {
        var sitearray = JSON.parse($A.get("$Label.c.PMP_SSO_Cookies"));
        var jsonSite = sitearray[strSite];
        if (jsonSite != undefined) {
            jsonValue = jsonSite[strName];
            if(jsonValue != undefined) {
                return jsonValue;
            }
        }
        return "";
    },

    /** Gets a cookie value.
    * Returns the cookie value based on the cookie name
    * This is wrapper for getCookieUtility
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	* @return {String} The attribute value as a string.
  	*/
    getRedirectCookie: function(component, event, helper) {
        var params = event.getParam("arguments");
        return this.getCookieUtility(params.cookieName);
    },

    /** Gets a cookie value.
    * Returns the cookie value based on the cookie name
   	* String cname: Cookie name
  	* return {String}: The cookie value
  	*/
    getCookieUtility: function(cname) {
		var name = cname + "=";
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        for(var i = 0; i <ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    },

    /** Set a cookie to indicate SSO was already attempted and failed.
    * This is implied when a user has visited the Accees Denied page.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	* No return value
  	*/
    setSSOAttemptCookie: function(component, event, helper) {
        var params = event.getParam("arguments");

        var cname = this.getCookieInfo(params.siteName, 'SSOAttemptedCookie');
        document.cookie = cname + "=true;path=/";
	},

    /** Checks if SSO was attempted by looking up the cookie set by setSSOAttemptCookie().
    * Returns the true or false based on existance of the cookie
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	* @return {Object} true or false
  	*/
    checkSSOAttempt: function(component, event, helper) {
        var params = event.getParam("arguments");
        
  		var wasAttempted = false;

        var cookieName = this.getCookieInfo(params.siteName, 'SSOAttemptedCookie');
        var attempted = this.getCookieUtility(cookieName);

        if(!(attempted == "" || attempted == "false")) {
            wasAttempted = true;
        }

        return wasAttempted;
	},
})