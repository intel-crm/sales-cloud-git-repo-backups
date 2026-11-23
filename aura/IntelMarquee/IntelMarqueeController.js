({
    doInit : function(component, event, helper) {
        
        console.log('SHowbreadcrumbs test : ', component.get('v.showBreadcrumbs'));
        
        
        var type = component.get('v.type');
        if(type == 'compareofferings'){
            component.set('v.heading', $A.get("$Label.c.PMP_Compare_Offerings"));
        }
        var marketplaceHomeLabel = $A.get("$Label.c.PMP_Breadcrumbs_Marketplace_Home");
        var allMarketplaceLabel = $A.get("$Label.c.PMP_Breadcrumbs_All_Marketplace");
        var allPartnersLabel = $A.get("$Label.c.PMP_Breadcrumbs_All_Partners");
        var allProductsLabel = $A.get("$Label.c.PMP_Breadcrumbs_All_Products");
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
        
        // IF L2 Marquee only
        if (type === "l2search") {
            component.set('v.mapStateToAttributes', function(state) {
                var searchType = state.searchType,
                    selectedCategory = state.selectedCategoryId;
                var selectedSpecialty = state.selectedSpecId;
                
                var categoryBreadcrumbs = state.categories.breadcrumbs;
                var label = "",
                    subheading = "",
                    learnMoreLink = "";
                
                // TODO -- Replace with any changed Custom Labels and update to proper URLs
                var marketplaceHomeLabel = $A.get("$Label.c.PMP_Breadcrumbs_Marketplace_Home"); //$A.get("$Label.c.PMP_L2_Marquee_All_Heading");
                var allMarketplaceLabel = $A.get("$Label.c.PMP_L2_Marquee_All_Heading");
                   var marketplaceUrl = $A.get("$Label.c.PMP_Marketplace_Community_URL");
                
                var breadcrumbData = [
                    {
                        label: $A.get("$Label.c.PMP_Breadcrumbs_Marketplace_Home"),
                        page: "home"
                    },
                    {
                        label: $A.get("$Label.c.PMP_Breadcrumbs_All_Marketplace"),
                        page: "search"
                    }
                ];
                
                if (!selectedCategory && !selectedSpecialty) {
                    if (searchType == "all") {
                        label = $A.get("$Label.c.PMP_L2_Marquee_All_Heading");
                        subheading = $A.get("$Label.c.PMP_L1_Home_Marquee_SubHeading");
                    } else if (searchType == "partner") {
                        label = $A.get("$Label.c.PMP_L2_Marquee_Partner_Heading");
                        subheading = $A.get("$Label.c.PMP_Intel_MP_Partners_subtitle");
                    } else if (searchType == "product") {
                        label = $A.get("$Label.c.PMP_L2_Marquee_Product_Heading");
                        subheading = $A.get("$Label.c.PMP_L1_Offering_Marquee_Sub_Heading");
                    }
                } else {
                    
                    label = state.searchHeading;
                    subheading = state.searchSubHeading;
                    learnMoreLink = state.searchCtaLink;//Category learnMore link
                    if(state.searchlearMoreLink !=null){
                        learnMoreLink=state.searchlearMoreLink;//Specialty learMore link
                   
                    }
                }
                
                if (searchType == "partner") {
                    var partnerLabel = $A.get("$Label.c.PMP_L2_Marquee_Partner_Heading");
                    breadcrumbData.push({
                        label: partnerLabel,
                        page:'search',
                       searchParams: {"type":"partner"}
                       });
                }
                
                if (searchType == "product") {
                    var productLabel = $A.get("$Label.c.PMP_L2_Marquee_Product_Heading");
                   breadcrumbData.push({
                        label: productLabel,
                        page: 'search',
                       searchParams: {"type":"product"}
                  });
                }
              
                
                if (selectedCategory && categoryBreadcrumbs && categoryBreadcrumbs.length) {
                    categoryBreadcrumbs.forEach(function(cat){
                      //if(cat.getSObjectType().getDescribe().getName()==='PMP_Category__c'){
                        breadcrumbData.push({
                            label: cat.categoryName,
                           //url : "https://nppdevpmp-intelcloudcrm.cs67.force.com/imp/s/pmp-category/"+cat.categoryId
                           //As part of US598255 Userstrory
                          url:marketplaceUrl+"/"+"pmp-category"+"/"+cat.categoryId+"/"+cat.categoryName
                          // page:'search',
                         // SearchParams: { type: cat.categoryType, cat: cat.categoryId }
                            });
                      
                    });
                }
                
                // convert breadcrumb to no link
                breadcrumbData[breadcrumbData.length-1].class = 'noLink';
                console.log('SHowbreadcrumbs test 2: ', component.get('v.showBreadcrumbs'));
                return {
                    breadcrumbData: breadcrumbData,
                    heading: label,
                    text: subheading,
                    learnMoreLink: learnMoreLink
                };
            }); 	
        } else {
            var breadcrumbData = [{ label: marketplaceHomeLabel, page: "home" }];
            // All Types
            switch (type) {
                case 'dashboard':
                    breadcrumbData.push({ label: allPartnersLabel, page: 'partners'});
                    breadcrumbData.push({ label: $A.get("$Label.c.PMP_Dashboard"), url: "#", class: 'noLink'});
                    helper.addCompanyBreadcrumb(component);
                    break;
                case 'editlead':
                    breadcrumbData = [{ label: $A.get("$Label.c.PMP_Breadcrumbs_Edit_Lead"), page: "home" }];
                    break;
                case 'l0':
                    breadcrumbData = [];
                    break;
                case 'leads':
                    breadcrumbData = [];
                   var marketplaceUrl = $A.get("$Label.c.PMP_Marketplace_Community_URL");
                    breadcrumbData.push({ label: marketplaceHomeLabel, url: marketplaceUrl});
                    breadcrumbData.push({ label: allPartnersLabel, url: marketplaceUrl + "/partners"});
                    breadcrumbData.push({ label: $A.get("$Label.c.PMP_Leads_Heading"), url: "#", class: 'noLink'});
                    helper.addCompanyBreadcrumb(component);
                    break;
                case 'offerings':
                    breadcrumbData.push({label: allMarketplaceLabel, page: "search"});
                    breadcrumbData.push({ label: allProductsLabel, url: "#", class: 'noLink'});
                    break;
                case 'partner':
                    breadcrumbData.push({ label: allPartnersLabel, page: 'partners'});
                    breadcrumbData.push({ label: $A.get("$Label.c.PMP_MyOfferings"), url: "#", class: 'noLink'});
                    helper.addCompanyBreadcrumb(component);
                    break;
                case 'partners':
                    breadcrumbData.push({label: allMarketplaceLabel, page: "search"});
                    breadcrumbData.push({ label: allPartnersLabel, url: "#", class: 'noLink'});
                    break;
                case 'product':
                    breadcrumbData.push({ label: $A.get("$Label.c.PMP_LoggedIn_Partner_Company_Name"), url: "#"});
                    break;
                case 'leadDetail' :
                    // Set to empty - this will be populated by the recordUpdate function
                    breadcrumbData = [];
                    break;
            }
            component.set("v.breadcrumbData", breadcrumbData);
        }
        
    }, 
    

    recordUpdate : function(component, event, helper) {
        //To display breadcrumbs on lead detail page. 
        if (component.get('v.type') === 'leadDetail'){
            var breadcrumbData = [];
            var recordName = (component.get("v.record") != null ? component.get("v.record").Name : '');
            breadcrumbData.push({ label: $A.get("$Label.c.PMP_Leads_Heading"), page: "home"});
            breadcrumbData.push({ label: recordName, url: '#', class: 'noLink'});
            component.set("v.breadcrumbData", breadcrumbData); 
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
    }
})