public without sharing class PMP_SearchEditStoreFrontController extends PMP_SearchWrapperStore{
    
    Static String image = '';
    Public static Boolean loggedInPartnerUser=true;
    
    //Method to get list of Step to be shown in Storefront based on User
    //this method will be called from method where event is handled
    @AuraEnabled(cacheable = true)
    public static List<String> getSteps(){
        List<String> steps = new List<String>();
 
            steps.add(PMP_StaticConstants_Partner.LOGO);
            steps.add(PMP_StaticConstants_Partner.COMPANY_DESCRIPTION);
            steps.add(PMP_StaticConstants_Partner.COMPANY_DETAILS);
            steps.add(PMP_StaticConstants_Partner.COMPANY_RESOURCES);
            steps.add(PMP_StaticConstants_Partner.SUMMARY);
            
            if(PMP_SearchUtilityController.isIntelAdmin()){
                steps.add(System.Label.PMP_Edit_Storefront_Admin_Review);
            }    

        return steps;
    }
    
    @AuraEnabled(cacheable = true)
    public static Boolean isLocked(String partnerId){
        PMP_Company__c partner = new PMP_Company__c();
        try{
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){ //ApexCRUDViolation Fix
                //String workCopyId = [SELECT PMP_Working_Copy_Id__c FROM PMP_Company__c WHERE Id =:partnerId].PMP_Working_Copy_Id__c;
                partner = [SELECT PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c WHERE Id =:partnerId];
                String workCopyId;
                if(partner.PMP_Is_Published_Ind__c){
                    if(String.isNotEmpty(partner.PMP_Working_Copy_Id__c)){
                        workCopyId = partner.PMP_Working_Copy_Id__c;
                    }
                    /*                    
else{
workCopyId = getWorkingCopyId(partner.Id);
}
*/
                }else if(partner.PMP_Is_Working_Copy_Ind__c){
                    workCopyId = partner.Id;
                }
                if(String.isNotEmpty(workCopyId)){
                    partner = [SELECT PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c where id=: workCopyId LIMIT 1];
                }else{
                    return false;
                }
                
                
            }
        }catch(Exception e){
            //system.debug('Error in fetching company record : '+ e.getMessage());
        }
        
        if (partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Admin_Review && !PMP_SearchUtilityController.isIntelAdmin())
            return true; 
        return false;
    }
    
    @AuraEnabled     /*(cacheable = true) */
    public static FormData getPartnerExistingData(String partnerId, String langCode){
        PMP_Company__c partner = new PMP_Company__c();
        FormData formData = new FormData();
        try{
            if(!PMP_SearchUtilityController.isGuest()){
              //  if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    
                    //String workCopyId = [SELECT PMP_Working_Copy_Id__c FROM PMP_Company__c WHERE Id =:partnerId].PMP_Working_Copy_Id__c;
                    partner = [SELECT Id,Name,PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c WHERE Id =:partnerId];
                    String workCopyId;
                    if(partner.PMP_Is_Published_Ind__c){
                        if(String.isNotEmpty(partner.PMP_Working_Copy_Id__c)){
                            workCopyId = partner.PMP_Working_Copy_Id__c;
                        }
                        /*                        
else{
workCopyId = getWorkingCopyId(partner.Id);
}
*/
                    }else if(partner.PMP_Is_Working_Copy_Ind__c){
                        workCopyId = partner.Id;
                    }
                    if(String.isNotEmpty(workCopyId)){
            //Modified as part of OPID Restructure : Removing PMP_Account_Id__r.Core_IPA_Partner_Role__c, PMP_Account_Id__r.website from query                                                                
                        partner = [SELECT Id,Name,PMP_Account_Tag_Line__c, PMP_Account_Dsc__c,PMP_Company_Status_Update_Dt__c,LastModifiedById,PMP_Intel_Admin_Id__c,PMP_Intel_Admin_Nm__c,
                                   PMP_Account_Industry__c, PMP_Account_Application__c, PMP_Account_Region__c,PMP_Company_Information_Language_Nm__c,LastModifiedDate,PMP_Account_Website__c,PMP_Partner_Benefit_Type__c,
                                   PMP_Partner_Program_nm__c,PMP_Partner_Segment_Nm__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c, PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                                   PMP_Partner_Zipcode_Txt__c,PMP_Partner_State_Txt__c,PMP_Partner_Secondary_Street_Txt__c,
                                   PMP_Partner_Primary_Street_Txt__c,PMP_Partner_Country_Txt__c,PMP_Partner_City_Txt__c FROM PMP_Company__c WHERE Id = :workCopyId LIMIT 1];
                        partnerId = partner.Id;
                        
                    }else{
                        return formData;
                    }
               // }
                formData.isPublishedCopyDraft = partner.PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c == 'Draft';
                formData.isDistributor = partner.PMP_Partner_Program_nm__c != NULL && partner.PMP_Partner_Program_nm__c.contains('Distributor'); //Added by Subash for US697109
 //IPA 2.0 TWC729-7822
               /*if(partner.PMP_Partner_Benefit_Type__c == PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced)
                    formData.isEnhanced =true;
                else 
                    formData.isEnhanced = false;*/
                PartnerWrapper part = new PartnerWrapper();
                part.name = partner.Name;
                part.website = partner.PMP_Account_Website__c;
                part.primaryStreet = partner.PMP_Partner_Primary_Street_Txt__c;
                part.secondaryStreet = partner.PMP_Partner_Secondary_Street_Txt__c;
                part.city = partner.PMP_Partner_City_Txt__c;
                part.country = partner.PMP_Partner_Country_Txt__c;
                part.state = partner.PMP_Partner_State_Txt__c;
                part.postalCode = partner.PMP_Partner_Zipcode_Txt__c;
                formData.partner = part; 
                
                /*part.name = partner.Name;
                part.website = partner.PMP_Account_Id__r.website;
                part.primaryStreet = partner.PMP_Account_Id__r.BillingStreet;
                part.secondaryStreet = partner.PMP_Account_Id__r.BillingStreet;
                part.city = partner.PMP_Account_Id__r.BillingCity;
                part.country = partner.PMP_Account_Id__r.BillingCountry;
                part.state = partner.PMP_Account_Id__r.BillingState;
                part.postalCode = partner.PMP_Account_Id__r.BillingPostalCode;
                formData.partner = part;*/
                
                
                
                //Step-1 Logo
                
                getLogo(formData, partner);
                
                
                //Step-2 Description and Tagline
                
                
                getCompDesc(formData, partner, langCode);
                
                
                //Step-3 Application, Industry and Region
                
                
                fetchRegion(partner.Id, formData,langCode);
                
                //Industry 
                formData.industryOptions = PMP_SearchUtilityController.getCategoryTree(PMP_StaticConstants_Partner.PIM_INDUSTRY_ID, true, langCode);
                formData.industriesSelected = fetchCatsSelected(partner.Id, PMP_StaticConstants_Partner.PIM_INDUSTRY_ID);
                
                //Application 
                formData.applicationOptions = PMP_SearchUtilityController.getCategoryTree(PMP_StaticConstants_Partner.PIM_APPLICATION_ID, true, langCode);
                formData.applicationsSelected = fetchCatsSelected(partner.Id, PMP_StaticConstants_Partner.PIM_APPLICATION_ID);
                //
                //Step-4 Resources
                
                
                getResources(formData, partner);
                
                
                //STEP-5 ADMIN REVIEW
                if(PMP_SearchUtilityController.isIntelAdmin()){
                    loggedInPartnerUser=false;
                    getAdminDetails(formData,partner);
                } 
                formData.currentStatus = partner.PMP_Company_Lifecycle_Status_Nm__c;
                // system.debug('130'+formData.currentStatus);
               //system.debug('list partner ' + partner);
                getPartnerNames(formData, partner);
            }
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());

        }
        // system.debug('FormData : '+formData);
        return formData;
    }
//IPA 2.0 TWC729-7822
    /*@AuraEnabled
    public static void AssignEnhancedBenefitToStorefront(Id partnerId, String requestJSON){
    try { 
            PMP_Company__c partner = [SELECT PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c FROM PMP_Company__c WHERE Id =:partnerId];
            String workCopyId;
            FormDataSaveRequest saveRequest = (FormDataSaveRequest)JSON.deserialize(requestJSON, FormDataSaveRequest.class);          
            if(partner.PMP_Is_Published_Ind__c){
                if(String.isNotEmpty(partner.PMP_Working_Copy_Id__c)){
                    workCopyId = partner.PMP_Working_Copy_Id__c;
                }
            }else if(partner.PMP_Is_Working_Copy_Ind__c){
                workCopyId = partner.Id;
            }else{
                throw new AuraHandledException('Record:'+partnerId+' is Not a Working Copy or Published Copy. Contact Administrator');
            }
            if(String.isNotEmpty(workCopyId)){
                partner = [SELECT Id,PMP_Partner_Benefit_Type__c
                           from PMP_Company__c WHERE id =: workCopyId LIMIT 1 ];
                partnerId = partner.Id;
            }else{
                throw new AuraHandledException('No working Copy Exists. Please contact administrator');
            }
            if(partner.PMP_Partner_Benefit_Type__c != PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced){
                partner.PMP_Suppress_Email_Ind__c = saveRequest.suppressEmail;
                partner.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
                update partner;   
            }
            
        } catch (Exception e) {
            //System.debug('Error while assigning Enhanced Benefit :' + e.getMessage());
            PMP_Utility.logError(e, 'PMP_SearchEditStoreFrontController');
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
             throw new AuraHandledException(e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(':'));
            }else {
                throw new AuraHandledException(e.getMessage());
            }
           
        }
    }*/
    
    @AuraEnabled
    public static Boolean saveEditFormData(Id partnerId, String requestJSON ){
        Boolean firstTimeUpdate = false;
         try{ 
            FormDataSaveRequest saveRequest = new FormDataSaveRequest();
            
            saveRequest = (FormDataSaveRequest)JSON.deserialize(requestJSON, FormDataSaveRequest.class);          
            
            PMP_Company__c partner = new PMP_Company__c();
            
            partner = [SELECT PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Partner_Submitter_UserId__c FROM PMP_Company__c WHERE Id =:partnerId];
            String workCopyId;
            if(partner.PMP_Is_Published_Ind__c){
                if(String.isNotEmpty(partner.PMP_Working_Copy_Id__c)){
                    workCopyId = partner.PMP_Working_Copy_Id__c;
                }
            }else if(partner.PMP_Is_Working_Copy_Ind__c){
                workCopyId = partner.Id;
            }
            if(String.isNotEmpty(workCopyId)){
                partner = [SELECT Id,Name,tolabel(PMP_Company_Information_Language_Nm__c),PMP_Account_Dsc__c,PMP_Partner_Submitter_UserId__c
                           ,PMP_Account_Industry__c,PMP_Account_Application__c,PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,LastModifiedDate,
                           PMP_Account_Region__c,PMP_Account_Tag_Line__c,PMP_Company_Resource__c,PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Updated_Ind__c,
                           PMP_Translation_Lifecycle_Status_nm__c,  PMP_Partner_Program_nm__c,PMP_Partner_Segment_Nm__c
                           from PMP_Company__c WHERE id =: workCopyId LIMIT 1 ];
                partnerId = partner.Id;
            }else{
                return false;
            }
            
            //Added by Subash for US682883, US685085 & US686667
            partner.Name = saveRequest.partner != NULL && String.isNotBlank(saveRequest.partner.name) ? saveRequest.partner.name : partner.Name;
            if(saveRequest.partner != NULL) {
                partner.PMP_Account_Website__c =  saveRequest.partner.website;
                partner.PMP_Partner_Primary_Street_Txt__c = saveRequest.partner.primaryStreet;
                partner.PMP_Partner_Secondary_Street_Txt__c = saveRequest.partner.secondaryStreet;
                partner.PMP_Partner_City_Txt__c = saveRequest.partner.city;
                partner.PMP_Partner_Country_Txt__c = saveRequest.partner.country;
                partner.PMP_Partner_State_Txt__c = saveRequest.partner.state;
                partner.PMP_Partner_Zipcode_Txt__c = saveRequest.partner.postalCode;
                List<PMP_Company_Translation__c> translations = new List<PMP_Company_Translation__c>();
                if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){ //ApexCRUDViolation Fix
                  translations = [SELECT Id,Name FROM PMP_Company_Translation__c WHERE PMP_Company_Information_Id__c=:partner.Id];
                }
                for(PMP_Company_Translation__c ct : translations) {
                    ct.Name = saveRequest.partner.name;
                }
                
                if(Schema.sObjectType.PMP_Company_Translation__c.isUpdateable()){ //ApexCRUDViolation Fix
                    if(translations.size() > 0) update translations;
                }
            }
            //End of US682883, US685085 & US686667
            if (partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Update_Required)
            {
                partner.PMP_Is_Updated_Ind__c = true;
            }
            else if (partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Approved || partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Draft || partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Rejected )
            {
                firstTimeUpdate = true;
                DateTime dtm = partner.LastModifiedDate;
                
                partner.PMP_Initial_Storefront_Submit_Date_Dt__c = dtm.date();
                partner.PMP_Is_Updated_Ind__c = false;
            }
            
            
            
            //Added by nikhil to use pub id for email storefront
            String pubCopyId;
            
            pubCopyId = [SELECT Id FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c =:partner.Id LIMIT 1].Id;
            
            
            partner.PMP_Published_Copy_Id__c = pubCopyId;
            
           
            
            //INTEL ADMIN SPECIFIC
            if(!PMP_SearchUtilityController.isIntelAdmin()){
                // system.debug('userInfo 203=> '+UserInfo.getUserName());
                partner.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Admin_Review;
                
                  //Added by Krishna to capture the last submitter id to send email for storefront
                partner.PMP_Partner_Submitter_UserId__c = UserInfo.getUserId();
            }
            //Added by Krishna to capture the last submitter id to send email for storefront
            if(partner.PMP_Partner_Submitter_UserId__c == null){
                partner.PMP_Partner_Submitter_UserId__c = UserInfo.getUserId();
                //system.debug('Last submitter id==>'+partner.PMP_Partner_Submitter_UserId__c);
            }          
                                        
            //Step-1 Logo
            updateLogo(saveRequest, partner);
            
            //Step-2 Input Language,Tagline and Description
            partner.PMP_Company_Information_Language_Nm__c = saveRequest.descriptionData.language;
 //         String language = saveRequest.descriptionData.language;
            String tagline = saveRequest.descriptionData.tagline;
            String description = saveRequest.descriptionData.description;
            
          
            if(!PMP_SearchUtilityController.isIntelAdmin()){
               String language = saveRequest.descriptionData.language;
               updateTranslationRecords(partner.Id, partner.Name, language, tagline, description);           
               }
            if(PMP_SearchUtilityController.isIntelAdmin()){
                String language = PMP_StaticConstants_Partner.English;
                updateTranslationRecords(partner.Id, partner.Name, language, tagline, description);
               }
  
            //Updating Translation Lifecycle status for Eligible Partners [Added by Sooriya as part of US549549]
            if(checkTransEnabled(partner.PMP_Partner_Segment_Nm__c)){ //Pratner program replaced with Partner Segment as part of US704420
                partner.PMP_Translation_Lifecycle_Status_nm__c = PMP_StaticConstants_Partner.Pending;    
                partner.PMP_Translated_Languages_Txt__c='';
                partner.PMP_Translated_Languages_Txt__c=partner.PMP_Company_Information_Language_Nm__c;                
            }    
            partner.PMP_Account_Dsc__c = description;   
            partner.PMP_Account_Tag_Line__c =  tagline;    
            //Step-3 Application,Industry and Region                        
            saveRegion(partner.Id, saveRequest.regionsSelected);
            
            //Step-4 Resource
            updateResources(saveRequest, partner);
            
            //Step-5 Industry
            savePartnerCategory(partner.Id, saveRequest.industriesSelected, PMP_StaticConstants_Partner.PIM_INDUSTRY_ID);
            
            //Step- 6 Application
            savePartnerCategory(partner.Id, saveRequest.applicationsSelected, PMP_StaticConstants_Partner.PIM_APPLICATION_ID);

            if(Schema.sObjectType.PMP_Company__c.isUpdateable()){
                // system.debug('partner => '+partner);
                update partner;
                if(firstTimeUpdate){
                    PMP_Company__c updatedPartner = [SELECT LastModifiedDate FROM PMP_Company__c WHERE Id =: partner.Id];
                    partner.PMP_Initial_Storefront_Submit_Date_Dt__c = updatedPartner.LastModifiedDate.date();
                    update partner;
                }
            } 
            
        }catch(Exception e){
            //System.debug('Error while updating company records :' + e.getMessage());
            PMP_Utility.logError(e, 'PMP_SearchEditStoreFrontController');
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
             throw new AuraHandledException(e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(':'));
            }else {
                throw new AuraHandledException(e.getMessage());
            }
               
           // return false;
            
        }
        return true;
    }
    
    
    //Step-1 Method to get existing Logo 
    public static void getLogo(FormData formData , PMP_Company__c partner){
        try{
            formData.workingCopyId = partner.Id;
            formData.logo = new ImageWrapper();
            formData.logoCheck = false;
            //system.debug('$$^^partner Id==>'+partner.Id);
            image = MarketplaceImageUploader.getImages(partner.Id);
            //system.debug('$$^^image==>'+image);          
            if(!String.isEmpty(image)){
                formData.logoCheck = true;
            }
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    //Step-1 Method to update Logo
    public static void updateLogo(FormDataSaveRequest saveRequest, PMP_Company__c partner){
        try {
            List<PMP_Company_Resource__c> workingPartnerImageResExisting = new List<PMP_Company_Resource__c>();
            List<PMP_Company_Resource__c> workingPartnerImageResToSave = new List<PMP_Company_Resource__c>();
            
            //if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){ //ApexCRUDViolation Fix
            workingPartnerImageResExisting = [SELECT id, Name from PMP_Company_Resource__c where PMP_Company_Id__c =:partner.Id 
                                              AND (PMP_Company_Resource_Type_Nm__c =: PMP_StaticConstants_partner.IMAGE OR PMP_Company_Resource_Type_Nm__c =: PMP_StaticConstants_partner.THUMBNAIL_IMAGE)];
            //}
            if(!workingPartnerImageResExisting.isEmpty()){
                //if(Schema.sObjectType.PMP_Company_Resource__c.isDeletable()){ //ApexCRUDViolation Fix
                delete workingPartnerImageResExisting;
                //}
                //system.debug('deleted');
            }
            
            
            List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: partner.Id];
            //system.debug('links' + links);
            
            List<String> linkIds = new List<String>();
            for (ContentDocumentLink l : links) {
                linkIds.add(l.ContentDocumentId);
            }
            List<ContentVersion> versions = [SELECT Id, Title, FileExtension, ContentSize, ContentDocumentId, VersionData, OwnerId FROM ContentVersion WHERE ContentDocumentId IN :linkIds AND IsLatest = true];            
            //System.debug('Versions ' + versions);
            
            for(ContentVersion ver : versions){
                
                PMP_Company_Resource__c res = new PMP_Company_Resource__c();
                res.PMP_Company_Id__c = partner.Id;
                res.PMP_Company_Image__c = ver.ContentDocumentId;
                //res.Name = 'logo'; // Uday: commented to pass actual name
                res.Name = ver.Title.length()>80 ? ver.Title.subString(0,80) : ver.Title;
                //res.Name = ver.Title;
                res.PMP_Company_Resource_Sequence_Nbr__c = 0;
                res.PMP_Company_Resource_Type_Nm__c = PMP_StaticConstants_partner.IMAGE;
                workingPartnerImageResToSave.add(res);                                           
            }
            
            
            if(!workingPartnerImageResToSave.isEmpty()){
                //if(Schema.sObjectType.PMP_Company_Resource__c.isCreateable()){
                insert workingPartnerImageResToSave;
                //}
                //system.debug('res created');
            }
            
            PMP_Image_Resizing.generateThumbnailImages(partner.Id); // Uday:for resizing the image                
            
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    //Step-2 Method to get Company Description
    public static void getCompDesc(FormData formData , PMP_Company__c partner, String langCode){
        try{
            String userLanguage;
            String description = '';
            String tagline = '';
            String status = partner.PMP_Company_Lifecycle_Status_Nm__c;
            
            //Code to set user language if status is Approved or Draft then consider user locale else language selected while edit storefront changes
            if(status == PMP_StaticConstants_Partner.Approved || status == PMP_StaticConstants_Partner.Draft){
                userLanguage = PMP_StaticConstants_Partner.localeMap.get(langCode); 
            }
                        
            else{
                userLanguage = partner.PMP_Company_Information_Language_Nm__c; //English 
            }
            
            //Logic End
            
            List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
            String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
            //if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
                transList = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c,
                             PMP_Chinese_Txt__c, PMP_Japanese_Txt__c from PMP_Company_Translation__c 
                             where PMP_Company_Information_Id__c = :partner.Id AND PMP_Field_Nm__c != :streamIdName];
            //}
            for(PMP_Company_Translation__c trans: transList)
            {
                String temp = '';
                
                //added by sooriya as part of US549549
                if(PMP_SearchUtilityController.isIntelAdmin()){
                    if(PMP_StaticConstants_Partner.localeMap.get(langCode)==PMP_StaticConstants_Partner.Chinese  && trans.PMP_Chinese_Txt__c != null){
                      temp = trans.PMP_Chinese_Txt__c;  
                    }
                    else if(PMP_StaticConstants_Partner.localeMap.get(langCode)==PMP_StaticConstants_Partner.Japanese && trans.PMP_Japanese_Txt__c != null){
                      temp = trans.PMP_Japanese_Txt__c;  
                    }
                    else if (trans.PMP_English_Txt__c != null){
                      temp = trans.PMP_English_Txt__c;
                    }
                } 
                else{  
                if (userLanguage == PMP_StaticConstants_Partner.Chinese && trans.PMP_Chinese_Txt__c != null){
                    temp = trans.PMP_Chinese_Txt__c;
                }
                else if (userLanguage == PMP_StaticConstants_Partner.Japanese && trans.PMP_Japanese_Txt__c != null){
                    temp = trans.PMP_Japanese_Txt__c;
                }
                else if (trans.PMP_English_Txt__c != null){
                    temp = trans.PMP_English_Txt__c;
                }                   
                }
                    
                if (trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.Description)
                {
                    description = temp;
                }
                else if (trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.Tagline)
                {
                    tagline = temp;
                }
            }
            
            DescriptionData descData = new DescriptionData();
            if(description!=null){
               descData.description = description; 
            }else{
                descData.description = '';
            }
                
            if(tagline!=null){
                descData.tagline = tagline;
            }else{
                descData.tagline = '';
            }
                
   //        descData.language = userLanguage;    // PMP_StaticConstants_Partner.localeMap.get(UserInfo.getLanguage());
            
            //Code to fetch available Language Options
            String partnerSegment = [SELECT PMP_Partner_Program_nm__c,PMP_Partner_Segment_Nm__c FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c =:partner.Id LIMIT 1].PMP_Partner_Segment_Nm__c;
            Boolean transEnabled = checkTransEnabled(partnerSegment); //check translation status for Partner segment
           
            if(transEnabled){
                descData.language = userLanguage;
            }else{
                descData.language = PMP_StaticConstants_Partner.English;
            } 
            
            //system.debug('transEnabled ' + transEnabled);
            descData.languageOptions = new List<Options>();
            
            Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Company_Information_Language_Nm__c.getDescribe();      
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry pickListVal : ple){
                Options opt = new Options();
                opt.label = pickListVal.getLabel();
                opt.value = pickListVal.getValue(); //modified to update value in english only
                if(opt.Value == PMP_StaticConstants_Partner.English){
                    descData.languageOptions.add(opt);   
                }else if(transEnabled){
                    descData.languageOptions.add(opt);
                }
                
            }
            
            formData.descriptionData = descData;
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    //Step-2 Method to Update Company Translation Records
    public static void updateTranslationRecords(String partnerId, String partnerName ,String language ,String tagline, String description){
        try{
            String temp;
            Boolean descUpdated = false;
            Boolean tagUpdated = false;
            List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
            String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
            //if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
                transList = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c,
                             PMP_Chinese_Txt__c, PMP_Japanese_Txt__c from PMP_Company_Translation__c 
                             where PMP_Company_Information_Id__c = :partnerId AND PMP_Field_Nm__c != :streamIdName];
            //}
            for(PMP_Company_Translation__c trans: transList)
            {
                if (trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.Description)
                {
                    temp = description;
                    descUpdated = true;
                }
                else if (trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.Tagline)
                {
                    temp = tagline;
                    tagUpdated = true;
                }
                                       
                if (language == PMP_StaticConstants_Partner.English)
                    trans.PMP_English_Txt__c = temp;
                else if (language == PMP_StaticConstants_Partner.Chinese)
                    trans.PMP_Chinese_Txt__c = temp;
                else if (language == PMP_StaticConstants_Partner.Japanese)
                    trans.PMP_Japanese_Txt__c = temp;                        
            }
            if(!descUpdated){
                transList.add(createTranslationRecords(partnerId,partnerName,language,PMP_StaticConstants_Partner.Description,description));
            }
            if(!tagUpdated){
                transList.add(createTranslationRecords(partnerId,partnerName,language,PMP_StaticConstants_Partner.Tagline,tagline));
            }
            
            if (!transList.isEmpty() && Schema.sObjectType.PMP_Company_Translation__c.isCreateable() && Schema.sObjectType.PMP_Company_Translation__c.isUpdateable()){
                upsert transList;
            }
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());

        }
    }
    
    public static PMP_Company_Translation__c createTranslationRecords(String partnerId, String partnerName ,String language, String fieldName, String fieldValue){
        PMP_Company_Translation__c trans = new PMP_Company_Translation__c();
        trans.Name = partnerName;
        trans.PMP_Company_Information_Id__c = partnerid;
        trans.PMP_Field_Nm__c = fieldName;
        if (language == PMP_StaticConstants_Partner.English)
            trans.PMP_English_Txt__c = fieldValue;
        else if (language == PMP_StaticConstants_Partner.Chinese)
            trans.PMP_Chinese_Txt__c = fieldValue;
        else if (language == PMP_StaticConstants_Partner.Japanese)
            trans.PMP_Japanese_Txt__c = fieldValue; 
        return trans;
    }
    //Step-4 Method to get Existing Resource
    public static void getResources(FormData formData , PMP_Company__c partner){
        try{
            List<PMP_Company_Resource__c> resourceList = new List<PMP_Company_Resource__c>();
            //if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
              resourceList = [SELECT Id, Name, PMP_Company_Resource_URL_txt__c,PMP_Company_Resource_Type_Nm__c from PMP_Company_Resource__c where 
                                                          PMP_Company_Id__c =: partner.Id AND 
                                                          PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.IMAGE AND PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.THUMBNAIL_IMAGE]; 
               //AND PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.THUMBNAIL_IMAGE];
            //}
            List<Resource> resources = new List<Resource>();
            
            for( PMP_Company_Resource__c cRes : resourceList ){
                Resource res = new Resource();
                res.title = cRes.Name;
                res.url = cRes.PMP_Company_Resource_URL_txt__c;
                res.type = cRes.PMP_Company_Resource_Type_Nm__c;
                resources.add(res);
            }
            
            Schema.DescribeFieldResult fieldResult = PMP_Company_Resource__c.PMP_Company_Resource_Type_Nm__c.getDescribe();      
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            List<Options> resOptions = new List<Options>();
            for( Schema.PicklistEntry pickListVal : ple){
                if(pickListVal.getLabel()!='Image' && pickListVal.getLabel()!='Thumbnail Image'){
                    Options option = new Options();
                    option.label = pickListVal.getLabel();
                    //option.value = pickListVal.getLabel();    //Commented as part of DE108385 and removed toLabel from the PMP_Company_Resource_Type_Nm__c in above resourceList query
                    option.value = pickListVal.getValue();      //modified to update value in english only                  
                    resOptions.add(option);}
            }
            ResourceData resData = new ResourceData();
            resData.resourceTypes = resOptions;
            resData.resources = resources;
            
            formData.resourceData = new ResourceData();
            formData.resourceData = resData;
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        } 
    }
    
    //Step-4 Method to update Resources
    public static void updateResources(FormDataSaveRequest saveRequest, PMP_Company__c partner){
        try{
            List<PMP_Company_Resource__c> workingPartnerResourceListExisting = new List<PMP_Company_Resource__c>();
            List<PMP_Company_Resource__c> workingPartnerResourceListToSave = new List<PMP_Company_Resource__c>();
            
            //if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
              workingPartnerResourceListExisting = [SELECT id, Name from PMP_Company_Resource__c where PMP_Company_Id__c =: partner.Id and (PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.IMAGE AND PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.THUMBNAIL_IMAGE) ];
            //}
            if(workingPartnerResourceListExisting.size()>0)
                delete workingPartnerResourceListExisting;
            
            
            for(Resource res : saveRequest.resources){
                PMP_Company_Resource__c resNew = new PMP_Company_Resource__c();
                resNew.Name = res.title;
                resNew.PMP_Company_Id__c = partner.Id;
                resNew.PMP_Company_Resource_Type_Nm__c = res.type;
                resNew.PMP_Company_Resource_URL_txt__c = res.url;
               
                workingPartnerResourceListToSave.add(resNew);
            }
            
            
            if(workingPartnerResourceListToSave.size()>0){
                insert workingPartnerResourceListToSave;
            }
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    
    public static void fetchRegion(String partnerId, FormData formData, String langCode){
        try{
            List<Option> regionOptions = new List<Option>();
            List<PMP_Specification__c> specList = new List<PMP_Specification__c>();
            List<PMP_Specification_Value__c> specValueList = new List<PMP_Specification_Value__c>();
           // List<PMP_Specification_Value_Association__c> specValueAccosList = new List<PMP_Specification_Value_Association__c>();
            
            
            String pimId = PMP_StaticConstants_Partner.REGION_PIM_ID;
            String geograPhyname = PMP_StaticConstants_Partner.Geography;
            String ansPimId = pimId + '%';
            Map<String,Option> specOptMap = new Map<String,Option>();
            //Map<String,Option> specValOptMap = new Map<String,Option>();
            
            if(Schema.sObjectType.PMP_Specification__c.isAccessible()){ //ApexCRUDViolation Fix
                specList = [SELECT Id, Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c,PMP_Product_Parent_Specification_Id__c,
                            PMP_Parent_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Ancestor_Specification_Cd__c  
                            LIKE :ansPimId AND PMP_Active_Ind__c = TRUE ORDER BY Name];
            }
            
            if(Schema.sObjectType.PMP_Specification_Value__c.isAccessible()){ //ApexCRUDViolation Fix
                specValueList = [SELECT Id, Name, PMP_Active_Ind__c, PMP_Product_Specification_Value_Cd__c, PMP_Product_Specification_Value_Key__c,
                                 PMP_Specification_Value_Cd__c, PMP_Name_Chinese__c,PMP_Name_Japanese__c,PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Japanese_Cd__c, 
                                 PMP_Specification_Value_Nm__c, PMP_Specification_Value_Sequence_Nbr__c,
                                 PMP_Specification_Product_Cd__c,(select Id, Name, PMP_Specification_Id__c, PMP_Specification_Value_Id__c, PMP_Active_Ind__c, 
                                 PMP_Category_Id__c, PMP_Category_Spec_Value_External_Key__c from Specification_SpecValue_Associations__r where PMP_Active_Ind__c = true) 
                                 FROM PMP_Specification_Value__c WHERE PMP_Spec_Value_Type_Nm__c =:geograPhyname and PMP_Active_Ind__c =true ORDER BY Name];
            }
            
             
            //List<String> regIdList = new List<String>();
            for (PMP_Specification__c spec:specList){
            
                Option opt = new Option();
                opt.label = PMP_SearchUtilityController.getLocalisedName(spec, '', langCode);
                opt.value = spec.Id;
                
                opt.children = new List<Option>();
        
                specOptMap.put(spec.id,opt);
                //specValOptMap.put(spec.PMP_Partner_Product_Specification_Id__c,opt);
                if( spec.PMP_Product_Parent_Specification_Id__c == pimId){
                    if(!regionOptions.contains(opt)){
                        regionOptions.add(opt);
                    } 
                }
                
            }
            
          //Added by Krishna
           for (PMP_Specification_Value__c specVal:specValueList){
              Option opt = new Option();
              opt.label = PMP_SearchUtilityController.getLocalisedName(specVal, '', langCode);//specVal.Name;
              opt.value = specVal.Id;

               
              for(PMP_Specification_Value_Association__c specAss : specVal.Specification_SpecValue_Associations__r){
                 if(specOptMap.containskey(specAss.PMP_Specification_Id__c)){
                    specOptMap.get(specAss.PMP_Specification_Id__c).children.add(opt);
                }

               }
 
            }
            //End
          
            for (PMP_Specification__c spec:specList)
            {                
                if (specOptMap.containsKey(spec.PMP_Parent_Specification_Id__c)){
                    specOptMap.get(spec.PMP_Parent_Specification_Id__c).children.add(specOptMap.get(spec.Id));
                }
            }
            
            List<String> regionsSelected = new List<String>();
            List<PMP_Company_Region__c> selRegList = new List<PMP_Company_Region__c>();
            if(Schema.sObjectType.PMP_Company_Region__c.isAccessible()){ //ApexCRUDViolation Fix
              selRegList = [SELECT PMP_Specification_Id__c,PMP_Specification_Value__c FROM PMP_Company_Region__c WHERE PMP_Company_Id__c =: partnerId];
            }
            for(PMP_Company_Region__c reg: selRegList){
                regionsSelected.add(reg.PMP_Specification_Id__c);
                regionsSelected.add(reg.PMP_Specification_Value__c);
            }
            
            formData.regionOptions = regionOptions;
            formData.regionsSelected = regionsSelected;
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    public static void saveRegion(String partnerId, List<String> specIds){
        // system.debug('specIds for save==>'+specIds);
        List<PMP_Specification__c> specList = new List<PMP_Specification__c>();
        //List<PMP_Specification_Value__c> specValueList = new List<PMP_Specification_Value__c>();
        //set<string> specnewIds = new set<string>();
        Map<string,PMP_Specification__c> specmap =new Map<string,PMP_Specification__c>();
        try{
            List<PMP_Company_Region__c> compRegList = new List<PMP_Company_Region__c>();
            List<PMP_Company_Region__c> exRegList = new List<PMP_Company_Region__c>();
            if(Schema.sObjectType.PMP_Company_Region__c.isAccessible()){ //ApexCRUDViolation Fix
              exRegList = [SELECT Id FROM PMP_Company_Region__c WHERE PMP_Company_Id__c =: partnerId];
            }
            if(!exRegList.isEmpty()){
                //if(Schema.sObjectType.PMP_Company_Region__c.isDeletable()){ // MS/PA/MP Admin users don't have delete permission
                delete exRegList;
                //}
                
            }
            
            if(Schema.sObjectType.PMP_Specification__c.isAccessible()){ //ApexCRUDViolation Fix
                specList = [SELECT Id, Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c,PMP_Product_Parent_Specification_Id__c,
                            PMP_Parent_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Ancestor_Specification_Cd__c  
                            LIKE : '%NPP_GeographicCoverage%' AND PMP_Active_Ind__c = TRUE ORDER BY Name];
            }
            
            for(PMP_Specification__c specs : specList){
                specmap.put(specs.id,specs);
            }
            
            for(String spec: specIds){
               if(specmap.containskey(spec)){
                PMP_Company_Region__c compReg = new PMP_Company_Region__c();
                compReg.PMP_Company_Id__c = partnerId;
                compReg.PMP_Specification_Id__c = spec;
                //compReg.PMP_Specification_Value__c=spec;
                compRegList.add(compReg);
                }
                else{
                PMP_Company_Region__c compReg = new PMP_Company_Region__c();
                compReg.PMP_Company_Id__c = partnerId;
                //compReg.PMP_Specification_Id__c = spec;
                compReg.PMP_Specification_Value__c=spec;
                compRegList.add(compReg);
                }
               
            }
            //system.debug('compRegList '+compRegList);
            if(Schema.sObjectType.PMP_Company_Region__c.isCreateable()){  //ApexCRUDViolation Fix
            insert compRegList;
            //system.debug('compRegList final'+compRegList);
            }
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    
    public static List<String> fetchCatsSelected(String partnerId, String pimId){
        List<String> catsSelected = new List<String>();
        List<PMP_Partner_Category__c> partnerCatList = new List<PMP_Partner_Category__c>();
        try{
            String ansPimId = pimId + '%';
            if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){     //ApexCRUDViolation Fix
                partnerCatList = [SELECT Id, PMP_Category_Id__c FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c =: partnerId 
                                  AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
                                  AND PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c like :ansPimId];
                
            }
            for(PMP_Partner_Category__c partnerCat: partnerCatList){
                catsSelected.add(partnerCat.PMP_Category_Id__c);
            }
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
        return catsSelected;
    }
    
    public static void savePartnerCategory(String partnerId, List<Id> catsSelected, String pimId){
        try{
            String ansPimId = pimId + '%';
            List<PMP_Partner_Category__c> catList = new List<PMP_Partner_Category__c>();
            List<PMP_Partner_Category__c> exCatList = [SELECT Id FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c =: partnerId AND  PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c like :ansPimId AND PMP_Category_Id__r.PMP_Active_Ind__c = true ];
            //if(Schema.sObjectType.PMP_Partner_Category__c.isDeletable()){ //Uday: Partner Admins doesn't have delete permissions, hence creating duplicates.
            if(!exCatList.isEmpty()){
                delete exCatList;
            }
            
            //}
            
            for(String cat: catsSelected){
                if(cat != null){
                    PMP_Partner_Category__c partCat = new PMP_Partner_Category__c();
                    partCat.PMP_Partner_Id__c = partnerId;
                    partCat.PMP_Category_Id__c = cat;
                    catList.add(partCat);
                }
            }
            if(Schema.sObjectType.PMP_Partner_Category__c.isCreateable()){
                if(!catList.isEmpty()){
                    insert catList;
                }   
            }
            
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    //Step-5 Method to get Admin Details
    public static void getAdminDetails(FormData formData , PMP_Company__c partner){
        try{
            User user = [SELECT Name FROM User WHERE Id=:partner.LastModifiedById];
            formdata.submittedBy = user.Name;
            formdata.submittedOn = partner.LastModifiedDate.format('MMM-dd-yyyy');
            if (partner.PMP_Intel_Admin_Id__c !=null){
                formdata.admin = partner.PMP_Intel_Admin_Nm__c;
            }
            else{
                formdata.admin = UserInfo.getName();
            }
            
            
            formdata.adminList = new List<Options>();
            List<User> admins = new List<User>();
            
            //Get public group members
            Group grp = new Group();
            List<GroupMember> groupMembers = new List<GroupMember>();
            
            //if(Schema.sObjectType.Group.isAccessible() && Schema.sObjectType.GroupMember.isAccessible()){
                //grp=[SELECT Id FROM Group where Name=: PMP_StaticConstants_Partner.IPA_INTERNAL_ADMIN LIMIT 1];
                grp=[SELECT Id FROM Group where developername=:PMP_StaticConstants_Partner.IPA_INTERNAL_ADMIN LIMIT 1];
                groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id]; 
                
            //}
            List<Id> userIds=new List<Id>();
            for (GroupMember groupMember: groupMembers){
                userIds.add(groupMember.UserOrGroupId);
            }
            admins = [SELECT Id, Name FROM User where Id in :userIds];
            
            for (User admin:admins)
            {
                Options opt= new Options();
                opt.label = admin.Name;
                opt.value = admin.Name;
                formdata.adminList.add(opt);
            }
            formdata.statusList = new List<Options>();
            Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Company_Lifecycle_Status_Nm__c.getDescribe();      
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                Options opt = new Options();
                opt.label= pickListVal.getLabel();
                opt.value = pickListVal.getValue();
                if (opt.value!=PMP_StaticConstants_Partner.Draft && opt.value!=PMP_StaticConstants_Partner.Published)
                    formdata.statusList.add(opt);
            }
            
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    @AuraEnabled
    public static Boolean updateStatusAdmin(Id partnerId, String requestJSON){
        FormDataSaveRequest saveRequest = new FormDataSaveRequest();
        
        saveRequest = (FormDataSaveRequest)JSON.deserialize(requestJSON, FormDataSaveRequest.class);
        
        PMP_Company__c partner = new PMP_Company__c();
        
        partner = [SELECT PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c WHERE Id =:partnerId];
        String workCopyId;
        if(partner.PMP_Is_Published_Ind__c){
            if(String.isNotEmpty(partner.PMP_Working_Copy_Id__c)){
                workCopyId = partner.PMP_Working_Copy_Id__c;
            }
            
        }else if(partner.PMP_Is_Working_Copy_Ind__c){
            workCopyId = partner.Id;
        }
        if(String.isNotEmpty(workCopyId)){
            partner = [SELECT Id,Name,PMP_Company_Information_Language_Nm__c,PMP_Account_Dsc__c
                       ,PMP_Account_Industry__c,PMP_Account_Application__c,PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,LastModifiedDate,
                       PMP_Account_Region__c,PMP_Account_Tag_Line__c,PMP_Company_Resource__c,PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Updated_Ind__c 
                       from PMP_Company__c WHERE id =: workCopyId LIMIT 1 ];
            partnerId = partner.Id;
        }else{
            return false;
        }
        List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE Assignee.Name = :saveRequest.admin AND
                                             PermissionSet.Name = :PMP_StaticConstants_Partner.INTEL_ADMIN LIMIT 1];
        //User user  = [SELECT Id FROM User WHERE Name=:saveRequest.admin];
        partner.PMP_Intel_Admin_Id__c = psa.size() > 0 ? psa[0].AssigneeId : NULL;
        
        //system.debug('userInfo 199=> '+UserInfo.getUserName()+' saveRequest => '+saveRequest.status);
        partner.PMP_Company_Lifecycle_Status_Nm__c = saveRequest.status;
        //system.debug('768'+partner.PMP_Company_Lifecycle_Status_Nm__c);
        update partner;
              
        return true;  
    }
    
    //Method to check if translation is Enabled for Partner Segment
    public static Boolean checkTransEnabled(String partnerSegment){ //ISA replaced with IOT Partner Segment as part of US704420
        Boolean transEnabled = false;
        //String partnerSegment='Internet of Things and Embedded';
       /* List<PMP_SearchPartnerProgram_Config__mdt> transEnablePP = [SELECT PMP_Partner_Program_value__c FROM PMP_SearchPartnerProgram_Config__mdt
                                                                    WHERE Active__c = true AND PMP_Enable_Translation_Ind__c = true];
        for(PMP_SearchPartnerProgram_Config__mdt pp: transEnablePP){
            if(partnerProgram !=null && partnerProgram.contains(pp.PMP_Partner_Program_value__c)){
                transEnabled = true;
                break;
            }
        }*/
       if(partnerSegment !=null && partnerSegment.contains(PMP_StaticConstants_Partner.IOT)){
           transEnabled = true;           
       }
                 
        return transEnabled;
    }
    
    @AuraEnabled
    //Method to get image URL
    public static string getlogoUrl(string partnerId){
       string requestJSON = MarketplaceImageUploader.getImages(partnerId);
        MarketplaceImageUploader.GalleryWrapper gw = (MarketplaceImageUploader.GalleryWrapper)JSON.deserializeStrict(requestJSON,MarketplaceImageUploader.GalleryWrapper.class);
        List<ImageWrapper>  request = (List<ImageWrapper>)JSON.deserialize(gw.galleryImages, List<ImageWrapper>.class);
        if (request != null && request.size() > 0 && request[0].url!=null) {
          return request[0].url;
        } 
           return null;  
    }    
    
    //Added by Subash for US682883 & US685085
    public static void getPartnerNames(FormData formData , PMP_Company__c partner){
        
        Map<string,PartnerWrapper> webaddwrap = new Map<string,PartnerWrapper>();

        List<Options> opts = new List<Options>();
    //Modified as a part of OPID Restructure
        List<Id> opids = new List<Id>();
        List<PMP_OPID_MPI_Rel__c> junctionObjects =  PMP_Utility.getJunctionAccToMpiByCompanyId(partner.Id);
        // system.debug('junctionObjects' + junctionObjects);
        for(PMP_OPID_MPI_Rel__c juncRec : junctionObjects){
            opids.add(juncRec.PMP_One_Partner_ID__c);
        }
        if(opids.size() == 0){
            List<PMP_OPID_MPI_Rel__c> junctionObjsPublRec =  PMP_Utility.getJunctionAccToMpiByCompanyId(partner.PMP_Published_Copy_Id__r.Id);
            for(PMP_OPID_MPI_Rel__c juncRec : junctionObjsPublRec){
                opids.add(juncRec.PMP_One_Partner_ID__c);
            }
        }
        //Existing Logic
        //Id OPID = partner.PMP_One_Partner_ID__c != NULL ? partner.PMP_One_Partner_ID__c : (partner.PMP_Published_Copy_Id__r.PMP_One_Partner_ID__c != NULL ? partner.PMP_Published_Copy_Id__r.PMP_One_Partner_ID__c : NULL);
        
        //if(OPID != NULL) {
      if(opids.size() > 0){
            User partnerUser;
          if(loggedInPartnerUser){
              partnerUser = [SELECT Id,Account.Id FROM User WHERE Id=:userInfo.getUserId()];
            }
            Set<Id> accIds = new Set<Id>();
             // logic to get option MPI Name    
              Options opt1 = new Options();
              opt1.label=partner.Name; //child accounts
              opt1.value=partner.Name;
              opts.add(opt1);
            system.debug('opts>>'+ opts);
            //Modified as a part of OPID Restructure
            //  Auto population of address for draft changes
            /* for(Core_Account_Group_Member__c agm : [SELECT Id,Core_Partner_Account_Id__r.Name,Core_Intel_Account_Id__r.Name,Core_Intel_Account_Id__c
                                                    
FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c in:opids AND Core_Inactive_Ind__c = FALSE]) {*/
      //Existing Logic
            /*for(Core_Account_Group_Member__c agm : [SELECT Id,Core_Partner_Account_Id__r.Name,Core_Intel_Account_Id__r.Name
                                                    
                                                    FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c = :OPID AND Core_Inactive_Ind__c = FALSE]) {*/
            
               /* if(opts.size() == 0) { //Commented the code as OPID accounts should not be shown in dropdown
                    Options opt = new Options();
                    opt.label=agm.Core_Partner_Account_Id__r.Name; //opid accounts
                    opt.value=agm.Core_Partner_Account_Id__r.Name;
                    opts.add(opt);
                } */
            List<Core_Account_Group_Member__c> agmList= new List<Core_Account_Group_Member__c>();
             agmList = [SELECT Id,Core_Partner_Account_Id__r.Name,Core_Intel_Account_Id__r.Name,Core_Intel_Account_Id__c,Primary_Account__c
               
                                                FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c in:opids AND Core_Inactive_Ind__c = FALSE and Primary_Account__c=true limit 1 ];                                                      
                 // logic to have option for logged in partner user
            system.debug('agmList>>'+agmList);
            if(!agmList.isEmpty()){
                if(loggedInPartnerUser && partnerUser!=null && partnerUser.Account.Id==agmList[0].Core_Intel_Account_Id__c) {
                     //if(partnerUser!=null && partnerUser.Account.Id==agm.Core_Intel_Account_Id__c){
                     Options relatedLocationOpt = new Options();
                    relatedLocationOpt.label=agmList[0].Core_Intel_Account_Id__r.Name; //child accounts
                    relatedLocationOpt.value=agmList[0].Core_Intel_Account_Id__r.Name;
                    if(agmList[0].Core_Intel_Account_Id__r.Name!=partner.Name){
                         opts.add(relatedLocationOpt);
                         }
                    //}
                 }
                                                          
                accIds.add(agmList[0].Core_Intel_Account_Id__c);
                system.debug('accIds>>'+accIds);
                // }
                //Auto population of address for draft changes
                /*for(Account acc : [SELECT Id, Name, Core_User_Defined_Website__c, BillingStreet, BillingCity,toLabel(BillingStateCode)BillingState,
BillingPostalCode, toLabel(BillingCountryCode)BillingCountry FROM Account WHERE Id IN :accIds]) {*/
                	List<Account> accList= new List<Account>();
                 accList = [SELECT Id, Name, Core_User_Defined_Website__c, BillingStreet, BillingCity,toLabel(BillingStateCode)BillingState,
                               BillingPostalCode, toLabel(BillingCountryCode)BillingCountry FROM Account WHERE Id IN :accIds limit 1 ];
                 system.debug('accList>>'+accList);
                //To populate location account website and address
                PartnerWrapper part = new PartnerWrapper();
                part.name = accList[0].Name;
                part.website = accList[0].Core_User_Defined_Website__c;
                part.primaryStreet = accList[0].BillingStreet;
                //part.secondaryStreet = acc.BillingStreet;
                part.city = accList[0].BillingCity;
                part.country = (String)accList[0].get('BillingCountry');
                part.state = (String)accList[0].get('BillingState');
                part.postalCode = accList[0].BillingPostalCode;
                webaddwrap.put(accList[0].Name, part);
                system.debug('webaddwrap>>'+webaddwrap);
                //End of location account website and address changes   
                //}
            }
        } else {
            
            List<PMP_Company__c> companies = [SELECT Id, Name FROM PMP_Company__c WHERE Id = :partner.Id];
            
            if(companies.size() > 0) {
                Options opt = new Options();
                opt.label = companies[0].Name;
                opt.value = companies[0].Name;
                opts.add(opt);
            }
        }
        formData.partnerNames = opts;
        formData.webaddwrap = webaddwrap;

system.debug('formData.partnerNames>>'+ formData.partnerNames);        
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Option> getDependentMap() {
        return PMP_SearchCountryStateMapping.getDependentMap();
    }  
   
}