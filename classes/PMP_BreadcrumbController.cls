/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_BreadcrumbController
* Description : Stores all logic to fetch the Breadcrumb.
* Version     : 1.0 
* Created Date: 10-July-2020
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/
public with sharing class PMP_BreadcrumbController extends PMP_SearchWrapperStore {
    
    @AuraEnabled(cacheable=true)
    public static BreadCrumb getBreadcrumb(String langCode, String url) {
        
        Boolean isGuest=PMP_SearchUtilityController.isGuest(); 
        Integer currentMainBreadCrumbIndex = 0;
        
        BreadCrumb mainBreadCrumb = new BreadCrumb();
        mainBreadCrumb.children = new List<BreadCrumb>();
        mainBreadCrumb.text = System.Label.PRM_Breadcrumb_IPA_Text;
        mainBreadCrumb.selected = true;
        mainBreadCrumb.id = 'IntelPartnerAlliance';
        mainBreadCrumb.cancelEvent = true;
        mainBreadCrumb.useCallback = true;
        if(!isGuest)
        {
            mainBreadCrumb.url = System.Label.PRM_Breadcrumb_PartnerHome_URL;
        }
        else
        {
            mainBreadCrumb.url = System.Label.PMP_Breadcrumb_PartnerHome_URL;
        }
        currentMainBreadCrumbIndex++;
        
        //Integer partnerHomeIndex = currentMainBreadCrumbIndex;
        BreadCrumb partnerHome = new BreadCrumb();
        partnerHome.text = System.Label.PRM_Breadcrumb_PartnerHome_Text;
        partnerHome.id = 'partnerHome';
        
        if(!isGuest)
        {
            partnerHome.url = System.Label.PRM_Breadcrumb_PartnerHome_URL;
        }
        else
        {
            partnerHome.url = System.Label.PMP_Breadcrumb_PartnerHome_URL;
        }
        mainBreadCrumb.children.add(partnerHome);
        currentMainBreadCrumbIndex++;
        
        if(!isGuest)
        {
            //Integer manageBenefitsIndex = currentMainBreadCrumbIndex;
            BreadCrumb manageBenefits = new BreadCrumb();
            manageBenefits.text = System.Label.PRM_Breadcrumb_PartnerBenefit_Txt;
            manageBenefits.id = 'manageBenefits';
            manageBenefits.url = System.Label.PRM_Breadcrumb_IPA_URL;
            mainBreadCrumb.children.add(manageBenefits);
            currentMainBreadCrumbIndex++;
            
            //Integer viewDashboardIndex = currentMainBreadCrumbIndex;
            BreadCrumb viewDashboard = new BreadCrumb();
            viewDashboard.text = System.Label.PRM_Breadcrumb_ViewDashboard_Text;
            viewDashboard.id = 'viewDashboard';
            viewDashboard.url = System.Label.PMP_IPA_Dashboard_Url;
            mainBreadCrumb.children.add(viewDashboard);
            currentMainBreadCrumbIndex++;
        }
        else
        {   
            //Integer aboutMembershipIndex = currentMainBreadCrumbIndex;
            BreadCrumb aboutMembership = new BreadCrumb();
            aboutMembership.text = System.Label.PRM_Breadcrumb_AboutMembership_Txt;
            aboutMembership.id = 'aboutMembership';
            aboutMembership.url = System.Label.PRM_Breadcrumb_AboutMembership_URL;
            mainBreadCrumb.children.add(aboutMembership);
            currentMainBreadCrumbIndex++;
        }
           
        //Commented for Breadcrumb POC to navigate to AEM URL
        // BreadCrumb breadCrumb = getIntelSolutionsBreadcrumb(langCode, url);
        // mainBreadCrumb.children.add(breadCrumb);
        // currentMainBreadCrumbIndex++;

        //Added for Breadcrumb POC to navigate to AEM URL
        //Integer marketplace = currentMainBreadCrumbIndex;
        BreadCrumb marketplaceComm = new BreadCrumb();
        marketplaceComm.text = System.Label.PMP_Breadcrumb_Header;
        marketplaceComm.id = 'marketplace';
        if(langCode == 'en-US'){
            marketplaceComm.url = System.Label.PMP_AEM_Offering_URL	 + 'us/en' + System.Label.PMP_AEMRedirectHome;
        }else if(langCode == 'zh-Hans-CN'){
            marketplaceComm.url = System.Label.PMP_AEM_Offering_URL	+ 'cn/zh' + System.Label.PMP_AEMRedirectHome ;
        }else if(langcode == 'ja'){
            marketplaceComm.url = System.Label.PMP_AEM_Offering_URL	+ 'jp/ja' + System.Label.PMP_AEMRedirectHome ;
        }else{
            marketplaceComm.url = System.Label.PMP_AEM_Offering_URL	 + 'us/en' + System.Label.PMP_AEMRedirectHome;
        }
        mainBreadCrumb.children.add(marketplaceComm);
        currentMainBreadCrumbIndex++;
        
        /*Utkarsh changes as part of story TWC727-841*/
        if(!isGuest)
        {
            
            //Integer partnerEnablementResourcesIndex = currentMainBreadCrumbIndex;
            BreadCrumb partnerEnablementResources = new BreadCrumb();
            partnerEnablementResources.text = System.Label.PRM_Breadcrumb_SalesEnablementResources;
            partnerEnablementResources.id = 'partnerEnablementResources';
            partnerEnablementResources.url = System.Label.PRM_Breadcrumb_SalesEnablementResources_URL;
            mainBreadCrumb.children.add(partnerEnablementResources);
            currentMainBreadCrumbIndex++;
        }
        else
        {   
            //Integer alreadyAMemberLoginIndex = currentMainBreadCrumbIndex;
            BreadCrumb alreadyAMemberLogin = new BreadCrumb();
            alreadyAMemberLogin.text = System.Label.PMP_Breadcrumb_AlreadyaMemberLogin_Text;
            alreadyAMemberLogin.id = 'alreadyAMemberLogin';
            alreadyAMemberLogin.url = System.Label.PMP_Breadcrumb_AlreadyaMemberLogin_URL;
            mainBreadCrumb.children.add(alreadyAMemberLogin);
            currentMainBreadCrumbIndex++;
        }
        
        /*TWC727-841 - END*/
        //Integer partnerUniversityIndex = currentMainBreadCrumbIndex;
        BreadCrumb partnerUniversity = new BreadCrumb();
        partnerUniversity.text = System.Label.PRM_Breadcrumb_PartnerUniversity_Text;
        partnerUniversity.id = 'partnerUniversity';
        partnerUniversity.url = System.Label.PRM_Partner_University_URL;
        mainBreadCrumb.children.add(partnerUniversity);
        currentMainBreadCrumbIndex++;
        
        //Integer partnerMarketingStudioIndex = currentMainBreadCrumbIndex;
        BreadCrumb partnerMarketingStudio = new BreadCrumb();
        partnerMarketingStudio.text = System.Label.PRM_Breadcrumb_MarketingStudio_Text;
        partnerMarketingStudio.id = 'partnerMarketingStudio';
        partnerMarketingStudio.url = System.Label.PRM_Breadcrumb_MarketingStudio_URL;
        mainBreadCrumb.children.add(partnerMarketingStudio);
        currentMainBreadCrumbIndex++;
        
        //Integer partnerCommunitiesIndex = currentMainBreadCrumbIndex;
        BreadCrumb partnerCommunities = new BreadCrumb();
        partnerCommunities.text = System.Label.PRM_Breadcrumb_PartnerCommunities_Text;
        partnerCommunities.id = 'partnerCommunities';
        if(!isGuest)
        {
            partnerCommunities.url = System.Label.PRM_Breadcrumb_PartnerCommunitiesSecure_URL;
        }
        else
        {
            partnerCommunities.url = System.Label.PRM_Breadcrumb_PartnerCommunitiesPublic_URL;
        }
        mainBreadCrumb.children.add(partnerCommunities);
        currentMainBreadCrumbIndex++;
              
        //Integer submitSolutionIndex = currentMainBreadCrumbIndex;
        // BreadCrumb submitSolution = new BreadCrumb();
        // submitSolution.text = System.Label.PRM_Manage_Solutions;
        // submitSolution.id = 'submitSolution';
        // if(!isGuest)
        // {
        //     submitSolution.url = System.Label.PRM_Breadcrumb_SubmitSolutionSecure_URL;
        // }
        // else
        // {
        //     submitSolution.url = System.Label.PRM_Breadcrumb_SubmitSolutionPublic_URL;
        // }
        // mainBreadCrumb.children.add(submitSolution);
        // currentMainBreadCrumbIndex++;
        // breadcrumb removal IPA 2.0
        
        /*Utkarsh changes as part of story TWC727-841*/
        if(!isGuest)
        {
            //Integer aboutMembershipIndex = currentMainBreadCrumbIndex;
            BreadCrumb aboutMembership = new BreadCrumb();
            aboutMembership.text = System.Label.PRM_Breadcrumb_AboutMembership_Txt;
            aboutMembership.id = 'aboutMembership';
            aboutMembership.url = System.Label.PRM_Breadcrumb_AboutMembership_URL;
            mainBreadCrumb.children.add(aboutMembership);
            currentMainBreadCrumbIndex++;
       
        }
        else
        {   
            //Integer alreadyAMemberLoginIndex = currentMainBreadCrumbIndex;
            BreadCrumb alreadyAMemberLogin = new BreadCrumb();
            alreadyAMemberLogin.text = System.Label.PMP_Breadcrumb_AlreadyaMemberLogin_Text;
            alreadyAMemberLogin.id = 'alreadyAMemberLogin';
            alreadyAMemberLogin.url = System.Label.PMP_Breadcrumb_AlreadyaMemberLogin_URL;
            mainBreadCrumb.children.add(alreadyAMemberLogin);
            currentMainBreadCrumbIndex++;
        }
        /*TWC727-841 - END*/
        
        //Integer getHelpIndex = currentMainBreadCrumbIndex;
        BreadCrumb getHelp = new BreadCrumb();
        getHelp.text = System.Label.PRM_Breadcrumb_GetHelp_Text;
        getHelp.id = 'getHelp';
        getHelp.url = System.Label.PRM_Breadcrumb_GetHelp_URL;
        mainBreadCrumb.children.add(getHelp);
        currentMainBreadCrumbIndex++;
        
        return mainBreadCrumb;
    }
    
    public static BreadCrumb getIntelSolutionsBreadcrumb(String langCode, String url) {
        
        Integer currentBreadCrumbIndex = 0;
        BreadCrumb breadCrumb = new BreadCrumb();
        breadCrumb.children = new List<BreadCrumb>();
        Set<String> partnerRoles = new Set<String>();
        Set<String> partnerSpeciality = new Set<String>();
        Set<String> partnerSegment = new Set<String>();
        
        breadCrumb.text = System.Label.PMP_Breadcrumb_Header;
        breadCrumb.selected = true;
        breadCrumb.id = 'IntelSolutionsMarketplace';
        breadCrumb.cancelEvent = true;
        breadCrumb.useCallback = true;
        breadCrumb.data = new BreadCrumbData();
        breadCrumb.data.type = 'comm__namedPage';
        breadCrumb.data.attributes = new BreadCrumbAttribute();
        breadCrumb.data.attributes.pageName = 'home';
        if(breadCrumb.selected) 
        { 
            BreadCrumb off = new BreadCrumb();
            off.text = System.Label.PMP_FindAnOffering;
            off.id = 'findAnOffering';
            breadCrumb.children.add(off);
            currentBreadCrumbIndex++;
            
            Integer offCatBCIndex = currentBreadCrumbIndex;
            BreadCrumb offCatBC = generateBreadCrumb(System.Label.PMP_L0_Offerings_Category, 'offerings-by-category', url);
            if(offCatBC.selected) { offCatBC.children = getCategories(langCode, 'NPP_01_TYPE'); }
            breadCrumb.children.add(offCatBC);
            currentBreadCrumbIndex++;
            
            // Integer offAppBCIndex = currentBreadCrumbIndex;
            // BreadCrumb offAppBC = generateBreadCrumb(System.Label.PMP_L0_Offerings_Application, 'offerings-by-use-cases', url);
            // if(offAppBC.selected) { offAppBC.children = getCategories(langCode, 'NPP_01_APP'); }
            // breadCrumb.children.add(offAppBC);
            // currentBreadCrumbIndex++;
            
            // Integer offIndBCIndex = currentBreadCrumbIndex;
            // BreadCrumb offIndBC = generateBreadCrumb(System.Label.PMP_L0_Offerings_Industry, 'offerings-by-industry', url);
            // if(offIndBC.selected) { offIndBC.children = getCategories(langCode, 'NPP_01_Industry'); }
            // breadCrumb.children.add(offIndBC);
            // currentBreadCrumbIndex++;
            // breadcrumb removal IPA 2.0
            
            
            BreadCrumb part = new BreadCrumb();
            part.text = System.Label.PMP_FindAPartner;
            part.id = 'findAPartner';
            breadCrumb.children.add(part);
            currentBreadCrumbIndex++;
            
            if(url.contains('/pmp-partner-segment/') || url.contains('partners-by-segment') || url.contains('partners-by-specialty') || url.contains('/pmp-partner-specialty/')) {
                for(PMP_Company__c partner : PMP_TaxonomyStore.getActivePartners()) {
                    if(partner.PMP_Partner_Program_nm__c != NULL) {
                        partnerRoles.addAll(partner.PMP_Partner_Program_nm__c.split(';'));
                    }
                    if(partner.PMP_Account_Specialty__c != NULL) {
                        partnerSpeciality.addAll(partner.PMP_Account_Specialty__c.split(';'));
                    }
                    if(partner.PMP_Partner_Segment_Nm__c != NULL) {
                        partnerSegment.addAll(partner.PMP_Partner_Segment_Nm__c.split(';'));
                    }
                }
            }
            
            Integer partDirBCIndex = currentBreadCrumbIndex;
            BreadCrumb partDirBC = generateBreadCrumb(System.Label.PMP_L0_Partner_Role, 'partner-directory', url);
            if(partDirBC.selected) { partDirBC.children = getPartnerDirectory(langCode, null); }
            breadCrumb.children.add(partDirBC);
            currentBreadCrumbIndex++;
            
            Integer partPartBCInext = currentBreadCrumbIndex;        
            BreadCrumb partPartBC = generateBreadCrumb(System.Label.PMP_L0_Partners_Industry, 'partners-by-industry', url);
            if(partPartBC.selected) { partPartBC.children = getPartnerIndustry(langCode); }
            breadCrumb.children.add(partPartBC);
            currentBreadCrumbIndex++;
            
            Integer partSpecBCIndex = currentBreadCrumbIndex;
            BreadCrumb partSpecBC = generateBreadCrumb(System.Label.PMP_L0_Partners_Specialty, 'partners-by-specialty', url);
            if(partSpecBC.selected) { partSpecBC.children = getPartnerSpeciality(langCode, null, partnerSpeciality); }
            breadCrumb.children.add(partSpecBC);
            currentBreadCrumbIndex++;
            
            Integer partSegBCIndex = currentBreadCrumbIndex;
            BreadCrumb partSegBC = generateBreadCrumb(System.Label.PMP_L0_Partners_Market_Segment, 'partners-by-segment', url);
            if(partSegBC.selected) { partSegBC.children = getPartnerSegment(langCode, null, partnerSegment); }
            breadCrumb.children.add(partSegBC);
            
            if(url.contains('/pmp-category/')) {
                
                String categoryId = getRecordId(url, '/pmp-category/');
                if(String.isNotBlank(categoryId)) {
                    
                    //List<PMP_Category__c> categories = new List<PMP_Category__c>();
                    String catPIMId = PMP_StaticConstants_Partner.taxonomyPimIdMap.get('offeringCategories');
                    String appPIMId = PMP_StaticConstants_Partner.taxonomyPimIdMap.get('offeringApplications');
                    String indPIMId = PMP_StaticConstants_Partner.taxonomyPimIdMap.get('offeringIndustries');
                    Set<String> topLevelIds = new Set<String>();
                    Map<Id, BreadCrumb> catIdAndBreadCrumbMap = new Map<Id, BreadCrumb>();
                    List<PMP_Category__c> categoriesList = [SELECT Id,Name,PMP_Ancestor_Category_Cd__c FROM PMP_Category__c WHERE Id = :categoryId AND PMP_Active_Ind__c = TRUE];
                    
                    if(categoriesList.size() > 0 && String.isNotBlank(categoriesList[0].PMP_Ancestor_Category_Cd__c)) {
                        String ancestorCategory = categoriesList[0].PMP_Ancestor_Category_Cd__c;
                        String pimId = ancestorCategory.contains(catPIMId) ? catPIMId : ancestorCategory.contains(appPIMId) ? appPIMId : ancestorCategory.contains(indPIMId) ? indPIMId : '';
                        String offPIMId = '%' + pimId + '%';
                        
                        if(Schema.sObjectType.PMP_Category__c.isAccessible()) {
                            for(PMP_Category__c cat : [SELECT Id, Name, PMP_Partner_Product_Category_Cd__c, PMP_Category_Chinese_Nm__c, PMP_Category_Japanese_Nm__c,PMP_Category_Chinese_Dsc__c,
                                                       PMP_Partner_Product_Parent_Category_Cd__c, PMP_Parent_Category_Id__c,PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Japanese_Dsc__c,PMP_Ancestor_Category_Cd__c,
                                                       (SELECT Id FROM  Offering_Categories__r WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published and PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE 
                                                        AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY AND PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY AND
                                                        PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = FALSE LIMIT 1) FROM PMP_Category__c WHERE PMP_Active_Ind__c = TRUE AND 
                                                       (PMP_Ancestor_Category_Cd__c like :offPIMId) ORDER BY Name]
                               ){
                                   if(cat.Offering_Categories__r.size() > 0) {
                                       if(cat.PMP_Partner_Product_Parent_Category_Cd__c == pimId) {
                                           topLevelIds.add(cat.Id);
                                       }
                                       BreadCrumb bc = new BreadCrumb();
                                       bc.text = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                                       bc.id = cat.Id;
                                       bc.selected = categoryId == cat.Id;
                                       bc.cancelEvent = true;
                                       bc.useCallback = true;
                                       bc.data = new BreadCrumbData();
                                       bc.data.type = 'standard__recordPage';
                                       bc.data.attributes = new BreadCrumbAttribute();
                                       bc.data.attributes.objectApiName = PMP_StaticConstants_Partner.CAT_OBJ_API;
                                       bc.data.attributes.actionName = 'view';
                                       bc.data.attributes.recordId = cat.Id;
                                       bc.parentId = cat.PMP_Parent_Category_Id__c;
                                       bc.children = new List<BreadCrumb>();
                                       catIdAndBreadCrumbMap.put(cat.Id, bc);
                                   }
                               }
                        }
                        
                        for(BreadCrumb bc : catIdAndBreadCrumbMap.values()) {
                            if(catIdAndBreadCrumbMap.containsKey(bc.parentId) && bc.parentId != null) {
                                catIdAndBreadCrumbMap.get(bc.parentId).children.add(bc);
                            }
                        }
                        // breadcrumb removal IPA 2.0
                        // BreadCrumb bc = pimId == 'NPP_01_TYPE' ? breadCrumb.children[offCatBCIndex] : pimId == 'NPP_01_APP' ? breadCrumb.children[offAppBCIndex] : pimId == 'NPP_01_Industry' ? breadCrumb.children[offIndBCIndex] : new BreadCrumb();
                       BreadCrumb bc = pimId == 'NPP_01_TYPE' ? breadCrumb.children[offCatBCIndex]  : new BreadCrumb();

                        if(bc != null) {
                            bc.children = bc.children == null ? new List<BreadCrumb>() : bc.children;
                            for(String catId : topLevelIds) {
                                bc.children.add(catIdAndBreadCrumbMap.get(catId));
                            }
                        }
                    }
                }
            }
            
            if(url.contains('/pmp-partner-program/')) {
                
                String partnerProgramId = getRecordId(url, '/pmp-partner-program/');
                if(String.isNotBlank(partnerProgramId)) {
                    BreadCrumb bc = breadCrumb.children[partDirBCIndex];
                    bc.children = getPartnerDirectory(langCode, partnerProgramId);
                }
            }
            
            
            if(url.contains('/pmp-partner-category/')) {
                
                String partnerCategoryId = getRecordId(url, '/pmp-partner-category/');
                if(String.isNotBlank(partnerCategoryId)) {
                    List<PMP_Category__c> categories = new List<PMP_Category__c>();
                    Set<String> topLevelIds = new Set<String>();
                    Map<Id, Id> shadowIdMap = new Map<Id, Id>(); 
                    Map<Id, BreadCrumb> catIdAndBreadCrumbMap = new Map<Id, BreadCrumb>();
                    
                    if(Schema.sObjectType.PMP_Category__c.isAccessible()) {
                        for(PMP_Category__c c : [SELECT Id,Name,PMP_Ancestor_Category_Cd__c,PMP_Parent_Category_Id__c,PMP_Ancestor_Category_Nm__c,PMP_Category_Japanese_Nm__c,
                                                 PMP_Partner_Product_Category_Cd__c, PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Chinese_Nm__c,
                                                 (SELECT PMP_Category_Id__c FROM Partner_Industry_Applications__r WHERE PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published 
                                                  AND PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=False limit 1) FROM PMP_Category__c 
                                                 WHERE PMP_Ancestor_Category_Cd__c like '%NPP_01_Industry%' order by Name]
                           ){
                               if(c.Partner_Industry_Applications__r.size() > 0) {
                                   categories.add(c);
                               }
                           } 
                        if(Schema.sObjectType.PMP_Category_Partner__c.isAccessible()) {            
                            for(PMP_Category_Partner__c shadowrecord :[SELECT Id,Name,PMP_Category_Id__c from PMP_Category_Partner__c WHERE PMP_Category_Id__c IN :categories]) {
                                shadowIdMap.put(shadowrecord.PMP_Category_Id__c, shadowrecord.Id);
                            }
                        }
                        
                        for(PMP_Category__c cat : categories) {
                            if(cat.PMP_Ancestor_Category_Cd__c == 'NPP_01_Industry') {
                                topLevelIds.add(cat.Id);
                            }
                            BreadCrumb bc = new BreadCrumb();
                            bc.text = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                            bc.id = shadowIdMap.get(cat.Id);
                            bc.selected = partnerCategoryId == shadowIdMap.get(cat.Id);
                            bc.cancelEvent = true;
                            bc.useCallback = true;
                            bc.data = new BreadCrumbData();
                            bc.data.type = 'standard__recordPage';
                            bc.data.attributes = new BreadCrumbAttribute();
                            bc.data.attributes.objectApiName = 'PMP_Category_Partner__c';
                            bc.data.attributes.actionName = 'view';
                            bc.data.attributes.recordId = shadowIdMap.get(cat.Id);
                            bc.parentId = cat.PMP_Parent_Category_Id__c;
                            bc.children = new List<BreadCrumb>();
                            catIdAndBreadCrumbMap.put(cat.Id, bc);
                        }  
                        
                        for(BreadCrumb bc : catIdAndBreadCrumbMap.values()) {
                            if(catIdAndBreadCrumbMap.containsKey(bc.parentId) && bc.parentId != null) {
                                catIdAndBreadCrumbMap.get(bc.parentId).children.add(bc);
                            }
                        }
                        
                        BreadCrumb bc = breadCrumb.children[partPartBCInext];
                        
                        if(bc != null) {
                            bc.children = bc.children == null ? new List<BreadCrumb>() : bc.children;
                            for(String catId : topLevelIds) {
                                bc.children.add(catIdAndBreadCrumbMap.get(catId));
                            }
                        }
                    }
                }
            }
            
            if(url.contains('/pmp-partner-specialty/')) {
                
                String partnerSpecialityId = getRecordId(url, '/pmp-partner-specialty/');
                if(String.isNotBlank(partnerSpecialityId)) {
                    BreadCrumb bc = breadCrumb.children[partSpecBCIndex];
                    bc.children = getPartnerSpeciality(langCode, partnerSpecialityId, partnerSpeciality);
                }
            }
            
            if(url.contains('/pmp-partner-segment/')) {
                
                String partnerSegmentId = getRecordId(url, '/pmp-partner-segment/');
                if(String.isNotBlank(partnerSegmentId)) {                
                    BreadCrumb bc = breadCrumb.children[partSegBCIndex];
                    bc.children = getPartnerSegment(langCode, partnerSegmentId, partnerSegment);
                }
            }
            
            Boolean isPartner = url.contains('/partner/');
            Boolean isOffering = url.contains('/offering/');
            //Boolean isEvent = url.contains('/pmp-marketplace-event/'); //IPA2.0:TWC729-8114 Topics Removal/Event Removal
            String partOrOffOrEvtId = NULL;
            
            if(isOffering || isPartner /*|| isEvent*/) { //IPA2.0:TWC729-8114 Topics Removal/Event Removal
                String splitBy = isOffering  ? '/offering/' : (/*isPartner ? */'/partner/' /*: '/pmp-marketplace-event/'*/); //IPA2.0:TWC729-8114 Topics Removal/Event Removal
                    partOrOffOrEvtId = getRecordId(url, splitBy);
            }
            
            if(isOffering && partOrOffOrEvtId != NULL) {
                BreadCrumb offCat = breadCrumb.children[offCatBCIndex];
                offCat.selected = true;
                List<PMP_Partner_Offering__c> offerings = new List<PMP_Partner_Offering__c>();
                if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()) { //Apex CRUD Violation Fix
                    offerings = [SELECT Id, Name FROM PMP_Partner_Offering__c WHERE Id = :partOrOffOrEvtId];
                }
                if(offerings.size() > 0) {
                    offCat.children.addAll(getCategories(langCode, 'NPP_01_TYPE'));
                    BreadCrumb offBC = new BreadCrumb();
                    offBC.selected = true;
                    offBC.useCallback = true;
                    offBC.text = offerings[0].Name;
                    offBC.id = partOrOffOrEvtId;
                    offCat.children.add(offBC); 
                }
            }
            
            if(isPartner && partOrOffOrEvtId != NULL && partOrOffOrEvtId != 'PMP_Company__c') {
                BreadCrumb partDir = breadCrumb.children[partDirBCIndex];
                partDir.selected = true;
                partDir.children = partDir.children == NULL ? new List<BreadCrumb>() : partDir.children;
                List<PMP_Company__c> companies = new List<PMP_Company__c>();
                if(Schema.sObjectType.PMP_Company__c.isAccessible()) { //Apex CRUD Violation Fix
                    companies = [SELECT Id, Name FROM PMP_Company__c WHERE Id = :partOrOffOrEvtId];
                }
                if(companies.size() > 0 && Schema.sObjectType.PMP_Partner_Program__c.isAccessible()) {
                    
                    partDir.children.addAll(getPartnerDirectory(langCode, null));
                    BreadCrumb partBC = new BreadCrumb();
                    partBC.selected = true;
                    partBC.useCallback = true;
                    partBC.text = companies[0].Name;
                    partBC.id = partOrOffOrEvtId;
                    partDir.children.add(partBC); 
                }
            }
            //IPA2.0:TWC729-8114 Topics Removal/Event Removal
            /*if(isEvent && partOrOffOrEvtId != NULL) {
                List<PMP_Marketplace_Event__c> events = new List<PMP_Marketplace_Event__c>();
                if(Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()) { //Apex CRUD Violation Fix
                    events = [SELECT Id, Name FROM PMP_Marketplace_Event__c WHERE Id = :partOrOffOrEvtId];
                }
                if(events.size() > 0) {
                    BreadCrumb evtBC = new BreadCrumb();
                    evtBC.selected = true;
                    evtBC.text = events[0].Name;
                    evtBC.id = partOrOffOrEvtId;
                    evtBC.useCallback = true;
                    breadCrumb.children.add(evtBC); 
                }
            }*/
            
            if(!isPartner && !isOffering) {
                updateSelectedFlag(BreadCrumb);
            }
            removeChild(breadCrumb);
        }
        return breadCrumb;
    }
    
    public static Boolean updateSelectedFlag(BreadCrumb breadCrumb) {
        
        Set<String> tempSet = new Set<String> { 'findAPartner', 'findAnOffering' };
        
        if(breadCrumb != NULL && !tempSet.contains(breadCrumb.id) && breadCrumb.children != NULL) { 
            for(BreadCrumb bc : breadCrumb.children) {
                if(bc != NULL) {
                    if(bc.selected == true) {
                        return true;
                    } else {
                        bc.selected = updateSelectedFlag(bc);
                        if(bc.selected == true) { return true; }
                    }
                }
            }
        }
        return false;
    }
    
    public static void removeChild(BreadCrumb breadCrumb) {
        
        if(breadCrumb != NULL && breadCrumb.children != NULL) {
            if(breadCrumb.selected != true) {
                breadCrumb.children = new List<BreadCrumb>(); 
            } else {
                for(BreadCrumb bc : breadCrumb.children) {
                    removeChild(bc);
                }
            }
        }
    }
    
    public static String getRecordId(String url, String splitBy) {
        
        String recId;
        if(String.isNotBlank(url) && String.isNotBlank(splitBy)) {
            
            List<String> tempArr = url.split(splitBy);
            if(tempArr.size() > 1) {
                List<String> strArr = tempArr[1].split('/');
                if(strArr.size() > 0) {
                    recId = strArr[0];
                }
            }
        }
        return recId;
    }
    
    public static BreadCrumb generateBreadCrumb(String pageName, String pageURL, String url) {
        
        BreadCrumb bc = new BreadCrumb();
        bc.id = pageURL;
        bc.selected = url.contains(pageURL);
        bc.text = pageName;
        bc.cancelEvent = true;
        bc.useCallback = true;
        bc.data = new BreadCrumbData();
        bc.data.type = 'comm__namedPage';
        bc.data.attributes = new BreadCrumbAttribute();
        bc.data.attributes.pageName = pageURL;
        bc.children = new List<BreadCrumb>();
        
        return bc;
    }
    
    public static List<BreadCrumb> getCategories(String langCode, String pimId) {
        
        List<BreadCrumb> breadCrumbs = new List<BreadCrumb>();
        
        if(Schema.sObjectType.PMP_Category__c.isAccessible()) { 
            for(PMP_Category__c cat : [SELECT Id, Name, PMP_Partner_Product_Category_Cd__c, PMP_Category_Chinese_Nm__c, PMP_Category_Japanese_Nm__c,PMP_Category_Chinese_Dsc__c,
                                    PMP_Partner_Product_Parent_Category_Cd__c, PMP_Parent_Category_Id__c,PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Japanese_Dsc__c,PMP_Ancestor_Category_Cd__c,
                                    (SELECT Id FROM  Offering_Categories__r WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published and PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE 
                                        AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY AND PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY AND
                                        PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = FALSE LIMIT 1) FROM PMP_Category__c WHERE PMP_Active_Ind__c = TRUE AND 
                                    (PMP_Ancestor_Category_Cd__c = :pimId) ORDER BY Name]
            ){
                if(cat.Offering_Categories__r.size() > 0) {
                    BreadCrumb bc = new BreadCrumb();
                    bc.text = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                    bc.id = cat.Id;
                    bc.cancelEvent = true;
                    bc.useCallback = true;
                    bc.data = new BreadCrumbData();
                    bc.data.type = 'standard__recordPage';
                    bc.data.attributes = new BreadCrumbAttribute();
                    bc.data.attributes.objectApiName = PMP_StaticConstants_Partner.CAT_OBJ_API;
                    bc.data.attributes.actionName = 'view';
                    bc.data.attributes.recordId = cat.Id;
                    bc.parentId = cat.PMP_Parent_Category_Id__c;
                    bc.children = new List<BreadCrumb>();
                    breadCrumbs.add(bc);
                }
            }
        }
        return breadCrumbs;
    }
    
    public static List<BreadCrumb> getPartnerDirectory(String langCode, String partnerProgramId) {
        
        List<BreadCrumb> breadCrumbs = new List<BreadCrumb>();
        
        if(Schema.sObjectType.PMP_Partner_Program__c.isAccessible()) { 
            for(PMP_Partner_Program__c pp : [SELECT id,Name, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Role_Parent_Id__c,PMP_Partner_Program_Desc_Chinese__c, 
                                             PMP_Partner_Program_Desc__c,PMP_Partner_Program_Desc_Japanese__c, PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c
                                             FROM PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c = TRUE AND PMP_Partner_Role_Parent_Id__c = null ORDER BY Name]
               ){
                   BreadCrumb bc = new BreadCrumb();
                   bc.selected = partnerProgramId == pp.Id;
                   bc.text = PMP_SearchUtilityController.getLocalisedName(pp, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                   bc.id = pp.Id;
                   bc.cancelEvent = true;
                   bc.useCallback = true;
                   bc.data = new BreadCrumbData();
                   bc.data.type = 'standard__recordPage';
                   bc.data.attributes = new BreadCrumbAttribute();
                   bc.data.attributes.objectApiName = 'PMP_Partner_Program__c';
                   bc.data.attributes.actionName = 'view';
                   bc.data.attributes.recordId = pp.Id;
                   bc.children = new List<BreadCrumb>();
                   breadCrumbs.add(bc);
               }
        }
        return breadCrumbs;
    }
    
    public static List<BreadCrumb> getPartnerSegment(String langCode, String partnerSegmentId, Set<String> partnerSegment) {
        
        List<BreadCrumb> breadCrumbs = new List<BreadCrumb>();
        String specialtyName = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Name', langCode);
        specialtyName = String.isNotBlank(specialtyName) ? specialtyName : 'Name';
        
        if(Schema.sObjectType.PMP_Partner_Segment__c.isAccessible()) { 
            for(PMP_Partner_Segment__c seg : [SELECT Id, Name, PMP_Is_Active_Ind__c, PMP_Partner_Segment_Value_Txt__c,PMP_Partner_Segment_English_Dsc_Txt__c,PMP_Partner_Segment_Japanese_Dsc_Txt__c,
                                              PMP_Partner_Segment_Chinese_Dsc_Txt__c,PMP_Partner_Segment_Chinese_Name_Txt__c,PMP_Partner_Segment_Japanese_Name_Txt__c
                                              FROM PMP_Partner_Segment__c  WHERE PMP_Is_Active_Ind__c = TRUE AND PMP_Partner_Segment_Value_Txt__c IN :partnerSegment order by Name]
               ) {
                   BreadCrumb bc = new BreadCrumb();
                   bc.text = PMP_SearchUtilityController.getLocalisedName(seg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                   bc.id = seg.Id;
                   bc.selected = partnerSegmentId == seg.Id;
                   bc.cancelEvent = true;
                   bc.useCallback = true;
                   bc.data = new BreadCrumbData();
                   bc.data.type = 'standard__recordPage';
                   bc.data.attributes = new BreadCrumbAttribute();
                   bc.data.attributes.objectApiName = 'PMP_Partner_Segment__c';
                   bc.data.attributes.actionName = 'view';
                   bc.data.attributes.recordId = seg.Id;
                   bc.children = new List<BreadCrumb>();
                   breadCrumbs.add(bc);
               }
        }
        return breadCrumbs;
    }
    
    public static List<BreadCrumb> getPartnerSpeciality(String langCode, String partnerSpecialityId, Set<String> partnerSpeciality) {
        
        List<BreadCrumb> breadCrumbs = new List<BreadCrumb>();
        
        if(Schema.sObjectType.PMP_Partner_Specialty__c.isAccessible()) { 
            
            String specialtyName = PMP_SearchUtilityController.getFieldApiName('PMP_Partner_Specialty__c', 'Name', langCode);
            specialtyName = String.isNotBlank(specialtyName) ? specialtyName : 'Name';
            //List<BreadCrumb> childBC = new List<BreadCrumb>();
            
            for(PMP_Partner_Specialty__c spec : [SELECT name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c, Id, PMP_Partner_Specialty_Chinese_Dsc__c, 
                                                 PMP_Partner_Specialty_English_Dsc__c, PMP_Partner_Specialty_Japanese_Dsc__c, PMP_Is_Active_Ind__c FROM PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE AND 
                                                 (Name IN :partnerSpeciality OR PMP_Partner_Specialty_Japanese_Nm__c IN :partnerSpeciality OR PMP_Partner_Specialty_Chinese_Nm__c IN :partnerSpeciality) ORDER BY Name]
               ) {
                   BreadCrumb bc = new BreadCrumb();
                   bc.text = (String)spec.get(specialtyName);
                   bc.id = spec.Id;
                   bc.selected = partnerSpecialityId == spec.Id;
                   bc.cancelEvent = true;
                   bc.useCallback = true;
                   bc.data = new BreadCrumbData();
                   bc.data.type = 'standard__recordPage';
                   bc.data.attributes = new BreadCrumbAttribute();
                   bc.data.attributes.objectApiName = 'PMP_Partner_Specialty__c';
                   bc.data.attributes.actionName = 'view';
                   bc.data.attributes.recordId = spec.Id;
                   bc.children = new List<BreadCrumb>();
                   breadCrumbs.add(bc);
               }
        }
        return breadCrumbs;
    }
    
    public static List<BreadCrumb> getPartnerIndustry(String langCode) {
        
        List<BreadCrumb> breadCrumbs = new List<BreadCrumb>();
        List<PMP_Category__c> categories = new List<PMP_Category__c>();
        Map<Id, Id> shadowIdMap = new Map<Id, Id>(); 
        
        if(Schema.sObjectType.PMP_Category__c.isAccessible()) { 
            for(PMP_Category__c c : [SELECT Id,Name,PMP_Ancestor_Category_Cd__c,PMP_Parent_Category_Id__c,PMP_Ancestor_Category_Nm__c,PMP_Category_Japanese_Nm__c,
                                    PMP_Partner_Product_Category_Cd__c, PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Chinese_Nm__c,
                                    (SELECT PMP_Category_Id__c FROM Partner_Industry_Applications__r WHERE PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published 
                                    AND PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=False limit 1) FROM PMP_Category__c 
                                    WHERE PMP_Ancestor_Category_Cd__c = 'NPP_01_Industry' order by Name]
            ){
                if(c.Partner_Industry_Applications__r.size() > 0) {
                    categories.add(c);
                }
            } 
            if(Schema.sObjectType.PMP_Category_Partner__c.isAccessible()) { 
                for(PMP_Category_Partner__c shadowrecord :[SELECT Id,Name,PMP_Category_Id__c from PMP_Category_Partner__c WHERE PMP_Category_Id__c IN :categories]) {
                    shadowIdMap.put(shadowrecord.PMP_Category_Id__c, shadowrecord.Id);
                }
            }
            for(PMP_Category__c cat : categories) {
                
                BreadCrumb bc = new BreadCrumb();
                bc.text = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                bc.id = shadowIdMap.get(cat.Id);
                bc.cancelEvent = true;
                bc.useCallback = true;
                bc.data = new BreadCrumbData();
                bc.data.type = 'standard__recordPage';
                bc.data.attributes = new BreadCrumbAttribute();
                bc.data.attributes.objectApiName = 'PMP_Category_Partner__c';
                bc.data.attributes.actionName = 'view';
                bc.data.attributes.recordId = shadowIdMap.get(cat.Id);
                bc.parentId = cat.PMP_Parent_Category_Id__c;
                bc.children = new List<BreadCrumb>();
                breadCrumbs.add(bc);
            }
        }
        return breadCrumbs;
    }

                                                   
    
    @AuraEnabled(cacheable=true)
    public static List<Buttons> getButtons(String langCode) {
        
        List<Buttons> btns = new List<Buttons>();
        Set<String> exceptionalLabel = new Set<String> { System.Label.PMP_FindAPartner, System.Label.PMP_FindAnOffering};
        BreadCrumb breadCrumbs = getIntelSolutionsBreadcrumb(langCode, System.Label.PMP_Marketplace_Community_URL);
        
        for(BreadCrumb bc : breadCrumbs.children) {
            if(!exceptionalLabel.contains(bc.text)) {
                Buttons btn = new Buttons();
                btn.name = bc.text;
                btn.url = '/' + bc.id;
                btns.add(btn);
            }
        }
        return btns;
    }
        
    public class Buttons {
        @AuraEnabled public String name { get; set; } 
        @AuraEnabled public String url { get; set; } 
    }
}