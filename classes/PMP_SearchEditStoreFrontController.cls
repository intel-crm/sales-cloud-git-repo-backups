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
    
    @AuraEnabled(cacheable=true)
    public static Boolean isLocked(String partnerId) {
        
        try {
            
            if (!Schema.sObjectType.PMP_Company__c.isAccessible()) {
                return false;
            }
            
            PMP_Company__c partner = [
                SELECT PMP_Working_Copy_Id__c,
                PMP_Is_Published_Ind__c,
                PMP_Is_Working_Copy_Ind__c,
                PMP_Company_Lifecycle_Status_Nm__c
                FROM PMP_Company__c
                WHERE Id = :partnerId
            ];
            
            String workCopyId;
            
            if (partner.PMP_Is_Published_Ind__c &&
                String.isNotBlank(partner.PMP_Working_Copy_Id__c)) {
                    
                    workCopyId = partner.PMP_Working_Copy_Id__c;
                    
                } else if (partner.PMP_Is_Working_Copy_Ind__c) {
                    
                    workCopyId = partner.Id;
                }
            
            if (String.isBlank(workCopyId)) {
                return false;
            }
            
            PMP_Company__c workCopy = [
                SELECT PMP_Company_Lifecycle_Status_Nm__c
                FROM PMP_Company__c
                WHERE Id = :workCopyId
                LIMIT 1
            ];
            
            return workCopy.PMP_Company_Lifecycle_Status_Nm__c ==
                PMP_StaticConstants_Partner.Admin_Review
                &&
                !PMP_SearchUtilityController.isIntelAdmin();
            
        } catch (Exception e) {
            
            PMP_Utility.logError(
                e,
                'PMP_SearchEditStoreFrontController-isLocked'
            );
            
            return false;
        }
    }
    @AuraEnabled
    public static FormData getPartnerExistingData(
        String partnerId,
        String langCode
    ){
        FormData formData = new FormData();
        
        try {
            
            if (PMP_SearchUtilityController.isGuest()) {
                return formData;
            }
            
            PMP_Company__c partner = [
                SELECT Id,
                Name,
                PMP_Working_Copy_Id__c,
                PMP_Is_Published_Ind__c,
                PMP_Is_Working_Copy_Ind__c,
                PMP_Company_Lifecycle_Status_Nm__c
                FROM PMP_Company__c
                WHERE Id = :partnerId
                LIMIT 1
            ];
            
            String workCopyId;
            
            if (
                partner.PMP_Is_Published_Ind__c &&
                String.isNotBlank(partner.PMP_Working_Copy_Id__c)
            ) {
                workCopyId = partner.PMP_Working_Copy_Id__c;
            }
            else if (partner.PMP_Is_Working_Copy_Ind__c) {
                workCopyId = partner.Id;
            }
            
            if (String.isBlank(workCopyId)) {
                return formData;
            }
            
            partner = [
                SELECT Id,
                Name,
                PMP_Account_Tag_Line__c,
                PMP_Account_Dsc__c,
                PMP_Company_Status_Update_Dt__c,
                LastModifiedById,
                PMP_Intel_Admin_Id__c,
                PMP_Intel_Admin_Nm__c,
                PMP_Account_Industry__c,
                PMP_Account_Application__c,
                PMP_Account_Region__c,
                PMP_Company_Information_Language_Nm__c,
                LastModifiedDate,
                PMP_Account_Website__c,
                PMP_Partner_Benefit_Type__c,
                PMP_Partner_Program_nm__c,
                PMP_Partner_Segment_Nm__c,
                PMP_Company_Lifecycle_Status_Nm__c,
                PMP_Is_Published_Ind__c,
                PMP_Is_Working_Copy_Ind__c,
                PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                PMP_Partner_Zipcode_Txt__c,
                PMP_Partner_State_Txt__c,
                PMP_Partner_Secondary_Street_Txt__c,
                PMP_Partner_Primary_Street_Txt__c,
                PMP_Partner_Country_Txt__c,
                PMP_Partner_City_Txt__c
                FROM PMP_Company__c
                WHERE Id = :workCopyId
                LIMIT 1
            ];
            
            partnerId = partner.Id;
            
            formData.isPublishedCopyDraft =
                partner.PMP_Published_Copy_Id__r != null
                &&
                partner.PMP_Published_Copy_Id__r
                .PMP_Company_Lifecycle_Status_Nm__c
                == 'Draft';
            
            formData.isDistributor =
                String.isNotBlank(partner.PMP_Partner_Program_nm__c)
                &&
                partner.PMP_Partner_Program_nm__c
                .contains('Distributor');
            
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
            
            // Step 1
            getLogo(formData, partner);
            
            // Step 2
            getCompDesc(formData, partner);
            
            // Step 3
            fetchRegion(partner.Id, formData, langCode);
            
            formData.industryOptions =
                PMP_SearchUtilityController.getCategoryTree(
                    PMP_StaticConstants_Partner.PIM_INDUSTRY_ID,
                    true,
                    langCode
                );
            
            formData.industriesSelected =
                fetchCatsSelected(
                    partner.Id,
                    PMP_StaticConstants_Partner.PIM_INDUSTRY_ID
                );
            
            formData.applicationOptions =
                PMP_SearchUtilityController.getCategoryTree(
                    PMP_StaticConstants_Partner.PIM_APPLICATION_ID,
                    true,
                    langCode
                );
            
            formData.applicationsSelected =
                fetchCatsSelected(
                    partner.Id,
                    PMP_StaticConstants_Partner.PIM_APPLICATION_ID
                );
            
            // Step 4
            getResources(formData, partner);
            
            // Step 5
            if (PMP_SearchUtilityController.isIntelAdmin()) {
                
                // Replaced static variable mutation
                loggedInPartnerUser = false;
                
                getAdminDetails(
                    formData,
                    partner
                );
            }
            
            formData.currentStatus =
                partner.PMP_Company_Lifecycle_Status_Nm__c;
            
            getPartnerNames(
                formData,
                partner
            );
            
        }
        catch(Exception e){
            
            PMP_Utility.logError(
                e,
                'PMP_SearchEditStoreFrontController-getPartnerExistingData'
            );
        }
        
        return formData;
    }
    @AuraEnabled
    public static Boolean saveEditFormData(Id partnerId, String requestJSON) {
        
        try {
            
            FormDataSaveRequest saveRequest =
                (FormDataSaveRequest) JSON.deserialize(
                    requestJSON,
                    FormDataSaveRequest.class
                );
            
            Boolean firstTimeUpdate = false;
            Boolean isIntelAdmin = PMP_SearchUtilityController.isIntelAdmin();
            
            PMP_Company__c partner = [
                SELECT Id,
                PMP_Working_Copy_Id__c,
                PMP_Is_Published_Ind__c,
                PMP_Is_Working_Copy_Ind__c,
                PMP_Partner_Submitter_UserId__c
                FROM PMP_Company__c
                WHERE Id = :partnerId
            
            ];
            
            String workCopyId;
            
            if (
                partner.PMP_Is_Published_Ind__c &&
                String.isNotBlank(partner.PMP_Working_Copy_Id__c)
            ) {
                workCopyId = partner.PMP_Working_Copy_Id__c;
            } else if (partner.PMP_Is_Working_Copy_Ind__c) {
                workCopyId = partner.Id;
            }
            
            if (String.isBlank(workCopyId)) {
                return false;
            }
            
            partner = [
                SELECT Id,
                Name,
                toLabel(PMP_Company_Information_Language_Nm__c),
                PMP_Account_Dsc__c,
                PMP_Partner_Submitter_UserId__c,
                PMP_Account_Industry__c,
                PMP_Account_Application__c,
                PMP_Working_Copy_Id__c,
                PMP_Is_Published_Ind__c,
                LastModifiedDate,
                PMP_Account_Region__c,
                PMP_Account_Tag_Line__c,
                PMP_Company_Resource__c,
                PMP_Company_Lifecycle_Status_Nm__c,
                PMP_Is_Updated_Ind__c,
                PMP_Translation_Lifecycle_Status_nm__c,
                PMP_Partner_Program_nm__c,
                PMP_Partner_Segment_Nm__c
                FROM PMP_Company__c
                WHERE Id = :workCopyId
                LIMIT 1
            ];
            
            partnerId = partner.Id;
            
            /* Partner Details */
            
            if (saveRequest.partner != null) {
                
                if (String.isNotBlank(saveRequest.partner.name)) {
                    partner.Name = saveRequest.partner.name;
                }
                
                partner.PMP_Account_Website__c = saveRequest.partner.website;
                partner.PMP_Partner_Primary_Street_Txt__c = saveRequest.partner.primaryStreet;
                partner.PMP_Partner_Secondary_Street_Txt__c = saveRequest.partner.secondaryStreet;
                partner.PMP_Partner_City_Txt__c = saveRequest.partner.city;
                partner.PMP_Partner_Country_Txt__c = saveRequest.partner.country;
                partner.PMP_Partner_State_Txt__c = saveRequest.partner.state;
                partner.PMP_Partner_Zipcode_Txt__c = saveRequest.partner.postalCode;
                
                if (Schema.sObjectType.PMP_Company_Translation__c.isAccessible()) {
                    
                    List<PMP_Company_Translation__c> translations = [
                        SELECT Id, Name
                        FROM PMP_Company_Translation__c
                        WHERE PMP_Company_Information_Id__c = :partner.Id
                    ];
                    
                    for (PMP_Company_Translation__c ct : translations) {
                        ct.Name = saveRequest.partner.name;
                    }
                    
                    if (
                        Schema.sObjectType.PMP_Company_Translation__c.isUpdateable()
                        && !translations.isEmpty()
                    ) {
                        update translations;
                    }
                }
            }
            
            /* Status Processing */
            
            if (
                partner.PMP_Company_Lifecycle_Status_Nm__c ==
                PMP_StaticConstants_Partner.Update_Required
            ) {
                
                partner.PMP_Is_Updated_Ind__c = true;
                
            } else if (
                partner.PMP_Company_Lifecycle_Status_Nm__c ==
                PMP_StaticConstants_Partner.Approved
                ||
                partner.PMP_Company_Lifecycle_Status_Nm__c ==
                PMP_StaticConstants_Partner.Draft
                ||
                partner.PMP_Company_Lifecycle_Status_Nm__c ==
                PMP_StaticConstants_Partner.Rejected
            ) {
                
                firstTimeUpdate = true;
                partner.PMP_Initial_Storefront_Submit_Date_Dt__c =
                    partner.LastModifiedDate.date();
                
                partner.PMP_Is_Updated_Ind__c = false;
            }
            
            /* Published Copy */
            
            List<PMP_Company__c> publishedCopies = [
                SELECT Id
                FROM PMP_Company__c
                WHERE PMP_Working_Copy_Id__c = :partner.Id
                LIMIT 1
            ];
            
            if (!publishedCopies.isEmpty()) {
                partner.PMP_Published_Copy_Id__c =
                    publishedCopies[0].Id;
            }
            
            /* Submitter */
            
            if (!isIntelAdmin) {
                
                partner.PMP_Company_Lifecycle_Status_Nm__c =
                    PMP_StaticConstants_Partner.Admin_Review;
                
                partner.PMP_Partner_Submitter_UserId__c =
                    UserInfo.getUserId();
            }
            
            if (partner.PMP_Partner_Submitter_UserId__c == null) {
                partner.PMP_Partner_Submitter_UserId__c =
                    UserInfo.getUserId();
            }
            
            /* Step 1 - Logo */
            
            updateLogo(saveRequest, partner);
            
            /* Step 2 - Description */
            
            if (saveRequest.descriptionData != null) {
                
                partner.PMP_Company_Information_Language_Nm__c =
                    saveRequest.descriptionData.language;
                
                String tagline =
                    saveRequest.descriptionData.tagline;
                
                String description =
                    saveRequest.descriptionData.description;
                
                String language = isIntelAdmin
                    ? PMP_StaticConstants_Partner.English
                    : saveRequest.descriptionData.language;
                
                updateTranslationRecords(
                    partner.Id,
                    partner.Name,
                    language,
                    tagline,
                    description
                );
                
                if (checkTransEnabled(
                    partner.PMP_Partner_Segment_Nm__c
                )) {
                    
                    partner.PMP_Translation_Lifecycle_Status_nm__c =
                        PMP_StaticConstants_Partner.Pending;
                    
                    partner.PMP_Translated_Languages_Txt__c =
                        partner.PMP_Company_Information_Language_Nm__c;
                }
                
                partner.PMP_Account_Dsc__c = description;
                partner.PMP_Account_Tag_Line__c = tagline;
            }
            
            /* Step 3 - Region */
            
            saveRegion(
                partner.Id,
                saveRequest.regionsSelected
            );
            
            /* Step 4 - Resources */
            
            updateResources(
                saveRequest,
                partner
            );
            
            /* Step 5 - Industry */
            
            savePartnerCategory(
                partner.Id,
                saveRequest.industriesSelected,
                PMP_StaticConstants_Partner.PIM_INDUSTRY_ID
            );
            
            /* Step 6 - Application */
            
            savePartnerCategory(
                partner.Id,
                saveRequest.applicationsSelected,
                PMP_StaticConstants_Partner.PIM_APPLICATION_ID
            );
            
            /* Final Update */
            
            if (Schema.sObjectType.PMP_Company__c.isUpdateable()) {
                
                update partner;
                
                // Intentionally retained to preserve existing behavior.
                if (firstTimeUpdate) {
                    
                    PMP_Company__c updatedPartner = [
                        SELECT LastModifiedDate
                        FROM PMP_Company__c
                        WHERE Id = :partner.Id
                    
                    ];
                    
                    partner.PMP_Initial_Storefront_Submit_Date_Dt__c =
                        updatedPartner.LastModifiedDate.date();
                    
                    update partner;
                }
            }
            
            return true;
            
        } catch (Exception e) {
            
            PMP_Utility.logError(
                e,
                'PMP_SearchEditStoreFrontController-saveEditFormData'
            );
            
            if (
                e.getMessage() != null &&
                e.getMessage().contains(
                    'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                )
            ) {
                
                throw new AuraHandledException(
                    e.getMessage()
                    .substringAfter(
                        'FIELD_CUSTOM_VALIDATION_EXCEPTION,'
                    )
                    .substringBefore(':')
                );
            }
            
            throw new AuraHandledException(
                e.getMessage()
            );
        }
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
    public static void updateLogo(FormDataSaveRequest saveRequest, PMP_Company__c partner){
        try {
            
            List<PMP_Company_Resource__c> workingPartnerImageResExisting = [
                SELECT Id
                FROM PMP_Company_Resource__c
                WHERE PMP_Company_Id__c = :partner.Id
                AND PMP_Company_Resource_Type_Nm__c IN (
                    :PMP_StaticConstants_partner.IMAGE,
                    :PMP_StaticConstants_partner.THUMBNAIL_IMAGE
                )
            ];
            
            if(!workingPartnerImageResExisting.isEmpty()){
                Database.DeleteResult[] wpResList =
                    Database.delete(workingPartnerImageResExisting, false);
                
                PMP_Utility.logDmlErrors(
                    (Object[]) wpResList,
                    'PMP_SearchEditStoreFrontController-updateLogo'
                );
            }
            
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :partner.Id
            ];
            
            List<Id> linkIds = new List<Id>();
            
            for(ContentDocumentLink l : links){
                linkIds.add(l.ContentDocumentId);
            }
            
            List<ContentVersion> versions = new List<ContentVersion>();
            
            if(!linkIds.isEmpty()){
                versions = [
                    SELECT Title, ContentDocumentId
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :linkIds
                    AND IsLatest = true
                ];
            }
            
            List<PMP_Company_Resource__c> workingPartnerImageResToSave =
                new List<PMP_Company_Resource__c>();
            
            for(ContentVersion ver : versions){
                
                PMP_Company_Resource__c res = new PMP_Company_Resource__c();
                
                res.PMP_Company_Id__c = partner.Id;
                res.PMP_Company_Image__c = ver.ContentDocumentId;
                res.Name = ver.Title.length() > 80
                    ? ver.Title.substring(0,80)
                    : ver.Title;
                res.PMP_Company_Resource_Sequence_Nbr__c = 0;
                res.PMP_Company_Resource_Type_Nm__c =
                    PMP_StaticConstants_partner.IMAGE;
                
                workingPartnerImageResToSave.add(res);
            }
            
            if(!workingPartnerImageResToSave.isEmpty()){
                
                Database.SaveResult[] wpImageList =
                    Database.insert(workingPartnerImageResToSave, false);
                
                PMP_Utility.logDmlErrors(
                    (Object[]) wpImageList,
                    'PMP_SearchEditStoreFrontController-updateLogo'
                );
            }
            
            PMP_Image_Resizing.generateThumbnailImages(partner.Id);
            
        }catch(Exception e){
            PMP_Utility.logError(
                e,
                'PMP_SearchEditStoreFrontController-updateLogo'
            );
        }
    }
    //Step-2 Method to get Company Description
    public static void getCompDesc(FormData formData , PMP_Company__c partner/*, String langCode*/){
        try{
            //Commented for TranslationEOL 
            //String userLanguage;
            String description = '';
            String tagline = '';
            String status = partner.PMP_Company_Lifecycle_Status_Nm__c;
            
            //Code to set user language if status is Approved or Draft then consider user locale else language selected while edit storefront changes
            //Commented for TranslationEOL 
            /*if(status == PMP_StaticConstants_Partner.Approved || status == PMP_StaticConstants_Partner.Draft){
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

*/
            DescriptionData descData = new DescriptionData();
            descData.description = partner.PMP_Account_Dsc__c != null ? partner.PMP_Account_Dsc__c : '';
            descData.tagline = partner.PMP_Account_Tag_Line__c != null ? partner.PMP_Account_Tag_Line__c : '';
            descData.language = PMP_StaticConstants_Partner.English; //userLanguage;    // 
            
            //Code to fetch available Language Options
            //Commented for TranslationEOL 
            /*String partnerSegment = [SELECT PMP_Partner_Program_nm__c,PMP_Partner_Segment_Nm__c FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c =:partner.Id LIMIT 1].PMP_Partner_Segment_Nm__c;
Boolean transEnabled = checkTransEnabled(partnerSegment); //check translation status for Partner segment

if(transEnabled){
descData.language = userLanguage;
}else{
descData.language = PMP_StaticConstants_Partner.English;
} */
            
            //system.debug('transEnabled ' + transEnabled);
            descData.languageOptions = new List<Options>();
            //Commented for TranslationEOL 
            /*Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Company_Information_Language_Nm__c.getDescribe();      
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
}*/
            Options opt = new Options();
            opt.label = 'English';//pickListVal.getLabel();
            opt.value = 'English';//pickListVal.getValue();
            descData.languageOptions.add(opt);
            formData.descriptionData = descData;
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    public static void updateTranslationRecords(
        String partnerId,
        String partnerName,
        String language,
        String tagline,
        String description) {
            
            try {
                
                Boolean descUpdated = false;
                Boolean tagUpdated = false;
                
                String streamIdName =
                    PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
                
                List<PMP_Company_Translation__c> transList = [
                    SELECT Id,
                    PMP_Field_Nm__c,
                    PMP_English_Txt__c,
                    PMP_Chinese_Txt__c,
                    PMP_Japanese_Txt__c
                    FROM PMP_Company_Translation__c
                    WHERE PMP_Company_Information_Id__c = :partnerId
                    AND PMP_Field_Nm__c != :streamIdName
                ];
                
                Boolean isEnglish  = language == PMP_StaticConstants_Partner.English;
                Boolean isChinese  = language == PMP_StaticConstants_Partner.Chinese;
                Boolean isJapanese = language == PMP_StaticConstants_Partner.Japanese;
                
                for(PMP_Company_Translation__c trans : transList){
                    
                    String temp;
                    
                    if(trans.PMP_Field_Nm__c ==
                       PMP_StaticConstants_Partner.Description){
                           
                           temp = description;
                           descUpdated = true;
                       }
                    else if(trans.PMP_Field_Nm__c ==
                            PMP_StaticConstants_Partner.Tagline){
                                
                                temp = tagline;
                                tagUpdated = true;
                            }
                    else{
                        continue;
                    }
                    
                    if(isEnglish){
                        trans.PMP_English_Txt__c = temp;
                    }
                    else if(isChinese){
                        trans.PMP_Chinese_Txt__c = temp;
                    }
                    else if(isJapanese){
                        trans.PMP_Japanese_Txt__c = temp;
                    }
                }
                
                if(!descUpdated){
                    transList.add(
                        createTranslationRecords(
                            partnerId,
                            partnerName,
                            language,
                            PMP_StaticConstants_Partner.Description,
                            description
                        )
                    );
                }
                
                if(!tagUpdated){
                    transList.add(
                        createTranslationRecords(
                            partnerId,
                            partnerName,
                            language,
                            PMP_StaticConstants_Partner.Tagline,
                            tagline
                        )
                    );
                }
                
                if(!transList.isEmpty()
                   && Schema.sObjectType.PMP_Company_Translation__c.isCreateable()
                   && Schema.sObjectType.PMP_Company_Translation__c.isUpdateable()) {
                       
                       Database.UpsertResult[] trList =
                           Database.upsert(transList, false);
                       
                       PMP_Utility.logDmlErrors(
                           (Object[]) trList,
                           'PMP_SearchEditStoreFrontController-updateTranslationRecords'
                       );
                   }
                
            } catch(Exception e) {
                PMP_Utility.logError(
                    e,
                    'PMP_SearchEditStoreFrontController-updateTranslationRecords'
                );
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
            if(workingPartnerResourceListExisting.size()>0){
                //delete workingPartnerResourceListExisting;
                Database.DeleteResult[] wprList = Database.delete(workingPartnerResourceListExisting, false);
                PMP_Utility.logDmlErrors((Object[]) wprList, 'PMP_SearchEditStoreFrontController-updateResources');
            }
            
            for(Resource res : saveRequest.resources){
                PMP_Company_Resource__c resNew = new PMP_Company_Resource__c();
                resNew.Name = res.title;
                resNew.PMP_Company_Id__c = partner.Id;
                resNew.PMP_Company_Resource_Type_Nm__c = res.type;
                resNew.PMP_Company_Resource_URL_txt__c = res.url;
                
                workingPartnerResourceListToSave.add(resNew);
            }
            
            
            if(workingPartnerResourceListToSave.size()>0){
                //insert workingPartnerResourceListToSave;
                Database.SaveResult[] wpResList = Database.insert(workingPartnerResourceListToSave, false);
                PMP_Utility.logDmlErrors((Object[]) wpResList, 'PMP_SearchEditStoreFrontController-updateResources');
                
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
                //delete exRegList;
                Database.DeleteResult[] erList = Database.delete(exRegList, false);
                PMP_Utility.logDmlErrors((Object[]) erList, 'PMP_SearchEditStoreFrontController-saveRegion');
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
                //insert compRegList;
                Database.SaveResult[] cRList = Database.insert(compRegList, false);
                PMP_Utility.logDmlErrors((Object[]) cRList, 'PMP_SearchEditStoreFrontController-saveRegion');
                
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
                //delete exCatList;
                Database.DeleteResult[] exCList = Database.delete(exCatList, false);
                PMP_Utility.logDmlErrors((Object[]) exCList, 'PMP_SearchEditStoreFrontController-savePartnerCategory');
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
                    //insert catList;
                    Database.SaveResult[] cList = Database.insert(catList, false);
                    PMP_Utility.logDmlErrors((Object[]) cList, 'PMP_SearchEditStoreFrontController-savePartnerCategory');
                    
                }   
            }
            
        }catch(Exception e){
            //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    public static void getAdminDetails(FormData formData, PMP_Company__c partner){
        try{
            
            User user = [
                SELECT Name
                FROM User
                WHERE Id = :partner.LastModifiedById
            ];
            
            formData.submittedBy = user.Name;
            formData.submittedOn = partner.LastModifiedDate.format('MMM-dd-yyyy');
            
            if(partner.PMP_Intel_Admin_Id__c != null){
                formData.admin = partner.PMP_Intel_Admin_Nm__c;
            }else{
                formData.admin = UserInfo.getName();
            }
            
            formData.adminList = new List<Options>();
            
            List<Group> groups = [
                SELECT Id
                FROM Group
                WHERE DeveloperName = :PMP_StaticConstants_Partner.IPA_INTERNAL_ADMIN
                LIMIT 1
            ];
            
            if(!groups.isEmpty()){
                
                List<GroupMember> groupMembers = [
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE GroupId = :groups[0].Id
                ];
                
                Set<Id> userIds = new Set<Id>();
                
                for(GroupMember groupMember : groupMembers){
                    userIds.add(groupMember.UserOrGroupId);
                }
                
                if(!userIds.isEmpty()){
                    
                    List<User> admins = [
                        SELECT Id, Name
                        FROM User
                        WHERE Id IN :userIds
                    ];
                    
                    for(User admin : admins){
                        Options opt = new Options();
                        opt.label = admin.Name;
                        opt.value = admin.Name;
                        formData.adminList.add(opt);
                    }
                }
            }
            
            formData.statusList = new List<Options>();
            
            for(Schema.PicklistEntry pickListVal :
                PMP_Company__c.PMP_Company_Lifecycle_Status_Nm__c
                .getDescribe()
                .getPicklistValues()){
                    
                    if(pickListVal.getValue() != PMP_StaticConstants_Partner.Draft &&
                       pickListVal.getValue() != PMP_StaticConstants_Partner.Published){
                           
                           Options opt = new Options();
                           opt.label = pickListVal.getLabel();
                           opt.value = pickListVal.getValue();
                           
                           formData.statusList.add(opt);
                       }
                }
            
        }catch(Exception e){
            PMP_Utility.logError(
                e,
                'PMP_SearchEditStoreFrontController-getAdminDetails'
            );
        }
    }
    @AuraEnabled
    public static Boolean updateStatusAdmin(Id partnerId, String requestJSON){
        
        try{
            
            FormDataSaveRequest saveRequest =
                (FormDataSaveRequest)JSON.deserialize(
                    requestJSON,
                    FormDataSaveRequest.class
                );
            
            PMP_Company__c partner = [
                SELECT Id,
                PMP_Working_Copy_Id__c,
                PMP_Is_Published_Ind__c,
                PMP_Is_Working_Copy_Ind__c
                FROM PMP_Company__c
                WHERE Id = :partnerId
                
            ];
            
            String workCopyId;
            
            if(partner.PMP_Is_Published_Ind__c &&
               String.isNotBlank(partner.PMP_Working_Copy_Id__c)) {
                   
                   workCopyId = partner.PMP_Working_Copy_Id__c;
                   
               } else if(partner.PMP_Is_Working_Copy_Ind__c) {
                   
                   workCopyId = partner.Id;
               }
            
            if(String.isBlank(workCopyId)){
                return false;
            }
            
            partner = new PMP_Company__c(
                Id = workCopyId
            );
            
            List<PermissionSetAssignment> psa = [
                SELECT AssigneeId
                FROM PermissionSetAssignment
                WHERE Assignee.Name = :saveRequest.admin
                AND PermissionSet.Name = :PMP_StaticConstants_Partner.INTEL_ADMIN
                LIMIT 1
            ];
            
            partner.PMP_Intel_Admin_Id__c =
                !psa.isEmpty() ? psa[0].AssigneeId : null;
            
            partner.PMP_Company_Lifecycle_Status_Nm__c =
                saveRequest.status;
            
            update partner;
            
            return true;
            
        }catch(Exception e){
            
            PMP_Utility.logError(
                e,
                'PMP_SearchEditStoreFrontController-updateStatusAdmin'
            );
            
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Boolean checkTransEnabled(String partnerSegment){ //ISA replaced with IOT Partner Segment as part of US704420
        Boolean transEnabled = false;
        
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
    public static void getPartnerNames(FormData formData, PMP_Company__c partner){
        
        Map<String, PartnerWrapper> webaddwrap = new Map<String, PartnerWrapper>();
        List<Options> opts = new List<Options>();
        
        List<Id> opids = new List<Id>();
        
        List<PMP_OPID_MPI_Rel__c> junctionObjects =
            PMP_Utility.getJunctionAccToMpiByCompanyId(partner.Id);
        
        for(PMP_OPID_MPI_Rel__c juncRec : junctionObjects){
            opids.add(juncRec.PMP_One_Partner_ID__c);
        }
        
        if(opids.isEmpty() && partner.PMP_Published_Copy_Id__r != null){
            
            List<PMP_OPID_MPI_Rel__c> junctionObjsPublRec =
                PMP_Utility.getJunctionAccToMpiByCompanyId(
                    partner.PMP_Published_Copy_Id__r.Id
                );
            
            for(PMP_OPID_MPI_Rel__c juncRec : junctionObjsPublRec){
                opids.add(juncRec.PMP_One_Partner_ID__c);
            }
        }
        
        if(!opids.isEmpty()){
            
            User partnerUser;
            
            if(loggedInPartnerUser){
                partnerUser = [
                    SELECT Id, Account.Id
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    
                ];
            }
            
            Options opt1 = new Options();
            opt1.label = partner.Name;
            opt1.value = partner.Name;
            opts.add(opt1);
            
            List<Core_Account_Group_Member__c> agmList = [
                SELECT Id,
                Core_Partner_Account_Id__r.Name,
                Core_Intel_Account_Id__r.Name,
                Core_Intel_Account_Id__c,
                Primary_Account__c
                FROM Core_Account_Group_Member__c
                WHERE Core_Partner_Account_Id__c IN :opids
                AND Core_Inactive_Ind__c = FALSE
                AND Primary_Account__c = TRUE
                LIMIT 1
            ];
            
            if(!agmList.isEmpty()){
                
                Core_Account_Group_Member__c agm = agmList[0];
                
                if(loggedInPartnerUser &&
                   partnerUser != null &&
                   partnerUser.Account != null &&
                   partnerUser.Account.Id == agm.Core_Intel_Account_Id__c){
                       
                       Options relatedLocationOpt = new Options();
                       relatedLocationOpt.label = agm.Core_Intel_Account_Id__r.Name;
                       relatedLocationOpt.value = agm.Core_Intel_Account_Id__r.Name;
                       
                       if(agm.Core_Intel_Account_Id__r.Name != partner.Name){
                           opts.add(relatedLocationOpt);
                       }
                   }
                
                List<Account> accList = [
                    SELECT Id,
                    Name,
                    Core_User_Defined_Website__c,
                    BillingStreet,
                    BillingCity,
                    toLabel(BillingStateCode) BillingState,
                    BillingPostalCode,
                    toLabel(BillingCountryCode) BillingCountry
                    FROM Account
                    WHERE Id = :agm.Core_Intel_Account_Id__c
                    LIMIT 1
                ];
                
                if(!accList.isEmpty()){
                    
                    Account acc = accList[0];
                    
                    PartnerWrapper part = new PartnerWrapper();
                    part.name = acc.Name;
                    part.website = acc.Core_User_Defined_Website__c;
                    part.primaryStreet = acc.BillingStreet;
                    part.city = acc.BillingCity;
                    part.country = (String)acc.get('BillingCountry');
                    part.state = (String)acc.get('BillingState');
                    part.postalCode = acc.BillingPostalCode;
                    
                    webaddwrap.put(acc.Name, part);
                }
            }
            
        } else {
            
            // Removed unnecessary Company SOQL
            Options opt = new Options();
            opt.label = partner.Name;
            opt.value = partner.Name;
            opts.add(opt);
        }
        
        formData.partnerNames = opts;
        formData.webaddwrap = webaddwrap;
    }
    @AuraEnabled(cacheable = true)
    public static List<Option> getDependentMap() {
        return PMP_SearchCountryStateMapping.getDependentMap();
    }  
    
}