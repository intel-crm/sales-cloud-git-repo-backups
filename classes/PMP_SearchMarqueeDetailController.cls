/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchMarqueeDetailController
* Description : Stores all the wrapper classes used throught the Marketplace.
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By  : Tanzanite & Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/

public without sharing class PMP_SearchMarqueeDetailController {
    
    
    /*@AuraEnabled 
    public static PMP_LightningServerResponse getOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language,String langCode, boolean isPreview){//IPA 2.0 Offering EOL
        if(isPreview){
            //system.debug('@isPreview if------'+isPreview);
            PMP_LightningServerResponse offeringDetailResponse = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode);
            return offeringDetailResponse;
        }else{
             //system.debug('@isPreview else------'+isPreview);
            PMP_LightningServerResponse offeringDetailNotPrevResponse = fetchOfferingDetailNotPreview(offeringId, bEditOffering, bViewOffering, bCompareOffering, language, langCode);
            return offeringDetailNotPrevResponse;
        }
              
        //PMP_LightningServerResponse response1 = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language);
            return response1; //
    }*/
    
    
    /*@AuraEnabled 
    public static PMP_LightningServerResponse getOfferingDetailProductDetails(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language,String langCode, boolean isPreview){//IPA 2.0 Offering EOL
    
     PMP_Partner_Offering__c offering = [ select PMP_Working_Copy_Id__c , PMP_Is_Not_Available_On_MP_Ind__c from PMP_Partner_Offering__c   where id= :offeringId Limit 1];
      try{            
             //System.debug('WorkingId' + offering.PMP_Working_Copy_Id__c);
         if(offering.PMP_Working_Copy_Id__c!= null){
             offeringId =  offering.PMP_Working_Copy_Id__c;
         PMP_Partner_Offering__c tempOffering = [ select Id from PMP_Partner_Offering__c 
                 where id= :offeringId Limit 1 ];
         if(tempOffering==null)
         {
             offeringId=offering.Id;
         }               
     }
 
     }catch (Exception e) {
         offeringId=offering.Id;
         PMP_Utility.logError(e,'PMP_OfferingDetails_getOfferingDetailProductDetails'); 
 
     }
         if(isPreview){
            //system.debug('@isPreview if------'+isPreview);
            PMP_LightningServerResponse offeringDetailResponse = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode);
            return offeringDetailResponse;
        }else{
             //system.debug('@isPreview else------'+isPreview);
            PMP_LightningServerResponse offeringDetailNotPrevResponse = fetchOfferingDetailNotPreview(offeringId, bEditOffering, bViewOffering, bCompareOffering, language, langCode);
            return offeringDetailNotPrevResponse;
        }
              
        //PMP_LightningServerResponse response1 = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language);
            return response1; //
    }*/
     
     
     /*@AuraEnabled
     //public static PMP_LightningServerResponse fetchOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bIsCloneable){
     public static PMP_LightningServerResponse fetchOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering, string language, String langCode){//IPA 2.0 Offering EOL
         // system.debug('Inside detail marqee'+language+'#'+langCode);
         // system.debug('been called here ' +language);
         Boolean bSuccessful = true;    
         map<string,object> uiData = new map<string,object>();
         map<String, Object> mapErrorInfo = new map<string,object>();
         List<PMP_Partner_Offering__c> offeringdetail = new List<PMP_Partner_Offering__c>();
         PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();       
         
         //long startTime = System.currentTimeMillis();
         //Part 1 To consider loggedIn user's language if langauge param is null or empty //     
         string userLanguageCode = userinfo.getLanguage();
         if(userLanguageCode =='ja'){
             userLanguageCode = userLanguageCode+ '_JP';
         }
         
         //Gireesh:US664733: To display in categories and specifications in respective lang based on 'language' param ex: '?language=zh_CN' for anonymous user
          if(langCode!=null && langCode =='ja'){
             langCode = langCode+ '_JP';
         }
         
         
         //------------------------------------Part 1 Changes End-----------------------------------// 
         try{
             if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible() && Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
                                 offering = [Select id,
                                                         
                                                     PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Partner_Offering_End_Dt__c,PMP_Offering_Language_Nm__c,
                                                     PMP_Partner_Offering_Id__c,PMP_Partner_Offering_Start_Dt__c,PMP_Offering_Status_Update_Dt__c,
                                                     PMP_Partner_Revision_Comment_Txt__c,PMP_Company_Id__c,PMP_Company_Id__r.Name,
                                                     PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,Name,PMP_Partner_Offering_Visibility_Nm__c,
                                                     PMP_Partner_Offering_Nm__c,PMP_Offering_Id__c,PMP_Translated_Languages__c
                                                     from PMP_Partner_Offering__c where id = :offeringId Limit 1];   
             }
             /*PART-2 To consider loggedIn user's language if langauge param is null or empty 
                 if(offering.PMP_Translated_Languages__c != null && language == null ){
                     translatedLanguages = offering.PMP_Translated_Languages__c.split(';');
                     system.debug(translatedLanguages);
                     if(translatedLanguages.contains(userLanguage) ){
                         language = userLanguage=='Japanese' ?  userLanguageCode+'_JP' : userLanguageCode;
                         system.debug('userLangCode' +language );
                     }
                 }
              //------------------------------------Part2 Changes End-----------------------------------//
              
             /*PART-2 To consider loggedIn user's language if langauge param is null or empty //
             if(language != 'NA'){
                 List<PMP_Partner_Offering_Translation__c> translatedValues = PMP_Utility.getOfferingTranslationRecords(offeringId);
                 Map<string,string> languageFieldMap = New Map<string,string>();
                 List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMtdList = New List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();
                         if(language!= null){
                            localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(language,'Offering_Translation');
                         }
                         else if(language== null && langCode!=null){ //Gireesh:US664733: To display in categories and specifications in respective lang based on 'language' param ex: '?language=zh_CN' for anonymous user
                             localeMtdList = PMP_Utility.getLocaleToFieldMdtRecordsByObject(langCode,'Offering_Translation');
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
                             fieldAndValueMap.put(iterValue.PMP_Field_Nm__c, iterValue );
                         }
                     }
                 
                     
                 //Gireesh:US664733: To display in categories and specifications in respective lang based on 'language' param ex: '?language=zh_CN' for anonymous user
                 if(language ==null && langCode!=null && languageFieldMap.get(langCode)!=null &&  fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c')
                       && string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(langCode )))!=null){
                         language = langCode; 
                     }
                 else{
                     if(language==null && fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c') && languageFieldMap.get(userLanguageCode)!=null
                       && string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(userLanguageCode )))!=null){
                           language = userLanguageCode; 
                     }
                     
                 }
                 
                 
              /*---------------------------------------Part 2 Changes End ------------------------//
                 
                 
                   if(language!=null && language != 'NA'){ //Added by Abhishek US398772 replacing the offering name, tooltip based on language parameter
                
                     offering.PMP_Partner_Offering_Nm__c= fieldAndValueMap.containsKey('PMP_Partner_Offering_Nm__c')?
                                                         string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Nm__c').get(languageFieldMap.get(language))) : null;     
                     offering.PMP_Partner_Offering_Dsc__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Dsc__c')?
                                                         string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Dsc__c').get(languageFieldMap.get(language))) : null;
                     offering.PMP_Partner_Offering_Tag_Line_Txt__c = fieldAndValueMap.containsKey('PMP_Partner_Offering_Tag_Line_Txt__c')?
                                                         string.valueOf(fieldAndValueMap.get('PMP_Partner_Offering_Tag_Line_Txt__c').get(languageFieldMap.get(language))) : null;
                     
                     
                     
                     } 
                 } 
                 
                 //Logic to fix escape HTML characters issue for name and tagline in marquee
                 if(!String.isBlank(offering.PMP_Partner_Offering_Nm__c)){
                   offering.PMP_Partner_Offering_Nm__c = offering.PMP_Partner_Offering_Nm__c.unescapeHtml4();
                 }  
                 if(!String.isBlank(offering.PMP_Partner_Offering_Tag_Line_Txt__c)){
                   offering.PMP_Partner_Offering_Tag_Line_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c.unescapeHtml4();
                 }
                 //Logic to fix escape HTML characters issue for name and tagline in marquee
                         
                 //system.debug(offering.name);
                 offeringdetail.add(offering); 
                 
             //This boolean value is used to show disclaimer on offering Details Marquee    
             
             uiData.put(PMP_StaticConstants_Offering.OfferingDetail,offeringdetail);
             
             
         }catch (Exception e) {
             bSuccessful = false;
             
         }
     
         //system.debug('marqueedetail------>'+offeringdetail[0].PMP_Partner_Offering_Nm__c);
         // system.debug('------>');
        // system.debug(new PMP_LightningServerResponse(true,mapErrorInfo,uiData));
        
         return (new PMP_LightningServerResponse(true,mapErrorInfo,uiData));
       
     }*/
     
     /*@AuraEnabled(cacheable=true)
     public static PMP_LightningServerResponse fetchOfferingDetailNotPreview(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering, string language, String langCode){//IPA 2.0 Offering EOL    
         return fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language, langCode);
     }*/
     
     //Get product info for the offeringId-Gireesh:US519754
     @AuraEnabled(cacheable=true)
     public static List<PMP_SearchProductController.Product> getProductInformation(Id offeringId,String langCode){
         //system.debug('Inside Prod Info---');
         List<PMP_SearchProductController.Product> productsCopy = new List<PMP_SearchProductController.Product>();
         try{
         List<String> offerings = new List<String>();
         offerings.add(offeringId);
         productsCopy=PMP_SearchProductController.getProducts(offerings, 1, 9, null, langCode, null);//PROD FIX: added keyword=null parameter at the end
             //system.debug('productsCopy------'+productsCopy);
         }catch(Exception e){
             //system.debug('---------------------prod info'+e.getMessage());
         }
         return productsCopy;
        
     }
     /*public Class offeringSpecValueMap {//IPA 2.0 Offering EOL
         @AuraEnabled
         @TestVisible public string masterCategory {get;set;}
         
         @AuraEnabled
         @TestVisible public List<string> valueList {get;set;}
     }*/
     /**************************Partner Data***********************/ 
     public static final String[] adminProfiles = new String[]{ 'Partner Admin', 'System Administrator'};
         public static final String guestUser = 'Partner Solutions Marketplace Site Guest User'; 
     public static final String[] permissionSets = new String[]{'PMP_External_Partner_Admin','PMP_External_Marketing_Specialist'}; 
         // Method to get partner details from recordId
         @AuraEnabled(cacheable=true)
         public static PartnerDetail getPartnerData(String recordId, String langCode){   
             PartnerDetail partnerWrapper = new PartnerDetail();
             
                 PMP_Company__c partner = new PMP_Company__c();
                 try{
                     if(Schema.sObjectType.PMP_Company__c.isAccessible()){ //PMD Fix
                     //Modified as a part of OPID restructure : Removing PMP_Account_Id__c from Query 																			 
                     partner = [SELECT id, name, PMP_Partner_Program_nm__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c
                                ,PMP_Account_Program_Membership__c, PMP_Account_Specialty__c,PMP_Company_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c
                                from PMP_Company__c WHERE id =: recordId ];
                     }           
                 }catch(Exception e){
                     //System.debug('Error while fetching record of company information :'+ e);
                 }
                 if (partner.PMP_Is_Working_Copy_Ind__c == true){
                     try{
                         if(Schema.sObjectType.PMP_Company__c.isAccessible()){ //PMD Fix
                         //Modified as a part of OPID restructure : Removing PMP_Account_Id__c from Query    																					
                         partner = [SELECT id, name, PMP_Partner_Program_nm__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,
                                    PMP_Account_Program_Membership__c, PMP_Account_Specialty__c,PMP_Company_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c
                                    from PMP_Company__c WHERE PMP_Working_Copy_Id__c =: recordId ];
                         }
                     }catch(Exception e){
                         //System.debug('Error while fetching record of company information :'+ e);
                     }
                 }
           
                 partnerWrapper.hasAccess = false;
                 partnerWrapper.isGuest = false;
             
             //added as part of US619896[disabling  edit access to insert Logo pencil edit icon for LDR/OE/Employee User]
               if(partner.PMP_Company_Lifecycle_Status_Nm__c=='Draft' || partner.PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c=='Draft')
             {

                    // get the permission sets for the current user -> Added by Onyx (18/02/2022) // Prod Fix - INC11025773
                    final List<String> entitlements = getEntitlementsForCurrentUser(); 
                    if (entitlements.contains(PMP_StaticConstants_Partner.EMPLOYEE) && entitlements.size()==1) {
                        partnerWrapper.isLdrOeEmployee = true;
                    } 
                    else if (entitlements.contains(PMP_StaticConstants_Partner.LDR) || entitlements.contains(PMP_StaticConstants_Partner.OFFERING_EDITOR)) {
                        partnerWrapper.isLdrOeEmployee = true;
                    }
                    else {
                        partnerWrapper.isLdrOeEmployee = false;
                    }    
 
                 
             }
                 
                 Boolean isSysAdmin = false;
                 Id profId = userInfo.getProfileId();
                 String profileName = [Select Name from Profile where Id =: profId].Name;
                 
                 if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName))
                     isSysAdmin = true;
                 
                 String userName = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
                 
                 List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
                 //if(Schema.sObjectType.PermissionSetAssignment.isAccessible() && Schema.sObjectType.User.isAccessible()){
                 permissionSetList =  [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name in :permissionSets];
                // }
                 List<String> partnerAccountIds = new List<String>();
                 //Added as a part of OPID restructure : getting OPID's connected to MPI's
                 List<PMP_OPID_MPI_Rel__c> allJunctionRecords = [SELECT Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_Marketing_Profile_Id__c =: partner.Id];
                 for(PMP_OPID_MPI_Rel__c singleJunctionRecord : allJunctionRecords){
                     partnerAccountIds.add(singleJunctionRecord.PMP_One_Partner_ID__c);
                 }
                 Map<String, Boolean> isSamePartnerMap = PMP_SearchUtilityController.isSamePartnerUser(partnerAccountIds);
                 //Existing logic
                 /*
                 partnerAccountIds.add(partner.PMP_Account_Id__c);
                 */																		 
                 
                 //Code to give access to storefront
                 
                 List<PermissionSetAssignment> admin = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name =: PMP_StaticConstants_Partner.INTEL_ADMIN];
                 if (!admin.isEmpty()){
                     partnerWrapper.hasAccess = true;
                 }
                 else{
                     if (!PMP_SearchUtilityController.isGuest()){
                         if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName))
                             partnerWrapper.hasAccess = true;
                         //Modified as a part of OPID restructure
                         for(String account : partnerAccountIds){
                            //Conditional check if the Map contains the key
                            if(isSamePartnerMap.containsKey(account) && isSamePartnerMap.get(account) && permissionSetList.size()>0){
                                //Checking if the current user is not of same partner
                                //if(isSamePartnerMap.get(account) && permissionSetList.size()>0){
                                    partnerWrapper.hasAccess = true; // If all conditions match set visibility boolean as true
                                //}
                            }
                        }
                    //Existing logic    
                    /*if (PMP_SearchUtilityController.isSamePartnerUser(partnerAccountIds).containsKey(partner.PMP_Account_Id__c)){
                        if (PMP_SearchUtilityController.isSamePartnerUser(partnerAccountIds).get(partner.PMP_Account_Id__c) && permissionSetList.size()>0)
                            partnerWrapper.hasAccess = true;
                    }*/
                     }
                 }
                 //Change End
                 
                 
                 
                 if(userName.equalsIgnoreCase(guestUser))
                     partnerWrapper.isGuest = true;
                 
                 
                 
                 
                 //Partner Image Implemetation
                 List<PMP_Company_Resource__c> partner_resource = new List<PMP_Company_Resource__c>();
                 List<String> partnerConDocList = new List<String>();
                 Map<String, String> partnerContentMap = new Map<String,String>();//Added by Manasa  - for content Asset implementation
                 try{
                     if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
                     partner_resource = [SELECT PMP_Company_Id__c, PMP_Company_Image__c from PMP_Company_Resource__c 
                                         WHERE PMP_Company_Id__c =: partner.id and PMP_Company_Resource_Type_Nm__c='Image' and PMP_Company_Image__c!=null and PMP_Company_Resource_Sequence_Nbr__c = 0];
                     }
                 
                 }catch(DmlException  e){
                     //	system.debug('No resource found');
                 }
             if(!partner_resource.isEmpty()){
                     //partnerConDocList.add(partner_resource[0].PMP_Company_Image__c);//Added by Manasa  - for content Asset implementation
                     partnerContentMap.put(partner_resource[0].PMP_Company_Id__c,partner_resource[0].PMP_Company_Image__c);//Added by Manasa  - for content Asset implementation
             }
                 partnerConDocList.addAll(partnerContentMap.values());
                // List<ContentDistribution> partnerConDistList = PMP_SearchOfferingImageUtility.getContentDistList(partnerConDocList);//Added by Manasa  - for content Asset implementation
                 Map<String,String> partnerConAssetUrl = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(partnerConDocList);//Added by Manasa  - for content Asset implementation
                 
                 //Partner Image Implemetation ends
                 
                 
                 partnerWrapper.id = partner.id;
                 partnerWrapper.categoryId = partner.id;
                 partnerWrapper.name = partner.Name;
                 
                 
                 //if( !partnerConDistList.isEmpty() )//Added by Manasa  - for content Asset implementation
                 if(partnerConAssetUrl.containsKey(partnerContentMap.get(partner.Id))){//Added by Manasa  - for content Asset implementation
                     //partnerWrapper.imageUrl = partnerConDistList[0].ContentDownloadUrl;//Added by Manasa  - for content Asset implementation
                     String assetName = partnerConAssetUrl.get(partnerContentMap.get(partner.Id));//Added by Manasa  - for content Asset implementation
                     partnerWrapper.imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';//Added by Manasa  - for content Asset implementation
                 }
             else{
                     //partnerWrapper.imageUrl = 'https://www.intel.com/content/dam/products/hero/foreground/badge-9th-gen-core-i9-1x1.png.rendition.intel.web.550.550.png';
                     //Changed default logo for storefront by NIKHIL
                     partnerWrapper.imageUrl = PMP_StaticConstants_Partner.staticStorefrontUrl;
             }
                 partnerWrapper.partnerName = partner.Name;
                 partnerWrapper.partnerLink = 'intel';
                 List<Attribute> types = new List<Attribute>();
                 //Integer length = 0;
               
             String programMembership = partner.PMP_Account_Program_Membership__c;
             
             if(String.isNotBlank(programMembership)) {
                 
                 Set<String> ppNames = new Set<String>();
                 Map<String, List<String>> membershipMapList = new Map<String, List<String>>(); // map to store list of role and List of tier or biz org values 
                 for(String str : programMembership.split(';')) {
                     if(String.isNotBlank(str)) {
                         str = str.trim();
                         if(str.contains('-')) {
                             String[] strArr = str.split('-');
                             if(strArr.size() > 1) {
                                 String key = strArr[0].trim();
                                 ppNames.add(key);
                                 if(membershipMapList.containsKey(key.toLowerCase())){
                                     List<String> distiBizOrgs= new List<String>();
                                     distiBizOrgs=membershipMapList.get(key.toLowerCase());
                                     distiBizOrgs.add(strArr[1].trim());
                                     membershipMapList.put(key.toLowerCase(), distiBizOrgs);
                                 }
                                 else{
                                     membershipMapList.put(key.toLowerCase(), new List<String> {strArr[1].trim()});
                                 }
                             }
                         }
                     }
                 }
                 
             //    Map<String, PMP_SearchPartnerProgram_Config__mdt> partProgConfig = new Map<String, PMP_SearchPartnerProgram_Config__mdt>();
                 Map<String, PMP_Partner_Tier__c> ipaBadgeTier = new Map<String, PMP_Partner_Tier__c>();
                 Map<String, PMP_Partner_Tier__c> bizOrgType = new Map<String, PMP_Partner_Tier__c>();
                 
          /*       for(PMP_SearchPartnerProgram_Config__mdt prog : [SELECT PMP_Partner_Program_Name__c,PMP_Partner_Program_Value__c,PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c FROM PMP_SearchPartnerProgram_Config__mdt WHERE Active__c = true]){
                   partProgConfig.put(prog.PMP_Partner_Program_Value__c, prog);
                 }*/
                 
                 List<PMP_Partner_Tier__c> partnerTiers = new List<PMP_Partner_Tier__c>();
                 
                 if(Schema.sObjectType.PMP_Partner_Tier__c.isAccessible()){   //ApexCRUDViolation Fix
                     partnerTiers = [SELECT Id,Name,PMP_Is_Biz_Org_Type_Ind__c,PMP_Partner_Tier_Chinese_Nm__c,PMP_Partner_Tier_Name_Japanese__c FROM PMP_Partner_Tier__c where Name != null];
                 }
                 
                 for(PMP_Partner_Tier__c tier : partnerTiers) {
                   
                     if(tier.PMP_Is_Biz_Org_Type_Ind__c) {
                         bizOrgType.put(tier.Name, tier);
                     } else {
                         ipaBadgeTier.put(tier.Name, tier);
                     }                    
                 }
                 
                 Set<String> chineseLangCodes = new Set<String> { 'zh-Hans-CN', 'zh-CN', 'zh_CN' };
                 String fieldName = chineseLangCodes.contains(langCode) ? 'PMP_Partner_Tier_Chinese_Nm__c' : (langCode == 'ja' ? 'PMP_Partner_Tier_Name_Japanese__c' : 'Name');
                 //String tierFieldName = chineseLangCodes.contains(langCode) ? 'PMP_IPA_Badge_Tier_Chinese__c' : (langCode == 'ja' ? 'PMP_IPA_Badge_Tier_Japanese__c' : 'PMP_IPA_Badge_Tier__c');
                 //String bizFieldName = chineseLangCodes.contains(langCode) ? 'PMP_Biz_Org_Type_Chinese__c' : (langCode == 'ja' ? 'PMP_Biz_Org_Type_Japanese__c' : 'PMP_Biz_Org_Type__c');
                 
                 if(ppNames.size() > 0) {
                     for(PMP_Partner_Program__c pp : [SELECT Id, Name, PMP_Partner_Role_Parent_Id__c,PMP_Partner_Program_Value_Txt__c,PMP_Partner_Program_Name_Chinese__c, 
                                                      PMP_Partner_Program_Name_Japanese__c FROM PMP_Partner_Program__c WHERE Name IN :ppNames AND PMP_Is_Active_Ind__c=TRUE]) {
                                                          //logic of forming the attributes and adding them to list is embedded inside the for loop to handle multiple disti bizorgs
                                                          for(String tier: membershipMapList.get(pp.Name.toLowerCase())){
                                                              Attribute att = new Attribute();
                                                              PMP_Partner_Tier__c badgeTier = ipaBadgeTier.get(tier);
                                                              PMP_Partner_Tier__c bizType = bizOrgType.get(tier);
                                                              String tierVal = badgeTier != NULL && badgeTier.get(fieldName) != NULL ? (String)badgeTier.get(fieldName) : NULL;
                                                              String bizVal = bizType != NULL && bizType.get(fieldName) != NULL ? (String)bizType.get(fieldName) : NULL;
                                                              String tVal = tierVal != NULL ? tierVal : (bizVal != NULL ? bizVal : tier);
                                                                  if(tVal == NULL) tVal = tier;
                                                              //    PMP_SearchPartnerProgram_Config__mdt ppConfig = partProgConfig.get(pp.Name);
                                                              //    String pname = ppConfig != NULL ? (String)ppConfig.get(fieldName) : pp.Name;
                                                              String pname = PMP_SearchUtilityController.getLocalisedName(pp, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                                                              att.id = pname + ' - ' + tVal;
                                                              att.label =  pname + ' - ' + tVal;
                                                              types.add(att); 
                                                              
                                                          }
                                                          
                                            }
                 }
             }
             
               /*
                 List<String> partner_progs = new List<String>();
                 List<String> partner_tiers  = new List<String>();
                 system.debug('outside of if');
                 system.debug('fecth vals'+'------>'+partner.PMP_Partner_Program_nm__c+'-------'+partner.PMP_Account_Program_Membership__c);
                 if(partner.PMP_Partner_Program_nm__c!=null && partner.PMP_Account_Program_Membership__c!=null){
                     length = partner.PMP_Partner_Program_nm__c.split(';').size();
                     partner_progs = partner.PMP_Partner_Program_nm__c.split(';');
                     partner_tiers = partner.PMP_Account_Program_Membership__c.split(';');
                     system.debug('----vls'+partner_progs+partner_tiers+length);
                 }
                 
                 //for(Integer i = 0; i< partner_tiers.size(); i++){
                 //partner_tiers[i] = partner_tiers[i].toLowerCase().capitalize();} 
                 
                 Map<String,String> partner_prog_ext = new Map<String,String>();
                 String partnerProgNameApi = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',langCode);
                 if(String.isEmpty(partnerProgNameApi)){
                     partnerProgNameApi = 'PMP_Partner_Program_Name__c';
                     system.debug('----partnerProgNameApi----'+partnerProgNameApi);
                 }
                 if(partner.PMP_Partner_Program_nm__c!=null){
                     for (PMP_SearchPartnerProgram_Config__mdt prog: [select PMP_Partner_Program_Name__c,PMP_Partner_Program_Value__c,
                                                                      PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c 
                                                                      from PMP_SearchPartnerProgram_Config__mdt where  PMP_Partner_Program_Value__c in :partner_progs]){
                                                                          if(String.isEmpty((String)prog.get(partnerProgNameApi))){
                                                                             partner_prog_ext.put(prog.PMP_Partner_Program_Value__c, prog.PMP_Partner_Program_Name__c); 
                                                                          }else{
                                                                              partner_prog_ext.put(prog.PMP_Partner_Program_Value__c, (String)prog.get(partnerProgNameApi));
                                                                          }
                         
                         System.debug('Tier partner_prog_ext '+partner_prog_ext);
                     }
                 }
                 
             
                 for(Integer i = 0; i < partner_tiers.size(); i++){
                     Attribute att = new Attribute();
                     if(partner_prog_ext.containsKey(partner_tiers[i].split('-')[0].trim()) && partner_tiers[i].contains('-')){
                         att.id =  partner_prog_ext.get(partner_tiers[i].split('-')[0].trim()) + ' - ' + partner_tiers[i].split('-')[1].trim().toLowerCase().capitalize();
                         att.label =  partner_prog_ext.get(partner_tiers[i].split('-')[0].trim()) + ' - ' + partner_tiers[i].split('-')[1].capitalize(); 
                         types.add(att);
 
                     }else{
                         att.id = partner_prog_ext.get(partner_tiers[i]);
                         att.label = partner_prog_ext.get(partner_tiers[i]);
                         types.add(att);
                     } 
                 }
         */
                 //Adding ODM-LOEM as Partner Program
                 if(String.isNotEmpty(partner.PMP_Account_Specialty__c) && partner.PMP_Account_Specialty__c.contains(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                     Attribute odm = new Attribute();
                     odm.id = System.Label.PMP_Partner_Directory_Id;
                     odm.label = System.Label.PMP_Partner_Directory_title3;
                     types.add(odm);
                     // system.debug('- LOM and ODM --'+types);
                 }
                 //Changes End
                 Map<String, List<Attribute>> partnerAttributes = new Map<String, List<Attribute>>();
                 partnerAttributes.put('Category', types);
                 partnerWrapper.attributes = partnerAttributes;
                 partnerWrapper.categories = types;
                 // system.debug('-----'+ partnerAttributes);
               partnerWrapper.publishedStatus = partner.PMP_Company_Lifecycle_Status_Nm__c;
             return partnerWrapper; 
         }
      
     //TO check if any of the Logged-In user's fellow accounts under the same OPID has signed Ts & Cs
     @AuraEnabled(cacheable=true)
     public static Boolean checkLegalAgreementForAllLocations(){
         
         Id userId = UserInfo.getUserId();
         
         Boolean retFlag = true;
         List<PermissionSetAssignment> validPermissionSetList = new List<PermissionSetAssignment>();
         //For DE99521 
         //All valid MP Permission sets list other than Guest,System Admin and Intel Admin
         List<String> mpPermissionSetNames = New List<String>{PMP_StaticConstants_Partner.PARTNER_ADMIN,
                                       PMP_StaticConstants_Partner.MARKETING_SPECIALIST,
                                                               PMP_StaticConstants_Partner.OFFERING_EDITOR,
                                                               PMP_StaticConstants_Partner.LDR,
                                                               PMP_StaticConstants_Partner.EMPLOYEE};
        
         // Checking the UserID in the MP permission set names other than Guest,System Admin and Intel Admin                                                        
         if(userId != NULL){ 
           validPermissionSetList = [SELECT Id,PermissionSet.Name  FROM PermissionSetAssignment WHERE Assignee.Id =: userId 
                                      AND PermissionSet.Name IN: mpPermissionSetNames];              
         }
 
          if(!validPermissionSetList.isEmpty()){        
     //    if(userId != NULL && !PMP_SearchUtilityController.isGuest() && !PMP_SearchUtilityController.isIntelAdmin() && !PMP_SearchUtilityController.isSysAdmin()) {
             User currentUser = [Select id, AccountId from User where Id =:userId];
             List<Core_Account_Group_Member__c> pagMember = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =: currentUser.AccountId];
             if(pagMember.size() > 0) {
                 
                 List<Core_Account_Group_Member__c> opidMemberList = [SELECT id,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c =:pagMember[0].Core_Partner_Account_Id__c];
                 
                 List<String> accountIds = new List<String>();
                 
                 for(Core_Account_Group_Member__c mem : opidMemberList){
                     accountIds.add(mem.Core_Intel_Account_Id__c);
                 }
                 
                 List<PRM_AccountLegalAgreemntAssociation__c> objList = [Select PRM_InActive_Ind__c,PRM_Account_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c IN: accountIds AND PRM_InActive_Ind__c = false]; 
                 
                 retFlag = objList.size() > 0;//currentUser.AccountId == null ? true : objList.size() > 0;
             }else{
                 List<PRM_AccountLegalAgreemntAssociation__c> objList = [Select PRM_InActive_Ind__c,PRM_Account_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =: currentUser.AccountId AND PRM_InActive_Ind__c = false];
                 retFlag = objList.size() > 0;
             }
         }
         
         return retFlag;
     }
     // get the permission sets for the current user -> Added by Onyx (18/02/2022) // Prod Fix - INC11025773
     public static List<String> getEntitlementsForCurrentUser() {
        List<String> entitlements = new List<String>();

        List<PermissionSetAssignment> pSetList = [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId() and PermissionSet.IsOwnedByProfile = false];
        for(PermissionSetAssignment ps : pSetList){
            entitlements.add(ps.PermissionSet.Name);
        }
        return entitlements;
    }
     
     
     //Partner detail wrapper for Partner Detail page
     public class PartnerDetail {
         @AuraEnabled public String id { get; set; }
         @AuraEnabled public String categoryId { get; set; }
         @AuraEnabled public String name { get; set; }
         @AuraEnabled public String imageUrl { get; set; }//  'https://via.placeholder.com/350x197/0071C5/FFFFFF?text=Partner';
         @AuraEnabled public String partnerName { get; set; }
         @AuraEnabled public String partnerLink { get; set; }        
         @AuraEnabled public Map<String, List<Attribute>> attributes { get; set; }
         @AuraEnabled public List<Attribute> categories { get; set; } 
         @AuraEnabled public Boolean hasAccess {get; set;}
         @AuraEnabled public Boolean isGUest {get; set;}
         @AuraEnabled public String publishedStatus {get; set;}
         @AuraEnabled public Boolean isLdrOeEmployee {get;set;}
     }
     // Attribute wrapper for the partner details
     public class Attribute{
         @AuraEnabled public String id { get; set; }
         @AuraEnabled public String label { get; set; }
     }
     // Wrapper for search Params
     /* public class searchParams{
 @AuraEnabled public String type { get; set; }
 @AuraEnabled public String id { get; set; }
 } */
     
     
 }