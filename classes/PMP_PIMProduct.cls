/****************************************************************************************************************************************
* Class Name  : PMP_PIMProduct
* Version     : 1.0 
* Created Date: 01-30-2019
* Modification Log :
*
* Developer           Modification Log                Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Gireesh                                  01/30/2019                    Method 'buildPostRequestMessage' to build request for sending it to PIM POST API
* Manasa				M-02					   05/28/2019					 US366078 : Offering status by Partners & no Archive (Remove Archive)
****************************************************************************************************************************************************************/

public class PMP_PIMProduct implements Queueable, Database.AllowsCallouts{
    public List<Id> offeringIds;
    public PMP_PIMProduct(List<Id> offeringIds){
        System.debug('PMP_PIMProduct::');
        this.offeringIds=offeringIds;
    }
    
    @InvocableMethod(label='PMP_PIMProduct' description='to build request for sending it to PIM POST API')
    public static void buildProduct(List<Id> offeringId){  
        Id jobId;
        //for(Id offering_Id: offeringId){
        jobId=System.enqueueJob(new PMP_PIMProduct(offeringId));
        //}
        
        
    }
    
    //Get the Offering record based on the offering ID
    public static PMP_Partner_Offering__c  getOffering(Id offeringId){
        return [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Offering_Language_Nm__c, OwnerId, Owner.Name, PMP_Company_Id__c, PMP_Company_Id__r.Name, PMP_Partner_Offering_Id__c,PMP_Partner_Offering_Sync_Status_Nm__c,
                PMP_Partner_Offering_Lifecycle_Status_Nm__c, PMP_Partner_Offering_Dsc__c, PMP_Partner_Offering_Tag_Line_Txt__c, PMP_Partner_Offering_Visibility_Nm__c,PMP_Is_Published_Ind__c
                FROM PMP_Partner_Offering__c where Id=:offeringId                                                        
               ]; 
    }
    
    //Get the Offering Categories
    public static List<PMP_Partner_Offering_Category__c> getOfferingCategoryList(Id offeringId){
        return [SELECT Id, PMP_Ancestor_Category_Cd__c, PMP_Offering_Category_External_Key__c
                FROM PMP_Partner_Offering_Category__c 
                where PMP_Offering_Id__c =:offeringId and PMP_Ancestor_Category_Cd__c != ''
               ];
    }
    
    //Get the Offering Specifications
    public static List<PMP_Partner_Offering_Specification__c> getOfferingSpecificationList(Id offeringId){
        return [SELECT Id, PMP_Ancestor_Specification_Cd__c,
                PMP_Specification_Id__r.PMP_Specification_Name__c, PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,
                PMP_Specification_Id__c, PMP_Product_Specification_Cd__c,
                PMP_Specification_Value_Nm__c,PMP_Specification_Value_Id__r.PMP_Specification_Value_Nm__c, PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c,
                PMP_Specification_Id__r.Name, PMP_Display_Type_Nm__c,
                PMP_Specification_Nm__c, PMP_Specification_Value_Cd__c, 
                PMP_Specification_Value_Id__r.Name  FROM PMP_Partner_Offering_Specification__c 
                where PMP_Offering_Id__c =:offeringId
               ];
    }
    
    
    //Get the Offering Resources 
    public static  List<PMP_Partner_Offering_Resource__c>  getOfferingResources(Id offeringId){
        return [SELECT Id, Name, PMP_Partner_Offering_Resource_URL_Txt__c, PMP_Offering_Id__c, 
                PMP_Partner_Offering_Image__c, PMP_Resource_Type_Nm__c
                FROM PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c = :offeringId
               ];
        
    }
    
    
    //Get translated data
    public static List<PMP_Partner_Offering_Translation__c>  getTranslatedData(Id offeringId){
        return [SELECT Id, Name,  PMP_Field_Nm__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c, 
                PMP_English_Txt__c FROM PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:offeringId];
    }
    
    public void execute(QueueableContext context){
        List<PMP_Languages__mdt> nullTranslations = new List<PMP_Languages__mdt>();
        generatePIMProduct(offeringIds, nullTranslations, False, False);              
    }
    
 	//US607597:Gireesh
    public static void generatePIMProduct(List<Id> offeringIds, List<PMP_Languages__mdt> translatedLanguageTrans, Boolean isFuture, Boolean isTranslationAvailable){
        List<String> jsonStrings=new List<String>();
        List<String> methods = new List<String>();
        List<Id> productIds = new List<Id>(); 
        List<String> pimProductIds = new List<String>();
        List<String> languageCodes = new List<String>();
        List<String> localeNames = new List<String>();
        //List<String> offeringInputLanguageNames = new List<String>();
        
        List<PMP_Partner_Offering_Translation__c>  offeringTranslations =new List<PMP_Partner_Offering_Translation__c>();

        
        //for(Id offeringId :offeringIds){
        for(Integer idx=0; idx<offeringIds.size(); idx++){
            
            //Holds all the attributes 
            List<PMP_PIMAttributes> pimAttributes = new List<PMP_PIMAttributes>();
            
            //If Translations
             if(isTranslationAvailable){
                 offeringTranslations=getTranslatedData(offeringIds[idx]);
             }
            
            //Gets the Offering record based on the offering ID
            PMP_Partner_Offering__c  offering=getOffering(offeringIds[idx]);
            
            //Gets the Offering Categories
            List<PMP_Partner_Offering_Category__c>  offeringCategoryList=getOfferingCategoryList(offeringIds[idx]);
            //Gets the Offering Specifications
            List<PMP_Partner_Offering_Specification__c>  offeringSpecificationList=getOfferingSpecificationList(offeringIds[idx]);
            //Gets the Offering Resources 
            List<PMP_Partner_Offering_Resource__c>  offeringResources=getOfferingResources(offeringIds[idx]);
            
            
            Map<string, PMP_PIMAttributes> offeringResourceMap = new Map<string, PMP_PIMAttributes>();
            List<String> additionalResourceNames=new List<String>();
            List<String> additionalResourceValues=new List<String>();
            List<String> contentDocumentIds=new List<String>();
            List<Id> partnerOfferingResourceIds=new List<String>();
            
            
            //Get all the resources(Product Web Page, DataSheet, Product Brief, Additional resources and ContentDocumentId of Images)
            for(PMP_Partner_Offering_Resource__c offeringResource : offeringResources)
            {
                
                //ProductWebPage
                if(offeringResource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.PRODUCT_WEB_PAGE)
                {
                    PMP_PIMAttributes pimResourceAttribute = new PMP_PIMAttributes(PMP_StaticConstants_Offering.PRODUCT_WEBPAGE_URL, offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c, 
                                                                                   offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c);
                    pimAttributes.add(pimResourceAttribute);
                }
                //DataSheet
                else if(offeringResource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.DATA_SHEET)
                {
                    PMP_PIMAttributes pimResourceAttribute1 = new PMP_PIMAttributes(PMP_StaticConstants_Offering.DATASHEET_URL, offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c, 
                                                                                    offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c);
                    pimAttributes.add(pimResourceAttribute1);
                }
                //Product Brief
                else if(offeringResource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.PRODUCT_BRIEF)
                {
                    
                    PMP_PIMAttributes productBriefName = new PMP_PIMAttributes(PMP_StaticConstants_Offering.PRODUCT_BRIEF_TITLE, offeringResource.Name, 
                                                                               offeringResource.Name);
                    pimAttributes.add(productBriefName);
                    
                    
                    PMP_PIMAttributes productBriefValue = new PMP_PIMAttributes(PMP_StaticConstants_Offering.PRODUCT_BRIEF_URL, offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c, 
                                                                                offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c);
                    pimAttributes.add(productBriefValue);
                    
                }
                //Additional Resources into list of String
                else if(offeringResource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.ADDITIONAL_RESOURCES)
                    
                {
                    
                    additionalResourceNames.add(offeringResource.Name);
                    additionalResourceValues.add(offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c);
                    
                }
                //ContentDocumentIds into list of String
                else if(offeringResource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE)
                {
                    partnerOfferingResourceIds.add(offeringResource.Id);
                }
            }
            
            
            //add Additional Resource Title for a separate json
            if(!additionalResourceNames.isEmpty()){
                PMP_PIMAttributes pimAdditionalResourceNameAttribute=new PMP_PIMAttributes();
                pimAdditionalResourceNameAttribute.label=PMP_StaticConstants_Offering.ADDITIONAL_RESOURCE_TITLE;
                if(additionalResourceNames.size()>1){
                    pimAdditionalResourceNameAttribute.value=additionalResourceNames;
                    pimAdditionalResourceNameAttribute.raw_value=additionalResourceNames;    
                }else{
                    pimAdditionalResourceNameAttribute.value=additionalResourceNames[0];
                    pimAdditionalResourceNameAttribute.raw_value=additionalResourceNames[0];
                }
                pimAttributes.add(pimAdditionalResourceNameAttribute);
            }
            
            
            //add Additional Resource Names for a separate json
            if(!additionalResourceValues.isEmpty()){
                PMP_PIMAttributes pimAdditionalResourceValueAttribute=new PMP_PIMAttributes();
                pimAdditionalResourceValueAttribute.label=PMP_StaticConstants_Offering.ADDITIONAL_RESOURCE_URL;
                if(additionalResourceValues.size()>1){
                    pimAdditionalResourceValueAttribute.value=additionalResourceValues;
                    pimAdditionalResourceValueAttribute.raw_value=additionalResourceValues;
                }else{
                    pimAdditionalResourceValueAttribute.value=additionalResourceValues[0];
                    pimAdditionalResourceValueAttribute.raw_value=additionalResourceValues[0];
                }
                
                pimAttributes.add(pimAdditionalResourceValueAttribute);
            }
            
            //Get all the specifications
            Map<string, PMP_PIMAttributes> offeringSpecificationMap = new Map<string, PMP_PIMAttributes>();
            for(PMP_Partner_Offering_Specification__c offeringspecification : offeringSpecificationList)
            {
                //Get the current Spec Id
                String mapId=offeringspecification.PMP_Product_Specification_Cd__c;
                
                //check if Spec Id or Ancestor Spec Id contains 'NPP_Processors'
                if((!String.isEmpty(offeringspecification.PMP_Ancestor_Specification_Cd__c) && (offeringspecification.PMP_Ancestor_Specification_Cd__c).contains(PMP_StaticConstants_Offering.PROCESSOR) ||
                    !String.isEmpty(offeringspecification.PMP_Product_Specification_Cd__c) && (offeringspecification.PMP_Product_Specification_Cd__c).contains(PMP_StaticConstants_Offering.PROCESSOR))&&
                   (offeringspecification.PMP_Product_Specification_Cd__c!='NPP_Processors_ProcessorSocketed' && 
                    offeringspecification.PMP_Product_Specification_Cd__c!='NPP_Processors_NoOfProcessors' )
                  ){
                      mapId=PMP_StaticConstants_Offering.PROCESSOR;
                  }
                //check if Spec Id or Ancestor Spec Id contains 'NPP_Chipsets'
                else if(!String.isEmpty(offeringspecification.PMP_Ancestor_Specification_Cd__c) && (offeringspecification.PMP_Ancestor_Specification_Cd__c).contains(PMP_StaticConstants_Offering.CHIPSET) ||
                        !String.isEmpty(offeringspecification.PMP_Product_Specification_Cd__c) && (offeringspecification.PMP_Product_Specification_Cd__c).contains(PMP_StaticConstants_Offering.CHIPSET)
                       ){
                           mapId=PMP_StaticConstants_Offering.CHIPSET;
                       }
                //check if Spec Id or Ancestor Spec Id contains 'NPP_FPGA'
                else if(!String.isEmpty(offeringspecification.PMP_Ancestor_Specification_Cd__c) && (offeringspecification.PMP_Ancestor_Specification_Cd__c).contains(PMP_StaticConstants_Offering.FPGA) ||
                        !String.isEmpty(offeringspecification.PMP_Product_Specification_Cd__c) && (offeringspecification.PMP_Product_Specification_Cd__c).contains(PMP_StaticConstants_Offering.FPGA)
                       ){
                           mapId=PMP_StaticConstants_Offering.FPGA;
                       }
                
                //check if Spec Id or Ancestor Spec Id contains 'NPP_GeographicCoverage'
                else if(!String.isEmpty(offeringspecification.PMP_Ancestor_Specification_Cd__c) && (offeringspecification.PMP_Ancestor_Specification_Cd__c).contains(PMP_StaticConstants_Offering.GEOREGION) ||
                        !String.isEmpty(offeringspecification.PMP_Product_Specification_Cd__c) && (offeringspecification.PMP_Product_Specification_Cd__c).contains(PMP_StaticConstants_Offering.GEOREGION)
                       ){
                           mapId=PMP_StaticConstants_Offering.GEOREGION;
                       }
                //check if Spec Id or Ancestor Spec Id contains 'NPP_IntelTechnologies'
                else if(!String.isEmpty(offeringspecification.PMP_Ancestor_Specification_Cd__c) && (offeringspecification.PMP_Ancestor_Specification_Cd__c).contains(PMP_StaticConstants_Offering.INTELTECH) ||
                        !String.isEmpty(offeringspecification.PMP_Product_Specification_Cd__c) && (offeringspecification.PMP_Product_Specification_Cd__c).contains(PMP_StaticConstants_Offering.INTELTECH)
                       ){
                           mapId=PMP_StaticConstants_Offering.INTELTECH;
                       }
                
                
                //If the value already exist in the Map,then append otherwise add the current SpecId to Map
                PMP_PIMAttributes pimSpecAttribute = offeringSpecificationMap.get(mapId);
                String newValue;
                String newRawValue;
                //new code
                //If Spec Value look up present, then get spec value and spec value id from specvalueid reference 
                if(!String.isEmpty(offeringspecification.PMP_Specification_Value_Id__c) || offeringspecification.PMP_Specification_Value_Id__c!=null){
                    newValue=offeringspecification.PMP_Specification_Value_Id__r.PMP_Specification_Value_Nm__c;
                    newRawValue=offeringspecification.PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c;
                }
                //If spec Value lookup is absent and Spec value is present, then get spec value and (SpecValue Id otherwise SpecValue) w.r.t. parter offering specification
                else if(String.isEmpty(offeringspecification.PMP_Specification_Value_Id__c) && !String.isEmpty(offeringspecification.PMP_Specification_Value_Cd__c)
                       ){
                           newValue=offeringspecification.PMP_Specification_Value_Cd__c;
                           
                           if(!String.isEmpty(offeringspecification.PMP_Specification_Value_Nm__c)){
                               newRawValue=offeringspecification.PMP_Specification_Value_Nm__c;
                           }else{
                               newRawValue=offeringspecification.PMP_Specification_Value_Cd__c;
                           }
                       }
                //Else get spec and pim spec id from the reference
                else{
                    if(!String.isEmpty(offeringspecification.PMP_Specification_Id__c)){
                        
                        newValue=offeringspecification.PMP_Specification_Id__r.PMP_Specification_Name__c;
                        newRawValue=offeringspecification.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c;    
                        
                        
                    }
                    
                }
                if(pimSpecAttribute == Null){
                    pimSpecAttribute = new PMP_PIMAttributes(mapId, newValue, newRawValue);
                    offeringSpecificationMap.put(mapId, pimSpecAttribute);
                }else{
                    pimSpecAttribute.value = pimSpecAttribute.value + ';' +newValue ;
                    pimSpecAttribute.raw_value = pimSpecAttribute.raw_value + ';' + newRawValue; 
                }
                
            }
            
            //Add values to the common list(PMP_PIMAttributes) from Specification Map
            for(PMP_PIMAttributes pimSpecAttribute : offeringSpecificationMap.values())
            {  
                string strSpecValue = string.valueOf(pimSpecAttribute.value);
                string strSpecRawValue = string.valueOf(pimSpecAttribute.raw_value);
                if(strSpecRawValue==null){
                    strSpecRawValue=strSpecValue; 
                }
                
                
                List<string> specValues;
                if(!String.isEmpty(strSpecValue) || strSpecValue!=null){
                    specValues=strSpecValue.split(';');
                }                
                List<string> specRawValues; 
                if(!String.isEmpty(strSpecRawValue) || strSpecRawValue!=null){
                    specRawValues=strSpecRawValue.split(';');
                }  
                if(specValues!=null && specValues.size() > 1)
                {  
                    pimSpecAttribute.value = specValues;                              
                    pimSpecAttribute.raw_value = specRawValues;
                }
                pimAttributes.add(pimSpecAttribute);
            }
            PMP_PIMAttributes offeringStatus = new PMP_PIMAttributes(PMP_StaticConstants_Offering.OFFERING_STATUS,offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c, offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c );
            pimAttributes.add(offeringStatus);
            
            
            
            PMP_PIMAttributes companyId = new PMP_PIMAttributes(PMP_StaticConstants_Offering.COMPANY_ID,offering.PMP_Company_Id__c, offering.PMP_Company_Id__c);
            pimAttributes.add(companyId);
            
            PMP_PIMAttributes companyName = new PMP_PIMAttributes(PMP_StaticConstants_Offering.COMPANT_NAME,offering.PMP_Company_Id__r.Name, offering.PMP_Company_Id__r.Name);
            pimAttributes.add(companyName);
            
            PMP_PIMAttributes ownerName = new PMP_PIMAttributes(PMP_StaticConstants_Offering.OWNER_NAME,offering.Owner.Name, offering.Owner.Name);
            pimAttributes.add(ownerName);
            
            
            PMP_PIMAttributes ownerId = new PMP_PIMAttributes(PMP_StaticConstants_Offering.OWNER_ID,offering.OwnerId, offering.OwnerId);
            pimAttributes.add(ownerId);
            
            //Check if the Offering Status is Published or not
            String status='false';
            if(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c==PMP_StaticConstants_Offering.PUBLISHED){
                status='true';
            }
            PMP_PIMAttributes pusblished = new PMP_PIMAttributes(PMP_StaticConstants_Offering.PUBLISHED,status, status);
            
            pimAttributes.add(pusblished);
            
            
            //Check if the Offering is Public Content or not and if Yes then add Public URLs
            status='false';
            if(offering.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_Offering.PUBLIC_CONTENT){
                status='true';   
                
                
                
                //US543740:Gireesh
                //get images stored from contentAssest and construct the URL
                PMP_PIMAttributes screenShotAttribute = new PMP_PIMAttributes();
                List<String> contentAssets = new List<String>();
                List<String> screenShots=new List<String>();
                if(!partnerOfferingResourceIds.isEmpty()){
                    for(Id partnerOfferingResourceId:partnerOfferingResourceIds){
                        contentAssets.add(string.valueOf(partnerOfferingResourceId) +'_'+ string.valueOf(offeringIds[idx]));
                    }
                    
                    //fetch base community URL
                    String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
                    
                    //remove '/s' from baseCommunityUrl community URL
                    if(baseCommunityUrl.endsWith('/s')){
                        baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
                    }  
                    
                    //fetch static text called "/file-asset" from metaData
                    String staticFileAsset = PMP_Utility.getValue('Community_File_Asset');  	
                    
                    String questionMarkSymbol = '?'; // for content asset to be resized we need to add this variable beofre jpg
                    
                    //iterate over content asset data and make a call out to PIM to get auto resized url
                    for(String contentAsset : contentAssets) {
                        //Send the string to PIM in the form of : communityURL/file-asset/AssetName? 
                        String contentUrl = baseCommunityUrl+staticFileAsset+contentAsset+questionMarkSymbol;
                        system.debug('contentUrl:'+contentUrl);
                        screenShots.add(contentUrl);
                    }
                    screenShotAttribute.label=PMP_StaticConstants_Offering.SCREEN_SHOT;
                    screenShotAttribute.value=screenShots;   
                    screenShotAttribute.raw_value=screenShots;                      
                    
                    pimAttributes.add(screenShotAttribute);
                }//else Image isn't available
            }
            PMP_PIMAttributes isPublic = new PMP_PIMAttributes(PMP_StaticConstants_Offering.PUBLIC_STR,status, status);
            pimAttributes.add(isPublic);
            
            
            // Offering Detail community URL 
            String offeringDetailCommunityURL = Label.PMP_Offering_Detail_Community_URL + offering.id;
            PMP_PIMAttributes marketplacePageUrl = new PMP_PIMAttributes(PMP_StaticConstants_Offering.MarketplacePageURL,offeringDetailCommunityURL, offeringDetailCommunityURL);
            pimAttributes.add(marketplacePageUrl);
            
            string categoryValue = '';
            string applicationValue = '';
            string industryValue = '';
            for (PMP_Partner_Offering_Category__c offeringCategory:offeringCategoryList)
            {
                categoryValue = categoryValue + offeringCategory.PMP_Offering_Category_External_Key__c+ ';';
                
            }
            String request='';
            try{
                JSONGenerator jsonGenerator = JSON.createGenerator(true);
                jsonGenerator.writeStartObject();   //begining of {            
                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.PRODUCT_TYPE, PMP_StaticConstants_Offering.PRODUCT_TYPE_VALUE);
                if(offering.PMP_Partner_Offering_Nm__c!=null){
                    if(!isTranslationAvailable)
                        jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TITLE, offering.PMP_Partner_Offering_Nm__c);
                }
                else{
                    jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TITLE, '');
                }
                
                if(offering.PMP_Partner_Offering_Dsc__c!=null){
                    if(!isTranslationAvailable)
                        jsonGenerator.writeStringField(PMP_StaticConstants_Offering.PRODUCT_DESCRIPTION, offering.PMP_Partner_Offering_Dsc__c);
                }
                else{
                    jsonGenerator.writeStringField(PMP_StaticConstants_Offering.PRODUCT_DESCRIPTION, '');
                }
                
                if(!string.isBlank(offering.PMP_Partner_Offering_Tag_Line_Txt__c)){
                    if(!isTranslationAvailable)
                        jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TAGLINE, offering.PMP_Partner_Offering_Tag_Line_Txt__c);
                }                
                else{
                    jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TAGLINE, '');
                }
                
                
                //Translations:US607597
                //
                if(isTranslationAvailable){
                    
                    languageCodes.add(translatedLanguageTrans[idx].PIM_Language_Code__c);
                    localeNames.add(translatedLanguageTrans[idx].PIM_Locale_Name__c);
                    
                    for(PMP_Partner_Offering_Translation__c offeringTranslation:offeringTranslations){
                        if(offeringTranslation.PMP_Field_Nm__c=='PMP_Partner_Offering_Nm__c'){
                            String englishTitle=offeringTranslation.PMP_English_Txt__c;
                            String chineseTitle=offeringTranslation.PMP_Chinese_Txt__c;
                            String japaneseTitle=offeringTranslation.PMP_Japanese_Txt__c;
                            if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='English' && englishTitle!=null){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TITLE, englishTitle);                    
                            }
                            else if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='Chinese' && chineseTitle!=null){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TITLE, chineseTitle);                    
                            }
                            else if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='Japanese' && japaneseTitle!=null){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TITLE, japaneseTitle);                    
                            }                
                        }
                        else  if(offeringTranslation.PMP_Field_Nm__c=='PMP_Partner_Offering_Dsc__c'){
                            String englishDescription=offeringTranslation.PMP_English_Txt__c;
                            String chineseDescription=offeringTranslation.PMP_Chinese_Txt__c;
                            String japaneseDescription=offeringTranslation.PMP_Japanese_Txt__c;
                            if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='English' && englishDescription!=null){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.PRODUCT_DESCRIPTION, englishDescription);                    
                            }
                            else if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='Chinese' && chineseDescription!=null){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.PRODUCT_DESCRIPTION, chineseDescription);                    
                            }
                            else if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='Japanese' && japaneseDescription!=null ){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.PRODUCT_DESCRIPTION, japaneseDescription);                    
                            }
                        }
                        else  if(offeringTranslation.PMP_Field_Nm__c=='PMP_Partner_Offering_Tag_Line_Txt__c'){
                            String englishTagline=offeringTranslation.PMP_English_Txt__c;
                            String chineseTagline=offeringTranslation.PMP_Chinese_Txt__c;
                            String japaneseTagline=offeringTranslation.PMP_Japanese_Txt__c;
                            if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='English' && englishTagline!=null){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TAGLINE, englishTagline);                    
                            }
                            else if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='Chinese' && chineseTagline!=null){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TAGLINE, chineseTagline);                    
                            }
                            else if(translatedLanguageTrans[idx].PIM_Locale_Name__c=='Japanese' && japaneseTagline!=null){
                                jsonGenerator.writeStringField(PMP_StaticConstants_Offering.TAGLINE, japaneseTagline);                    
                            }
                        }
                    }
                }
                //endTranslations
                if(offering.PMP_Partner_Offering_Visibility_Nm__c!=null)
                    jsonGenerator.writeStringField(PMP_StaticConstants_Offering.VIEW_OPTION, offering.PMP_Partner_Offering_Visibility_Nm__c);
                else
                    jsonGenerator.writeStringField(PMP_StaticConstants_Offering.VIEW_OPTION, '');
                
                if(categoryValue!=null)
                    jsonGenerator.writeStringField(PMP_StaticConstants_Offering.CATEGORY, categoryValue);
                else
                    jsonGenerator.writeStringField(PMP_StaticConstants_Offering.CATEGORY, '');
                
                jsonGenerator.writeObjectField('attributes', pimAttributes);
                
                jsonGenerator.writeEndObject(); //ending of }
                
                request = jsonGenerator.getAsString();
            }
            catch(Exception e){
                system.debug('e1:'+e.getMessage());
                system.debug('e2:'+e.getLineNumber());
                system.debug('e3:'+e.getCause());
            }
            String method;
            if(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c==PMP_StaticConstants_Offering.PUBLISHED &&
               offering.PMP_Partner_Offering_Id__c==null){
                   method=PMP_StaticConstants_Offering.POST;                 
               }
            else if(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c==PMP_StaticConstants_Offering.PUBLISHED && offering.PMP_Partner_Offering_Id__c!=null)
            {
                
                method=PMP_StaticConstants_Offering.PUT;
            }
            
            if(offering.PMP_Offering_Language_Nm__c!=null){
                List<PMP_Languages__mdt> languageList = [select PIM_Language_Code__c, PIM_Locale_Name__c  from PMP_Languages__mdt where 
                                                         Locale_Nm__c=:offering.PMP_Offering_Language_Nm__c
                                                        ];
                if(languageList.size()>0){
                    //PMP_PIMServiceCallout.publishProduct(request,method, offeringId,offering.PMP_Partner_Offering_Id__c, languageList[0].PIM_Language_Code__c,languageList[0].PIM_Locale_Name__c);
                    jsonStrings.add(request);
                    methods.add(method);
                    productIds.add(offeringIds[idx]);	
                    pimProductIds.add(offering.PMP_Partner_Offering_Id__c);
                    if(!isTranslationAvailable){
                        languageCodes.add(languageList[0].PIM_Language_Code__c);
                        localeNames.add(languageList[0].PIM_Locale_Name__c);
                    }
                    //offeringInputLanguageNames.add(offering.PMP_Offering_Language_Nm__c);
                }
                system.debug('after PMP_PIMServiceCallout::');
                
                //System.enqueueJob(new TranslatedPIMProduct(offeringId, offering.PMP_Partner_Offering_Id__c, offering.PMP_Offering_Language_Nm__c));
            }
        }
        try{
            system.debug(offeringIds.size()+'<-->'+productIds.size());
            for(Integer idx=0; idx<productIds.size(); idx++){
                system.debug('#ugg:'+productIds[idx]+':'+offeringIds[idx]);
                system.debug('#ugg2:'+pimProductIds[idx]);
                system.debug('#ugg3:'+localeNames[idx]);
            }
            System.debug('PMP_PIMServiceCallout in PIMPRoduct');
            PMP_PIMServiceCallout.isFuturepublishProduct(jsonStrings,methods, productIds,pimProductIds, languageCodes,localeNames, isFuture, isTranslationAvailable);
        }
        catch(Exception e){
            
            //Set status to Out Of Sync in case of any exception
            system.debug('e1:'+e.getMessage());
            system.debug('e2:'+e.getLineNumber());
            system.debug('e3:'+e.getCause());
            system.debug('Callout Unsuccessful');
            
        }
    }
    
    // check if any other tranlations are present to publish to PIM    
    public static void checkExistingTranslatedDataList(List<Id> offeringId) {
        system.debug('running checkExistingTranslatedDataList');
        List<String> pimProductId=new List<String>();
        List<String> offeringBaseLanguage=new List<String>();
        List<Id> productIdsExTrans = new List<Id>();
        List<String> pimProductIdsExTrans = new List<String>();
        List<PMP_Languages__mdt> languagesExTrans= new List<PMP_Languages__mdt>();
        
        
        Map<String,PMP_Languages__mdt> languageMap = new Map<String,PMP_Languages__mdt>();                    
        for(PMP_Languages__mdt lang:[select PIM_Language_Code__c,PIM_Locale_Name__c, Locale_Nm__c from PMP_Languages__mdt]){
            languageMap.put(lang.Locale_Nm__c,lang);
        }
        system.debug('#languageMap#:'+languageMap);
        system.debug('#offeringId#:'+offeringId.size());
        
        List<PMP_Partner_Offering__c> offeringDetails=[SELECT Id, Name, PMP_Offering_Language_Nm__c, PMP_Partner_Offering_Id__c from PMP_Partner_Offering__c where Id IN :offeringId];
        for(Integer idx=0; idx<offeringId.size(); idx++){
            
            
            if(offeringDetails.size()>0){
                pimProductId.add(offeringDetails[idx].PMP_Partner_Offering_Id__c);
                offeringBaseLanguage.add(offeringDetails[idx].PMP_Offering_Language_Nm__c);
            }
            
            //Send translated data to PIM if already available
            List<PMP_Partner_Offering_Translation__c> partnerOfferingTranslations = [SELECT Id, Name, PMP_Chinese_Txt__c,PMP_English_Txt__c,PMP_Japanese_Txt__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:offeringId[idx] and PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c'];
            system.debug('partnerOfferingTranslations:'+partnerOfferingTranslations);
            for(PMP_Partner_Offering_Translation__c partnerOfferingTranslation :partnerOfferingTranslations){
                system.debug('#pimProductId:'+pimProductId[idx]);
                if(partnerOfferingTranslation.PMP_Japanese_Txt__c!=null && offeringBaseLanguage[idx]!='Japanese' ){
                    PMP_Languages__mdt language = languageMap.get('Japanese');
                    if(language!=null && pimProductId[idx]!=null){
                        system.debug('Japanese');
                        productIdsExTrans.add(offeringId[idx]);
                        pimProductIdsExTrans.add(pimProductId[idx]);
                        languagesExTrans.add(language);
                    }
                }
                if(partnerOfferingTranslation.PMP_Chinese_Txt__c!=null && offeringBaseLanguage[idx]!='Simplified Chinese' ){
                    system.debug('#11.1');
                    PMP_Languages__mdt language = languageMap.get('Simplified Chinese');
                    system.debug('language:'+language);
                    if(language!=null && pimProductId[idx]!=null){
                        system.debug('Simplified Chinese');
                        productIdsExTrans.add(offeringId[idx]);
                        pimProductIdsExTrans.add(pimProductId[idx]);
                        languagesExTrans.add(language);
                    }
                }
                if(partnerOfferingTranslation.PMP_English_Txt__c!=null && offeringBaseLanguage[idx]!='English' ){
                    PMP_Languages__mdt language = languageMap.get('English');
                    if(language!=null && pimProductId[idx]!=null){
                        system.debug('English');
                        productIdsExTrans.add(offeringId[idx]);
                        pimProductIdsExTrans.add(pimProductId[idx]);
                        languagesExTrans.add(language);
                    }
                }
                
            }
        }
        system.debug('running 1 checkExistingTranslatedDataList');
        for(Integer i=0;i<pimProductIdsExTrans.size(); i++){
            system.debug('productIdsExTrans:'+productIdsExTrans[i]);
            system.debug('productIdsExTrans1:'+languagesExTrans[i]);
        }
        generatePIMProduct(productIdsExTrans, languagesExTrans ,False, True);
        system.debug('running 2 checkExistingTranslatedDataList');
    }
    
    public class PMP_PIMAttributes
    {
        PMP_PIMAttributes (){}
        string label;
        object value;
        object raw_value;
        
        PMP_PIMAttributes(string strLabel, string strValue, string strRawValue)
        {
            label = strLabel;
            value = strValue;
            raw_value = strRawValue;
        }
    }
}