public with sharing class PMP_SearchEditStoreFrontController extends PMP_SearchWrapperStore{
    
    Static String image = '';
    
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
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
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
            system.debug('Error in fetching company record : '+ e.getMessage());
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
                        partner = [SELECT Id, Name,PMP_Account_Tag_Line__c, PMP_Account_Dsc__c,PMP_Company_Status_Update_Dt__c,LastModifiedById,PMP_Intel_Admin_Id__c,PMP_Intel_Admin_Nm__c,
                                   PMP_Account_Industry__c, PMP_Account_Application__c, PMP_Account_Region__c,PMP_Company_Information_Language_Nm__c,LastModifiedDate,
                                   PMP_Partner_Program_nm__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c, PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c
                                   from PMP_Company__c WHERE Id =: workCopyId LIMIT 1];
                        partnerId = partner.Id;
                    }else{
                        return formData;
                    }
               // }
                formData.isPublishedCopyDraft = partner.PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c == 'Draft';
                
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
                    getAdminDetails(formData,partner);
                } 
                formData.currentStatus = partner.PMP_Company_Lifecycle_Status_Nm__c;
                system.debug('130'+formData.currentStatus);
            }
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());

        }
        system.debug('FormData : '+formData);
        return formData;
    }
    
    @AuraEnabled
    public static Boolean saveEditFormData(Id partnerId, String requestJSON ){
        Boolean firstTimeUpdate = false;
        try{
            FormDataSaveRequest saveRequest = new FormDataSaveRequest();
            
            saveRequest = (FormDataSaveRequest)JSON.deserialize(requestJSON, FormDataSaveRequest.class);          
            
            PMP_Company__c partner = new PMP_Company__c();
            
            partner = [SELECT PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c FROM PMP_Company__c WHERE Id =:partnerId];
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
                           PMP_Account_Region__c,PMP_Account_Tag_Line__c,PMP_Company_Resource__c,PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Updated_Ind__c,
                           PMP_Translation_Lifecycle_Status_nm__c,  PMP_Partner_Program_nm__c
                           from PMP_Company__c WHERE id =: workCopyId LIMIT 1 ];
                partnerId = partner.Id;
            }else{
                return false;
            }
            
            if (partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Update_Required)
            {
                partner.PMP_Is_Updated_Ind__c = true;
            }
            else if (partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Approved || partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Draft )
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
                system.debug('userInfo 203=> '+UserInfo.getUserName());
                partner.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Admin_Review;
                
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
            if(checkTransEnabled(partner.PMP_Partner_Program_nm__c)){
                partner.PMP_Translation_Lifecycle_Status_nm__c = PMP_StaticConstants_Partner.Pending;    
                partner.PMP_Translated_Languages_Txt__c='';
                partner.PMP_Translated_Languages_Txt__c=partner.PMP_Company_Information_Language_Nm__c;                
            }    
                      
            //Step-3 Application,Industry and Region                        
            saveRegion(partner.Id, saveRequest.regionsSelected);
            
            //Step-4 Resource
            updateResources(saveRequest, partner);
            
            //Step-5 Industry
            savePartnerCategory(partner.Id, saveRequest.industriesSelected, PMP_StaticConstants_Partner.PIM_INDUSTRY_ID);
            
            //Step- 6 Application
            savePartnerCategory(partner.Id, saveRequest.applicationsSelected, PMP_StaticConstants_Partner.PIM_APPLICATION_ID);
            
            if(Schema.sObjectType.PMP_Company__c.isUpdateable()){
                system.debug('partner => '+partner);
                update partner;
                if(firstTimeUpdate){
                    PMP_Company__c updatedPartner = [SELECT LastModifiedDate FROM PMP_Company__c WHERE Id =: partner.Id];
                    partner.PMP_Initial_Storefront_Submit_Date_Dt__c = updatedPartner.LastModifiedDate.date();
                    update partner;
                }
            }
            
        }catch(Exception e){
            System.debug('Error while updating company records :' + e.getMessage());
            
        }
        return true;
    }
    
    
    //Step-1 Method to get existing Logo 
    public static void getLogo(FormData formData , PMP_Company__c partner){
        try{
            formData.workingCopyId = partner.Id;
            formData.logo = new ImageWrapper();
            formData.logoCheck = false;
            image = MarketplaceImageUploader.getImages(partner.Id);
            
            if(!String.isEmpty(image)){
                formData.logoCheck = true;
            }
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    //Step-1 Method to update Logo
    public static void updateLogo(FormDataSaveRequest saveRequest, PMP_Company__c partner){
        try{
            List<PMP_Company_Resource__c> workingPartnerImageResExisting = new List<PMP_Company_Resource__c>();
            List<PMP_Company_Resource__c> workingPartnerImageResToSave = new List<PMP_Company_Resource__c>();
            
            //if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible() && Schema.sObjectType.PMP_Company_Resource__c.isDeletable()){
            workingPartnerImageResExisting = [SELECT id, Name from PMP_Company_Resource__c where PMP_Company_Id__c =:partner.Id 
                                              AND (PMP_Company_Resource_Type_Nm__c =: PMP_StaticConstants_partner.IMAGE OR PMP_Company_Resource_Type_Nm__c =: PMP_StaticConstants_partner.THUMBNAIL_IMAGE)];
            
            if(!workingPartnerImageResExisting.isEmpty()){
                delete workingPartnerImageResExisting;
                system.debug('deleted');
            }
            
            //}
                                
            
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            
            links = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: partner.Id];
            
            
            List<String> linkIds = new List<String>();
            for (ContentDocumentLink l : links) {
                linkIds.add(l.ContentDocumentId);
            }
            List<ContentVersion> versions = new List<ContentVersion>();
            
            
            versions = [SELECT Id, Title, FileExtension, ContentSize, ContentDocumentId, VersionData, OwnerId FROM ContentVersion WHERE ContentDocumentId IN :linkIds AND IsLatest = true];
            system.debug('version accessed');           
            
            system.debug('Versions ' + versions);
            for(ContentVersion ver : versions){
                
                PMP_Company_Resource__c res = new PMP_Company_Resource__c();
                res.PMP_Company_Id__c = partner.Id;
                res.PMP_Company_Image__c = ver.ContentDocumentId;
                //res.Name = 'logo'; // Uday: commented to pass actual name
                res.Name = ver.Title;
                res.PMP_Company_Resource_Sequence_Nbr__c = 0;
                res.PMP_Company_Resource_Type_Nm__c = PMP_StaticConstants_partner.IMAGE;
                workingPartnerImageResToSave.add(res);                                           
            }
            
            
            if(!workingPartnerImageResToSave.isEmpty()){
                
                insert workingPartnerImageResToSave;
                system.debug('res created');
            }
            
            
            PMP_Image_Resizing.generateThumbnailImages(partner.Id); // Uday:for resizing the image                
            
            
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
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
           // if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
                transList = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c,
                             PMP_Chinese_Txt__c, PMP_Japanese_Txt__c from PMP_Company_Translation__c 
                             where PMP_Company_Information_Id__c = :partner.Id];
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
            String partnerProgram = [SELECT PMP_Partner_Program_nm__c FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c =:partner.Id LIMIT 1].PMP_Partner_Program_nm__c;
            Boolean transEnabled = checkTransEnabled(partnerProgram); //check translation status
            if(transEnabled){
                descData.language = userLanguage;
            }else{
                descData.language = PMP_StaticConstants_Partner.English;
            } 
            
            system.debug('transEnabled ' + transEnabled);
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
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    //Step-2 Method to Update Company Translation Records
    public static void updateTranslationRecords(String partnerId, String partnerName ,String language ,String tagline, String description){
        try{
            String temp;
            Boolean descUpdated = false;
            Boolean tagUpdated = false;
            List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
            if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
                transList = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c,
                             PMP_Chinese_Txt__c, PMP_Japanese_Txt__c from PMP_Company_Translation__c 
                             where PMP_Company_Information_Id__c = :partnerId];
            }
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
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());

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
            List<PMP_Company_Resource__c> resourceList = [SELECT Id, Name, PMP_Company_Resource_URL_txt__c, PMP_Company_Resource_Type_Nm__c from PMP_Company_Resource__c where 
                                                          PMP_Company_Id__c =: partner.Id AND 
                                                          PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.IMAGE AND PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.THUMBNAIL_IMAGE]; 
            //AND PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.THUMBNAIL_IMAGE];
            
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
                    option.value = pickListVal.getLabel();            
                    
                    resOptions.add(option);}
            }
            ResourceData resData = new ResourceData();
            resData.resourceTypes = resOptions;
            resData.resources = resources;
            
            formData.resourceData = new ResourceData();
            formData.resourceData = resData;
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        } 
    }
    
    //Step-4 Method to update Resources
    public static void updateResources(FormDataSaveRequest saveRequest, PMP_Company__c partner){
        try{
            List<PMP_Company_Resource__c> workingPartnerResourceListExisting = new List<PMP_Company_Resource__c>();
            List<PMP_Company_Resource__c> workingPartnerResourceListToSave = new List<PMP_Company_Resource__c>();
            
            
            workingPartnerResourceListExisting = [SELECT id, Name from PMP_Company_Resource__c where PMP_Company_Id__c =: partner.Id and (PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.IMAGE AND PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Offering.THUMBNAIL_IMAGE) ];
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
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    
    public static void fetchRegion(String partnerId, FormData formData, String langCode){
        try{
            List<Option> regionOptions = new List<Option>();
            List<PMP_Specification__c> specList = new List<PMP_Specification__c>();
            
            
            String pimId = PMP_StaticConstants_Partner.REGION_PIM_ID;
            String ansPimId = pimId + '%';
            Map<String,Option> specOptMap = new Map<String,Option>();
            
            
                specList = [SELECT Id, Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c,PMP_Product_Parent_Specification_Id__c,PMP_Parent_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Ancestor_Specification_Cd__c  LIKE :ansPimId AND PMP_Active_Ind__c = TRUE ORDER BY Name];
                
            
            
            List<String> regIdList = new List<String>();
            for (PMP_Specification__c spec:specList)
            {
                Option opt = new Option();
                opt.label = PMP_SearchUtilityController.getLocalisedName(spec, '', langCode);
                opt.value = spec.Id;
                
                opt.children = new List<Option>();
                
                specOptMap.put(spec.id,opt);
                if( spec.PMP_Product_Parent_Specification_Id__c == pimId){
                    if(!regionOptions.contains(opt)){
                        regionOptions.add(opt);
                    } 
                }
                
            }
            for (PMP_Specification__c spec:specList)
            {                
                if (specOptMap.containsKey(spec.PMP_Parent_Specification_Id__c)){
                    specOptMap.get(spec.PMP_Parent_Specification_Id__c).children.add(specOptMap.get(spec.Id));
                }
            }
            
            List<String> regionsSelected = new List<String>();
            List<PMP_Company_Region__c> selRegList = [SELECT PMP_Specification_Id__c FROM PMP_Company_Region__c WHERE PMP_Company_Id__c =: partnerId];
            
            for(PMP_Company_Region__c reg: selRegList){
                regionsSelected.add(reg.PMP_Specification_Id__c);
            }
            
            formData.regionOptions = regionOptions;
            formData.regionsSelected = regionsSelected;
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    public static void saveRegion(String partnerId, List<String> specIds){
        try{
            List<PMP_Company_Region__c> compRegList = new List<PMP_Company_Region__c>();
            List<PMP_Company_Region__c> exRegList = [SELECT Id FROM PMP_Company_Region__c WHERE PMP_Company_Id__c =: partnerId];
            if(!exRegList.isEmpty()){
                //if(Schema.sObjectType.PMP_Company_Region__c.isDeletable()){
                delete exRegList;
                //}
                
            }
            
            for(String spec: specIds){
                PMP_Company_Region__c compReg = new PMP_Company_Region__c();
                compReg.PMP_Company_Id__c = partnerId;
                compReg.PMP_Specification_Id__c = spec;
                compRegList.add(compReg);
            }
            insert compRegList;
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
        }
    }
    
    
    public static List<String> fetchCatsSelected(String partnerId, String pimId){
        List<String> catsSelected = new List<String>();
        List<PMP_Partner_Category__c> partnerCatList = new List<PMP_Partner_Category__c>();
        try{
            String ansPimId = pimId + '%';
            if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){
                partnerCatList = [SELECT Id, PMP_Category_Id__c FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c =: partnerId 
                                  AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
                                  AND PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c like :ansPimId];
                
            }
            for(PMP_Partner_Category__c partnerCat: partnerCatList){
                catsSelected.add(partnerCat.PMP_Category_Id__c);
            }
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
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
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
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
            
            if(Schema.sObjectType.Group.isAccessible() && Schema.sObjectType.GroupMember.isAccessible()){
                grp=[SELECT Id FROM Group where Name=: PMP_StaticConstants_Partner.IPA_INTERNAL_ADMIN LIMIT 1];
                groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id]; 
                
            }
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
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
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
        User user  = [SELECT Id FROM User WHERE Name=:saveRequest.admin];
        partner.PMP_Intel_Admin_Id__c = user.Id;
        
        system.debug('userInfo 199=> '+UserInfo.getUserName()+' saveRequest => '+saveRequest.status);
        partner.PMP_Company_Lifecycle_Status_Nm__c = saveRequest.status;
        system.debug('768'+partner.PMP_Company_Lifecycle_Status_Nm__c);
        update partner;
              
        return true;  
    }
    
    //Method to check if translation is Enabled for Partner Program by NIKHIL
    public static Boolean checkTransEnabled(String partnerProgram){ //ISA;CIP
        Boolean transEnabled = false;
        List<PMP_SearchPartnerProgram_Config__mdt> transEnablePP = [SELECT PMP_Partner_Program_value__c FROM PMP_SearchPartnerProgram_Config__mdt
                                                                    WHERE Active__c = true AND PMP_Enable_Translation_Ind__c = true];
        for(PMP_SearchPartnerProgram_Config__mdt pp: transEnablePP){
            if(partnerProgram !=null && partnerProgram.contains(pp.PMP_Partner_Program_value__c)){
                transEnabled = true;
                break;
            }
        }
        return transEnabled;
    }
    
    @AuraEnabled
    //Method to get image URL
    public static string getlogoUrl(string partnerId){
        string requestJSON = MarketplaceImageUploader.getImages(partnerId);
        List<ImageWrapper>  request = (List<ImageWrapper>)JSON.deserialize(requestJSON, List<ImageWrapper>.class);
        return request[0].url;
    }    
}