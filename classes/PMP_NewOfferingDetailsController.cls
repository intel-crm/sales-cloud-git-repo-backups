/*************************************************************************************************************************************************************************
* Class Name  : PMP_NewOfferingDetailsController  
* Version     : 1.0 
* Created Date: 11/10/2021
* Modification Log :
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Vasanth Krishnamurthy        : Original version         11/10/2021                            This class is used for functionalities related to new offering Detail page
**************************************************************************************************************************************************************************/
public with sharing class PMP_NewOfferingDetailsController extends PMP_SearchWrapperStore{
//     public static boolean recurseCheck = false;

//     /**
//     * @description Method To Fetch Multiple Offering Details
//     * @param Id
//     * @return String
//     **/
//     @AuraEnabled
//     public static Map<String,object> fetchOfferingDetails(List<Id> offeringIds,Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering, String langCode, Boolean isPartnerDetails){
//         Map<String,object> offerings = new Map<String,String>();
//         map<string,object> multiProductInfo = new map<string,object>();
        
//         Map<String, Map<String, object>> details = new Map<String, Map<String, object>>();
//         for(Integer i=0;i<offeringIds.size();i++)
//         {    
//             if(isPartnerDetails){
//               multiProductInfo.put(offeringIds[i],PMP_SearchMarqueeDetailController.getProductInformation(offeringIds[i], langCode));   
//             }
//             else{
//                 offerings.put(offeringIds[i], PMP_OfferingDetailsController.fetchOfferingDetail(offeringIds[i], bEditOffering, bViewOffering,bCompareOffering,null,langCode,null));          
//             }
            
//         } 
//         if(isPartnerDetails){
//             details.put('productInfo', multiProductInfo);
//         }
//         else{
//             details.put('offerings', offerings);
//         }
//         return details;

//     }
    
//    @AuraEnabled
//    public static String getOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){
//        if(isPreview){
//            String offeringDetailResponse = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode,isPreview);
//            return offeringDetailResponse;
//        }else{
//            String offeringDetailNotPrevResponse = fetchOfferingDetailNotPreview(offeringId, bEditOffering, bViewOffering, bCompareOffering, language, langCode,isPreview);
//            return offeringDetailNotPrevResponse;
//        }       
       
//    } 
    
//     /**
//     * @description Method to fetch all the offering related data
//     * @param Id
//     * @return String
//     **/
//    @AuraEnabled
//     public static String fetchOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){
//         String userURLLaguageCode = language; 
//         Boolean bSuccessful = true;    
//         map<string,object> uiData = new map<string,object>();
//         map<String, Object> mapErrorInfo = new map<string,object>();
//         Map<String,List<sObject>> fetchOffering = new Map<String,List<sObject>>();
//         List<PMP_Partner_Offering_Resource__c> offeringResources = new List<PMP_Partner_Offering_Resource__c>();
//         List<ContentDocument> conDocuments = new List<ContentDocument>();
//         List<ContentVersion> conVersions = new List<ContentVersion>();
//         List<ContentAsset> conAssets = new List<ContentAsset>();
//         List<ContentAsset> thumbNailconAssets = new List<ContentAsset>();
//         List<ContentAsset> imageConAssets = new List<ContentAsset>();
//         //List<ContentDistribution> conDistribution = new List<ContentDistribution>();
//         List<Id> contentDocIds = New List<Id>();
//         List<OfferingResourceWrapper> resourceWrapperList = New List<OfferingResourceWrapper>();
//         Map<String,ContentDocument> contentDocMap = New Map<String,ContentDocument>();
//         List <offeringSpecValueMap> specMapWrapper = New List <offeringSpecValueMap>();
//         List<String> docIds = new List<String>();
//         Map<id,PMP_Partner_Offering_Resource__c > docIdIResourceMap = New Map<id, PMP_Partner_Offering_Resource__c >();
//         List<PMP_Partner_Offering__c> offeringdetail = new List<PMP_Partner_Offering__c>();
//         Set<Id> contentAssetIds = new Set<Id>();
//         Integer seqNumberCounter = 0;
//         Map<string, contentAssetWrapper> contentAssetWrapperMap = New Map<string, contentAssetWrapper>(); 

//         //fetch base community URL
//         String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
            
//         //remove '/s' from baseCommunityUrl community URL
//         if(baseCommunityUrl.endsWith('/s')){
//             baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
//         }            
//         //fetch static text called "/file-asset" from metaData
//         String staticFileAsset = PMP_Utility.getValue('Community_File_Asset'); 
                          

//         Boolean isEventExist = False;
//         List<PMP_Marketplace_Event_Offering__c> eventPartnerOffering = new List<PMP_Marketplace_Event_Offering__c>();
        
//         if (Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible()) {
//             eventPartnerOffering = [select Id, Name, PMP_Event_Id__c from PMP_Marketplace_Event_Offering__c where PMP_Offering_Id__c=:offeringId AND PMP_Event_Id__r.PMP_Marketplace_Event_Status__c =true];
//         }
        
//         system.debug('eventPartnerOffering::'+eventPartnerOffering);
//         if(!eventPartnerOffering.isEmpty()){
//             isEventExist=True;
//         }
//         uiData.put('eventPartnerOffering',isEventExist);

       
//         String cacheLanguage;
//         String jsonValue;
//         Boolean cachePreview=False;
//        // String cachedOffering;
       
//         //Caching only for Guest users
//         Boolean isGuestUser = false;
//         Id profileId = userInfo.getProfileId();

//         String guestProfileName = [Select Name from Profile where Id =: profileId].Name;
//         if(PMP_StaticConstants_Offering.guestProfiles.contains(guestProfileName)){
//             isGuestUser = true;
//         }

      
//         //Add the guest user language to Cache as Key
//         if(langCode != null){
//             if(langCode.contains('_')){
//                 cacheLanguage = langCode.replace('_', '');
//             }else{
//                 cacheLanguage = langCode;
//             }
//         }
//         System.debug('Param Values----'+offeringId +'--- '+cacheLanguage);
//         // Name of a partition
//         String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        
//         //Get the flag from Custom Metadata
//         String cacheFlag = PMP_Utility.getValue('OfferingDetail_CacheFlag');
         
//         //Prepare the key
//         String cacheKey = 'OfferingDetail'+(String)offeringId+cacheLanguage; 

        
//         if(isPreview != null){
//             cachePreview = isPreview; 
//         } 
        
//         if(Cache.Org.contains(partitionInput+'.'+cacheKey) && !cachePreview  && cacheFlag.equalsIgnoreCase('true') && isGuestUser){
//             jsonValue = (String)Cache.Org.getPartition(partitionInput).get(cacheKey);
//             if(jsonValue != null){
                
//             return jsonValue;  
//             }
//         }
//         else{
                 
//           String userLanguageCode = userinfo.getLanguage();
//           if(userLanguageCode =='ja'){
//             userLanguageCode = userLanguageCode+ '_JP'; 
//           }
        
//         try{  
//             for(PMP_Partner_Offering__c offering : [Select id,
//                                             (Select id,Name,PMP_Partner_Offering_Image__c,toLabel(PMP_Resource_Type_Nm__c),PMP_Resource_Description_Txt__c,
//                                             PMP_Partner_Offering_Resource_URL_Txt__c,PMP_Offering_Id__c,PMP_Resource_Sequence_Nbr__c from Offering_Resources__r ORDER by PMP_Resource_Sequence_Nbr__c),
//                                             PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Partner_Offering_End_Dt__c,PMP_Offering_Language_Nm__c,
//                                             PMP_Partner_Offering_Id__c,PMP_Partner_Offering_Start_Dt__c,PMP_Offering_Status_Update_Dt__c,PMP_Translated_Languages__c,
//                                             PMP_Partner_Revision_Comment_Txt__c,PMP_Company_Id__c,PMP_Company_Id__r.Name,PMP_Working_Copy_Id__c,
//                                             PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,Name,PMP_Partner_Offering_Nm__c,
//                                             PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__c,
//                                             PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Is_Notified_Ind__c,PMP_Pre_Release_Check_Nm__c,PMP_Pre_Release_Item_Count_Num__c,
//                                             PMP_Category_nm__c, PMP_Sub_Category_nm__c         
//                                             from PMP_Partner_Offering__c where id = :offeringId])
//             {
            

//                 if(langCode!=null && langCode =='ja'){
//                     langCode = langCode+ '_JP';
//                 }
//              if(language != 'NA'){
//                      List<PMP_Partner_Offering_Translation__c> translatedValues = PMP_Utility.getOfferingTranslationRecords(offeringId);
//                             Map<string,string> languageFieldMap = New Map<string,string>();
//                             List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMtdList = New List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();
//                             if(language!= null){ 
//                                localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(language,'Offering_Translation');
//                             }
//                             else if(language== null && langCode!=null){ //Gireesh:US664733: To display in categories and specifications in respective lang based on 'language' param ex: '?language=zh_CN' for anonymous user
//                                 localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(langCode,'Offering_Translation');
//                             }
//                             else{
//                                 localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(userLanguageCode ,'Offering_Translation');
//                             }
                            
//                             for(PMP_Locale_To_FieldAPINm_Mapping__mdt mapping : localeMtdList ){
//                                  languageFieldMap.put(mapping.PMP_Locale_Nm__c,mapping.PMP_Field_APINm__c );
//                              } 
//                         Map<string, PMP_Partner_Offering_Translation__c> fieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c>();
//                         if(translatedValues.size()>0){
//                             for(PMP_Partner_Offering_Translation__c iterValue : translatedValues){
//                             system.debug('trans--.' +iterValue );
//                                 fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
//                             }
//                         }
//                         system.debug(userLanguageCode );

               
//                      if(language ==null && langCode!=null && languageFieldMap.get(langCode)!=null &&  fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c')
//                         && string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(langCode )))!=null){
//                             language = langCode; 
//                         }
//                      else{
//                          if(language==null && fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c') && languageFieldMap.get(userLanguageCode)!=null
//                             && string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(userLanguageCode )))!=null){
//                                 language = userLanguageCode; 
//                             }
                         
//                      }

//                     system.debug('lang183--'+ language);   
//                     if(language!=null && language != 'NA'){ 
                        
//                         offering.PMP_Partner_Offering_Nm__c= fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c')?
//                                                             string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(language))) : null;     
//                         offering.PMP_Partner_Offering_Dsc__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Dsc__c')?
//                                                             string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(language))) : null;
//                         offering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
//                                                             string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(language))) : null;
                        
                        
//                       system.debug('Description---'+offering.PMP_Partner_Offering_Dsc__c);  
//                     }
//                 } 

//                 if(!String.isBlank(offering.PMP_Partner_Offering_Dsc__c)){
//                     offering.PMP_Partner_Offering_Dsc__c = offering.PMP_Partner_Offering_Dsc__c.unescapeHtml4();
//                 }
                
                
//                 offeringdetail.add(offering);
                

//                 if(offering.PMP_Working_Copy_Id__c!=null){ 
//                    uiData.put('WorkingCopyId',offering.PMP_Working_Copy_Id__c); 
//                 }

                
//                 for(PMP_Partner_Offering_Resource__c resource : offering.Offering_Resources__r){
//                     system.debug('resource-->' +resource);
//                     if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Image || resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Thumbnail_Image){ 
//                        //US592997 : Wrapper is required so that we can send both thumbnail and actual image url as 1 row to the UI
//                         contentAssetWrapper contWrapper = New contentAssetWrapper();
//                         //resource name will be the key for the contentAssetWrapperMap
//                         // -----populating contentAssetWrapperMap start ---
//                         if(contentAssetWrapperMap.containsKey(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c))){ 
//                             contWrapper = contentAssetWrapperMap.get(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c));
//                             if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Thumbnail_Image ){
//                                 system.debug('thumbnail' +resource) ;                          
//                                 contWrapper.thumbnailUrl = resource.id+'_'+offering.id;
//                             }
//                             else if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Image ){
//                                 system.debug('image' +resource);
//                                 contWrapper.imageUrl = resource.id+'_'+offering.id;
//                             }
//                             contentAssetWrapperMap.put(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c),contWrapper );
//                         }
//                         else{
                            
//                             contWrapper.type = resource.PMP_Resource_Type_Nm__c;
//                            // contWrapper.contentId = ca.id;
//                             if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Thumbnail_Image ){   
//                                 system.debug('thumbnail2' +resource)  ;                      
//                                 contWrapper.thumbnailUrl = resource.id+'_'+offering.id;
//                             }
//                             else if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Image ){
//                                 system.debug('image2' +resource);
//                                 contWrapper.imageUrl = resource.id+'_'+offering.id;
//                             }
//                             contentAssetWrapperMap.put(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c),contWrapper );
//                         }
//                     }

//                     else{
//                         if(String.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
//                             contentDocIds.add(resource.PMP_Partner_Offering_Image__c);
//                         }
//                         OfferingResourceWrapper resourceWrapper = New OfferingResourceWrapper();
//                         resourceWrapper.id = resource.Id;
//                         resourceWrapper.title = resource.name;
//                         resourceWrapper.resourceType = resource.PMP_Resource_Type_Nm__c;
//                         resourceWrapper.url = resource.PMP_Partner_Offering_Resource_URL_Txt__c;
//                         resourceWrapper.uploadId = resource.PMP_Partner_Offering_Image__c;
//                         resourceWrapper.description = String.IsNotBlank(resource.PMP_Resource_Description_Txt__c) ? resource.PMP_Resource_Description_Txt__c : '';
//                         resourceWrapperList.add(resourceWrapper);
//                     }

//                     offeringResources.add(resource);
//                 }
                

//                 if(!contentDocIds.isEmpty()){
//                     //Fetch the content document details for the Ids in contentDocIds list to get file size and file type
//                     List<ContentDocument> cdList = PMP_OfferingResourceHelper.getContentDocList(contentDocIds);
//                     for(ContentDocument cd : cdList){
//                         contentDocMap.put(cd.Id, cd);
//                     }
//                     for(OfferingResourceWrapper resourceWrap :  resourceWrapperList){
//                         if(String.isNotBlank(resourceWrap.uploadId) && !contentDocMap.isEmpty()){
//                             resourceWrap.fileType = contentDocMap.get(resourceWrap.uploadId).FileType;
//                             resourceWrap.fileSize = PMP_Utility.FileSizeToString(contentDocMap.get(resourceWrap.uploadId).ContentSize);
//                             //framing the download url with community url+'file-asset/'+contentasset developer name(resourceId_offeringId)
//                             resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset + resourceWrap.Id +'_'+ string.valueOf(offeringId);
//                         }
//                     }
//                 }

               
//               //  string mdaId = PMP_SearchUtilityController.getMdaId(String.valueOf(offering.PMP_Company_Id__r.PMP_Account_Id__c));
//               //  uiData.put('mdaId', mdaId);
//                 if(!recurseCheck ){ 
//                     boolean showContactPartner = PMP_SearchUtilityController.isContactButtonVisible(offering);
//                     uiData.put('showContactPartner',showContactPartner); 
//                     recurseCheck = true; 
//                 }       
//              }
             
      
//             //Gets offering specification
//             List<PMP_Partner_Offering_Specification__c> offSpecs = PMP_SpecificationController.getOfferingSpecifications(offeringId);
//            if(contentAssetWrapperMap.values().size() >0){
            
//             uiData.put('contentWrapper',contentAssetWrapperMap.values());}
//             system.debug('image3' +uiData.get('contentWrapper'));

//             uiData.put(PMP_StaticConstants_Offering.OfferingDetail,offeringdetail);
//             uiData.put(PMP_StaticConstants_Offering.existingURLs,offeringResources);
//             uiData.put(PMP_StaticConstants_Offering.offeringResources,resourceWrapperList);
//             uiData.put(PMP_StaticConstants_MasterData.Approved,PMP_StaticConstants_MasterData.Approved);
            
//             boolean isAdmin = PMP_Utility.isLoggedInUserAdmin();
//             uiData.put('isAdmin', isAdmin);
            
//             boolean isAnonymousUser = PMP_Utility.isLoggedInUserAnonymous();
//             uiData.put('isAnonymousUser', isAnonymousUser);
            
//             if(!String.isBlank(language) && language != 'NA'){
//                 uiData.put('userLocale', language);
                
//             }

//                 Boolean hasEditAccess = Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable();
//                 Boolean isSysAdmin = false;
//                 Boolean isSamePartner = PMP_Utility.isUserUnderSamePartner(offeringdetail[0]);
//                 Boolean showEditButton = false;
//                 Id profId = userInfo.getProfileId();
            
//             String profileName = [Select Name from Profile where Id =: profId].Name;
            
//             if(PMP_StaticConstants_Offering.adminProfiles.contains(profileName)){
//                 isSysAdmin = true;
//             }  

//                 if(( hasEditAccess && isSamePartner && MarketplaceCreateProductController.getCreateOfferingAccess()) || isSysAdmin || isAdmin){
//                 showEditButton = true;
//             }
//                 uiData.put(PMP_StaticConstants_Offering.showEditButton,showEditButton);

            
//             if(offeringId != null && bEditOffering){
//                 List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryWrap = PMP_CategoryController.getOfferingCategoryList(offeringId);
//                 uiData.put(PMP_StaticConstants_Offering.masterCategoriesWithSelectedValues,categoryWrap);
//                 uiData.put(PMP_StaticConstants_Offering.selectedSpecifications,offSpecs);
//             }
//             if(offeringId != null && bViewOffering){
                
//                 //Gets offering Categories
//                 List<PMP_Partner_Offering_Category__c> offCategories = PMP_CategoryController.getOfferingCaregories(offeringId);
//                 if(String.isBlank(language)){
//                     language = PMP_Utility.getLoggedInUsersLanguage();    
//                 }
                

//                 if(String.isNotBlank(language) && language == 'NA'){
//                     language = PMP_Utility.getLoggedInUsersLanguage(); 
//                 }
                

//                 if(String.isNotBlank(language) && language != 'NA'){//if the language URL parameter is not null,store local name in categories and specs
//                     String localeCatNmField;//to store local field of category
//                     String localeSpecNmField;//to store local field of specification
//                     String localeSpecValNmField;//to store local field of specification value
//                     if(userURLLaguageCode==null && langCode!=null) 
//                     {
//                         language = langCode;
//                     }
                        
//                     //fetch local Name fields from Utility method for all three objects(i.e Categories,Specifications,Specification Values)
//                     List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeFields = PMP_Utility.getLocaleToFieldMdtRecordsByField(language, 'Name');
                    
//                     for(PMP_Locale_To_FieldAPINm_Mapping__mdt localField : localeFields){//iterating over metadata records and getting the api field names of category, spec and specVal
//                         if(localField.PMP_Object_Nm__c == 'Category'){
//                             localeCatNmField = localField.PMP_Field_APINm__c;//storing the local field name of category
//                         }
//                         else if(localField.PMP_Object_Nm__c == 'Specification'){
//                             localeSpecNmField = localField.PMP_Field_APINm__c;//storing the local field name of specifications
//                         }
//                         else if(localField.PMP_Object_Nm__c == 'Specification Value'){
//                             localeSpecValNmField = localField.PMP_Field_APINm__c;//storing the local field name of specification values
//                         }
//                     }
                    
//                     for(PMP_Partner_Offering_Category__c offCat : offCategories){//iterating over all the offering Categories and changing their name according to the language param 
                        
//                         offCat.Name = String.valueOf(offCat.PMP_Category_Id__r.get(localeCatNmField));//getting the category name in user preferred language
                        
//                     }
//                     System.debug('!!!Before language processing '+offSpecs);
//                     for(PMP_Partner_Offering_Specification__c offSpec : offSpecs){//iterating over all the offering specifications and changing their name according to the language param
//                         system.debug('!!!!!offSpec'+offSpec);
//                         system.debug('!!!!!offSpec.PMP_Specification_Id__r'+offSpec.PMP_Specification_Id__r);
//                         system.debug('localeSpecNmField'+localeSpecNmField);
//                         if(String.isNotBlank(String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField)))){//getting the specification name in user preferred language
//                             offSpec.PMP_Specification_Nm__c = String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField));//getting the category name in user preferred language
//                             offSpec.Name = String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField));//getting the specification name in user preferred language
//                             if(offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r != null){
//                                 offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name = String.valueOf(offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.get(localeSpecNmField));
//                             } 
//                         }
                        
//                         if(offSpec.PMP_Specification_Value_Id__r != null){//If spec value is there, get it's name in user preferred language
//                             if(String.isNotBlank(String.valueOf(offSpec.PMP_Specification_Value_Id__r.get(localeSpecValNmField)))){
//                                 offSpec.PMP_Specification_Value_Cd__c = String.valueOf(offSpec.PMP_Specification_Value_Id__r.get(localeSpecValNmField));//getting the spec value in user preferred language
//                             }
//                             else{
//                                 offSpec.PMP_Specification_Value_Cd__c = String.valueOf(offSpec.PMP_Specification_Value_Id__r.get('PMP_Specification_Value_Nm__c'));//getting the spec value in user english language
//                             }
//                         }
//                     }
//                 }

//                 System.debug('!!!After language processing '+offSpecs);
//                 uiData.put(PMP_StaticConstants_Offering.selectedCategories,offCategories);
//                 uiData.put(PMP_StaticConstants_Offering.selectedSpecifications,offSpecs);

//                 //call getPartnerDetails method of PMP_ProductPartnerDetailsController to fetch partner details
                
//                 if(bCompareOffering != null && !bCompareOffering){ 
//                     String langCodeClone = langCode;
//                     if (langCodeClone!=null && langCodeClone=='ja_JP'){ 
//                         langCodeClone='ja';
//                     }
//                     Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(offeringdetail[0].Id, offeringdetail[0].PMP_Company_Id__c, null, true, langCodeClone);

//                     PMP_SearchPartnerDetailsController.partnerDetail productCompanyRes = PMP_SearchPartnerDetailsController.getPartnerDetails(partner.Id, langCodeClone);
//                     uiData.put(PMP_StaticConstants_Offering.partnerDetail, partner);
//                     system.debug('partner:'+partner);

//                     //PMP_SearchCompanyArticles.ArticleData articleProductList = PMP_SearchCompanyArticles.getPartnerArticles(partner.Id,langCodeClone);
//                     PMP_SearchCompanyArticles.ArticleData articleProductList = PMP_CompanyArticles.getArticles(partner.Id,langCodeClone);
//                     system.debug('productCompanyRes:'+productCompanyRes);
//                     system.debug('articleProductList:'+articleProductList);
                    
//                     uiData.put(PMP_StaticConstants_Offering.productCompanyResource, productCompanyRes);
//                     uiData.put(PMP_StaticConstants_Offering.articleCompanyResource, articleProductList);
//                 }
                

//                       system.debug('bCompareOffering:::'+bCompareOffering);        
//                 if(bCompareOffering != null && !bCompareOffering){
//                     system.debug('4::::'+offSpecs);
//                     map <string, List<string>> masterValueMap = PMP_SpecificationController.getOfferingValuesAndSpecificationMap(offSpecs,language);
//                     for(string key :masterValueMap.keyset() ){
//                         offeringSpecValueMap tempWrap = New offeringSpecValueMap();
//                         tempWrap.masterCategory = key;
//                         tempWrap.valueList = masterValueMap.get(key);
//                         if(key.contains(PMP_StaticConstants_MasterData.BoardQualityMetricPIMId) || key.contains(PMP_StaticConstants_MasterData.IPQualityMetricPIMId)){
//                             tempWrap.category = key.substringAfter('|');
//                         }else{
//                             tempWrap.category = null;
//                         }
//                         specMapWrapper.add(tempWrap);
//                     }
                    
//                     uiData.put(PMP_StaticConstants_Offering.selectedSpecificationsMap, specMapWrapper );
//                 }
                
//             }
//             boolean isIntelEmployee = PMP_Utility.isIntelEmployee();
            
//             uiData.put('isIntelEmployee',isIntelEmployee);
            
//             system.debug('intelEmp-->' +isIntelEmployee);
             
 
//         }catch (Exception e) {
//             PMP_Utility.logError(e,'PMP_OfferingDetails'); 
//             bSuccessful = false;
            
//         }
        

//         try{
//          System.debug('JSON.deserialize in detail-------------'+JSON.serialize(new PMP_LightningServerResponse(true,mapErrorInfo,uiData)));
//             jsonValue = JSON.serialize(new PMP_LightningServerResponse(true,mapErrorInfo,uiData));
//             system.debug('cacheKey in else-----'+cacheKey +isGuestUser);
//             String cacheTTLStr = PMP_Utility.getValue('Cache_TTL');
//             Integer cacheTTL = Integer.valueOf(cacheTTLStr); // 48hrs
//             if(cacheFlag.equalsIgnoreCase('true') && isGuestUser){
//                 Cache.Org.put(partitionInput+'.'+cacheKey, jsonValue,cacheTTL);
//             }              
//             }Catch(Cache.ItemSizeLimitExceededException error){
//                 System.debug('Error due to Item Size Exceeded***********'+error.getMessage() +'at line '+error.getLineNumber());
//                 PMP_Utility.logError(error,'PMP_OfferingDetails');  
//             }Catch(Cache.Org.OrgCacheException error){
//                 System.debug('Error due to Partition Exception***********'+error.getMessage() +'at line '+error.getLineNumber());
//                 PMP_Utility.logError(error,'PMP_OfferingDetails');   
//             }
            
//         }

//         return jsonValue;
//     }
   
//     @AuraEnabled(cacheable = true)
//     public static String fetchOfferingDetailNotPreview(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){     
//         return fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode,isPreview);
//     }
    
//     /**
//     * @description Method To clone Offering
//     * @param Id
//     * @return String
//     **/
//     @AuraEnabled
//     public static String cloneOfferingDetail(Id offeringId, string language){
    
//         PMP_LightningServerResponse lightningResponse = new PMP_LightningServerResponse();
        
//         try{
//             lightningResponse = PMP_CloneOfferingController.cloneOffering(offeringId, language);
        
//         }catch (Exception e) {
//             PMP_Utility.logError(e,'PMP_CloneOffering'); 
//         }
              
//         return JSON.serialize(lightningResponse);
   
    
//     }
    
        
//     @AuraEnabled
//     public static void updateOfferingDates(PMP_Partner_Offering__c offering){
//         if(offering.id != null){
//             system.debug(offering);
//             offering.PMP_Is_Notified_Ind__c = false;
//             offering.PMP_Offering_Submitter_UserId__c = UserInfo.getUserId();
//             if(Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()){
//                 update offering;
//             }    
//         }
//     }
    
//     @AuraEnabled
//     public static Boolean checkValidOffering(String offeringId, Boolean isPreview){
        
//         Boolean isActive = FALSE;
//         if(offeringId != null && Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()) {
            
//             List<PMP_Partner_Offering__c> offerings = new List<PMP_Partner_Offering__c>();
//             //Modified as a part of OPID Restucture : Removing PMP_Account_Id__c from Query
//             List<PMP_Partner_Offering__c> partnerOfferings = [SELECT Id,PMP_Partner_Offering_Start_Dt__c,PMP_Partner_Offering_End_Dt__c,PMP_Company_Id__c,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c FROM PMP_Partner_Offering__c WHERE Id = :offeringId];
//             Set<Id> compIds = new Set<Id>();
//             List<String> accIds = new List<String>();
//             for(PMP_Partner_Offering__c offeringRec : partnerOfferings){
//                 compIds.add(offeringRec.PMP_Company_Id__c);
//             }
//             List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(compIds);
//             for(PMP_OPID_MPI_Rel__c juncRec : junctionObjects){
//                 accIds.add(juncRec.PMP_One_Partner_ID__c);
//             }

//             Boolean isSamePartner = FALSE;
//             if(partnerOfferings.size() > 0 && accIds.size() > 0){
//                 Map<String, Boolean> samePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(accIds);
//                 for(String acc : accIds){
//                     isSamePartner = samePartnerMap.get(acc);
//                 }
//             }
            
//             //Existing Query
//             /*List<PMP_Partner_Offering__c> partnerOfferings = [SELECT Id,PMP_Partner_Offering_Start_Dt__c,PMP_Partner_Offering_End_Dt__c,PMP_Company_Id__r.PMP_Account_Id__c,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c FROM PMP_Partner_Offering__c WHERE Id = :offeringId];

//             Boolean isSamePartner = FALSE;
//             if(partnerOfferings.size() > 0 && partnerOfferings[0].PMP_Company_Id__r.PMP_Account_Id__c != null) {
//                 Map<String, Boolean> samePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(new List<String> {partnerOfferings[0].PMP_Company_Id__r.PMP_Account_Id__c});
//                 isSamePartner = samePartnerMap.get(partnerOfferings[0].PMP_Company_Id__r.PMP_Account_Id__c);
//             }*/
//             system.debug('1::'+isMPAdmin());
//             system.debug('2::'+isPreview);
//             if(isPreview || isMPAdmin()) {
//                 isActive = true;
//             } else if(isOfferingPermissionUser() && isSamePartner) {
                
//                 if(partnerOfferings.size() > 0) {
//                     if(partnerOfferings[0].PMP_Working_Copy_Id__c != null) {
//                         offerings = [SELECT Id FROM PMP_Partner_Offering__c WHERE Id = :offeringId AND PMP_Partner_Offering_Start_Dt__c <= TODAY AND PMP_Partner_Offering_End_Dt__c >= TODAY AND 
//                                      PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = FALSE AND PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published];
//                     } else {
//                         offerings = [SELECT Id FROM PMP_Partner_Offering__c WHERE Id = :offeringId AND PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = FALSE AND PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published];
//                     }
//                 }
//                 isActive = offerings.size() > 0;
//             } else {
//                 offerings = [SELECT Id FROM PMP_Partner_Offering__c WHERE Id = :offeringId AND PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND PMP_Is_Not_Available_On_MP_Ind__c = FALSE AND 
//                              PMP_Partner_Offering_Start_Dt__c <= TODAY AND PMP_Partner_Offering_End_Dt__c >= TODAY AND PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND
//                              PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = FALSE];
//               isActive = offerings.size() > 0;
//             }
//         }
//         return isActive;
//     }
    
//     public static Boolean isMPAdmin(){
        
//         List<PermissionSetAssignment> permissionSetList = [SELECT Id,Assignee.Profile.Name  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
//                                                             AND (PermissionSet.Name =:PMP_StaticConstants_Partner.INTEL_ADMIN OR Assignee.Profile.Name IN ('System Administrator','IT Admin'))];
        
//         return permissionSetList.size() > 0;
//     }

//     public static Boolean isOfferingPermissionUser() {
        
//         List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
//         permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId() AND 
//                             (PermissionSet.Name = :PMP_StaticConstants_Partner.PARTNER_ADMIN OR PermissionSet.Name = :PMP_StaticConstants_Partner.OFFERING_EDITOR)];
        
//         return permissionSetList.size() > 0;
//     }
    
//     public Class offeringSpecValueMap {
//         @AuraEnabled
//         @TestVisible public string masterCategory {get;set;}
        
//         @AuraEnabled
//         @TestVisible public List<string> valueList {get;set;}
        
//         @AuraEnabled
//         @TestVisible public string category {get;set;}
//     }
//     public class contentAssetWrapper{
        
       
//         @AuraEnabled
//         public string type{get;set;}
         
       
       
//         @AuraEnabled 
//         public string thumbnailUrl{get;set;}
//         @AuraEnabled
//         public string imageUrl{get;set;}
//     }
    
    
}