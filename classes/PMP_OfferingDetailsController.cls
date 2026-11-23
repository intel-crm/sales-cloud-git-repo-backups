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
public with sharing class PMP_OfferingDetailsController extends PMP_SearchWrapperStore{ 
    public static boolean recurseCheck = false;
    
    /**
    * @description Method To Fetch Multiple Offering Details
    * @param Id
    * @return String
    **/
    @AuraEnabled
    public static Map<String,String> fetchOfferingDetails(List<Id> offeringIds,Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering){
        Map<String,String> offerings = new Map<String,String>();
        for(Integer i=0;i<offeringIds.size();i++)
        {
            offerings.put(offeringIds[i], PMP_OfferingDetailsController.fetchOfferingDetail(offeringIds[i], bEditOffering, bViewOffering,bCompareOffering,null,null,null));
        } 
        return offerings;  
    }
    
   @AuraEnabled 
   public static String getOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){
       if(isPreview){
           
           String offeringDetailResponse = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode,isPreview);
           return offeringDetailResponse;
       }else{
            
           String offeringDetailNotPrevResponse = fetchOfferingDetailNotPreview(offeringId, bEditOffering, bViewOffering, bCompareOffering, language, langCode,isPreview);
           return offeringDetailNotPrevResponse;
       }       
       
   }
    
    /**
    * @description Method to fetch all the offering related data
    * @param Id
    * @return String
    **/
   @AuraEnabled
    public static String fetchOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){
        system.debug('Inside detail page---');
        String userURLLaguageCode = language; //Gireesh:US664733
        Boolean bSuccessful = true;    
        map<string,object> uiData = new map<string,object>();
        map<String, Object> mapErrorInfo = new map<string,object>();
        Map<String,List<sObject>> fetchOffering = new Map<String,List<sObject>>();
        List<PMP_Partner_Offering_Resource__c> offeringResources = new List<PMP_Partner_Offering_Resource__c>();
        List<ContentDocument> conDocuments = new List<ContentDocument>();
        List<ContentVersion> conVersions = new List<ContentVersion>();
        List<ContentAsset> conAssets = new List<ContentAsset>();
        List<ContentAsset> thumbNailconAssets = new List<ContentAsset>();
        List<ContentAsset> imageConAssets = new List<ContentAsset>();
        List<ContentDistribution> conDistribution = new List<ContentDistribution>();
        List <offeringSpecValueMap> specMapWrapper = New List <offeringSpecValueMap>();
        List<String> docIds = new List<String>();
        Map<id,PMP_Partner_Offering_Resource__c > docIdIResourceMap = New Map<id, PMP_Partner_Offering_Resource__c >();
        List<PMP_Partner_Offering__c> offeringdetail = new List<PMP_Partner_Offering__c>();
        Set<Id> contentAssetIds = new Set<Id>();
        Integer seqNumberCounter = 0;
        Map<string, contentAssetWrapper> contentAssetWrapperMap = New Map<string, contentAssetWrapper>(); //US592997 
        
       
        /*Sandhya - Implementation of Platform Cache :START - US614322*/
       
        String cacheLanguage;
        String jsonValue;
        Boolean cachePreview=False;
       
        //Caching only for Guest users
        Boolean isGuestUser = false;
		Id profileId = userInfo.getProfileId();
            
		String guestProfileName = [Select Name from Profile where Id =: profileId].Name;
		if(PMP_StaticConstants_Offering.guestProfiles.contains(guestProfileName)){
            isGuestUser = true;
        }
      
        //Add the guest user language to Cache as Key
        if(langCode != null){
            if(langCode.contains('_')){
                cacheLanguage = langCode.replace('_', '');
            }else{
                cacheLanguage = langCode;
        	}
        }
        
        // Name of a partition
        String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        
        //Get the flag from Custom Metadata
        String cacheFlag = PMP_Utility.getValue('Cache_Flag');
         
        //Prepare the key
        String cacheKey = (String)offeringId+cacheLanguage; 
        
        if(isPreview != null){
            cachePreview = isPreview;
        }
        long startTime = System.currentTimeMillis();
        system.debug('startTime----'+startTime);
        
        if(Cache.Org.contains(partitionInput+'.'+cacheKey) && !cachePreview  && cacheFlag.equalsIgnoreCase('true') && isGuestUser){
            //system.debug('Inside Cache Code');
            //system.debug('cacheKey inside cache----'+cacheKey);
        	//system.debug('isGuestUser inside cache----'+isGuestUser);
        	//system.debug('cachePreview inside cache----'+cachePreview);
            jsonValue = (String)Cache.Org.getPartition(partitionInput).get(cacheKey);
            //system.debug('cacheKey in If-----'+cacheKey +isGuestUser);
            if(jsonValue != null){
                
                long elapsedTime = System.currentTimeMillis() - startTime;
                System.debug('elapsedTime with Cache(Detail)------------------'+elapsedTime);
            return jsonValue;  
            }
        }
        /*Sandhya : End - US614322*/
        else{
                 
          String userLanguageCode = userinfo.getLanguage();
          if(userLanguageCode =='ja'){
            userLanguageCode = userLanguageCode+ '_JP'; 
          }
        /*------------------------------------Part 1 Changes End-----------------------------------*/

        try{
            for(PMP_Partner_Offering__c offering : [Select id,
                                            (Select id,Name,PMP_Partner_Offering_Image__c,toLabel(PMP_Resource_Type_Nm__c),
                                             PMP_Partner_Offering_Resource_URL_Txt__c,PMP_Resource_Sequence_Nbr__c from Offering_Resources__r ORDER by PMP_Resource_Sequence_Nbr__c),
                                            PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Partner_Offering_End_Dt__c,PMP_Offering_Language_Nm__c,
                                            PMP_Partner_Offering_Id__c,PMP_Partner_Offering_Start_Dt__c,PMP_Offering_Status_Update_Dt__c,PMP_Translated_Languages__c,
                                            PMP_Partner_Revision_Comment_Txt__c,PMP_Company_Id__c,PMP_Company_Id__r.Name,PMP_Working_Copy_Id__c,
                                            PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,Name,PMP_Partner_Offering_Nm__c,
                                            PMP_Partner_Offering_Visibility_Nm__c,PMP_Company_Id__r.PMP_Account_Id__c,PMP_Offering_Id__c,PMP_Pre_Release_Check_Nm__c,
                                            PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Is_Notified_Ind__c,
                                            PMP_Category_nm__c, PMP_Sub_Category_nm__c,PMP_Pre_Release_Item_Count_Num__c,PMP_Is_Published_Ind__c       
                                            from PMP_Partner_Offering__c where id = :offeringId])
            {
            
             
             /*PART-2 To consider loggedIn user's language if langauge param is null or empty */
             
             if(language != 'NA'){
                     List<PMP_Partner_Offering_Translation__c> translatedValues = PMP_Utility.getOfferingTranslationRecords(offeringId);
                            Map<string,string> languageFieldMap = New Map<string,string>();
                            List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMtdList = New List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();
                            if(language!= null){
                               localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(language,'Offering_Translation');
                            }
                            else{
                                localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(userLanguageCode ,'Offering_Translation');
                            }
                            
                            for(PMP_Locale_To_FieldAPINm_Mapping__mdt mapping : localeMtdList ){
                                 languageFieldMap.put(mapping.PMP_Locale_Nm__c,mapping.PMP_Field_APINm__c );
                             } 
                        Map<string, PMP_Partner_Offering_Translation__c> fieldAndValueMap = New Map<string,PMP_Partner_Offering_Translation__c>();
                        if(translatedValues.size()>0){
                            for(PMP_Partner_Offering_Translation__c iterValue : translatedValues){
                            system.debug('trans--.' +iterValue );
                                fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
                            }
                        }
                        system.debug(userLanguageCode );
                        if(language ==null && fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c')
                          && string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(userLanguageCode )))!=null){
                            language = userLanguageCode; 
                        }
                 
                 /*---------------------------------------Part 2 Changes End ------------------------*/
                   
                    if(language!=null && language != 'NA'){ //Added by Abhishek US398772 replacing the offering name, tooltip based on language parameter
                        
                        offering.PMP_Partner_Offering_Nm__c= fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c')?
                                                            string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(language))) : null;     
                        offering.PMP_Partner_Offering_Dsc__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Dsc__c')?
                                                            string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(language))) : null;
                        offering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
                                                            string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(language))) : null;
                        
                        
                        
                    }
                } 
                
                if(!String.isBlank(offering.PMP_Partner_Offering_Dsc__c)){
                    offering.PMP_Partner_Offering_Dsc__c = offering.PMP_Partner_Offering_Dsc__c.unescapeHtml4();
                }    
                
                offeringdetail.add(offering);
                
                //Added by shahrukh US396679 : To navigate from published copy to working copy
                if(offering.PMP_Working_Copy_Id__c!=null){ 
                   uiData.put('WorkingCopyId',offering.PMP_Working_Copy_Id__c); 
                }
                //End of Code US396679
                
                //Get resources(Images and URLs) and  Content Document Id for the images
                
                for(PMP_Partner_Offering_Resource__c resource : offering.Offering_Resources__r){
                    
                    if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Image || resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Thumbnail_Image){ 
                       //US592997 : Wrapper is required so that we can send both thumbnail and actual image url as 1 row to the UI
                        contentAssetWrapper contWrapper = New contentAssetWrapper();
                        //resource name will be the key for the contentAssetWrapperMap
                        // -----populating contentAssetWrapperMap start ---
                        if(contentAssetWrapperMap.containsKey(resource.Name)){ 
                            contWrapper = contentAssetWrapperMap.get(resource.name);
                            if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Thumbnail_Image){                           
                                contWrapper.thumbnailUrl = resource.id+'_'+offering.id;
                            }
                            else if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Image){
                                contWrapper.imageUrl = resource.id+'_'+offering.id;
                            }
                            contentAssetWrapperMap.put(resource.name,contWrapper );
                        }
                        else{
                            
                            contWrapper.type = resource.PMP_Resource_Type_Nm__c;
                           // contWrapper.contentId = ca.id;
                            if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Thumbnail_Image){                           
                                contWrapper.thumbnailUrl = resource.id+'_'+offering.id;
                            }
                            else if(resource.PMP_Resource_Type_Nm__c == System.Label.PMP_Image){
                                contWrapper.imageUrl = resource.id+'_'+offering.id;
                            }
                            contentAssetWrapperMap.put(resource.name,contWrapper );
                        }
                    }
                    // -----populating contentAssetWrapperMap start ---
                    offeringResources.add(resource);
                }
                
                string mdaId = PMP_SearchUtilityController.getMdaId(String.valueOf(offering.PMP_Company_Id__r.PMP_Account_Id__c));
                
                uiData.put('mdaId', mdaId);
                
                if(!recurseCheck ){ //Contact Partner button visibility check logic for US536318 & US519720 - Prabuddh 
                    boolean showContactPartner = PMP_SearchUtilityController.isContactButtonVisible(offering);
                    uiData.put('showContactPartner',showContactPartner); 
                    recurseCheck = true; 
                }
                
             }
             //commented by Abhishek
       /*     Map<id,id> contAsetContDocIdMap = New Map<id,id>();
            List<contentAssetWrapper> contentWrapperList = New List<contentAssetWrapper>();
            //if(docIds.size() >0 ){
            if(docIdIResourceMap.keyset().size() > 0){
                conDocuments = [select id,title,contentAssetId,FileType,FileExtension,ContentSize from ContentDocument where id in :docIds ORDER by createdDate];
                
                if(!conDocuments.isEmpty()){
                       for(contentDocument cd: conDocuments){
                            //if(cd.contentAssetId!=NULL && cd.contentAssetId!=''){
                                contentAssetIds.add(cd.contentAssetId);
                                contAsetContDocIdMap.put(cd.contentAssetId,cd.id);
                            //}
                       }
                   
                   if(contentAssetIds.size() > 0){
                        conAssets = [select id,developerName from contentAsset where id IN:contentAssetIds];
                   }
                } 
                
                conVersions = [select id,ContentDocumentId from ContentVersion where ContentDocumentId in :docIds ORDER by createdDate];
                
                conDistribution = [select id,ContentDocumentId,DistributionPublicUrl,ContentDownloadURL from ContentDistribution where ContentDocumentId in :docIds order By id];
                
            } Abhishek comment End--*/
      
            //Gets offering specification
            List<PMP_Partner_Offering_Specification__c> offSpecs = PMP_SpecificationController.getOfferingSpecifications(offeringId);
          //  uiData.put(PMP_StaticConstants_Offering.uploadedFiles,conDocuments);
          //  uiData.put(PMP_StaticConstants_Offering.contentVersions,conVersions);
           // uiData.put('conAssets',conAssets);
           if(contentAssetWrapperMap.values().size() >0){uiData.put('contentWrapper',contentAssetWrapperMap.values());}
            
            //uiData.put('image', imageconAssets);
            uiData.put('downloadURL',conDistribution);
            uiData.put(PMP_StaticConstants_Offering.OfferingDetail,offeringdetail);
            uiData.put(PMP_StaticConstants_Offering.existingURLs,offeringResources);
            uiData.put(PMP_StaticConstants_MasterData.Approved,PMP_StaticConstants_MasterData.Approved);
            
            boolean isAdmin = PMP_Utility.isLoggedInUserAdmin();
            uiData.put('isAdmin', isAdmin);
            
            boolean isAnonymousUser = PMP_Utility.isLoggedInUserAnonymous();
            uiData.put('isAnonymousUser', isAnonymousUser);
            
            if(!String.isBlank(language) && language != 'NA'){
                uiData.put('userLocale', language);
                
            }
            
            
            /*Added by raj to restrict editing for external users (US428208)*/
                Boolean hasEditAccess = Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable();
                Boolean isSysAdmin = false;
                Boolean isSamePartner = PMP_Utility.isUserUnderSamePartner(offeringdetail[0]);
                Boolean showEditButton = false;
                Id profId = userInfo.getProfileId();
            
            String profileName = [Select Name from Profile where Id =: profId].Name;
            
            if(PMP_StaticConstants_Offering.adminProfiles.contains(profileName)){
                isSysAdmin = true;
            }  
            
            if((hasEditAccess && isSamePartner) || isSysAdmin || isAdmin){
                showEditButton = true;
            }
                uiData.put(PMP_StaticConstants_Offering.showEditButton,showEditButton);
            /*-------------------------End---------------------------------*/
            
            
            
            if(offeringId != null && bEditOffering){
                List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryWrap = PMP_CategoryController.getOfferingCategoryList(offeringId);
                uiData.put(PMP_StaticConstants_Offering.masterCategoriesWithSelectedValues,categoryWrap);
                uiData.put(PMP_StaticConstants_Offering.selectedSpecifications,offSpecs);
            }
            if(offeringId != null && bViewOffering){
                
                //Gets offering Categories
                List<PMP_Partner_Offering_Category__c> offCategories = PMP_CategoryController.getOfferingCaregories(offeringId);
                if(String.isBlank(language)){
                    language = PMP_Utility.getLoggedInUsersLanguage();    
                }
                
                //Added by Abhishek to consider NA parameter
                if(String.isNotBlank(language) && language == 'NA'){
                    language = PMP_Utility.getLoggedInUsersLanguage(); 
                }
                /*US434807 : Added by raj to display taxonomy in user preferred language US434807*/
                if(String.isNotBlank(language) && language != 'NA'){//if the language URL parameter is not null,store local name in categories and specs
                    String localeCatNmField;//to store local field of category
                    String localeSpecNmField;//to store local field of specification
                    String localeSpecValNmField;//to store local field of specification value
                    
                    //fetch local Name fields from Utility method for all three objects(i.e Categories,Specifications,Specification Values)
                    List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeFields = PMP_Utility.getLocaleToFieldMdtRecordsByField(language, 'Name');
                    
                    for(PMP_Locale_To_FieldAPINm_Mapping__mdt localField : localeFields){//iterating over metadata records and getting the api field names of category, spec and specVal
                        if(localField.PMP_Object_Nm__c == 'Category'){
                            localeCatNmField = localField.PMP_Field_APINm__c;//storing the local field name of category
                        }
                        else if(localField.PMP_Object_Nm__c == 'Specification'){
                            localeSpecNmField = localField.PMP_Field_APINm__c;//storing the local field name of specifications
                        }
                        else if(localField.PMP_Object_Nm__c == 'Specification Value'){
                            localeSpecValNmField = localField.PMP_Field_APINm__c;//storing the local field name of specification values
                        }
                    }
                    
                    for(PMP_Partner_Offering_Category__c offCat : offCategories){//iterating over all the offering Categories and changing their name according to the language param 
                        
                        offCat.Name = String.valueOf(offCat.PMP_Category_Id__r.get(localeCatNmField));//getting the category name in user preferred language
                        
                    }
                    
                    for(PMP_Partner_Offering_Specification__c offSpec : offSpecs){//iterating over all the offering specifications and changing their name according to the language param
                        system.debug('offSpec'+offSpec);
                        system.debug('offSpec.PMP_Specification_Id__r'+offSpec.PMP_Specification_Id__r);
                        system.debug('localeSpecNmField'+localeSpecNmField);
                        if(String.isNotBlank(String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField)))){//getting the specification name in user preferred language
                            offSpec.PMP_Specification_Nm__c = String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField));//getting the category name in user preferred language
                            offSpec.Name = String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField));//getting the specification name in user preferred language
                            //Added by Deepanshu for DE77627
                            if(offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r != null){
                                offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name = String.valueOf(offSpec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.get(localeSpecNmField));
                            }
                        }
                        
                        if(offSpec.PMP_Specification_Value_Id__r != null){//If spec value is there, get it's name in user preferred language
                            if(String.isNotBlank(String.valueOf(offSpec.PMP_Specification_Value_Id__r.get(localeSpecValNmField)))){
                                offSpec.PMP_Specification_Value_Cd__c = String.valueOf(offSpec.PMP_Specification_Value_Id__r.get(localeSpecValNmField));//getting the spec value in user preferred language
                            }
                            else{
                                offSpec.PMP_Specification_Value_Cd__c = String.valueOf(offSpec.PMP_Specification_Value_Id__r.get('PMP_Specification_Value_Nm__c'));//getting the spec value in user english language
                            }
                        }
                    }
                }
                /*----------------------------------End------------------------------*/
                
                uiData.put(PMP_StaticConstants_Offering.selectedCategories,offCategories);
                uiData.put(PMP_StaticConstants_Offering.selectedSpecifications,offSpecs);
                /*--------------Added by raj to fetch partner details for US340041----------------------------------------*/
                //call getPartnerDetails method of PMP_ProductPartnerDetailsController to fetch partner details
                system.debug('compare--' +bCompareOffering);
                if(bCompareOffering != null && !bCompareOffering){ //Gireesh-fetch if CompareOffering is false
                    //Sandhya DE55547
                    Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(offeringdetail[0].PMP_Company_Id__c, null, true, langCode);
                    PMP_SearchPartnerDetailsController.partnerDetail productCompanyRes = PMP_SearchPartnerDetailsController.getPartnerDetails(partner.Id, langCode);
                    //Sandhya DE55547
                    PMP_SearchCompanyArticles.ArticleData articleProductList = PMP_SearchCompanyArticles.getPartnerArticles(partner.Id,langCode);
                    uiData.put(PMP_StaticConstants_Offering.partnerDetail, partner);
                    uiData.put(PMP_StaticConstants_Offering.productCompanyResource, productCompanyRes);
                    uiData.put(PMP_StaticConstants_Offering.articleCompanyResource, articleProductList);
                }
                
                /*-----------------------End US340041---------------------------------------------------------------------*/
                              
                if(bCompareOffering != null && !bCompareOffering){
                  
                    map <string, List<string>> masterValueMap = PMP_SpecificationController.getOfferingValuesAndSpecificationMap(offSpecs,language);
                
                    for(string key :masterValueMap.keyset() ){
                        offeringSpecValueMap tempWrap = New offeringSpecValueMap();
                        tempWrap.masterCategory = key;
                        tempWrap.valueList = masterValueMap.get(key);
                        tempWrap.category = null;
                        specMapWrapper.add(tempWrap);
                    }
                    
                    uiData.put(PMP_StaticConstants_Offering.selectedSpecificationsMap, specMapWrapper );
                }
                
            }
            boolean isIntelEmployee = PMP_Utility.isIntelEmployee();
            
            uiData.put('isIntelEmployee',isIntelEmployee);
            
            system.debug('intelEmp-->' +isIntelEmployee);
               
 
        }catch (Exception e) {
            system.debug('*****exception********'+e.getMessage() +'line' +e.getLineNumber());
            bSuccessful = false;
            
        }
        //Sandhya : START - US614322
        try{
            jsonValue = JSON.serialize(new PMP_LightningServerResponse(true,mapErrorInfo,uiData));
            //system.debug('cacheKey in else-----'+cacheKey +isGuestUser);
            String cacheTTLStr = PMP_Utility.getValue('Cache_TTL');
            Integer cacheTTL = Integer.valueOf(cacheTTLStr); // 48hrs
            if(isGuestUser){
		    	Cache.Org.put(partitionInput+'.'+cacheKey, jsonValue,cacheTTL);
            }              
            }Catch(Cache.ItemSizeLimitExceededException error){
                System.debug('Error due to Item Size Exceeded***********'+error.getMessage() +'at line '+error.getLineNumber());
            }Catch(Cache.Org.OrgCacheException error){
                System.debug('Error due to Partition Exception***********'+error.getMessage() +'at line '+error.getLineNumber());   
            }
            long elapsedTime = System.currentTimeMillis() - startTime;
            System.debug('elapsedTime with SOQL(Detail)------------------'+elapsedTime);
        }
        //Sandhya : END - US614322
      
        return jsonValue;
    }
    @AuraEnabled(cacheable = true)
    public static String fetchOfferingDetailNotPreview(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview){     
        return fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode,isPreview);
    }
    /**
    * @description Method To clone Offering
    * @param Id
    * @return String
    **/
    @AuraEnabled
    public static String cloneOfferingDetail(Id offeringId, string language){
    
        PMP_LightningServerResponse lightningResponse = new PMP_LightningServerResponse();
        
        try{
            lightningResponse = PMP_CloneOfferingController.cloneOffering(offeringId, language);
        
        }catch (Exception e) {
            system.debug('*****exception********'+e.getMessage() +'line' +e.getLineNumber()); 
        }
        return JSON.serialize(lightningResponse);
    
        
    
    }
    
    @AuraEnabled
    public static void updateOfferingDates(PMP_Partner_Offering__c offering){
        if(offering.id != null){
            system.debug(offering);
           /* PMP_Partner_Offering__c off = [Select id, PMP_Partner_Offering_Start_Dt__c, PMP_Partner_Offering_End_Dt__c ,PMP_Is_Notified_Ind__c from PMP_Partner_Offering__c where id =: offering.id ];
            off.PMP_Partner_Offering_Start_Dt__c = offering.PMP_Partner_Offering_Start_Dt__c;
            off.PMP_Partner_Offering_End_Dt__c = offering.PMP_Partner_Offering_End_Dt__c; 
            off.PMP_Is_Notified_Ind__c = false; */
            offering.PMP_Is_Notified_Ind__c = false;

            update offering;
        }
    }
    
    
    public Class offeringSpecValueMap {
        @AuraEnabled
        @TestVisible public string masterCategory {get;set;}
        
        @AuraEnabled
        @TestVisible public List<string> valueList {get;set;}
        
        @AuraEnabled
        @TestVisible public string category {get;set;}
    }
    public class contentAssetWrapper{
        
       
        @AuraEnabled
        public string type{get;set;}
        
       
       
        @AuraEnabled
        public string thumbnailUrl{get;set;}
        @AuraEnabled
        public string imageUrl{get;set;}
    }
}