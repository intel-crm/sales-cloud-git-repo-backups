/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchMarqueeDetailController
* Description : Stores all the wrapper classes used throught the Marketplace.
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By  : Tanzanite & Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/

public class PMP_SearchMarqueeDetailController {
    
    
   @AuraEnabled 
   public static PMP_LightningServerResponse getOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language,boolean isPreview){
       if(isPreview){
           system.debug('@isPreview if------'+isPreview);
           PMP_LightningServerResponse offeringDetailResponse = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language);
           return offeringDetailResponse;
       }else{
            system.debug('@isPreview else------'+isPreview);
           PMP_LightningServerResponse offeringDetailNotPrevResponse = fetchOfferingDetailNotPreview(offeringId, bEditOffering, bViewOffering, bCompareOffering, language);
           return offeringDetailNotPrevResponse;
       }
             
       /*PMP_LightningServerResponse response1 = fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language);
           return response1; */
   }
    
    
    
    @AuraEnabled
    //public static PMP_LightningServerResponse fetchOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bIsCloneable){
    public static PMP_LightningServerResponse fetchOfferingDetail(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering, string language){
        system.debug('Inside detail marqee');
        system.debug('been called here ' +language);
       
        Boolean bSuccessful = true;    
        map<string,object> uiData = new map<string,object>();
        map<String, Object> mapErrorInfo = new map<string,object>();
        List<PMP_Partner_Offering__c> offeringdetail = new List<PMP_Partner_Offering__c>();
        PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();       
        
        long startTime = System.currentTimeMillis();
        /*Part 1 To consider loggedIn user's language if langauge param is null or empty */     
        string userLanguageCode = userinfo.getLanguage();
        if(userLanguageCode =='ja'){
            userLanguageCode = userLanguageCode+ '_JP';
        }
        
        /*------------------------------------Part 1 Changes End-----------------------------------*/ 
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
             /*------------------------------------Part2 Changes End-----------------------------------*/
             
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
                
                //Logic to fix escape HTML characters issue for name and tagline in marquee
                if(!String.isBlank(offering.PMP_Partner_Offering_Nm__c)){
                  offering.PMP_Partner_Offering_Nm__c = offering.PMP_Partner_Offering_Nm__c.unescapeHtml4();
                }  
                if(!String.isBlank(offering.PMP_Partner_Offering_Tag_Line_Txt__c)){
                  offering.PMP_Partner_Offering_Tag_Line_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c.unescapeHtml4();
                }
                //Logic to fix escape HTML characters issue for name and tagline in marquee
                        
                system.debug(offering.name);
                offeringdetail.add(offering); 
                
            //This boolean value is used to show disclaimer on offering Details Marquee    
            
            uiData.put(PMP_StaticConstants_Offering.OfferingDetail,offeringdetail);
            
            
        }catch (Exception e) {
            bSuccessful = false;
            
        }
    
        //system.debug('marqueedetail------>'+offeringdetail[0].PMP_Partner_Offering_Nm__c);
        system.debug('------>');
        system.debug(new PMP_LightningServerResponse(true,mapErrorInfo,uiData));
       
        return (new PMP_LightningServerResponse(true,mapErrorInfo,uiData));
      
    }
    
    @AuraEnabled(cacheable=true)
 	public static PMP_LightningServerResponse fetchOfferingDetailNotPreview(Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering, string language){    
    	return fetchOfferingDetail(offeringId, bEditOffering, bViewOffering, bCompareOffering,language);
    }
    
    //Get product info for the offeringId-Gireesh:US519754
    @AuraEnabled(cacheable=true)
    public static List<PMP_SearchProductController.Product> getProductInformation(Id offeringId,String langCode){
        system.debug('Inside Prod Info---');
        List<PMP_SearchProductController.Product> productsCopy = new List<PMP_SearchProductController.Product>();
        try{
        List<String> offerings = new List<String>();
        offerings.add(offeringId);
        productsCopy=PMP_SearchProductController.getProducts(offerings, 1, 9, null, langCode);
            system.debug('productsCopy------'+productsCopy);
        }catch(Exception e){
            system.debug('---------------------prod info'+e.getMessage());
        }
        return productsCopy;
       
    } 
    public Class offeringSpecValueMap {
        @AuraEnabled
        @TestVisible public string masterCategory {get;set;}
        
        @AuraEnabled
        @TestVisible public List<string> valueList {get;set;}
    }
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
                    if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    partner = [SELECT id,PMP_Account_Id__c, name, PMP_Partner_Program_nm__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c
                               ,PMP_Account_Program_Membership__c, PMP_Account_Specialty__c,PMP_Company_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c
                               from PMP_Company__c WHERE id =: recordId ];
                    }           
                }catch(Exception e){
                    System.debug('Error while fetching record of company information :'+ e);
                }
                if (partner.PMP_Is_Working_Copy_Ind__c == true){
                    try{
                        partner = [SELECT id, name,PMP_Account_Id__c, PMP_Partner_Program_nm__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c
                                   ,PMP_Account_Program_Membership__c, PMP_Account_Specialty__c,PMP_Company_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c
                                   from PMP_Company__c WHERE PMP_Working_Copy_Id__c =: recordId ];
                    }catch(Exception e){
                        System.debug('Error while fetching record of company information :'+ e);
                    }
                }
          
                partnerWrapper.hasAccess = false;
                partnerWrapper.isGuest = false;
            
            //added as part of US619896[disabling  edit access to insert Logo pencil edit icon for LDR/OE/Employee User]
              if(partner.PMP_Company_Lifecycle_Status_Nm__c=='Draft' || partner.PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c=='Draft')
            {
                 List<PermissionSetAssignment> LdrOeEmployee = [SELECT Id  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                                 AND (PermissionSet.Name =:PMP_StaticConstants_Partner.LDR
                                      OR PermissionSet.Name =:PMP_StaticConstants_Partner.OFFERING_EDITOR
                                      OR PermissionSet.Name =:PMP_StaticConstants_Partner.EMPLOYEE )];
            if(LdrOeEmployee.size() > 0)
            {
                system.debug('LdrOeEmployee'+LdrOeEmployee);
                 partnerWrapper.hasAccess = false;
                
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
                partnerAccountIds.add(partner.PMP_Account_Id__c);
                
                //Code to give access to storefront
                
                List<PermissionSetAssignment> admin = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name =: PMP_StaticConstants_Partner.INTEL_ADMIN];
                if (!admin.isEmpty()){
                    partnerWrapper.hasAccess = true;
                }
                else{
                    if (!PMP_SearchUtilityController.isGuest()){
                        if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName))
                            partnerWrapper.hasAccess = true;
                        if (PMP_SearchUtilityController.isSamePartnerUser(partnerAccountIds).containsKey(partner.PMP_Account_Id__c)){
                            if (PMP_SearchUtilityController.isSamePartnerUser(partnerAccountIds).get(partner.PMP_Account_Id__c) && permissionSetList.size()>0)
                                partnerWrapper.hasAccess = true;
                        }
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
                    system.debug('No resource found');
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
                Integer length = 0;
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
                
                /* for(Integer i = 0; i< partner_tiers.size(); i++){
partner_tiers[i] = partner_tiers[i].toLowerCase().capitalize();
} */
                
                Map<String,String> partner_prog_ext = new Map<String,String>();
                String partnerProgNameApi = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',langCode);
                if(String.isEmpty(partnerProgNameApi)){
                    partnerProgNameApi = 'PMP_Partner_Program_Name__c';
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
                    if(partner_prog_ext.containsKey(partner_tiers[i].split('-')[0].replace(' ','')) && partner_tiers[i].contains('-')){
                        att.id =  partner_prog_ext.get(partner_tiers[i].split('-')[0].replace(' ','')) + ' - ' + partner_tiers[i].split('-')[1].replace(' ','').toLowerCase().capitalize();
                        att.label =  partner_prog_ext.get(partner_tiers[i].split('-')[0].replace(' ','')) + ' - ' + partner_tiers[i].split('-')[1].replace(' ','').toLowerCase().capitalize(); 
                        types.add(att);
                    }else{
                        att.id = partner_prog_ext.get(partner_tiers[i]);
                        att.label = partner_prog_ext.get(partner_tiers[i]);
                        types.add(att);
                    } 
                    
                }
                //Adding ODM-LOEM as Partner Program
                if(String.isNotEmpty(partner.PMP_Account_Specialty__c) && partner.PMP_Account_Specialty__c.contains(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                    Attribute odm = new Attribute();
                    odm.id = 'm0b0n00000001CcAAI';
                    odm.label = System.Label.PMP_Partner_Directory_title3;
                    types.add(odm);
                }
                //Changes End
                Map<String, List<Attribute>> partnerAttributes = new Map<String, List<Attribute>>();
                partnerAttributes.put('Category', types);
                partnerWrapper.attributes = partnerAttributes;
                partnerWrapper.categories = types;
                system.debug('-----'+ partnerAttributes);
            
            return partnerWrapper; 
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