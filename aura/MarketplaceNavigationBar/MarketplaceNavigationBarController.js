({
    doInit : function(component, event, helper) {
        //US757978 - Page Access POC-------------
        var checkPageAccess =false;
        var urlStr = window.location.href;
        
        /*if current page is offering/partner/event list view page then we need to check the users access 
        for the page */    
        //Unable to use document.title, as there is inconsistency with page names hence depending on Url
     /*   if(urlStr.match('/pmp-partner-offering/') || urlStr.match('/pmp-marketplace-event/' )
            || urlStr.match('/partner/')){
            	//Setting the spinner visiblity to true for the 3 pages
                component.set('v.showSpinner', true);
            	//checkPageAccess when true, we call the checkAccess helper method below in the code
                checkPageAccess = true;
           } */
        
        // -----Page Access Poc -- Not to be Moved ------
        helper.setLinks(component);    
        //Gireesh
        var actionFetchCompanyId = component.get("c.getCompanyId");        						
        actionFetchCompanyId.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue(); 
                if(response != null){
                    component.set("v.companyId",response);
                   var CompId = component.get("v.companyId");
                      //var urlStr = window.location.href;
                  
                  // set manage Storefront Url - to show manage storefront button on lead portal - 27/01/2022
                  var manageStorefrontUrl = component.get('v.links.manageStorefrontUrl')+'/partner-edit/'+CompId;
                   component.set("v.links.manageStorefrontUrl", manageStorefrontUrl);   
                  // manage storefront button on lead portal - 27/01/2022
                        
        			  var isManageStorefront = urlStr.match('/partner/'+ CompId); 
                        if(isManageStorefront){
                            component.set("v.disableManageStorefront",true)
                        }
                        else{
                            component.set("v.disableManageStorefront",false) 
                        }
                    
                    // var isSolutionsPage = urlStr.match('/survey/ArdiraSurvey__Survey__c/'); 
                    // if(isSolutionsPage){
                    //     component.set("v.disableManageSolutions",true)
                    // }
                    // else{
                    //     component.set("v.disableManageSolutions",false) 
                    // }
                }
            }
            else if (status === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error(errors[0].message);
                    this.reject(errors[0].message);
                } else { this.reject('Unknown error.'); }
            }
        });
        $A.enqueueAction(actionFetchCompanyId);
        //end
		
        var urlStr = window.location.href;
        // IPA2.0 + US TWC4497-1631
        // var isOfferingPage = urlStr.match('/pmp-partner-offering/PMP_Partner_Offering__c/'); 
        // if(isOfferingPage){
        //     component.set("v.disableManageOfferings",true)
        // }
        // else{
        //     component.set("v.disableManageOfferings",false) 
        // }
        //TWC4497-1569 changes to remove offering and solutions Button Shivini
        
        var isBasicAccess = false;
        var is_PMP_Manage_Events = false;
        var isBasic = false;
        var isEnhanced = false;
        var isPartnerUser = false;
        var is_Intel_Admin_Profile = false;
       // var is_Partner_Admin_Profile = false;
        var is_PMP_Manage_Leads = false;
        var is_PMP_Manage_Storefront = false;
        // var is_PMP_Manage_Offerings = false;        // IPA2.0 + US TWC4497-1631
        var is_PMP_Manage_Partners = false;
        var is_PMP_View_Dashboard = false;
        // var is_Offering_Page =false; //IPA2.0 + US TWC4497-1631
        var is_PMP_Manage_Solutions = false;
        var is_PMP_Manage_Storefront = false;
        // Added by Subash for US842248
        var pageName = window.document.title;
        
        var actionPermissionSet = component.get("c.checkForCustomPermission");
        
        actionPermissionSet.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                console.log('storeResponse',storeResponse);
                if(storeResponse != null){ 
                    if(storeResponse.PMP_Manage_Leads !== undefined){
                        is_PMP_Manage_Leads = true;
                    }
// IPA2.0 + US TWC4497-1631
                    // if(storeResponse.PMP_Manage_Offerings !== undefined){
                    //     is_PMP_Manage_Offerings = true;
                    // }
                    //TWC4497-1569 changes to remove offering and solutions Button Shivini
                 
                    if(storeResponse.PMP_Manage_Partners !== undefined){
                        is_PMP_Manage_Partners = true;
                    }
                
                    if(storeResponse.PMP_View_Dashboard !== undefined){
                        is_PMP_View_Dashboard = true;
                    }
                
                    if(storeResponse.PMP_Manage_Events !== undefined){
                        is_PMP_Manage_Events = true;
                    }
                    
                    if(storeResponse.PMP_Manage_Solutions !== undefined){
                        is_PMP_Manage_Solutions = true;
                    }
                     if(storeResponse.PMP_Manage_Storefront !== undefined){
                        is_PMP_Manage_Storefront = true;
                    }
                    console.log('is_PMP_Manage_Storefront',is_PMP_Manage_Storefront);
                   // console.log('PMP_Manage_Events',PMP_Manage_Events);
                    
                }
                
                var action = component.get("c.checkBenefitLevel");
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();
                         //TWC4497-1569 changes to remove offering and solutions Button check label
                       /* if(storeResponse != '' &&  storeResponse == $A.get("{!$Label.c.PMP_Offering_Benefit}")){ //storeResponse.includes("Enhanced")
                            isEnhanced = true;
                        }
                        if(storeResponse == '' || storeResponse == 'Solution Marketplace Basic Access'){
                            isBasicAccess = true;
                        }*/

                        //NOTE : Add check for basic access restriction here
                        
                        var actionInternalPermCheck = component.get("c.fetchPermissionSetName");
                        actionInternalPermCheck.setCallback(this, function(response) {
                            var state = response.getState();
                            console.log('state',state);
                            if (state === "SUCCESS") {
                                var storeResponse = response.getReturnValue();
                                console.log('storeResponse',storeResponse);
                                // if(storeResponse != null && storeResponse.includes("PMP_Internal_Intel_Admin")){ 
                               // IPA2.0 + US TWC729-8177 - View Dashboard Removal
                                if(storeResponse != null && (storeResponse.includes("PMP_Internal_Intel_Admin") || storeResponse.includes("PMP_Internal_Intel_Admin_Read_Only") || storeResponse.includes("PMP_Internal_Intel_Read_Only"))){
                                    is_Intel_Admin_Profile = true;
                                     console.log('storeResponseinside',storeResponse);
                                }
                               /* if(storeResponse != null && (storeResponse.includes("PMP_External_Partner_Admin") || storeResponse.includes("PMP_External_Marketing_Specialist") )){
                                    is_Partner_Admin_Profile = true;
                                }*/
                                // IPA2.0 + US TWC729-8177 - View Dashboard Removal
                                // Check if current page is dashboard and user is admin - redirect if admin
                                var currentUrl = window.location.href;
                                if(currentUrl.includes('/dashboard') && is_Intel_Admin_Profile == true){
                                var marketplaceUrl = $A.get('$Label.c.PMP_Marketplace_Community_URL');
                                window.location.href = marketplaceUrl + '/error';
                            }
                                
                                var actionFetchUserDetails = component.get("c.fetchUser");
                                
                                actionFetchUserDetails.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var storeResponse = response.getReturnValue();
                                        if(storeResponse != null && storeResponse.ContactId !== undefined
                                           && storeResponse.ContactId != null){
                                            isPartnerUser = true;
                                            component.set('v.userName',storeResponse.Name);
                                            component.set('v.loggedInInfo',true);
                                            component.set('v.loggedInCompany',true);
                                        }
                                        
                                        
                                        if($A.get("$SObjectType.CurrentUser.Email") !== undefined){
                                            component.set('v.userName',storeResponse.Name); 
                                            component.set('v.loggedInInfo',true);
                                        }
                                        
                                          var isPortal = component.get("v.portal");
       									  var isLoggedincmp = component.get("v.loggedInCompany");
                                       // console.log('is_Partner_Admin_Profile',is_Partner_Admin_Profile);
                                         console.log('isPartnerUser',isPartnerUser);
                                        console.log('is_Intel_Admin_Profile',is_Intel_Admin_Profile);
                                        
                                        //Visibility of buttons logic
                                        if(isPartnerUser == false){
                                            // IPA2.0 + US TWC4497-1631
                                            // if(is_PMP_Manage_Offerings == true)                                                
                                            //     component.set('v.showManageOfferings', true);
                                            if(is_PMP_Manage_Leads == true)
                                                component.set('v.showManageLeads', true);
                                            if(is_PMP_View_Dashboard == true && is_Intel_Admin_Profile == false)
                                                component.set('v.showDashboard', true);
                                            //  viewdash story
                                            if(is_PMP_Manage_Partners == true)
                                                component.set('v.showManagedPartners', true);
                                            if(is_PMP_Manage_Events == true)
                                                component.set('v.showManageEvents', true);
                                            // Added by Subash for US842248
                                            if(is_PMP_Manage_Solutions == true) {
                                                component.set('v.showManageSolutions', true);
                                            }
                                        }else{
                                           // if(!isBasicAccess){
                                                // Added isPortal == 'Partner Admin' to show manager storefront button on lead portal -27/01/2022
                                               /* if((is_Partner_Admin_Profile || isPortal == 'Partner Admin') && isLoggedincmp == true){
                                                    component.set('v.showManageStorefront', true);
                                                }  */
                                             if(is_PMP_Manage_Storefront == true) {
                                                component.set('v.showManageStorefront', true);
                                            }
                                                // IPA2.0 + US TWC4497-1631
                                                // if(is_PMP_Manage_Offerings == true /*&& isEnhanced == true*/){                                          
                                                //     component.set('v.showManageOfferings', true);
                                                // }    
                                                if(is_PMP_Manage_Leads == true){
                                                    component.set('v.showManageLeads', true);
                                                }    
                                                if(is_PMP_View_Dashboard == true && is_Intel_Admin_Profile == false){
                                                    component.set('v.showDashboard', true);
                                                }    
                                                // viewdash story
                                                // Added by Subash for US842248
                                                if(is_PMP_Manage_Solutions == true) {
                                                    component.set('v.showManageSolutions', true);
                                                }
                                          //  }
                                          //  else if(isBasicAccess){ //Updated by Hanuma as per Defects raised in QA
                                                if(is_PMP_Manage_Solutions == true) {
                                                    component.set('v.showManageSolutions', true);
                                                }
                                          //  }
                                        }
                               //US757978 - calling the checkAccess helper function          
                                     if(checkPageAccess){
                                         function showError(hideSpinner){
                                             var hide = helper.checkAccess(component);
                                             if(hide){
                                                 hideSpinner();
                                             }
                                                    
                                         }
                                         showError(function(){
                                             component.set('v.showSpinner', false);
                                         });
                                     	} 
                                    }
                                });
                                $A.enqueueAction(actionFetchUserDetails);
                                
                            }
                        });
                        //
                        $A.enqueueAction(actionInternalPermCheck);
                        
                    }
                });
                $A.enqueueAction(action);     
                
            }
            
        });
        $A.enqueueAction(actionPermissionSet);
        
        
        
    },
    
    handleToggleOpen : function(component, event, helper) {
        if (component.get('v.showManageStorefront') ||  component.get('v.showManageLeads') || component.get('v.showDashboard') || component.get('v.disableManagedMPPartners')  ) {
            // IPA2.0 + US TWC4497-1631
        //if (component.get('v.showManageStorefront') || component.get('v.showManageOfferings') || component.get('v.showManageLeads') || component.get('v.showDashboard') || component.get('v.disableManagedMPPartners')  ) {
            var isOpen = !component.get('v.open'), callback = component.get('v.ontoggle');
            if (callback && typeof callback == 'function') {
                callback(component.get('v.name'), isOpen);
            }
            component.set('v.open', isOpen);
        }
    },
    
    
    
})