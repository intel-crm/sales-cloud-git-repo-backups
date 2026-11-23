/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchTopicDetailController
* Description : to get the topics data and is related offerings and partner cards
* Version     : 1.0 
* Created Date: 12-May-2022
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/

public without sharing class PMP_SearchTopicDetailController extends PMP_SearchWrapperStore {
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : getTopicDetails
* Description : this method returns TopicDetails Wrapperdata - refer PMP_SearchWrapperStore to see wrapper data
* Version     : 1.0 
* Created Date: 18-May-2022
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/
//     @AuraEnabled(cacheable = true)
//     public static TopicDetails getTopicDetails(String requestJSON){
//         //variables declaraions
//         TopicCardParams params = (TopicCardParams)JSON.deserialize(requestJSON, TopicCardParams.class);
//         TopicDetails topicDetails = new TopicDetails();
//         List<Id> offIds= new List<Id>();
//         list<Id> partnerIds= new List<Id>();
//         String topicId=params.topicId;
//         String langCode=params.langCode;
//         String keyword=params.keyword;
//         String cardType=params.cardType;
//         Integer currentPage=params.currentPage;
//         Integer pageSize=params.pageSize;
//         List<Id> categories=params.categories;
//         List<Id> specifications=params.specifications;
        
//         List<PMP_Marketplace_Topics_Data__c> topics =[SELECT id, PMP_Is_Active__c, PMP_Topic_Chinese_Desc__c, PMP_Topic_Chinese_Title__c, 
//                                                    PMP_Topic_English_Desc__c, PMP_Topic_English_Title__c, PMP_Topic_Id__c,
//                                                    PMP_Topic_Japanese_Desc__c, PMP_Topic_Japanese_Title__c FROM PMP_Marketplace_Topics_Data__c WHERE PMP_Topic_Id__c =:topicId];
        
        
        
//         if(topics.size()>0){
//             //Language code for cache key,key should not contain special characters
//             String cacheLanguage = langCode;
//             cacheLanguage=((langCode=='zh-Hans-CN'|| langCode=='zh-CN' || langCode=='zh_CN') ?'zhHansCN':(langCode=='ja'? 'ja':'enUS'));
            
//             // Name of a partition and key
//             String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');     
// 			Boolean isGuestUser = PMP_SearchUtilityController.isGuest();

//             //Get the flag from Custom Metadata
//             String cacheFlag = PMP_Utility.getValue('PMP_TopicPage_CacheFlag');//switch to handle the platform cache
//             String cacheKey = 'TopicDetails'+cardType+topics[0].PMP_Topic_Id__c+cacheLanguage; //name of the cache key
//             Boolean isTopicPageLoad= (String.isEmpty(keyword) && categories.size()==0 && specifications.size()==0 && currentPage==1 && isGuestUser) ;// check if its detail page load without filters
//             if(isTopicPageLoad && Cache.Org.contains(partitionInput+'.'+cacheKey) && cacheFlag.equalsIgnoreCase('true')){
//                 //To prepare the cachekey
//                 topicDetails = (TopicDetails)Cache.Org.getPartition(partitionInput).get(cacheKey);
//                 if(topicDetails!=NULL){
//                     return topicDetails;
//                 }
//             }
            
//             topicDetails.Name=topics[0].PMP_Topic_English_Title__c;
//             topicDetails.description=topics[0].PMP_Topic_English_Desc__c;
//             topicDetails.topicId=topics[0].PMP_Topic_Id__c;
//             //topic active of inactive , if inactive UI redicts the topic page  to MP error page
//             topicDetails.isActive=topics[0].PMP_Is_Active__c;
            
//             if(cardType=='product'){
//                 // get offerings related to topic and by keyword
//                 offIds=getTopicOfferings(topics[0].PMP_Topic_Id__c, keyword);
//                 system.debug('PPP test: --offIds:'+offIds);
//                 //filter offerings by category (usecase, industry)
//                 if(categories.size()>0){
//                     offIds=PMP_SearchProductController.filterOfferings(categories,offIds);
//                 }
                
//                 //filter offerings by specification
//                 if(specifications.size()>0){
//                     offIds= PMP_SearchContextualFilterController.contFilterOfferings(specifications,offIds);  
//                 }
                
//                 //to form product cards
//                 List<PMP_SearchProductController.Product> products = PMP_SearchProductController.getProducts(offIds, currentPage, pageSize, 'event', langCode, keyword);
//                 topicDetails.productCards = products;
                
//                 if (offIds.size() > 0){
//                     topicDetails.productTotal = offIds.size();
//                 }
                
//             }
            
//             else{
//                 // get partners related to topic and by keyword
//                 partnerIds=getTopicPartners(topics[0].PMP_Topic_Id__c, keyword);
                
//                 //filter partner by category
//                 if(categories.size()>0){
//                     partnerIds= filterPartnersByCategory(categories,partnerIds);
                    
//                 }
//                 //filter partners by region
//                 if(specifications.size()>0){
//                     partnerIds=filterPartnersBySpecification(specifications,partnerIds);
//                 }
                
//                 //to form partner cards
//                 List<PMP_SearchPartnerController.Partner> partners = PMP_SearchPartnerController.getPartners(partnerIds, currentPage, pageSize, 'event', langCode, keyword, null, new List<String>());
//                 topicDetails.partnerCards = partners;
                
//                 if (partnerIds.size() > 0){
//                     topicDetails.partnerTotal = partnerIds.size();
//                 }
//             }
            
//             if(isTopicPageLoad){ //if its page load without filters, then get the data from the cache
//                 //Adding the return value into platform cache
//                 try{
//                     String cacheTTLStr = PMP_Utility.getValue('Cache_TTL');
//                     Integer cacheTTL = Integer.valueOf(cacheTTLStr); // 48hrs
//                     if(cacheFlag.equalsIgnoreCase('true')){
//                         Cache.Org.put(partitionInput+'.'+cacheKey, topicDetails,cacheTTL);  
//                     }
//                 }
//                 Catch(Cache.ItemSizeLimitExceededException error){
//                     System.debug('Error due to Item Size Exceeded::'+error.getMessage() +'at line '+error.getLineNumber());
//                 }Catch(Cache.Org.OrgCacheException error){ 
//                     System.debug('Error due to Partition Exception::'+error.getMessage() +'at line '+error.getLineNumber());
//                 }
//             }
            
//         }   
        
        
//         return topicDetails;
//     }
    
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : getTopicOfferings
// * Description : this method returns List<String> that offering ids related to topic and filtered by keyword 
// * Version     : 1.0 
// * Created Date: 20-May-2022
// * Modification Log :
// * Created By  : Onyx Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
//     public static List<Id> getTopicOfferings(Id topicId,String keyword){
//         List<Id> offIds = new List<Id>();
//         Set<Id> filteroffIdsbykeyword = new Set<Id>();
//         Map<ID, PMP_Partner_Offering__c> offMap= new Map<ID, PMP_Partner_Offering__c>();
//         if (Schema.sObjectType.TopicAssignment.isAccessible()){
            
//             for (TopicAssignment topicOff : [SELECT id,EntityId, EntityType,TopicId FROM TopicAssignment 
//                                              WHERE EntityType='PMP_Partner_Offering' AND  TopicId =:topicId]){
//                                                  offIds.add(topicOff.EntityId);
//                                              }
//         }
        
//        /* if (Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
//             offMap = new Map<ID, PMP_Partner_Offering__c> ([SELECT  Id from PMP_Partner_Offering__c WHERE id in :offIds AND
//                                                             ( PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY 
//                                                              AND PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND PMP_Is_Not_Available_On_MP_Ind__c = false )]);
//         }
//         offIds.clear();
//         offIds.addAll(offMap.keySet());
        
//         if(String.isNotBlank(keyword)){//request.keyword != null is changed to String.isNotBlank(request.keyword) done similar to partner
//             List<List<SObject>> pubTransList= new List<List<SObject>>();    
//             if (Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
                
//                 pubTransList=[FIND :keyword IN ALL FIELDS RETURNING 
//                               PMP_Partner_Offering_Translation__c(PMP_Partner_Offering_Id__c WHERE PMP_Partner_Offering_Id__c IN :offIds)];
//             }
            
//             for (List<SObject> listObj : pubTransList)
//             {
//                 for(SObject obj : listObj)
//                 {
//                     if(obj.getSObjectType() == PMP_Partner_Offering_Translation__c.sObjectType)
//                     {
//                         PMP_Partner_Offering_Translation__c trans = (PMP_Partner_Offering_Translation__c) obj; 
//                         filteroffIdsbykeyword.add(trans.PMP_Partner_Offering_Id__c);
//                     }
//                 }
//             }  
//         }
//         return !String.isEmpty(keyword)?new List<Id> (filteroffIdsbykeyword):new List<Id>(offIds);*/
//         offIds=PMP_SearchProductController.getOfferingIds(keyword,offIds);
//         return offIds;

//     }
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : getTopicPartners
// * Description : this method returns List<String> that partner ids related to topic and filtered by keyword 
// * Version     : 1.0 
// * Created Date: 19-May-2022
// * Modification Log :
// * Created By  : Onyx Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
//     public static List<String> getTopicPartners(Id topicId, String keyword){
        
//         List<String> partnerIds = new List<String>();
//         Map<Id, PMP_Company__c> compList= new Map<Id, PMP_Company__c>();
//         if (Schema.sObjectType.TopicAssignment.isAccessible()){
            
//             for (TopicAssignment topicPartner : [SELECT id,EntityId, EntityType,TopicId FROM TopicAssignment 
//                                                  WHERE EntityType='PMP_Company' And  TopicId =:topicId]){
//                                                      partnerIds.add(topicPartner.EntityId);
                                                     
//                                                  }
//         }
//         if (Schema.sObjectType.PMP_Company__c.isAccessible()){
            
//             compList=new Map<Id, PMP_Company__c> ([SELECT Id from PMP_Company__c
//                                                    WHERE PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published
//                                                    AND PMP_Benefit_Update_Ind__c=False and Id in: partnerIds ]);
//         }
        
//         partnerIds=new List<Id> (compList.keySet());
//         if(String.isNotBlank(keyword)){ 
//             partnerIds = PMP_SearchPartnerController.getPartnerList(keyword, new List<Id> (compList.keySet()));
            
//         }
//         return partnerIds;
//     }
    
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : getTopicMarqueeDetails
// * Description : this method returns TopicDetailsForMarquee wrapper data to UI. this method is called from 
// * Version     : 1.0 
// * Created Date: 20-May-2022
// * Modification Log :
// * Created By  : Onyx Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     @AuraEnabled(cacheable = true)
//     public static TopicDetailsForMarquee getTopicMarqueeDetails(String topicId, String langCode){
//         List<PMP_Marketplace_Topics_Data__c> topicTranslations =[SELECT id, PMP_Is_Active__c, PMP_Topic_Chinese_Desc__c, PMP_Topic_Chinese_Title__c, 
//                                                               PMP_Topic_English_Desc__c, PMP_Topic_English_Title__c, PMP_Topic_Id__c,
//                                                               PMP_Topic_Japanese_Desc__c, PMP_Topic_Japanese_Title__c from PMP_Marketplace_Topics_Data__c WHERE PMP_Topic_Id__c =:topicId];
        
//         TopicDetailsForMarquee topicMarqueeDetails= new TopicDetailsForMarquee();
//         if(topicTranslations.size()>0){
//             topicMarqueeDetails.name=langCode=='zh-Hans-CN'|| langCode=='zh-CN' || langCode=='zh_CN' ?topicTranslations[0].PMP_Topic_Chinese_Title__c:(langCode=='ja'? topicTranslations[0].PMP_Topic_Japanese_Title__c:topicTranslations[0].PMP_Topic_English_Title__c);
//                 topicMarqueeDetails.description=langCode=='zh-Hans-CN' || langCode=='zh-CN' || langCode=='zh_CN' ?topicTranslations[0].PMP_Topic_Chinese_Desc__c:(langCode=='ja'? topicTranslations[0].PMP_Topic_Japanese_Desc__c:topicTranslations[0].PMP_Topic_English_Desc__c);
//                     topicMarqueeDetails.isActive=topicTranslations[0].PMP_Is_Active__c;
//         }
        
//         return topicMarqueeDetails;
//     }
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : filterPartnersBySpecification
// * Description : this method returns List<Id> i.e  partner ids filtered based on specification
// * Version     : 1.0 
// * Created Date: 20-May-2022
// * Modification Log :
// * Created By  : Onyx Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     public static List<Id> filterPartnersBySpecification(List<Id> specIds, List<Id> partnerIds){
//         List<Id> filteredPartnerIds=new List<Id>();
        
//         List<PMP_Company_Region__c> partnerRegionList= new List<PMP_Company_Region__c>();
        
//         if(Schema.sObjectType.PMP_Company_Region__c.isAccessible()){
//             partnerRegionList = [SELECT PMP_Company_Id__c FROM PMP_Company_Region__c  WHERE (PMP_Specification_Id__c IN :specIds OR PMP_Specification_Value__c IN:specIds) AND PMP_Company_Id__c in:partnerIds];
//         }
//         for(PMP_Company_Region__c partner : partnerRegionList)
//         {
//             filteredPartnerIds.add(partner.PMP_Company_Id__c);   
//         }
//         return  filteredPartnerIds;
//     }
    
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : filterPartnersByCategory
// * Description : this method returns List<Id> i.e  partner ids filtered based on category
// * Version     : 1.0 
// * Created Date: 20-May-2022
// * Modification Log :
// * Created By  : Onyx Team (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     public static List<Id> filterPartnersByCategory(list<Id> catIds,List<Id> partnerIds){
//         List<PMP_Partner_Category__c> partnerCategories= new List<PMP_Partner_Category__c>();
//         List<Id> filterPartnerIdsByCategory= new List<Id>();
//         if (Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){
//             partnerCategories=[SELECT PMP_Partner_Id__c FROM PMP_Partner_Category__c WHERE PMP_Category_Id__c =:catIds  AND PMP_Category_Id__r.PMP_Active_Ind__c = TRUE 
//                                AND PMP_Partner_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND PMP_Partner_Id__r.PMP_Benefit_Update_Ind__c=FALSE
//                                AND PMP_Partner_Id__c in: partnerIds];
//         }
//         for(PMP_Partner_Category__c partnerCategory:partnerCategories){
//             filterPartnerIdsByCategory.add(partnerCategory.PMP_Partner_Id__c);
            
//         }
//         return filterPartnerIdsByCategory;
//     }

//     public class TopicCardParams{
//         @AuraEnabled public Id topicId  { get; set; } 
//         @AuraEnabled public String langCode  { get; set; } 
//         @AuraEnabled public String keyword  { get; set; } 
//         @AuraEnabled public String cardType  { get; set; } 
//         @AuraEnabled public Integer currentPage { get; set; } 
//         @AuraEnabled public  Integer pageSize { get; set; } 
//         @AuraEnabled public List<Id> categories  { get; set; } 
//         @AuraEnabled public List<Id> specifications  { get; set; } 
//     }


//      //For Topics
//      public class TopicDetails {
//         @AuraEnabled public String cardType { get; set; } 
//         @AuraEnabled public Integer partnerTotal { get; set; } 
//         @AuraEnabled public Integer productTotal { get; set; } 
//         @AuraEnabled public String topicId { get; set; } 
//         @AuraEnabled public String name { get; set; } 
//         @AuraEnabled public String description { get; set; } 
//         @AuraEnabled public String externalUrl { get; set; } 
//         @AuraEnabled public String image {get; set;}
//         //added for event banner(imageAlt)
//         @AuraEnabled public String imageAlt {get; set;}
//         @AuraEnabled public String title { get; set; }
//         @AuraEnabled public String linkLabel { get; set; }
//         @AuraEnabled public String linkUrl { get; set; }
//         @AuraEnabled public Boolean isInvalidEvent { get; set; }
//         @AuraEnabled public List<PMP_SearchPartnerController.Partner> partnerCards { get; set; }    
//         @AuraEnabled public List<PMP_SearchProductController.Product> productCards { get; set; }  
//         @AuraEnabled public Boolean isActive { get; set; } 

//     }
    
    
//     //For Topics
//     public class TopicDetailsForMarquee {
//         //@AuraEnabled public String topicId { get; set; } 
//         @AuraEnabled public String name { get; set; } 
//         @AuraEnabled public String description { get; set; } 
//         @AuraEnabled public Boolean isActive { get; set; } 

        
//     }
    
    
    
}