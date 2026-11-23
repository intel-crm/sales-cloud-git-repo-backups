({
    doInit: function(component, event, helper) {
        var breadcrumbData = [];
        
        // Determine if need to display the Sign In Link
        var redirectLibrary = component.find('redirectLibrary');
        var showMarketplace = $A.get('$Label.c.PMP_SSO_Show_Sign_In_Marketplace');
        var showLeads = $A.get('$Label.c.PMP_SSO_Show_Sign_In_Leads');

        // Default to the Marketplace value
        var showSignIn = !!parseInt(showMarketplace);
        if (redirectLibrary.whichSite() === 'Leads') {
            showSignIn = !!parseInt(showLeads);
        }
        
        // Update the sign in variables
        component.set('v.showSignIn', showSignIn);
        component.set('v.userLoggedIn', false);
        if($A.get("$SObjectType.CurrentUser.Email") !== undefined){
          	component.set('v.userLoggedIn', true);  
        }
        
        
        helper.setLabels(component);
        if (component.get("v.displayType") == "product") {
            helper.getOffering(component, component.get("v.recordId"),helper);
        } else if (component.get("v.displayType") == "partner") {
            helper.getPartner(component, component.get("v.recordId"));
        }
        
        component.set("v.bookmarkUrl", window.location.href);
        
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
        var signInUrl = $A.get("$Label.c.PMP_SSO_MP_Login_URL");
        event.preventDefault();
        event.stopPropagation();
		window.location = signInUrl + '?RelayState=' + encodeURIComponent(window.location.pathname);
    },
    
    
    isRefreshed: function(component, event, helper) {
        location.reload();
    }
});