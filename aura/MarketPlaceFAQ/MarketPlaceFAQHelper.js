({
   /* helperMethod : function(component, event, helper) {

        var marketplaceHomePage = $A.get("$Label.c.PMP_PageName_Home");
        var marketplaceHomeTitle = $A.get("$Label.c.PMP_Title_Home");     	
        var leadTitle = $A.get("$Label.c.PMP_Title_Leads");
        var marketplacePartnerDirPage = $A.get("$Label.c.PMP_PageName_Partner_Directory");
        var marketplacePartnerDirTitle = $A.get("$Label.c.PMP_Title_Partner_Directory");
        var marketplacePartnerDirUrlType = $A.get("$Label.c.PMP_Partner_Directory_UrlContains");
        var marketplaceCataloguePage = $A.get("$Label.c.PMP_Offerning_Catalogue_Page");
        var marketplaceCatalogueTitle = $A.get("$Label.c.PMP_Offerning_Catalogue_Title");
        var marketplaceCatalogueResultUrlType = $A.get("$Label.c.PMP_Offering_Catalogue_Result_UrlContains");
        var marketplaceDashboardPage = $A.get("$Label.c.PMP_Dashboard_Page");
        var marketplaceDashboardTitle = $A.get("$Label.c.PMP_Dashboard_Title");
        var marketplaceOfferingCreation = $A.get("$Label.c.PMP_Offering_Creation_Page");
        var marketplaceOfferingJsontitle = $A.get("$Label.c.PMP_Offering_Creation_Json_Title");
        var marketplaceOfferingEdit = $A.get("$Label.c.PMP_Offering_Edit_Page");
        var marketplaceOfferingeditJsonTitle = $A.get("$Label.c.PMP_Offering_Edit_Json_Title");
        var marketplaceManageOffering = $A.get("$Label.c.PMP_Manage_Offering_Page");
        var marketplaceManageLeads = $A.get("$Label.c.PMP_Manage_Leads");
        var marketPlaceSearchResultPage = $A.get("$Label.c.PMP_Search_Result_Page");
        var marketPlacePartnerProgramPage = $A.get("$Label.c.PMP_PageName_Partner_Program");                
        var marketPlacePartnerSpecialtyPage = $A.get("$Label.c.PMP_PageName_Partner_Specialty");        
        var marketplaceOfferingSubmitPage = $A.get("$Label.c.PMP_Offering_Submit_Page");
        var marketplaceEditStorefront = $A.get("$Label.c.PMP_Edit_Storefront");
        var marketplaceSearchTypeAll = $A.get("$Label.c.PMP_Search_Type_All");

        //Added by shahrukh for FAQ implementation - US744409
        var marketplaceProductDetail = $A.get("$Label.c.PMP_Offering_Details_Page");
        var marketplaceCategoryDeatil = $A.get("$Label.c.PMP_FAQ_CategoryDetail");
        var OfferingByCategories = $A.get("$Label.c.PMP_FAQ_OfferingByCategories");
        var OfferingsByIndustry = $A.get("$Label.c.PMP_FAQ_OfferingsByIndustry");
        var OfferingsByApplication = $A.get("$Label.c.PMP_FAQ_OfferingsByApplication");
        var PartnerDetail = $A.get("$Label.c.PMP_FAQ_PartnerDetail");
        var PartnerSegment = $A.get("$Label.c.PMP_FAQ_PartnerSegment");
        var PartnersByIndustry = $A.get("$Label.c.PMP_FAQ_PartnersByIndustry");
        var PartnersBySegment = $A.get("$Label.c.PMP_FAQ_PartnersBySegment");
        var PartnersBySpeciality = $A.get("$Label.c.PMP_FAQ_PartnersBySpeciality");
        var partnerDirectory = $A.get("$Label.c.PMP_FAQ_PartnerDirectory");
        var JsonOfferingTitle = $A.get("$Label.c.PMP_FAQ_JsonOfferingTitle");
        var JsonPartnerTitle = $A.get("$Label.c.PMP_FAQ_JsonPartnerTitle");
        var partnerEventDetail = $A.get("$Label.c.PMP_FAQ_PartnerEventDetail");

        //var leadDetail =$A.get("Label.c.PMP_Lead_Detail"); - MGD 12/20 - removed $ from the label in order to get through migration validation (validation was still happening even though the code was commented)

        component.set('v.loggedInInfo',true);

        //Setting loggedInInfo as false for ananyomous user
        if($A.get("$SObjectType.CurrentUser.Email") === undefined){
            component.set('v.loggedInInfo', false);  
        }

        // Getting Logged in user info
        var loggedInUser = component.get("v.loggedInInfo");


        //Fetching page title
        var pageName = window.document.title;


        // Fetching the current page url 
        var sPageURL = decodeURIComponent(window.location.href);


        var httpReq  = new XMLHttpRequest();

        // Getting faq url
        var aemFaqUrl = $A.get("$Label.c.PMP_FAQ_URL");


        httpReq.open('GET', aemFaqUrl, true);

        httpReq.onreadystatechange = function(component1) {

            if (this.readyState == 4 && httpReq.status == 200) {

                var parsedData = JSON.parse(this.responseText);
                //console.log('faqData' ,parsedData);
                if(this.responseText != null){
                    var finalData = [];

                    let parsedDataMap = new Map();

                    for(var i in parsedData){
                        parsedDataMap.set(parsedData[i].title,parsedData[i]);

                    }


                    finalData.push(parsedDataMap.get(component.get('v.faqTitle'))); 
                    console.log('FAQ data 1 : ' , parsedDataMap);
                    console.log('FAQ data 2 : ' , finalData);
                    component.set("v.data", finalData);


                }  
            }
        };

        httpReq.send();

    },


    setCommunityDisplay: function(component) {
      var libraryCmp = component.find("ssoLibrary");

      var site = libraryCmp.whichSite();
      if (!site) {
        return;
      }

      // Default to Marketplace
      var showSiteMap = true;
      var helpUrl = $A.get("$Label.c.PMP_IPA_HelpLink");
      var helpLabel = $A.get("$Label.c.PMP_All_MP_Help_Label"); 
      var pageName = component.get('v.faqTitle');  

      if (site === 'Leads') {
        showSiteMap = false;
        helpUrl = $A.get("$Label.c.PMP_Leads_Help_Link");
        helpLabel = $A.get("$Label.c.PMP_Leads_Help_Label");
      }

      if (showSiteMap) {
        var baseUrl = window.location.href.substring(0, window.location.href.indexOf("/s/"));
        component.set('v.siteMapUrl', baseUrl+'/s/sitemap');
      }

        if(pageName===$A.get("$Label.c.PSS_Solution_Page_Title")){
           helpUrl =  $A.get("$Label.c.PSS_Help_URL");
           helpLabel = $A.get("$Label.c.PSS_Help_Label");  
        }

      component.set('v.showSiteMap', showSiteMap);
      component.set('v.helpUrl', helpUrl);
      component.set('v.helpLabel', helpLabel);
    }
    */
})