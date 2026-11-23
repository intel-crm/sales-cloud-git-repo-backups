({
	/**
   	* Sets the IntelLink settings used for each button.
   	* @param {Object} component  The Lightning web component.
  	*/
    setLinks : function(component) {
        // Get which portal is displaying the component
        
        var sPageURL = decodeURIComponent(window.location.href);
        if(sPageURL.includes('partneradmin')){
            component.set('v.portal','Partner Admin');
        }
        
        var portal = component.get('v.portal');
        
        // Default to Marketplace settings
        
        // [7/7/2020] Sandhya - US702706  
		//var baseUrl = window.location.href.substring(0, window.location.href.indexOf("/imp/")); 
        //console.log('baseUrl---',baseUrl);
     
 		var marketplaceUrl = $A.get('$Label.c.PMP_Marketplace_Community_URL'); // Changed postion of variable to show manage storfront on lead portal - 27/01/2022
		var ipaDashboardUrl = $A.get('$Label.c.PMP_IPA_Dashboard_Url');
        var links = {
            // IPA2.0 + US TWC4497-1631
            // manageOfferingsApi: 'PMP_Partner_Offering__c',
            // manageOfferingsUrl: '',
            manageLeadsPage: '',
            manageLeadsUrl: $A.get('$Label.c.PMP_Partneradmin_Community_URL'),
            manageDashboardPage: 'dashboard',
            manageDashboardUrl: $A.get('$Label.c.PMP_IPA_Dashboard_Url'), //US702706
            managePartnersApi: 'PMP_Company__c',
            managePartnersUrl: '',
            manageEventsApi: 'PMP_Marketplace_Event__c',
            manageEventsUrl:'',
            //manageSolutions: 'ArdiraSurvey__Survey_Result__c',
            manageSolutionsUrl:'/imp/s/partner-solution-list',
            manageStorefrontUrl:marketplaceUrl			//to show manage storfront on lead portal - 27/01/2022
        };
        
        // Check if in Portal Admin portal
        if (portal === 'Partner Admin') {
            // Yes so update the settings
            var solutionListpageName = $A.get('$Label.c.PSS_Redirecting_to_Manage_Solutions');
            
            links = {
                // IPA2.0 + US TWC4497-1631
                // manageOfferingsApi: '',
                // manageOfferingsUrl: marketplaceUrl + '/pmp-partner-offering/PMP_Partner_Offering__c',
                manageLeadsPage: 'home',
                manageLeadsUrl: '',
                manageDashboardPage: '',
                manageDashboardUrl: marketplaceUrl + '/dashboard',
                managePartnersApi: '',
                managePartnersUrl: marketplaceUrl + '/partner/PMP_Company__c',
                manageEventsApi: '',
            	manageEventsUrl: marketplaceUrl + '/pmp-marketplace-event/PMP_Marketplace_Event__c',
                manageSolutionsUrl: marketplaceUrl + solutionListpageName,
                manageStorefrontUrl:marketplaceUrl  //to show manage storfront on lead portal - 27/01/2022
            };
        }
        console.log('links--->'+ links.manageDashboardUrl);
        component.set('v.links', links);
    },
    checkAccess : function(component) {	
        var urlStr = window.location.href;
        // IPA2.0 + US TWC4497-1631
        // if(urlStr.match('/pmp-partner-offering/')&& component.get('v.showManageOfferings') == false){
        //    	this.navigateToErrorPage(component);
        //     return false;
        //    }
        // else 
        if(urlStr.match('/pmp-marketplace-event/' ) && component.get('v.showManageEvents') == false){
        	this.navigateToErrorPage(component);
            return false;
    	}
 	/*	else if(urlStr.match('/partner/' ) && component.get('v.showManagedPartners') == false){
        	this.navigateToErrorPage(component);
            console.log('insideNav');
            return false;
    	}	*/
            
        
        else{
            return true;
        }
    },
    navigateToErrorPage : function(component){
        var marketplaceUrl = $A.get('$Label.c.PMP_Marketplace_Community_URL');
        window.location.href = marketplaceUrl + '/error';
    }
})