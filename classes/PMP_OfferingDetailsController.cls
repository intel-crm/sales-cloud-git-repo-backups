@isTest
/*************************************************************************************************************************************************************************
* Class Name  : PMP_OfferingDetailsController 
* Version     : 1.0 
* Created Date: 4/22/2019
* Modification Log :
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh Riyan    M-01    : Original version     7/04/2019                            This class is used for functionalities related to offering Detail 
**************************************************************************************************************************************************************************/
//Gireesh: US685027: changed from without sharing to with sharing
public with sharing class PMP_OfferingDetailsController extends PMP_SearchWrapperStore{
//     public static boolean recurseCheck = false;

//     /**
//     * @description Method To Fetch Multiple Offering Details
//     * @param Id
//     * @return String
//     **/
//     @AuraEnabled
//     public static Map<String,object> fetchOfferingDetails(List<Id> offeringIds,Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering, String langCode, Boolean isPartnerDetails){
//        // langCode recieved from LWC component for chinese will be zh_Hans_CN, so adding the below conditions to convert that langCode to zh_CN
//         if(langCode == 'en-US'){
//             langCode = 'en_US';
//         }else if(langCode == 'zh_Hans_CN' || langCode == 'zh-CN' || langCode == 'zh-Hans-CN'){
//             langCode = 'zh_CN';
//         }
       
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
//         //return offerings;  
//     }
    
//    @AuraEnabled
//    public static String getOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){
//        if(isPreview){
//            //system.debug('@isPreview if------'+isPreview);
//            String offeringDetailResponse = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode,isPreview);
//            return offeringDetailResponse;
//        }else{
//            //system.debug('@isPreview else------'+isPreview);
//            String offeringDetailNotPrevResponse = fetchOfferingDetailNotPreview(offeringId, bEditOffering, bViewOffering, bCompareOffering, language, langCode,isPreview);
//            return offeringDetailNotPrevResponse;
//        }       
       
//    } 

//     @AuraEnabled
//     public static String getOfferingDetailProductDetails(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){
        
//         PMP_Partner_Offering__c offering = [ select PMP_Working_Copy_Id__c , PMP_Is_Not_Available_On_MP_Ind__c from PMP_Partner_Offering__c 
//                                              where id= :offeringId Limit 1];
//         try{            
//             if(offering.PMP_Working_Copy_Id__c!= null){
//                 offeringId =  offering.PMP_Working_Copy_Id__c;
//                 PMP_Partner_Offering__c tempOffering = [ select Id from PMP_Partner_Offering__c 
//                                                          where id= :offeringId Limit 1 ];
//                 if(tempOffering==null)
//                 {
//                     offeringId=offering.Id;
//                 }               
//             }
            
//         }catch (Exception e) {
//             offeringId=offering.Id;
//             PMP_Utility.logError(e,'PMP_OfferingDetails_getOfferingDetailProductDetails'); 
            
//         }
        
//         if(isPreview){
//             //system.debug('@isPreview if------'+isPreview);
//             String offeringDetailResponse = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode,isPreview);
//             return offeringDetailResponse;
//         }else{
//             //system.debug('@isPreview else------'+isPreview);
//             String offeringDetailNotPrevResponse = fetchOfferingDetailNotPreview(offeringId, bEditOffering, bViewOffering, bCompareOffering, language, langCode,isPreview);
//             return offeringDetailNotPrevResponse;
//         }       
        
//     } 
    
//     /**
//     * @description Method to fetch all the offering related data
//     * @param Id
//     * @return String
//     **/
//    @AuraEnabled
//     public static String fetchOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){
//         // system.debug('Inside detail page---');
//         String userURLLaguageCode = language; //Gireesh:US664733
//         Boolean bSuccessful = true;    
//         map<string,object> uiData = new map<string,object>();
//         map<String, Object> mapErrorInfo = new map<string,object>();
//         //Map<String,List<sObject>> fetchOffering = new Map<String,List<sObject>>();
//         List<PMP_Partner_Offering_Resource__c> offeringResources = new List<PMP_Partner_Offering_Resource__c>();
//         //List<ContentDocument> conDocuments = new List<ContentDocument>();
//         //List<ContentVersion> conVersions = new List<ContentVersion>();
//         //List<ContentAsset> conAssets = new List<ContentAsset>();
//         //List<ContentAsset> thumbNailconAssets = new List<ContentAsset>();
//         //List<ContentAsset> imageConAssets = new List<ContentAsset>();
//         //List<ContentDistribution> conDistribution = new List<ContentDistribution>();
//         List<Id> contentDocIds = New List<Id>();
//         List<OfferingResourceWrapper> resourceWrapperList = New List<OfferingResourceWrapper>();
//         Map<String,ContentDocument> contentDocMap = New Map<String,ContentDocument>();
//         List <offeringSpecValueMap> specMapWrapper = New List <offeringSpecValueMap>();
//         List <offeringSpecValueMap> qualityMetricsWrapper = New List <offeringSpecValueMap>();
//         List <offeringSpecValueMap> RestSpecsWrapper = New List <offeringSpecValueMap>();
        
//         //List<String> docIds = new List<String>();
//         //Map<id,PMP_Partner_Offering_Resource__c > docIdIResourceMap = New Map<id, PMP_Partner_Offering_Resource__c >();
//         List<PMP_Partner_Offering__c> offeringdetail = new List<PMP_Partner_Offering__c>();
//         //Set<Id> contentAssetIds = new Set<Id>();
//         //Integer seqNumberCounter = 0;
//         Map<string, contentAssetWrapper> contentAssetWrapperMap = New Map<string, contentAssetWrapper>(); //US592997 
//         List<media> mediaWrapperList = New List<media>(); //Sreelatha new List media
        
//         //SOORIYA -New Resource List Changes
//         //fetch base community URL
//         String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
            
//         //remove '/s' from baseCommunityUrl community URL
//         if(baseCommunityUrl.endsWith('/s')){
//             baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
//         }            
//         //fetch static text called "/file-asset" from metaData
//         String staticFileAsset = PMP_Utility.getValue('Community_File_Asset'); 
                          
//         //Gireesh:US758953
//         //Event Banner
//         Boolean isEventExist = False;
//         List<PMP_Marketplace_Event_Offering__c> eventPartnerOffering = new List<PMP_Marketplace_Event_Offering__c>();
        
//         if (Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible()) {
//             eventPartnerOffering = [select Id, Name, PMP_Event_Id__c from PMP_Marketplace_Event_Offering__c where PMP_Offering_Id__c=:offeringId AND PMP_Event_Id__r.PMP_Marketplace_Event_Status__c =true];
//         }
        
//         // system.debug('eventPartnerOffering::'+eventPartnerOffering);
//         if(!eventPartnerOffering.isEmpty()){
//             isEventExist=True;
//         }
//         uiData.put('eventPartnerOffering',isEventExist);
//         //end - event banner
         
//         /*Sandhya - Implementation of Platform Cache :START - US614322*/
       
//         String cacheLanguage;
//         String jsonValue;
//         Boolean cachePreview=False;
//        // String cachedOffering;
       
//         //Caching only for Guest users
//         Boolean isGuestUser = false;
//         Id profileId = userInfo.getProfileId();
//         //US1029844
//         String guestProfileName = [Select Name from Profile where Id =: profileId].Name;
//         if(PMP_StaticConstants_Offering.guestProfiles.contains(guestProfileName)){
//             isGuestUser = true;
//         }
//         //US1029844
      
//         //Add the guest user language to Cache as Key
//         if(langCode != null){
//             if(langCode.contains('_')){
//                 cacheLanguage = langCode.replace('_', '');
//             }else{
//                 cacheLanguage = langCode;
//             }
//         }

//         // Name of a partition
//         String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        
//         //Get the flag from Custom Metadata
//         String cacheFlag = PMP_Utility.getValue('OfferingDetail_CacheFlag');
         
//         //Prepare the key
//         String cacheKey = 'OfferingDetail'+(String)offeringId+cacheLanguage; //US1029844 , updated the key
//        //String cacheKey = (String)offeringId+cacheLanguage+isGuestUser; 
        
//         if(isPreview != null){
//             cachePreview = isPreview; 
//         } 
        
//         if(Cache.Org.contains(partitionInput+'.'+cacheKey) && !cachePreview  && cacheFlag.equalsIgnoreCase('true') && isGuestUser){
//             jsonValue = (String)Cache.Org.getPartition(partitionInput).get(cacheKey);
//             if(jsonValue != null){
//                 return jsonValue;  
//             }
//         }
//         /*Sandhya : End - US614322*/
//         else{
                 
//           String userLanguageCode = userinfo.getLanguage();
//           if(userLanguageCode =='ja'){            userLanguageCode = userLanguageCode+ '_JP'; 
//           }
//         /*------------------------------------Part 1 Changes End-----------------------------------*/
        
//         try{  

//             Map<String, String> resourceMap  = new Map<String, String>();
//             Set<id> imageIds = new Set<id>();
            
//             for(PMP_Partner_Offering_Resource__c resource1 : [Select id,Name,PMP_Partner_Offering_Image__c 
//                                                              from PMP_Partner_Offering_Resource__c  where 	PMP_Offering_Id__c = :offeringId]){
            
//                  if(resource1.PMP_Partner_Offering_Image__c!=null){
//                         imageIds.add(resource1.PMP_Partner_Offering_Image__c);
//                  }
                                               
//             }
            
//             List<ContentAsset> ca = new List<ContentAsset>();
//             ca = PMP_FetchAssetContent.getContentAsset(imageIds);
            
//             if(!ca.isEmpty()){
//                 for (ContentAsset ca1 : ca){
//                     resourceMap.put(ca1.ContentDocumentId, ca1.DeveloperName);
//                 }
//             }

//             //Modified as a part of OPID Restructure : Removing PMP_Company_Id__r.PMP_Account_Id__c from Query
//             for(PMP_Partner_Offering__c offering : [Select id,
//                                             (Select id,Name,PMP_External_Source_Id__c,PMP_Video_Title_Txt__c,PMP_BrightCove_Video_Extension_Txt__c,PMP_File_Size_Txt__c,PMP_Partner_Offering_Image__c,PMP_Resource_Type_Nm__c,PMP_Resource_Description_Txt__c,
//                                             PMP_Partner_Offering_Resource_URL_Txt__c,PMP_Offering_Id__c,PMP_Resource_Sequence_Nbr__c,PMP_BrightCoveVideoAccountID__c, PMP_BrightCoveVideoId__c,PMP_BrightCoveVideoThumbnail_URL__c,PMP_Alt_Text__c,PMP_Offering_Gallery_Video_Ind__c,LastModifiedDate,PMP_Delete_BrightCove_Video_Ind__c from Offering_Resources__r ORDER by PMP_Resource_Sequence_Nbr__c),
//                                             PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Partner_Offering_End_Dt__c,PMP_Offering_Language_Nm__c,
//                                             PMP_Partner_Offering_Id__c,PMP_Partner_Offering_Start_Dt__c,PMP_Offering_Status_Update_Dt__c,PMP_Translated_Languages__c,
//                                             PMP_Partner_Revision_Comment_Txt__c,PMP_Company_Id__c,PMP_Company_Id__r.Name,PMP_Working_Copy_Id__c,PMP_Is_Not_Available_On_MP_Ind__c,PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,
//                                             PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,Name,PMP_Partner_Offering_Nm__c,
//                                             PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__c,
//                                             PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Is_Notified_Ind__c,PMP_Pre_Release_Check_Nm__c,PMP_Pre_Release_Item_Count_Num__c,
//                                             PMP_Category_nm__c, PMP_Sub_Category_nm__c         
//                                             from PMP_Partner_Offering__c where id = :offeringId])
//             {
//                 String nameValue = offering.PMP_Partner_Offering_Nm__c;
//              /*PART-2 To consider loggedIn user's language if langauge param is null or empty */
//                 if(langCode!=null && langCode =='ja'){
//                     langCode = langCode+ '_JP';
//                 }
//                 //system.debug('Inside detail page3---'); 
//              if(language=='ja' && isPreview == false){
//                 language = 'ja_JP';
//              } 
             
//              if(language=='zh_Hans_CN' && isPreview == false){
//                  language = 'zh_CN';
//              }
                
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
//                             // system.debug('trans--.' +iterValue );
//                                 fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
//                             }
//                         }
//                         //system.debug(userLanguageCode );

//                  //Gireesh:US664733: To display in categories and specifications in respective lang based on 'language' param ex: '?language=zh_CN' for anonymous user
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
//                      //end
                 
//                  /*---------------------------------------Part 2 Changes End ------------------------*/
//                     // system.debug('lang183--'+ language);   
//                     if(language!=null && language != 'NA'){ //Added by Abhishek US398772 replacing the offering name, tooltip based on language parameter
                        
//                         offering.PMP_Partner_Offering_Nm__c= fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c')?
//                                                             string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(language))) : offering.PMP_Partner_Offering_Nm__c;     
//                         offering.PMP_Partner_Offering_Dsc__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Dsc__c')?
//                                                             string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(language))) : offering.PMP_Partner_Offering_Dsc__c;
//                         offering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
//                                                             string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(language))) : offering.PMP_Partner_Offering_Tag_Line_Txt__c;
            
                        
                        
//                         if((offering.PMP_Partner_Offering_Nm__c == null || offering.PMP_Partner_Offering_Nm__c == '') || Test.isRunningTest()){// shiva_vats added (|| Test.isRunningTest())
//                             offering.PMP_Partner_Offering_Nm__c = nameValue;
//                         }
//                         if(isPreview!=null && isPreview){
//                             offering.PMP_Partner_Offering_Nm__c = nameValue;
//                         }
                        
//                         if(!String.isBlank(offering.PMP_Partner_Offering_Nm__c)){
//                             offering.PMP_Partner_Offering_Nm__c =  offering.PMP_Partner_Offering_Nm__c.unescapeHtml4().stripHtmlTags();
//                         }
//                         //system.debug('Offering Name is '+ offering.PMP_Partner_Offering_Nm__c);
//                         if(!String.isBlank(offering.PMP_Partner_Offering_Tag_Line_Txt__c) && offering.PMP_Partner_Offering_Tag_Line_Txt__c!=null){
//                             offering.PMP_Partner_Offering_Tag_Line_Txt__c=offering.PMP_Partner_Offering_Tag_Line_Txt__c.unescapeHtml4().stripHtmlTags();
//                         }
//                     }
//                 } 
//                 // Description Inconsistent - As part of US954461
//                 if(!String.isBlank(offering.PMP_Partner_Offering_Dsc__c) ){
//                     offering.PMP_Partner_Offering_Dsc__c = offering.PMP_Partner_Offering_Dsc__c.unescapeHtml4().stripHtmlTags();
//                 }
                
                
//                 offeringdetail.add(offering);
                
//                 //Added by shahrukh US396679 : To navigate from published copy to working copy
//                 if(offering.PMP_Working_Copy_Id__c!=null){ 
//                    uiData.put('WorkingCopyId',offering.PMP_Working_Copy_Id__c); 
//                 }else{
//                     uiData.put('WorkingCopyId',offering.Id); 
//                 }
//                 //End of Code US396679
                
                
//                 //Get resources(Images and URLs) and  Content Document Id for the images
//                 //System.debug(offering.Offering_Resources__r);
//                 for(PMP_Partner_Offering_Resource__c resource : offering.Offering_Resources__r){
//                     // system.debug('resource-->' +resource);
//                     if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE || (resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && resource.PMP_Offering_Gallery_Video_Ind__c==true&&resource.PMP_Delete_BrightCove_Video_Ind__c==false)){ 
//                        //US592997 : Wrapper is required so that we can send both thumbnail and actual image url as 1 row to the UI
//                         contentAssetWrapper contWrapper = New contentAssetWrapper();
//                          media mediaWrapper = new media();
//                         //mediaWrapper.placeholder1920px = PMP_StaticConstants_Partner.offeringGalleryPlaceholder1920px;
//                         //mediaWrapper.placeholder246px = PMP_StaticConstants_Partner.offeringGalleryPlaceholder246px;
//                         mediaWrapper.placeholder1920px = '/resource/1651070965000/IPA_Video/unavailable_1920x1080.png';
//                         mediaWrapper.placeholder246px ='/resource/1651070965000/IPA_Video/unavailable_thumbnail_246x138.png';
//                         mediaWrapper.altText = resource.PMP_Alt_Text__c;
//                         if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE ){
//                             //system.debug('image' +resource);
//                             //mediaWrapper.imageUrl = resource.id+'_'+offering.id;
//                             if(resourceMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
//                                 mediaWrapper.imageUrl = resourceMap.get(resource.PMP_Partner_Offering_Image__c);     
//                             }else{                         
//                                 mediaWrapper.imageUrl = resource.id+'_'+offering.id;
//                             }
//                              mediaWrapperList.add(mediaWrapper);
//                         }
                        
//                         else if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && (resource.PMP_BrightCoveVideoAccountID__c != null) && resource.PMP_Offering_Gallery_Video_Ind__c == true &&resource.PMP_Delete_BrightCove_Video_Ind__c==false) {
//                             //system.debug('video details' +resource) ; 
//                             mediaWrapper.accountId = resource.PMP_BrightCoveVideoAccountID__c;
//                             mediaWrapper.videoId = resource.PMP_BrightCoveVideoId__c;
//                            // mediaWrapper.title = resource.PMP_VideoName__c;
//                             mediaWrapper.videoType = 'brightcove';
//                             mediaWrapper.videoThumbnailUrl = resource.PMP_BrightCoveVideoThumbnail_URL__c;
//                             mediaWrapper.description = resource.PMP_Resource_Description_Txt__c;
//                             mediaWrapper.imageUrl = resource.PMP_BrightCoveVideoThumbnail_URL__c;
//                             if(resource.PMP_BrightCoveVideoThumbnail_URL__c==''||resource.PMP_BrightCoveVideoThumbnail_URL__c==null){
//                                 mediaWrapper.videoId = null;
//                             }

//                             mediaWrapperList.add(mediaWrapper);
//                             //System.debug('mediaWrapper::'+mediaWrapper);
//                         }
                        
                       
//                         //resource name will be the key for the contentAssetWrapperMap
//                         // -----populating contentAssetWrapperMap start ---
//                         if(contentAssetWrapperMap.containsKey(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c))){ 
//                             contWrapper = contentAssetWrapperMap.get(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c));
//                             if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE){
//                                 //system.debug('image' +resource);
//                                 //contWrapper.imageUrl = resource.id+'_'+offering.id;
//                                 if(resourceMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
//                                     contWrapper.imageUrl = resourceMap.get(resource.PMP_Partner_Offering_Image__c); 
//                                  }else{    
//                                      contWrapper.imageUrl = resource.id+'_'+offering.id;
//                                  }
//                             }
//                             contentAssetWrapperMap.put(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c),contWrapper );
//                         }
//                         else{
                            
//                             contWrapper.type = resource.PMP_Resource_Type_Nm__c;
//                            // contWrapper.contentId = ca.id;
//                             if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE){
//                                 //system.debug('image2' +resource);
//                                 //contWrapper.imageUrl = resource.id+'_'+offering.id;
//                                 if(resourceMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
//                                     contWrapper.imageUrl = resourceMap.get(resource.PMP_Partner_Offering_Image__c); 
//                                  }else{    
//                                      contWrapper.imageUrl = resource.id+'_'+offering.id;
//                                  }
//                             }
//                             contentAssetWrapperMap.put(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c),contWrapper );
//                         }
//                     }
   
//                      // -----populating contentAssetWrapperMap end ---
//                     //Added by SOORIYA - US1006907 - START
//                     else{
//                       if(resource.PMP_Delete_BrightCove_Video_Ind__c==false && resource.PMP_Resource_Type_Nm__c!=PMP_StaticConstants_Offering.THUMBNAIL_IMAGE){
//                         if(String.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
//                             contentDocIds.add(resource.PMP_Partner_Offering_Image__c);
//                         }
//                         OfferingResourceWrapper resourceWrapper = New OfferingResourceWrapper();
//                         resourceWrapper.id = resource.Id;
//                         resourceWrapper.externalId = resource.PMP_External_Source_Id__c;
//                         resourceWrapper.title = resource.name;
//                         resourceWrapper.resourceType = resource.PMP_Resource_Type_Nm__c;
//                         resourceWrapper.url = resource.PMP_Partner_Offering_Resource_URL_Txt__c;
//                         resourceWrapper.uploadId = resource.PMP_Partner_Offering_Image__c;
//                         resourceWrapper.description = String.IsNotBlank(resource.PMP_Resource_Description_Txt__c) ? resource.PMP_Resource_Description_Txt__c : '';
//                         resourceWrapper.publishDate = resource.LastModifiedDate.format('MMM dd, yyyy');
//                         resourceWrapper.altText = resource.PMP_Alt_Text__c;
//                         //System.debug('Add Resources: '+resourceWrapper);
//                         if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && resource.PMP_Offering_Gallery_Video_Ind__c==false){
//                             VideoTypeWrapper videoWrapper = new VideoTypeWrapper();
//                             videoWrapper.accountId = resource.PMP_BrightCoveVideoAccountID__c;
//                             videoWrapper.thumbnailUrl = String.IsNotBlank(resource.PMP_BrightCoveVideoThumbnail_URL__c)?resource.PMP_BrightCoveVideoThumbnail_URL__c:'' ;
//                             videoWrapper.videoId = resource.PMP_BrightCoveVideoId__c;
//                             if(videoWrapper.videoId!=''){
//                                 videoWrapper.videoType = 'brightcove';
//                             }
//                             if(resource.PMP_BrightCoveVideoThumbnail_URL__c==''||resource.PMP_BrightCoveVideoThumbnail_URL__c==null){
//                                 videoWrapper.videoId = null;
//                             }
//                            // videoWrapper.title = resource.PMP_VideoName__c;
//                             resourceWrapper.videoType = videoWrapper;
//                             resourceWrapper.fileSize = resource.PMP_File_Size_Txt__c;
//                             String filetype = resource.PMP_BrightCove_Video_Extension_Txt__c;
//                             if(filetype!=null && filetype.length()>0){
//                                 filetype = filetype.substring(1);
//                                 filetype = filetype.toUpperCase();
//                             }
//                             resourceWrapper.fileType = filetype;
//                             resourceWrapper.uploadName = resource.PMP_Video_Title_Txt__c;
//                         }
//                         //System.debug('After resourceWrapper: '+resourceWrapper);
//                         resourceWrapperList.add(resourceWrapper);
//                     }
//                     //Added by SOORIYA - US1006907 - END
//                     offeringResources.add(resource);
//                 }
//                 }
                
//                 //Added by SOORIYA - US1006907 - START
//                 if(!contentDocIds.isEmpty()){
//                     //Fetch the content document details for the Ids in contentDocIds list to get file size and file type
//                     List<ContentDocument> cdList = PMP_OfferingResourceHelper.getContentDocList(contentDocIds);
//                     for(ContentDocument cd : cdList){
//                         contentDocMap.put(cd.Id, cd);
//                     }
//                     for(OfferingResourceWrapper resourceWrap :  resourceWrapperList){
//                         if(String.isNotBlank(resourceWrap.uploadId) && !contentDocMap.isEmpty()){
//                             if(contentDocMap.containsKey(resourceWrap.uploadId)){
//                                 resourceWrap.fileType = contentDocMap.get(resourceWrap.uploadId).FileType;
//                                 resourceWrap.fileSize = PMP_Utility.FileSizeToString(contentDocMap.get(resourceWrap.uploadId).ContentSize);
//                             }
//                             if(resourceWrap.resourceType!=PMP_StaticConstants_Offering.VIDEO){
//                                 if(resourceWrap.externalId!=null && resourceWrap.uploadId!=null){
//                                     //framing the download url with community url+'file-asset/'+contentasset developer name(rma_conDocId)
//                                     resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset +'rma_'+resourceWrap.uploadId;
//                                 } else {
//                                     //framing the download url with community url+'file-asset/'+contentasset developer name(resourceId_offeringId)
//                                     //resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset + resourceWrap.Id +'_'+ string.valueOf(offeringId);
//                                     if(resourceMap.containsKey(resourceWrap.uploadId)){
//                                         resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset + resourceMap.get(resourceWrap.uploadId);  
//                                     }else{
//                                         resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset + resourceWrap.Id +'_'+ string.valueOf(offeringId);
//                                     } 
//                                 }
//                             }
//                         }
//                     }
//                 }
//                 //US1006907 -END
//                // commented as part of opid restructure
//                 //string mdaId = PMP_SearchUtilityController.getMdaId(String.valueOf(offering.PMP_Company_Id__r.PMP_Account_Id__c));
//                 //uiData.put('mdaId', mdaId);
//                 if(!recurseCheck ){ //Contact Partner button visibility check logic for US536318 & US519720 - Prabuddh 
//                     boolean showContactPartner = PMP_SearchUtilityController.isContactButtonVisible(offering);
//                     uiData.put('showContactPartner',showContactPartner); 
//                     recurseCheck = true; 
//                 }       
//              }
             
      
//             //Gets offering specification
//             List<PMP_Partner_Offering_Specification__c> offSpecs = PMP_SpecificationController.getOfferingSpecifications(offeringId);
//           //  uiData.put(PMP_StaticConstants_Offering.uploadedFiles,conDocuments);
//           //  uiData.put(PMP_StaticConstants_Offering.contentVersions,conVersions);
//            // uiData.put('conAssets',conAssets);
//            if(contentAssetWrapperMap.values().size() >0){
            
//             uiData.put('contentWrapper',contentAssetWrapperMap.values());}
//             //system.debug('image3' +uiData.get('contentWrapper'));
//             // system.debug('media**************' +mediaWrapperList);
//            if(mediaWrapperList.size() >0){
//             List<Media> sortedMedia = new List<Media>();
//             for(Media mediaRec : mediaWrapperList){
//                 if(mediaRec.videoType != null && mediaRec.videoType == 'brightcove'){
//                     sortedMedia.add(mediaRec);
//                 }
//             }
//             for(Media mediaRec : mediaWrapperList){
//                 if(mediaRec.videoType != 'brightcove'){
//                     sortedMedia.add(mediaRec);
//                 }
//             }
//             uiData.put('media',sortedMedia);
//             //uiData.put('media',mediaWrapperList);
//             }
//             //uiData.put('image', imageconAssets);
//             //uiData.put('downloadURL',conDistribution);
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
//             /*Added by raj to restrict editing for external users (US428208)*/
//                 Boolean hasEditAccess = Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable();
//                 Boolean isSysAdmin = false;
//                 Boolean isSamePartner = PMP_Utility.isUserUnderSamePartner(offeringdetail[0]);
//                 Boolean showEditButton = false;
//                 Id profId = userInfo.getProfileId();
            
//             String profileName = [Select Name from Profile where Id =: profId].Name;
            
//             if(PMP_StaticConstants_Offering.adminProfiles.contains(profileName)){
//                 isSysAdmin = true;
//             }   
//                  // system.debug('show edit before if:'+showEditButton);
//                 //  system.debug('has edit access before if:'+hasEditAccess);
//                 //  system.debug('is same partner before if:'+isSamePartner);
//                 //  system.debug('is sys admin before if:'+isSysAdmin);
//                 //  system.debug('is admin before if:'+isAdmin);
//                 //Gireesh:US707412 added getCreateOfferingAccess() condition
//                 if(( hasEditAccess && isSamePartner && MarketplaceCreateProductController.getCreateOfferingAccess()) || isSysAdmin || isAdmin){
//                 showEditButton = true;
//             }
//             //system.debug('show edit after if:'+showEditButton);
//                 uiData.put(PMP_StaticConstants_Offering.showEditButton,showEditButton);
//             /*-------------------------End---------------------------------*/
            
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
//                 String marketingInfoLang;
//                 if(language=='NA' && langCode!='NA' && langCode!=null)
//                 {
//                      marketingInfoLang=langCode;
//                 }
//                 else if(language=='NA' && langCode=='NA' && language!='en_US')
//                 { 
//                      marketingInfoLang=userLanguageCode;
//                 }
//                 else
//                 {
//                      marketingInfoLang=language;
//                 }
//                 List<marketingInfoWrapperFinal> marketingInfo = buildMarketingInfo(offSpecs,offCategories,marketingInfoLang);
//                 uiData.put('marketingInfo',marketingInfo);
                
//                 //Added by Abhishek to consider NA parameter
//                 if(String.isNotBlank(language) && language == 'NA'){
//                     language = PMP_Utility.getLoggedInUsersLanguage(); 
//                 }
                
//                 /*US434807 : Added by raj to display taxonomy in user preferred language US434807*/
//                 if(String.isNotBlank(language) && language != 'NA'){//if the language URL parameter is not null,store local name in categories and specs
//                     String localeCatNmField;//to store local field of category
//                     String localeSpecNmField;//to store local field of specification
//                     String localeSpecValNmField;//to store local field of specification value
//                     if(userURLLaguageCode==null && langCode!=null) //Gireesh:US664733: To display in categories and specifications in respective lang based on 'language' param ex: '?language=zh_CN' for anonymous user
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
//                     for(PMP_Partner_Offering_Specification__c offSpec : offSpecs){//iterating over all the offering specifications and changing their name according to the language param
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
//                 /*----------------------------------End------------------------------*/
//                 uiData.put(PMP_StaticConstants_Offering.selectedCategories,offCategories);
//                 uiData.put(PMP_StaticConstants_Offering.selectedSpecifications,offSpecs);
//                 /*--------------Added by raj to fetch partner details for US340041----------------------------------------*/
//                 //call getPartnerDetails method of PMP_ProductPartnerDetailsController to fetch partner details
                
//                 if(bCompareOffering != null && !bCompareOffering){ //Gireesh-fetch if CompareOffering is false
//                     String langCodeClone = langCode;
//                     if (langCodeClone!=null && langCodeClone=='ja_JP'){ //Gireesh:US664733 changing langCode back to ja if ja_JP
//                         langCodeClone='ja';
//                     }
//                     Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(offeringdetail[0].Id, offeringdetail[0].PMP_Company_Id__c, null, true, langCodeClone);

//                     PMP_SearchPartnerDetailsController.partnerDetail productCompanyRes = PMP_SearchPartnerDetailsController.getPartnerDetails(partner.Id, langCodeClone);
//                     uiData.put(PMP_StaticConstants_Offering.partnerDetail, partner);
//                     // system.debug('partner:'+partner);
//                     //Sandhya DE55547
//                     //PMP_SearchCompanyArticles.ArticleData articleProductList = PMP_SearchCompanyArticles.getPartnerArticles(partner.Id,langCodeClone);
//                     PMP_SearchCompanyArticles.ArticleData articleProductList = PMP_CompanyArticles.getArticles(partner.Id,langCodeClone);
//                     // system.debug('productCompanyRes:'+productCompanyRes);
//                     // system.debug('articleProductList:'+articleProductList);
                    
//                     uiData.put(PMP_StaticConstants_Offering.productCompanyResource, productCompanyRes);
//                     uiData.put(PMP_StaticConstants_Offering.articleCompanyResource, articleProductList);
//                 }
                
//                 /*-----------------------End US340041---------------------------------------------------------------------*/
//                     //system.debug('4::::'+offSpecs);
//                       //system.debug('bCompareOffering:::'+bCompareOffering);        
//                 if((bCompareOffering != null && !bCompareOffering) || Test.isRunningTest()){ // shiva_vats added (|| Test.isRunningTest())
//                     map <string, List<string>> masterValueMap = PMP_SpecificationController.getOfferingValuesAndSpecificationMap(offSpecs,language);
//                     for(string key :masterValueMap.keyset() ){
//                         offeringSpecValueMap tempWrap = New offeringSpecValueMap();
//                         if(key == 'IP Quality Metrics|IPQualityMetricsLevel1' || key == 'Board Quality Metrics|BoardQualityMetricsLevel1'){
//                             String keyValues = key.subStringBefore('|');
//                             tempWrap.masterCategory = keyValues;
//                         }
//                         else{
//                             tempWrap.masterCategory = key;
//                         }                        
//                         tempWrap.valueList = masterValueMap.get(key);
//                         if(key.contains(PMP_StaticConstants_MasterData.BoardQualityMetricPIMId) || key.contains(PMP_StaticConstants_MasterData.IPQualityMetricPIMId)){
//                             tempWrap.category = key.substringAfter('|');
//                         }else{
//                             tempWrap.category = null;
//                         }
//                         specMapWrapper.add(tempWrap);
//                     }
                    
//                     for(offeringSpecValueMap offSpec: specMapWrapper){
//                         if(offSpec.masterCategory.contains(system.label.PMP_Quality_Metrics_Table) || offSpec.masterCategory=='IP Quality Metrics'){
//                             qualityMetricsWrapper.add(offSpec);
//                             uiData.put('qualityMetricsLabel',system.label.PMP_Quality_Metrics_Table);
//                         }else if(offSpec.masterCategory.contains(system.label.PMP_BoardQualityMetrics) || offSpec.masterCategory=='Board Quality Metrics'){
//                             qualityMetricsWrapper.add(offSpec);
//                             uiData.put('qualityMetricsLabel',system.label.PMP_BoardQualityMetrics);
//                         }else{
//                             restSpecsWrapper.add(offSpec);
//                         }
//                     }
                    
//                     uiData.put(PMP_StaticConstants_Offering.selectedSpecificationsMap,restSpecsWrapper);
                    
//                     uiData.put('QualityMetrics', qualityMetricsWrapper);
//                 }
                
//             }
//             boolean isIntelEmployee = PMP_Utility.isIntelEmployee();
            
//             uiData.put('isIntelEmployee',isIntelEmployee);
            
//            //Capture Cache time 
//             //Added by Manasa 
//             DateTime cacheTimeStamp;
//             if(isGuestUser){
//                 cacheTimeStamp = System.now();
//                 uiData.put('CaptureCacheTime',cacheTimeStamp);
//             }else {
//                 jsonValue = (String)Cache.Org.getPartition(partitionInput).get(cacheKey);
//                 if(jsonValue !=null){
//                     Map<String, Object> mapvalues = (Map<String,Object>)JSON.deserializeUntyped(jsonValue);          
//                     map<String,Object> items = (map<String,Object>)mapvalues.get('objectData');
//                     Object cacheTimeStampobj = items.get('CaptureCacheTime');
//                     String cacheTimeStampStr = cacheTimeStampobj.toString();    
//                     if(cacheTimeStampStr !=null){
//                         uiData.put('CaptureCacheTime',cacheTimeStampStr);
//                     }else {
//                         uiData.put('CaptureCacheTime',cacheTimeStamp); 
//                     }           
//                 }
//                 else{
//                     uiData.put('CaptureCacheTime',cacheTimeStamp); 
//                 }                             
//             }

//         }catch (Exception e) {
//             PMP_Utility.logError(e,'PMP_OfferingDetails'); 
//             bSuccessful = false;
            
//         }
        
//         //Sandhya : START - US614322
//         try{
//             jsonValue = JSON.serialize(new PMP_LightningServerResponse(true,mapErrorInfo,uiData));
//             //system.debug('cacheKey in else-----'+cacheKey +isGuestUser);
//             String cacheTTLStr = PMP_Utility.getValue('Cache_TTL');
//             Integer cacheTTL = Integer.valueOf(cacheTTLStr); // 48hrs
//             if(cacheFlag.equalsIgnoreCase('true') && isGuestUser){
//                 Cache.Org.put(partitionInput+'.'+cacheKey, jsonValue,cacheTTL);
//             }              
//             }Catch(Cache.ItemSizeLimitExceededException error){
//                 PMP_Utility.logError(error,'PMP_OfferingDetails');  
//             }Catch(Cache.Org.OrgCacheException error){
//                 PMP_Utility.logError(error,'PMP_OfferingDetails');   
//             }
            
//         }
//         //Sandhya : END - US614322
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
//             //system.debug(offering);
//             PMP_Partner_Offering__c workingCopyId = [ select PMP_Working_Copy_Id__c,PMP_Is_Not_Available_On_MP_Ind__c from PMP_Partner_Offering__c 
//                                                     where id=:offering.Id ];
//             if(workingCopyId.PMP_Working_Copy_Id__c <> null){
//                 //system.debug('Working Copy Id is ' + workingCopyId.PMP_Working_Copy_Id__c);
//                 offering.Id = workingCopyId.PMP_Working_Copy_Id__c;
//                 //system.debug(' New Copy Id is ' + offering.Id);
//             } 
//             offering.PMP_Is_Notified_Ind__c = false;
//             //Below line is added by Krishna for part of user story :US847115 : capturing the recent submitter offering user id.
//             offering.PMP_Offering_Submitter_UserId__c = UserInfo.getUserId();
//             if(Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()){
//                 update offering;
//             }    
//         }
//     }
//     //Manasa Madapati
//     //Added to remove offering record cache
//     //Button - Clear Cache 
//     @AuraEnabled
//     public static Boolean removeRecordCache(String recordId, String objectName){  
//         String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
//         String langKeys=PMP_StaticConstants_Partner.supportedLanguagesForPlatformCache;
//         Map<String,String> langMap= new Map<string,string>();
//         for(String languageCode : langKeys.split('\\;')){
//             langMap.put(languageCode,languageCode.replace('_', '').replace('-', ''));
//         }
//         for(string str : langMap.keySet()){
//             if(langMap.containsKey(str)){
//                String cachekey = objectName+recordId+langMap.get(str); 
//                 if(cachekey != null){
//                     Cache.Org.remove(partitionInput+'.'+cachekey);
//                  } 
//                }            
//         }                     
//         return true;
//     }
    
  
//     //Sai Thotakura
//     //Filter conditions have been updated to exclude the offerings where Is not Available on marketplace indicator is true
//     @AuraEnabled
//     public static Boolean checkValidOffering(String offeringId, Boolean isPreview){
//         boolean isIntelEmployee = PMP_Utility.isIntelEmployee();
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
//             Boolean isSamePartnerUserIndicator = false;
//             if(partnerOfferings.size() > 0 && accIds.size() > 0){
//                 Map<String, Boolean> samePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(accIds);
//                 for(String acc : accIds){
//                     isSamePartner = samePartnerMap.get(acc);
//                 }
//                 isSamePartnerUserIndicator=PMP_SearchUtilityController.isSamePartnerUserMethod(accIds);
//             }
            
//             //Existing Query
//             /*List<PMP_Partner_Offering__c> partnerOfferings = [SELECT Id,PMP_Partner_Offering_Start_Dt__c,PMP_Partner_Offering_End_Dt__c,PMP_Company_Id__r.PMP_Account_Id__c,PMP_Is_Published_Ind__c,PMP_Working_Copy_Id__c FROM PMP_Partner_Offering__c WHERE Id = :offeringId];

//             Boolean isSamePartner = FALSE;
//             if(partnerOfferings.size() > 0 && partnerOfferings[0].PMP_Company_Id__r.PMP_Account_Id__c != null) {
//                 Map<String, Boolean> samePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(new List<String> {partnerOfferings[0].PMP_Company_Id__r.PMP_Account_Id__c});
//                 isSamePartner = samePartnerMap.get(partnerOfferings[0].PMP_Company_Id__r.PMP_Account_Id__c);
//             }*/
//             if(isIntelEmployee || isPreview || isMPAdmin()) {
//                 isActive = true;
//             } else if(isOfferingPermissionUser() && isSamePartnerUserIndicator) {
                
//                 if(partnerOfferings.size() > 0) {
//                     if(partnerOfferings[0].PMP_Working_Copy_Id__c != null) {
//                         offerings = [SELECT Id FROM PMP_Partner_Offering__c WHERE Id = :offeringId AND ((PMP_Partner_Offering_Lifecycle_Status_Nm__c !='Retired') OR (PMP_Partner_Offering_Lifecycle_Status_Nm__c ='Retired')) AND 
//                                      PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = FALSE AND PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published  ];
//                     } else {
//                         offerings = [SELECT Id FROM PMP_Partner_Offering__c WHERE Id = :offeringId AND PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = FALSE AND PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published ];
//                     }
//                 }
//                 isActive = offerings.size() > 0;
//             } else {
//                 offerings = [SELECT Id FROM PMP_Partner_Offering__c WHERE Id = :offeringId AND PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND PMP_Is_Not_Available_On_MP_Ind__c=false  AND 
//                 ((PMP_Partner_Offering_Lifecycle_Status_Nm__c !='Retired' AND PMP_Partner_Offering_End_Dt__c >= TODAY) OR (PMP_Partner_Offering_Lifecycle_Status_Nm__c ='Retired')) AND PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND
//                              PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = FALSE];
//                 isActive = offerings.size() > 0;
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
    
//         public static list<marketingInfoWrapperFinal> buildMarketingInfo(list<PMP_Partner_Offering_Specification__c> offSpecs,list<PMP_Partner_Offering_Category__c> offCategories,string language) {
//         //list<marketingInfoWrapper> marketInfoList = new List<marketingInfoWrapper> ();
//         map<string,marketingInfoWrapper> wrapperMap = new map<string,marketingInfoWrapper>();
//         list<marketingInfoWrapperFinal> marketInfoListFinal = new List<marketingInfoWrapperFinal> ();
//         map<string,marketingInfoWrapperFinal> wrapperMapFinal = new map<string,marketingInfoWrapperFinal>();
//         map<string,list<string>> subSectionMap = new map<string,list<string>>();
//         map<string,string> existingDataMap = new map<string,string>();
//         map<string,marketingInfoWrapperFinal> categoryWrapperMap = new map<string,marketingInfoWrapperFinal>();
//         map<string,boolean> parentCategoryMap = new map<string,boolean>();
        
        
//         for(integer i=0;i<offCategories.size();i++){
//             if(offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c!=Null && (offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('Industry') || offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('Use Cases'))){
//                if(offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')){
//                    if(parentCategoryMap.get(offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name)==Null){
//                        parentCategoryMap.put(offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name,true);
//                    }else{
//                        parentCategoryMap.put(offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name,false);
//                    }
//                }else{
//                    if(parentCategoryMap.get(offCategories[i].Name)==Null){
//                        parentCategoryMap.put(offCategories[i].Name,true);
//                    }else if(offCategories[i].Name=='Others'){
//                     parentCategoryMap.put(offCategories[i].Name,true);
//                    }else{
//                        parentCategoryMap.put(offCategories[i].Name,false); 
//                    }
//                }
//             }
//         }
        
        
//         for(integer i=0;i<offCategories.size();i++){
            
//             if(offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c!=Null && (offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('Industry') || offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('Use Cases'))){
//                 string headline = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Nm__c : offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c;
//                 if(categoryWrapperMap.get(headline)!=Null){
//                     marketingInfoWrapperFinal info = categoryWrapperMap.get(headline);
//                     items infoItems = new items();
//                     if((offCategories[i]!=Null && offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')) || (parentCategoryMap.get(offCategories[i].Name)!=Null && parentCategoryMap.get(offCategories[i].Name)==true)){
//                             infoItems.section = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name+' : '+ offCategories[i].Name : offCategories[i].Name;
//                             infoItems.sectionChinese = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Chinese_Nm__c+' : '+ offCategories[i].PMP_Category_Id__r.PMP_Category_Chinese_Nm__c : offCategories[i].PMP_Category_Id__r.PMP_Category_Chinese_Nm__c;
//                             infoItems.sectionJapanese = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Japanese_Nm__c+' : '+ offCategories[i].PMP_Category_Id__r.PMP_Category_Japanese_Nm__c : offCategories[i].PMP_Category_Id__r.PMP_Category_Japanese_Nm__c;
//                             info.Items.add(infoItems); 
//                             info.Items.sort();
//                             categoryWrapperMap.put(info.headline,info);
//                     }
//                 }    
//                 else{
//                     marketingInfoWrapperFinal info = new marketingInfoWrapperFinal();
//                     info.items = new list<items>();
//                     info.headline = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Nm__c : offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c;
//                     info.headlineChinese = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Chinese_Nm__c : offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Chinese_Nm__c;
//                     info.headlineJapanese = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Japanese_Nm__c : offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Japanese_Nm__c;
//                     items infoItems = new items();
//                     infoItems.section = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name+' : '+ offCategories[i].Name : offCategories[i].Name;
//                     infoItems.sectionChinese = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Chinese_Nm__c+' : '+ offCategories[i].PMP_Category_Id__r.PMP_Category_Chinese_Nm__c : offCategories[i].PMP_Category_Id__r.PMP_Category_Chinese_Nm__c;
//                     infoItems.sectionJapanese = offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.contains('|')? offCategories[i].PMP_Category_Id__r.PMP_Ancestor_Category_Japanese_Nm__c+' : '+ offCategories[i].PMP_Category_Id__r.PMP_Category_Japanese_Nm__c : offCategories[i].PMP_Category_Id__r.PMP_Category_Japanese_Nm__c;
//                     info.Items.add(infoItems); 
//                     info.Items.sort();
//                     categoryWrapperMap.put(info.headline,info);
//                 }
//             }
//         }
        
        
        
        
//         for(PMP_Partner_Offering_Specification__c offSpec: offSpecs){
//            if(offSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c!=Null && (offSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c.contains('Availability and Pricing') || offSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c.contains('Regional Coverage'))){
//                     if(offSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c=='Availability and Pricing'){
//                         marketingInfoWrapper newInfo = new marketingInfoWrapper();
//                         newInfo.headline = offSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c;
                        
//                         newInfo.headlineChinese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                         newInfo.headlineJapanese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
//                         newInfo.section = offSpec.PMP_Specification_Nm__c;
//                         newInfo.sectionChinese = offSpec.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                         newInfo.sectionJapanese = offSpec.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
//                         if(offSpec.PMP_Specification_Value_Cd__c!=Null){
//                             newInfo.section = newInfo.section + ': ' +offSpec.PMP_Specification_Value_Cd__c;
//                             newInfo.sectionChinese = newInfo.sectionChinese + ': ' +offSpec.PMP_Specification_Value_Cd__c;
//                             newInfo.sectionJapanese = newInfo.sectionJapanese + ': ' +offSpec.PMP_Specification_Value_Cd__c;
//                         }
//                         wrapperMap.put(offSpec.PMP_Specification_Nm__c,newInfo);
//                     }else{
//                         if(offSpec.PMP_Specification_Value_Cd__c!=Null && wrapperMap.get(offSpec.PMP_Specification_Nm__c)!=Null){
//                             marketingInfoWrapper newInfo = new marketingInfoWrapper();
//                             newInfo.headline = offSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c;
//                             newInfo.headlineChinese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                             newInfo.headlineJapanese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
//                             newInfo.parentName = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c;
//                             newInfo.parentNameChinese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                             newInfo.parentNameJapanese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                             newInfo.section = offSpec.PMP_Specification_Nm__c;
//                             newInfo.sectionChinese = offSpec.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                             newInfo.sectionJapanese = offSpec.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
//                             if(offSpec.PMP_Specification_Value_Cd__c!=Null){
//                                 newInfo.subsections = wrapperMap.get(offSpec.PMP_Specification_Nm__c).subsections+', '+offSpec.PMP_Specification_Value_Cd__c;
//                                 newInfo.subsectionsChinese = wrapperMap.get(offSpec.PMP_Specification_Nm__c).subsectionsChinese +', '+offSpec.PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c;
//                                 newInfo.subsectionsJapanese = wrapperMap.get(offSpec.PMP_Specification_Nm__c).subsectionsJapanese +', '+offSpec.PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c; 
//                             }
//                              wrapperMap.put(offSpec.PMP_Specification_Nm__c,newInfo); 
//                          }else if(offSpec.PMP_Specification_Value_Cd__c!=Null){
//                             marketingInfoWrapper newInfo = new marketingInfoWrapper();
//                             newInfo.headline = offSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c;
//                             newInfo.headlineChinese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                             newInfo.headlineJapanese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
//                             newInfo.parentName = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c;
//                             newInfo.parentNameChinese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                             newInfo.parentNameJapanese = offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                             newInfo.section = offSpec.PMP_Specification_Nm__c;
//                             newInfo.sectionChinese = offSpec.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c;
//                             newInfo.sectionJapanese = offSpec.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c;
//                             if(offSpec.PMP_Specification_Value_Cd__c!=Null){
//                                 newInfo.subsections = newInfo.section+': '+offSpec.PMP_Specification_Value_Cd__c;
//                                 newInfo.subsectionsChinese = newInfo.sectionChinese+': '+offSpec.PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c;
//                                 newInfo.subsectionsJapanese = newInfo.sectionJapanese+': '+offSpec.PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c;
//                                 existingDataMap.put(offSpec.PMP_Specification_Nm__c+'|'+offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c,'false');
//                                 existingDataMap.put(newInfo.sectionChinese+'|'+offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c,'false');
//                                 existingDataMap.put(newInfo.sectionJapanese+'|'+offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Japanese_Nm__c,'false');
//                             }
//                             wrapperMap.put(offSpec.PMP_Specification_Nm__c,newInfo);
//                          }else{
//                              if(offSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c.contains('|') && existingDataMap.get(offSpec.PMP_Specification_Nm__c+'|'+offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c)==Null){                      
//                                  existingDataMap.put(offSpec.PMP_Specification_Nm__c+'|'+offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c,'en_us');
//                                  existingDataMap.put(offSpec.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c+'|'+offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c,'zh_cn');
//                                  existingDataMap.put(offSpec.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c+'|'+offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Japanese_Nm__c,'ja_jp');
//                              }else if(offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c=='Regional Coverage'){
//                                  existingDataMap.put(offSpec.PMP_Specification_Nm__c,'en_us|Region');
//                                  existingDataMap.put(offSpec.PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,'zh_cn|Region');
//                                  existingDataMap.put(offSpec.PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c,'ja_jp|Region');
//                              }
//                          }  
//                     }      
               
//             }
//         }
        
        
       
//         for(string str: wrapperMap.keyset()){
            
//             if(wrapperMap.get(str).headline=='Availability and Pricing' && wrapperMapFinal.get(wrapperMap.get(str).headline)!=Null){
//                 marketingInfoWrapperFinal info = wrapperMapFinal.get(wrapperMap.get(str).headline);
//                 items infoItems = new items();
//                 infoItems.section = wrapperMap.get(str).section;
//                 infoItems.sectionChinese = wrapperMap.get(str).sectionChinese;
//                 infoItems.sectionJapanese = wrapperMap.get(str).sectionJapanese;
//                 info.Items.add(infoItems); 
//                 wrapperMapFinal.put(wrapperMap.get(str).headline,info);               
                
//             }else if(wrapperMap.get(str).headline=='Availability and Pricing'){
//                 marketingInfoWrapperFinal info = new marketingInfoWrapperFinal();
//                 info.headline = 'Availability and Pricing';
//                 info.headlineChinese = wrapperMap.get(str).headlineChinese;
//                 info.headlineJapanese = wrapperMap.get(str).headlineJapanese;
//                 info.items = new list<items>();
//                 items infoItems = new items();
//                 infoItems.section = wrapperMap.get(str).section;
//                 infoItems.sectionChinese = wrapperMap.get(str).sectionChinese;
//                 infoItems.sectionJapanese = wrapperMap.get(str).sectionJapanese;
//                 info.Items.add(infoItems); 
//                 wrapperMapFinal.put(wrapperMap.get(str).headline,info);   
//             }
            
//             if(wrapperMap.get(str).headline.contains('Regional Coverage') && wrapperMapFinal.get('Regional Coverage')!=Null){
//                 marketingInfoWrapperFinal info = wrapperMapFinal.get('Regional Coverage');
//                 items infoItems = new items();
//                 infoItems.section = wrapperMap.get(str).parentName;
//                 infoItems.sectionChinese = wrapperMap.get(str).parentNameChinese;
//                 infoItems.sectionJapanese = wrapperMap.get(str).parentNameJapanese;
//                 infoItems.subsection = new List<string>();
//                 infoItems.subsectionChinese = new List<string>();
//                 infoItems.subsectionJapanese = new List<string>();
//                 infoItems.subsection.add(wrapperMap.get(str).subsections);
//                 infoItems.subsectionChinese.add(wrapperMap.get(str).subsectionsChinese);
//                 infoItems.subsectionJapanese.add(wrapperMap.get(str).subsectionsJapanese);
//                 info.Items.add(infoItems);
//                 wrapperMapFinal.put(info.headline,info);  
//             }else if(wrapperMap.get(str).headline.contains('Regional Coverage')){
//                 marketingInfoWrapperFinal info = new marketingInfoWrapperFinal();
//                 info.headline = 'Regional Coverage';
//                 info.items = new list<items>();
//                 items infoItems = new items();
//                 infoItems.section = wrapperMap.get(str).parentName;
//                 infoItems.sectionChinese = wrapperMap.get(str).parentNameChinese;
//                 infoItems.sectionJapanese = wrapperMap.get(str).parentNameJapanese;
//                 infoItems.subsection = new List<string>();
//                 infoItems.subsectionChinese = new List<string>();
//                 infoItems.subsectionJapanese = new List<string>();
//                 infoItems.subsection.add(wrapperMap.get(str).subsections);
//                 infoItems.subsectionChinese.add(wrapperMap.get(str).subsectionsChinese);
//                 infoItems.subsectionJapanese.add(wrapperMap.get(str).subsectionsJapanese);
//                 info.Items.add(infoItems);
//                 wrapperMapFinal.put(info.headline,info);  
            
//             }
//         }
        
//         for(string str: wrapperMapFinal.keyset()){
            
//             if(wrapperMapFinal.get(str).headline=='Regional Coverage'){
//                for(integer i=0;i<wrapperMapFinal.get(str).items.size();i++){
                   
//                    if(subSectionMap.get(wrapperMapFinal.get(str).items[i].section)!=null){
//                        wrapperMapFinal.get(str).items[i].subsection.addall(subSectionMap.get(wrapperMapFinal.get(str).items[i].section));
                       
//                        wrapperMapFinal.get(str).items[i].subsectionChinese.addall(subSectionMap.get('zh_cn'+ '|' + wrapperMapFinal.get(str).items[i].sectionChinese));
//                        wrapperMapFinal.get(str).items[i].subsectionJapanese.addall(subSectionMap.get('ja_jp'+ '|' + wrapperMapFinal.get(str).items[i].sectionJapanese));
//                        subSectionMap.put(wrapperMapFinal.get(str).items[i].section,wrapperMapFinal.get(str).items[i].subsection);
//                        subSectionMap.put('zh_cn'+ '|' + wrapperMapFinal.get(str).items[i].sectionChinese,wrapperMapFinal.get(str).items[i].subsectionChinese);
//                        subSectionMap.put('ja_jp'+ '|' + wrapperMapFinal.get(str).items[i].sectionJapanese,wrapperMapFinal.get(str).items[i].subsectionJapanese);
//                    }else{
//                        subSectionMap.put(wrapperMapFinal.get(str).items[i].section,wrapperMapFinal.get(str).items[i].subsection);
//                        subSectionMap.put('zh_cn'+ '|' +wrapperMapFinal.get(str).items[i].sectionChinese,wrapperMapFinal.get(str).items[i].subsectionChinese);
//                        subSectionMap.put('ja_jp'+ '|' + wrapperMapFinal.get(str).items[i].sectionJapanese,wrapperMapFinal.get(str).items[i].subsectionJapanese);
//                    }
//                }     
//             }else{
//                 marketingInfoWrapperFinal info = wrapperMapFinal.get(str);
//                 for(integer i=0;i<wrapperMapFinal.get(str).items.size();i++){
//                     if(language.contains('zh')){
//                         info.headLine = info.headLineChinese;
//                         info.items[i].section = info.items[i].sectionChinese;
//                     }else if(language.contains('ja')){
//                         info.headLine = info.headLineJapanese;
//                         info.items[i].section = info.items[i].sectionJapanese;
//                     }
//                 }
//                 marketInfoListFinal.add(info);
//             }
//         }
        
//         marketingInfoWrapperFinal newRegions = new marketingInfoWrapperFinal();
//         newRegions.headline = system.label.PMP_GeographicalCoverage;
//         newRegions.items = new List<items>();
//         map<string,string> regionMap = new map<string,string>();
        
//         for(string str: subSectionMap.keySet()){
//             //system.debug('**language'+language);
//             if(str.contains('zh_cn') && language.contains('zh')){
//                 items infoItem = new items();
//                 list<string> chineseList = str.split('\\|');
//                 infoItem.section = chineseList[1];
//                 infoItem.subSection = new List<string>();
//                 regionMap.put(infoItem.section,'true');
//                 for(Integer i=0;i<subSectionMap.get(str).size();i++){
//                     infoItem.subSection.add(subSectionMap.get(str)[i]+'.');
//                 }
//                 newRegions.items.add(infoItem);
//             }else if(str.contains('ja_jp') && language.contains('ja')){
//                 items infoItem = new items();
//                 list<string> japaneseList = str.split('\\|');
//                 infoItem.section = japaneseList[1];
//                 infoItem.subSection = new List<string>();
//                 regionMap.put(infoItem.section,'true');
//                 for(Integer i=0;i<subSectionMap.get(str).size();i++){
//                     infoItem.subSection.add(subSectionMap.get(str)[i]+'.');
//                 }
//                 newRegions.items.add(infoItem);
//             }else if(!str.contains('ja_jp') && !str.contains('zh_cn') && (language.contains('en') || language=='NA')){
//                 items infoItem = new items();
//                 infoItem.section = str;
//                 infoItem.subSection = new List<string>();
//                 regionMap.put(infoItem.section,'true');
//                 for(Integer i=0;i<subSectionMap.get(str).size();i++){
//                     infoItem.subSection.add(subSectionMap.get(str)[i]);
//                 }
//                 newRegions.items.add(infoItem);
//             }
//         }
        
//         map<string,items> existingDataMapFinal = new map<string,items>();
//         for(string str: existingDataMap.keyset()){
//             if(existingDataMap.get(str)!='false' && (((language.contains('en') || language=='NA') && existingDataMap.get(str)=='en_us') || (language.contains('zh') && existingDataMap.get(str)=='zh_cn') || (language.contains('ja') && existingDataMap.get(str)=='ja_jp'))){
//                list<string> strList = str.split('\\|');
               
//                if(existingDataMapFinal.get(strList[1])!=Null){
//                    items infoItem = existingDataMapFinal.get(strList[1]);
//                    infoItem.subSection.add(strList[0]+'.');
                   
//                    for(integer i=0;i<newRegions.items.size();i++){
//                        if(newRegions.items[i].section==strList[1]){
//                           newRegions.items.remove(i); 
//                        }
//                    }
//                    newRegions.items.add(infoItem);
//                    existingDataMapFinal.put(strList[1],infoItem);
//                }else{
//                    items infoItem = new items();
//                    infoItem.section = strList[1]; 
//                    infoItem.subSection = new List<string>();
//                    infoItem.subSection.add(strList[0]+'.');
//                    for(integer i=0;i<newRegions.items.size();i++){
//                         if(newRegions.items[i].section==strList[1] && newRegions.items[i].subSection==null){
//                            newRegions.items.remove(i);
//                         }
//                     }
//                    newRegions.items.add(infoItem);
//                    existingDataMapFinal.put(strList[1],infoItem);
//                }    
//             }else if(existingDataMap.get(str)!='false' && (((language.contains('en') || language=='NA') && existingDataMap.get(str)=='en_us|Region') || (language.contains('zh') && existingDataMap.get(str)=='zh_cn|Region') || (language.contains('ja') && existingDataMap.get(str)=='ja_jp|Region')) && regionMap.get(str)==Null){
//                    items infoItem = new items();
//                    infoItem.section = str;
//                    newRegions.items.add(infoItem);
//             }
//         }
//         List<String> sortedsubsecList = new List<String>();
//         List<items> newRegSorted = new List<items>();
//         map<string,items> regMap = new map<string,items>();
//         for(items itemRecord :newRegions.items){
//             String sortedsubsec = '';
//             sortedsubsecList=new List<String>();
//             if(itemRecord.subsection!=null && itemRecord.subsection.size()>0){
//                 for(String subsecRecord:itemRecord.subsection){
//                     string[] splitted = subsecRecord.split('\\:');
//                     List<String> subList = new List<String>();
//                     if(splitted.size()>1){
//                         subList = splitted[1].split(',');
//                         subList.sort();
//                     }
//                     if(subList.size()>0){
//                         sortedsubsec = splitted[0]+': '+string.join(subList,', ');
//                     }
//                     else{
//                         sortedsubsec = splitted[0];
//                     }
//                     sortedsubsecList.add(sortedsubsec);
//                 }
//            }
//            items itemstemp = itemRecord;
//            sortedsubsecList.sort();
//            if(sortedsubsecList.size()>0){
//                 itemstemp.subsection = sortedsubsecList;
//            }
//            else{
//                 itemstemp.subsection = null;
//            }
//            regMap.put(itemstemp.section, itemstemp);
//         }
//         List<String> keySectionList = new List<String>();
//         keySectionList.addAll(regMap.keySet());
//         keySectionList.sort();
//         for(String section:keySectionList){
//             newRegSorted.add(regMap.get(section));
//         }
//         newRegions.items = newRegSorted;
//         marketInfoListFinal.add(newRegions);
        
       
//        for(string str: categoryWrapperMap.keyset()){
//            marketingInfoWrapperFinal info = categoryWrapperMap.get(str);
           
//               for(integer i=0;i<info.items.size();i++){
//                   if(language.contains('zh')){
//                       info.headline = info.headLineChinese;
//                       info.items[i].section = info.items[i].sectionChinese;
//                   }else if(language.contains('ja')){
//                       info.headline = info.headLineJapanese;
//                       info.items[i].section = info.items[i].sectionJapanese;
//                   }
//               }
//            marketInfoListFinal.add(categoryWrapperMap.get(str));
//         }

//         return marketInfoListFinal;
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
//     public class marketingInfoWrapper{
//         @AuraEnabled
//         public string headline{get;set;}
//         @AuraEnabled
//         public string headlineChinese{get;set;}
//         @AuraEnabled
//         public string headlineJapanese{get;set;}
//         @AuraEnabled 
//         public string section{get;set;}
//         @AuraEnabled
//         public string sectionChinese{get;set;}
//         @AuraEnabled
//         public string sectionJapanese{get;set;}
//         @AuraEnabled
//         public string parentName{get;set;}
//         @AuraEnabled
//         public string parentNameChinese{get;set;}
//         @AuraEnabled
//         public string parentNameJapanese{get;set;}
//         @AuraEnabled
//         public string subSections{get;set;}
//         @AuraEnabled
//         public string subSectionsChinese{get;set;}
//         @AuraEnabled
//         public string subSectionsJapanese{get;set;}
//     }
//     public class marketingInfoWrapperFinal{
//         @AuraEnabled
//         public string headline{get;set;}
//         @AuraEnabled
//         public string headlineChinese{get;set;}
//         @AuraEnabled
//         public string headlineJapanese{get;set;}
//         @AuraEnabled 
//         public list<items> items{get;set;}
//     }
//     public class items implements Comparable{
//         @AuraEnabled
//         public string section{get;set;}
//         @AuraEnabled
//         public string sectionChinese{get;set;}
//         @AuraEnabled
//         public string sectionJapanese{get;set;}
//         @AuraEnabled 
//         public List<string> subsection{get;set;}
//         @AuraEnabled 
//         public List<string> subsectionChinese{get;set;}
//         @AuraEnabled 
//         public List<string> subsectionJapanese{get;set;}
//         public Integer compareTo(Object ObjToCompare) 
//         {
//             return section.CompareTo(((items)ObjToCompare).section);
//         }
//     }
//     public class media{
//         @AuraEnabled
//         public string accountId{get;set;}
//         @AuraEnabled
//         public string videoId{get;set;}
//         @AuraEnabled
//         public string title{get;set;}
//         @AuraEnabled 
//         public string videoType{get;set;}
//         @AuraEnabled 
//         public string thumbnailUrl{get;set;}
//         @AuraEnabled
//         public string imageUrl{get;set;}
//         @AuraEnabled
//         public string videoThumbnailUrl{get;set;}
//         @AuraEnabled
//         public string description{get;set;}
//         @AuraEnabled
//         public string altText{get;set;}
//         @AuraEnabled
//         public string placeholder1920px{get;set;}
//         @AuraEnabled
//         public string placeholder246px{get;set;}
//     }
     
}