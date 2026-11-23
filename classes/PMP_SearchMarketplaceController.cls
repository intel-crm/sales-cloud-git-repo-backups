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
        
        
        System.debug('childCatId : '+childCatId);   //Id of Contextual filter selected.
        Map<String, List<String>> selectedFilters = null;
        //Added by Kartik as part of US598273
        //Checking for Object name to put the correct childCatId
        String sobjectType = childCatId.getSObjectType().getDescribe().getName();
        
        if(sobjectType == 'PMP_Category__c'){
            
            
            try{
                PMP_Category__c childCat = [SELECT id,PMP_Ancestor_Category_Cd__c from PMP_Category__c where id =: childCatId limit 1];
                system.debug('Split : '+ childCat.PMP_Ancestor_Category_Cd__c.split('\\|')[0]);
                PMP_Category__c parentCat = [SELECT id,PMP_Partner_Product_Category_Cd__c from PMP_Category__c
                                             where PMP_Partner_Product_Category_Cd__c=:childCat.PMP_Ancestor_Category_Cd__c.split('\\|')[0]];
                
                System.debug('parentCat.Id : '+parentCat.Id);
                
                selectedFilters = new Map<String, List<String>>();
                List<String> selectedTagIds = new List<String>();
                selectedTagIds.add(childCatId);
                
                System.debug('parentCat.Id : '+parentCat.Id);
                System.debug('Selected Tag Ids : '+selectedTagIds);
                if(childCat.PMP_Ancestor_Category_Cd__c.split('\\|')[0] != 'NPP_01_TYPE'){
                   selectedFilters.put(parentCat.Id, selectedTagIds); 
                }
                
            }catch(Exception e){
                system.debug('Error in fetching selectedFilters : '+ e.getMessage());
            }
        }else if(sobjectType == 'PMP_Specification__c'){
            try{
                PMP_Specification__c childSpec = [SELECT id,PMP_Ancestor_Specification_Cd__c from PMP_Specification__c where id =: childCatId limit 1];
                system.debug('Split : '+ childSpec.PMP_Ancestor_Specification_Cd__c.split('\\|')[0]); //Ancestor or root value for regions.
                PMP_Specification__c parentSpec = [SELECT id,PMP_Product_Parent_Specification_Id__c from PMP_Specification__c
                                                   where PMP_Partner_Product_Specification_Id__c =:childSpec.PMP_Ancestor_Specification_Cd__c.split('\\|')[0] limit 1];
                
                System.debug('After SOQL Queries');
                
                System.debug('parentSpec.Id = '+parentSpec.Id); //Parent Contextual filter selected.
                
                selectedFilters = new Map<String, List<String>>();
                List<String> selectedTagIds = new List<String>();
                selectedTagIds.add(childCatId);
                System.debug('Selected Tag Ids : '+selectedTagIds);   //Child Contextual filter selected.
                System.debug('parentSpec.Id = '+parentSpec.Id); 
                selectedFilters.put(parentSpec.Id, selectedTagIds);
            }catch(Exception e){
                system.debug('Error in fetching selectedFilters : '+ e.getMessage());
            } 
        }  
        
        
        return selectedFilters; 
        
    }
    
    @AuraEnabled(cacheable=true)       
    public static String categorySearch(String requestJSON) {
        return PMP_SearchUtilityController.categorySearch(requestJSON);
    }
    
   /* @AuraEnabled(cacheable=true)       
    public static String lazyLoadTest(String requestJSON) {
        return JSON.serialize('lazy');
    }*/
    
    @AuraEnabled(cacheable=true)
    public static String search(String requestJSON) {
        
        return PMP_SearchUtilityController.search(requestJSON);
    }
    
    @AuraEnabled(cacheable=true)
    public static String searchAutoComplete(String query,String Type, String langCode) {
        return PMP_SearchUtilityController.searchAutoComplete(query, Type,langCode);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Option> getSearchFilterData(String searchType, String langCode) {
        return PMP_SearchQuickSearchDataController.getSearchFilterData(searchType, langCode);
    }
    
    @AuraEnabled(cacheable=true)
    public static PartnerDetail getPartnerDetails(String partnerId, String langCode) {
        return PMP_SearchPartnerDetailsController.getPartnerDetails(partnerId, langCode);
    }
    
    
    @AuraEnabled(cacheable=true)
    public static ArticleData getPartnerArticles(String partnerId, String langCode){
        return PMP_SearchCompanyArticles.getPartnerArticles(partnerId, langCode);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FeaturedProductTab> getFeaturedTabs(String langCode) { 
        return PMP_SearchFeaturedCarouselController.getFeaturedTabs(langCode);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product> getFeaturedOfferings(String catId, Integer prevLmt, Integer currentLmt, String langCode) { 
        return PMP_SearchFeaturedCarouselController.getFeaturedOfferings(catId, prevLmt , currentLmt, langCode);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Listing> getCategoryData(String searchType, String langCode) {
        return PMP_SearchCategoryCardListController.getCategoryData(searchType, langCode);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Listing> getPartnerPrograms(String langCode) {
        return PMP_SearchCategoryCardListController.getPartnerPrograms(langCode);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Listing> getSpecialistGroupListData(String pageType, String langCode) {
        return PMP_SearchSpecialistGroupListController.getSpecialistGroupListData(pageType, langCode);
    }
    
    
    
    //To Fetch Multiple Offering Details
    @AuraEnabled(cacheable=true)
    public static Map<String, String> fetchMultipleOfferings(List<Id> offeringIds, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering, String langCode) {
        system.debug('MPsearchCntlr-->' +bCompareOffering);
        return PMP_OfferingDetailsController.fetchOfferingDetails(offeringIds,bEditOffering,bViewOffering,bCompareOffering);
        
    } 
    
    
    @AuraEnabled(cacheable=true)
    public static String getUserInfo(){
        
        return UserInfo.getFirstName()+' '+ UserInfo.getLastName() + '' + UserInfo.getUserId();
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Promotion> getPromotionData(String userLanguage){
        return PMP_SearchEventDetailController.getPromotionData(userLanguage);
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Option> getPromotionLanguageOptions(){
        return PMP_SearchEventDetailController.getPromotionLanguageOptions();
    }
    
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
        Id userAccountId = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()].AccountId;
        try
        {
            permissionSetList = [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                                 AND PermissionSet.Name =:PMP_StaticConstants_Partner.OFFERING_EDITOR];
            for(PermissionSetAssignment per: permissionSetList)
            {
                if(per.PermissionSet.Name==PMP_StaticConstants_Partner.OFFERING_EDITOR)
                {
                    
                    accountBenefit = [SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                                      WHERE PRM_Account_Id__c =:userAccountId AND (PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c =:PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE AND PRM_Status_Nm__c = 'Active')]; 
                    if(accountBenefit.size()>0){
                        result =true;
                    } 
                    
                }
                
            }
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
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
                                      OR PermissionSet.Name =:PMP_StaticConstants_Partner.OFFERING_EDITOR)];
            
            
            if(permissionSetList.size()>0){
                
                result =true;
            }
        }
        catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,List<SeoCat>> getAllCategories(){
        return PMP_SearchSiteMapController.getAllCategories();
    }
    
    @AuraEnabled
    public static String updatePartnerInfo(String partnerId) {
        return PMP_SearchPartnerDetailsController.updatePartnerInfo(partnerId);
    }
    
    @AuraEnabled
    public static boolean isEmployee(){
        return PMP_DashboardTabVisibilityController.isEmployee();
    }

    @AuraEnabled
    public static boolean isLeadTabforAdminsAndLDR(){
        return PMP_DashboardTabVisibilityController.isLeadTabforAdminsAndLDR();
    } 
}