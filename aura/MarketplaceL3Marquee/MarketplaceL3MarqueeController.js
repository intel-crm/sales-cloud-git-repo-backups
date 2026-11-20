({
    doInit: function(component, event, helper) {
		
        if($A.get("$SObjectType.CurrentUser.Email") !== undefined){
            helper.gotoTermsAndCondition(component);
        }
        
        var showSignIn = false;
        var loginUrl = '';

        // Determine if need to display the Sign In Link
        var ssoLibrary = component.find('ssoLibrary');
        var ssoSettings = ssoLibrary.getSSOSettings();
        if (ssoSettings) {
          showSignIn = !!parseInt(ssoSettings.showSignIn);
          loginUrl = ssoSettings.ighf.loginUrl;
        }    
        
        // Update the sign in variables
        component.set('v.showSignIn', showSignIn);
        component.set('v.loginUrl', loginUrl);
        component.set('v.userLoggedIn', false);
        if($A.get("$SObjectType.CurrentUser.Email") !== undefined){
          	component.set('v.userLoggedIn', true);  
        }
        
        
        helper.setLabels(component);
        // IPA2.0 + US TWC4497-1631
        // if (component.get("v.displayType") == "product") {
        //     helper.getOffering(component, component.get("v.recordId"),helper);
        // }
        //  else
          if (component.get("v.displayType") == "partner") {
            helper.getPartner(component, component.get("v.recordId"));
        }
        
        component.set("v.bookmarkUrl", window.location.href);
        
        console.log("11");
        //Get product info-Gireesh:US519754
        helper.getProductInfo(component,helper);
        
    },
    
    handleOpenMoreModal: function(component, event, helper) {
        component.set("v.moreModalOpen", true);
    },
    
    handleCloseMoreModal: function(component, event, helper) {
        component.set("v.moreModalOpen", false);
    },
    
    handleBookmark: function(component, event, helper) {
        if (!component.get("v.bookmarkCopied")) {
            var copyText = component.find("bookmarkUrl").getElement();
            copyText.select();
            document.execCommand("copy");
            component.set("v.bookmarkCopied", true);
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.bookmarkCopied", false);
                }),
                3050
            );
        }
    },
    
    handleClickCategory: function(component, event, helper) {
        event.preventDefault();
        var urlParams = {
            type: "partner",
            cat: event.currentTarget.dataset.id
        };
        var pageName = "search";
        var searchUrlParams = encodeURIComponent(JSON.stringify(urlParams));
        
        if (component.get("v.debugMode")) {
            console.log(
                "DEBUG: Search will navigate to...   " +
                "/" +
                pageName +
                "?search=" +
                searchUrlParams
            );
            console.log("DEBUG: URL Length: " + searchUrlParams.length);
        } else {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                url: "/" + pageName + "?search=" + searchUrlParams
            });
            urlEvent.fire();
        }
    },
    
    
    handleSignIn : function(component, event, helper) {
      // Create URL so that the user is returned to the page they are on after logging in
      var ssoLibrary = component.find('ssoLibrary');
      var ssoSettings = ssoLibrary.getSSOSettings();
      if (ssoSettings && ssoSettings.ighf && ssoSettings.ighf.loginUrl) {
        event.preventDefault();
        event.stopPropagation();
        window.location = ssoSettings.ighf.loginUrl + '?RelayState=' + encodeURIComponent(window.location.pathname);
      }
    },
    
    
    isRefreshed: function(component, event, helper) {
        location.reload();
    },
    
    openEditStoreModal: function(component, event, helper) {
        
        var appEvent = $A.get("e.c:MarketplacePageEvent");
        appEvent.setParams({
                type: 'openEditStoreFrontFromDraft',
                payload: { 
                    currentStep: 0
                }
            });
        appEvent.fire();
    }
});