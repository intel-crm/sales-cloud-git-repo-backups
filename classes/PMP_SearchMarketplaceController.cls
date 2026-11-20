/****************************************************************************************************************************************
* Class Name  : PMP_SearchMarketplaceController 
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By : Tanzanite Team Infosys
* 
*****************************************************************************************************************************************/

public with sharing class PMP_SearchMarketplaceController extends PMP_SearchWrapperStore{
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getSelectedFilters(Id childCatId){ //Changed childCatId from String to Id for getSobjectType()
        
        
        // System.debug('childCatId : '+childCatId);   //Id of Contextual filter selected.
        Map<String, List<String>> selectedFilters = null;
        //Added by Kartik as part of US598273
        //Checking for Object name to put the correct childCatId
        String sobjectType = childCatId.getSObjectType().getDescribe().getName();
        
        if(sobjectType == 'PMP_Category__c'){
            
            
            try{
                PMP_Category__c childCat = [SELECT id,PMP_Ancestor_Category_Cd__c from PMP_Category__c where id =: childCatId  WITH SECURITY_ENFORCED limit 1];
                //system.debug('Split : '+ childCat.PMP_Ancestor_Category_Cd__c.split('\\|')[0]);
                PMP_Category__c parentCat = [SELECT id,PMP_Partner_Product_Category_Cd__c from PMP_Category__c
                                             where PMP_Partner_Product_Category_Cd__c=:childCat.PMP_Ancestor_Category_Cd__c.split('\\|')[0]  WITH SECURITY_ENFORCED ];
                
                // System.debug('parentCat.Id : '+parentCat.Id);
                
                selectedFilters = new Map<String, List<String>>();
                List<String> selectedTagIds = new List<String>();
                selectedTagIds.add(childCatId);
                
                // System.debug('parentCat.Id : '+parentCat.Id);
                // System.debug('Selected Tag Ids : '+selectedTagIds);
                
                selectedFilters.put(parentCat.Id, selectedTagIds);
            }catch(Exception e){
                system.debug('Error in fetching selectedFilters : '+ e.getMessage());
            }
        }else if(sobjectType == 'PMP_Specification__c'){
            try{
                PMP_Specification__c childSpec = [SELECT id,PMP_Ancestor_Specification_Cd__c from PMP_Specification__c where id =: childCatId   WITH SECURITY_ENFORCED limit 1];
                //system.debug('Split : '+ childSpec.PMP_Ancestor_Specification_Cd__c.split('\\|')[0]); //Ancestor or root value for regions.
                PMP_Specification__c parentSpec = [SELECT id,PMP_Product_Parent_Specification_Id__c from PMP_Specification__c
                                                   where PMP_Partner_Product_Specification_Id__c =:childSpec.PMP_Ancestor_Specification_Cd__c.split('\\|')[0]   WITH SECURITY_ENFORCED limit 1];
                
                // System.debug('After SOQL Queries');
                
                // System.debug('parentSpec.Id = '+parentSpec.Id); //Parent Contextual filter selected.
                
                selectedFilters = new Map<String, List<String>>();
                List<String> selectedTagIds = new List<String>();
                selectedTagIds.add(childCatId);
                 //System.debug('Selected Tag Ids : '+selectedTagIds);   //Child Contextual filter selected.
                 //System.debug('parentSpec.Id = '+parentSpec.Id); 
                selectedFilters.put(parentSpec.Id, selectedTagIds);
            }catch(Exception e){
                system.debug('Error in fetching selectedFilters : '+ e.getMessage());
            } 
        }  
        
        
        return selectedFilters; 
        
    }
    
 /*   @AuraEnabled(cacheable=true)       
    public static String categorySearch(String requestJSON) {
        //Abhishek- spike for performance
        string response = PMP_SearchUtilityController.categorySearch(requestJSON);
        //Cache.Org.put('local.PMPMarketplaceOrgCache.categorySearch', response ,172800 );
        return response;
    }*/
    
    /*@AuraEnabled(cacheable=true)       
    public static String lazyLoadTest(String requestJSON) {
        return PMP_SearchFilterLazyLoading.lazyLoadFilters(requestJSON);
    }*/
    
  /*  @AuraEnabled(cacheable=true)
    public static String search(String requestJSON) {
        //Abhishek- spike for performance
        string response = PMP_SearchUtilityController.search(requestJSON);
       // Cache.Org.put('local.PMPMarketplaceOrgCache.searchMethod', response ,172800 );
        return response;
    }*/
    
  /*  @AuraEnabled(cacheable=true)
    public static String searchAutoComplete(String query,String Type, String langCode) {
        return PMP_SearchUtilityController.searchAutoComplete(query, Type,langCode);
    }*/
    
    // @AuraEnabled(cacheable=true)
    // public static List<Option> getSearchFilterData(String searchType, String langCode) {
    //     return PMP_SearchQuickSearchDataController.getSearchFilterData(searchType, langCode);
    // }
    
    @AuraEnabled(cacheable=true)
    public static PartnerDetail getPartnerDetails(String partnerId, String langCode) {
        return PMP_SearchPartnerDetailsController.getPartnerDetails(partnerId, langCode);
    }
    
    
    @AuraEnabled(cacheable=true)
    public static ArticleData getPartnerArticles(String partnerId, String langCode){
        //return PMP_SearchCompanyArticles.getPartnerArticles(partnerId, langCode);
        return PMP_CompanyArticles.getArticles(partnerId, langCode);
    }
    
    // @AuraEnabled(cacheable=true)
    // public static List<FeaturedProductTab> getFeaturedTabs(String langCode) { 
    //     return PMP_SearchFeaturedCarouselController.getFeaturedTabs(langCode);
    // }
    
    // @AuraEnabled(cacheable=true)
    // public static List<Product> getFeaturedOfferings(String catId, Integer prevLmt, Integer currentLmt, String langCode) { 
    //     return PMP_SearchFeaturedCarouselController.getFeaturedOfferings(catId, prevLmt , currentLmt, langCode);
    // }
    
    // @AuraEnabled(cacheable=true)
    // public static List<Listing> getCategoryData(String searchType, String langCode) {
    //     return PMP_SearchCategoryCardListController.getCategoryData(searchType, langCode);
    // }
    
    // @AuraEnabled(cacheable=true)
    // public static List<Listing> getPartnerPrograms(String langCode) {
    //     return PMP_SearchCategoryCardListController.getPartnerPrograms(langCode);
    // }
    
    // @AuraEnabled(cacheable=true)
    // public static List<Listing> getSpecialistGroupListData(String pageType, String langCode) {
    //     return PMP_SearchSpecialistGroupListController.getSpecialistGroupListData(pageType, langCode);
    // }
    
    //To Fetch Multiple Offering Details
    //Gireesh
    //No longer be using it 
    /*@AuraEnabled(cacheable=true)
    public static Map<String, String> fetchMultipleOfferings(List<Id> offeringIds, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering, String langCode) {
        return PMP_OfferingDetailsController.fetchOfferingDetails(offeringIds,bEditOffering,bViewOffering,bCompareOffering, langCode);
        
    }*/
    
    
    @AuraEnabled(cacheable=true)
    public static String getUserInfo(){
        
        return UserInfo.getFirstName()+' '+ UserInfo.getLastName() + '' + UserInfo.getUserId();
    }
    
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*@AuraEnabled(cacheable=true)
    public static List<Promotion> getPromotionData(String userLanguage){
        return PMP_SearchEventDetailController.getPromotionData(userLanguage);
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Option> getPromotionLanguageOptions(){
        return PMP_SearchEventDetailController.getPromotionLanguageOptions();
    }*/
    
    @AuraEnabled
    public static boolean isMPAdmin(){
        return PMP_DashboardTabVisibilityController.isMPAdmin();
    }
    @AuraEnabled
    public static boolean isBasicProfileBenefit(){
        return PMP_DashboardTabVisibilityController.isBasicProfileBenefit();
    }
    
    
    //Method to fetch benefit and hiding tabs in dashboard for Offering Editor - Added by Megha[US528775] 
    @AuraEnabled
    public static Boolean isBasicProfileBenefitForOE(){
        Boolean result = false;
        
        List<PRM_AccountBenefitAssociation__c> accountBenefit = new List<PRM_AccountBenefitAssociation__c>();
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Id userAccountId = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED].AccountId;
        try
        {
            permissionSetList = [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                                 AND PermissionSet.Name =:PMP_StaticConstants_Partner.OFFERING_EDITOR  WITH SECURITY_ENFORCED];
            
            accountBenefit = [SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                              WHERE PRM_Account_Id__c =:userAccountId AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c =:PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE AND PRM_Status_Nm__c = 'Active'  WITH SECURITY_ENFORCED];
            
            for(PermissionSetAssignment per: permissionSetList)
            {
                if(per.PermissionSet.Name==PMP_StaticConstants_Partner.OFFERING_EDITOR)
                {
                    /*
                    accountBenefit = [SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                    WHERE PRM_Account_Id__c =:userAccountId AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c =:PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE AND PRM_Status_Nm__c = 'Active']; 
                    */
                    if(accountBenefit.size()>0){
                        result =true;
                    } 
                    
                }
                
            }
            
        }
        catch(Exception e)
        {
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    //Method to fetch the MS AND OE permission set to hide the lead tab in dashboard - Added by Megha[US528777]
    //Added Employee Permission set as part of requirement - Added by manjula[US613062]    
    @AuraEnabled
    public static Boolean isMarketingSpecialistAndOfferingEditor(){
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Boolean result = false;
        try{
            //Query to fetch MS and OE Permission set
            
            permissionSetList = [SELECT Id  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
            AND (PermissionSet.Name =:PMP_StaticConstants_Partner.MARKETING_SPECIALIST
            OR PermissionSet.Name =:PMP_StaticConstants_Partner.OFFERING_EDITOR
            OR PermissionSet.Name =:PMP_StaticConstants_Partner.EMPLOYEE )];//
            permissionSetList = [SELECT Id  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                                 AND (PermissionSet.Name =:PMP_StaticConstants_Partner.MARKETING_SPECIALIST
                                      OR PermissionSet.Name =:PMP_StaticConstants_Partner.OFFERING_EDITOR
                                     )  WITH SECURITY_ENFORCED];
            
            
            if(permissionSetList.size()>0){
                
                result =true;
            }
        }
        catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
        return result;
    }
    
    @AuraEnabled
    public static boolean isEmployee(){
        return PMP_DashboardTabVisibilityController.isEmployee();
    }
    
    @AuraEnabled
    public static boolean isLeadTabforAdminsAndLDR()
    {
        return PMP_DashboardTabVisibilityController.isLeadTabforAdminsAndLDR();
    }
    
    
    
    
    // @AuraEnabled(cacheable=true)
    // public static Map<String,List<SeoCat>> getAllCategories(String langCode){
    //     return PMP_SearchSiteMapController.getAllCategories(langCode);
    // }
    
    @AuraEnabled
    public static String updatePartnerInfo(String partnerId) {
        return PMP_SearchPartnerDetailsController.updatePartnerInfo(partnerId);
    }
    
    @AuraEnabled
    public static Boolean checkValidPartner(String partnerId){
        
        Boolean isActive = FALSE;
        
        if(isPartnerPermissionUser()) {
            if(Schema.sObjectType.PMP_Company__c.isAccessible()) {
                List<PMP_Company__c> company = [SELECT Id FROM PMP_Company__c WHERE Id = :partnerId AND PMP_Benefit_Update_Ind__c = FALSE 
                                                AND (PMP_Published_Copy_Id__r.PMP_Benefit_Update_Ind__c = FALSE OR PMP_Working_Copy_Id__r.PMP_Benefit_Update_Ind__c = FALSE) AND PMP_Partner_Benefit_Type__c!='Solution Marketplace Basic Access'];
                isActive = company.size() > 0;
            }
        } else if(partnerId != null) {
            isActive = PMP_SearchUtilityController.isIntelAdmin();
            //Below condition added by Krishna as part of TWC1824-5246 : QA: MP: Bookmarked URL of inactivated Storefront issue.
              if(Schema.sObjectType.PMP_Company__c.isAccessible()) {
                /*List<PMP_Company__c> companies1 = [SELECT Id,PMP_Is_Published_Ind__c FROM PMP_Company__c WHERE Id = :partnerId AND PMP_Benefit_Update_Ind__c = FALSE 
                                                AND (PMP_Published_Copy_Id__r.PMP_Benefit_Update_Ind__c = FALSE OR PMP_Working_Copy_Id__r.PMP_Benefit_Update_Ind__c = FALSE) AND PMP_Partner_Benefit_Type__c!='Solution Marketplace Basic Access'];*/
				//TWC729-7584 - ApexGuru
                List<PMP_Company__c> companies1 = [SELECT Id,PMP_Is_Published_Ind__c FROM PMP_Company__c WHERE Id = :partnerId AND PMP_Benefit_Update_Ind__c = FALSE 
                                                AND (PMP_Published_Copy_Id__r.PMP_Benefit_Update_Ind__c = FALSE OR PMP_Working_Copy_Id__r.PMP_Benefit_Update_Ind__c = FALSE) AND PMP_Partner_Benefit_Type__c IN ('Solutions Marketplace Basic Profile', 'Solutions Marketplace Enhanced', '')];
                isActive = companies1.size() > 0;
                }
            

            if(!isActive && Schema.sObjectType.PMP_Company__c.isAccessible()) { 
                //if(Schema.sObjectType.PMP_Company__c.isAccessible()) {
                    List<PMP_Company__c> companies = [SELECT Id,PMP_Is_Published_Ind__c FROM PMP_Company__c WHERE Id = :partnerId];
                    if(companies.size() > 0) {
                        List<PMP_Company__c> partners = new List<PMP_Company__c>();
                        if(companies[0].PMP_Is_Published_Ind__c) {
                            partners = [SELECT Id FROM PMP_Company__c WHERE Id = :partnerId AND PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND PMP_Benefit_Update_Ind__c = FALSE AND PMP_Partner_Benefit_Type__c!='Solutions Marketplace Basic Profile'/*'Solution Marketplace Basic Access'*/];
                            // system.debug('if Partners: ' +partners);

                        } else {
                            partners = [SELECT Id FROM PMP_Company__c WHERE Id = :partnerId AND PMP_Published_Copy_Id__r.PMP_Benefit_Update_Ind__c = FALSE AND PMP_Partner_Benefit_Type__c!='Solutions Marketplace Basic Profile'/*'Solution Marketplace Basic Access'*/];
                            //system.debug('else partners: ' +partners);

                        }
                        isActive = partners.size() > 0;                    
                    }
                //}
            }
        }
        return isActive;
    }
    
    public static Boolean isPartnerPermissionUser() {
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Set<String> ps = new Set<String> {PMP_StaticConstants_Partner.PARTNER_ADMIN, PMP_StaticConstants_Partner.MARKETING_SPECIALIST, PMP_StaticConstants_Partner.EMPLOYEE,
            PMP_StaticConstants_Partner.LDR, PMP_StaticConstants_Partner.OFFERING_EDITOR };
        permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId() AND PermissionSet.Name = :ps];
        return permissionSetList.size() > 0;
    	
    }

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*@AuraEnabled(cacheable=true)
    public static String getEventIdForTopics(String topicId){
        return PMP_MarketplaceTopics.getEventIdForTopics(topicId);
    }

    @AuraEnabled
    public static void getCloneImageToEvents(String topicId){
        PMP_MarketplaceTopics.cloneImageToEvents(topicId);
    }

    @AuraEnabled
    public static boolean getEventTopicType(String topicId){
        return PMP_MarketplaceTopics.getEventTopicType(topicId);
    }*/   
}