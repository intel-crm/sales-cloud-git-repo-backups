public without sharing class MarketplaceImageUploader {
    
    
    public class ValidationWrapper {
        @AuraEnabled
        public Integer galleryVideosCount { get; set; }
        @AuraEnabled
        public ContentDocument contentDoc { get; set; }
    }
    
    public class GalleryWrapper {
        public String galleryImages { get; set; }
        public Integer videoCount { get; set; }
    }
    
    public class ImageWrapper {
        public String id { get; set; }
        public String url { get; set; }
        public String title { get; set; }
        public Integer size { get; set; }
        public String versionId { get; set; }
        public String altText { get; set; } // Added By Pranjal : TWC4497-41
    }

    @AuraEnabled
    public static String getImages(String offeringId){
        // Network myNetwork = [SELECT Id FROM Network WHERE Name ='Intel Style Guide' ];
        // ConnectApi.Community myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
        // String baseUrl = myCommunity.siteUrl;
        //System.debug('inside servers get image');
        GalleryWrapper offeringGallery = new GalleryWrapper();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        List<ImageWrapper> images = new List<ImageWrapper>();
        //To get the additional resources related to offering
        List<PMP_Partner_Offering_Resource__c> OffResources= new List<PMP_Partner_Offering_Resource__c>();
        List<Id> resDocIdList = new List<Id>();
        Map<String,String> conDocToAltTextMap = new Map<String,String>();// Added By Pranjal : TWC4497-41 
        
		if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
        OffResources= [select Id, Name, PMP_Partner_Offering_Image__c,PMP_Offering_Id__c,PMP_Alt_Text__c,PMP_Resource_Type_Nm__c from PMP_Partner_Offering_Resource__c 
                                                              where PMP_Offering_Id__c =:offeringId AND (PMP_Resource_Type_Nm__c =:PMP_StaticConstants_Offering.IMAGE OR PMP_Resource_Type_Nm__c =:PMP_StaticConstants_Offering.ADDITIONAL_RESOURCES) ORDER BY CREATEDDATE];// Added By Pranjal : TWC4497-41 : Adding the field and Removing the Filter 
            }
        List<ContentDocumentLink> links = [SELECT ContentDocumentId,LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId = :offeringId];
        List<PMP_Partner_Offering_Resource__c> OffVideoResources= new List<PMP_Partner_Offering_Resource__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
            OffVideoResources= [select Id, /*Name,*/PMP_Offering_Id__c from PMP_Partner_Offering_Resource__c 
                                where PMP_Resource_Type_Nm__c ='Video' and PMP_Offering_Gallery_Video_Ind__c = true and PMP_Delete_BrightCove_Video_Ind__c=false and PMP_Offering_Id__c =:offeringId ORDER BY CREATEDDATE];
        }
        List<Id> linkIds = new List<Id>();

         for(PMP_Partner_Offering_Resource__c offRes:OffResources){
            if(offRes.PMP_Resource_Type_Nm__c=='Additional Resources'){//Added By Pranjal : TWC4497-41: Added the Filter
                resDocIdList.add(offRes.PMP_Partner_Offering_Image__c);//get the document ids for additional resources
            }
            else{
                conDocToAltTextMap.put(offRes.PMP_Partner_Offering_Image__c,offRes.PMP_Alt_Text__c);// Added By Pranjal : TWC4497-41: creating the map
            }
        }
        for (ContentDocumentLink l : links) {
            if(!resDocIdList.contains(l.ContentDocumentId)){ //exclude images from additional resources
                 linkIds.add(l.ContentDocumentId);
            }
        }
        List<ContentVersion> versions = [SELECT Id, Title, FileExtension, ContentSize, ContentDocumentId, CreatedDate FROM ContentVersion WHERE ContentDocumentId IN :linkIds AND IsLatest = true ORDER BY CreatedDate];
       
        for (ContentVersion version : versions) {
            ImageWrapper i = new ImageWrapper();
            i.id = version.ContentDocumentId;
            i.url = baseUrl + System.Label.PMP_CommunityURLSuffix + 'sfc/servlet.shepherd/version/download/' + version.Id;
            i.title = version.Title + '.' + version.FileExtension;
            i.size = version.ContentSize;
            i.versionId=version.Id;
            i.altText=conDocToAltTextMap.get(i.id);//Added By Pranjal : TWC4497-41: saving to wrapper
            images.add(i);
        }
        offeringGallery.galleryImages = JSON.serialize(images);
        offeringGallery.videoCount = OffVideoResources.size();
        return JSON.serialize(offeringGallery);
        //return JSON.serialize(images);
         
    }

    //Modified by Nikhil on 12-Feb-2020 to delete Content Assets also when ContentDocument is deleted
    @AuraEnabled
    public static Boolean deleteImage(String contentDocumentId, String offeringId) {
           List<sObject> objToBeDeleted = new List<sObject>();
        
        List <PMP_Partner_Offering_Resource__c> offResList = [Select id,PMP_Partner_Offering_Image__c/*,PMP_Offering_Id__c*/ from PMP_Partner_Offering_Resource__c WHERE PMP_Partner_Offering_Image__c =: contentDocumentId];
        if ( offResList.size() <=1 ) {
            ContentDocument document = [SELECT Id FROM ContentDocument WHERE Id =: contentDocumentId];
            List<ContentAsset> assets = [SELECT id FROM ContentAsset WHERE ContentDocumentId =:contentDocumentId];
            objToBeDeleted.addAll(assets);
            objToBeDeleted.add(document);
            if (!objToBeDeleted.isEmpty()) {
                delete objToBeDeleted;
            }
        }
        else{
            List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =:offeringId and ContentDocumentId =:contentDocumentId];
            delete cdlList;
        }
        return true;
    }
    
    /**
    * Added by raj for US357476
    * @description - fetch ContentDocument record based on documentID
    * @param documentID - contentDocument Id
    * @return ContentDocument 
    * Method Parameters - documentID
    */
    @AuraEnabled
    public static ContentDocument getContentDocument(String documentID){
        ContentDocument contentDocument = new ContentDocument();
        contentDocument = [select id,title,FileType,FileExtension,ContentSize from ContentDocument where id = :documentID];
        return contentDocument;
    }
    /**
    * Method added by Pranjal 
    * @description-Validation of Images
    * @param contentDocId- Id of content document
    * @param offeringId - the Id of the offering
    * @return ValidationWrapper
    * This method is used in MarketplaceformImageuploader Aura component
    */
    @AuraEnabled
    //public static ValidationWrapper validateVideo(String offeringId, String documentID){
    public static ValidationWrapper validateVideo( String documentID){
   
    try{
            ValidationWrapper output = new ValidationWrapper();
            output.contentDoc = getContentDocument(documentID);
            //output.galleryVideosCount = getGalleryVideosCount(offeringId);
            return output;
        }
        catch(Exception e){
            PMP_Utility.logError(e,'MarketplaceImageUploader');
            return null;
        }
    }
    /**
    * Method added by Pranjal 
    * @description-to get the images count
    * @param offerinmgId the Id of the offering
    * This method is used in MarketplaceformImageuploader aura component
    */
    // @AuraEnabled
    // public static Integer getGalleryVideosCount(Id offeringId){
    //     List<PMP_Partner_Offering_Resource__c> offeringGalleryVideoResourcesList = [SELECT id,name,PMP_Resource_Type_Nm__c, PMP_Partner_Offering_Resource_URL_Txt__c,
    //     PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c,PMP_Offering_Id__c ,PMP_Alt_Text__c,PMP_BrightCoveVideoThumbnail_URL__c,LastModifiedDate,PMP_Offering_Gallery_Video_Ind__c,PMP_BrightCoveVideoAccountID__c,PMP_External_Source_Id__c,PMP_BrightCoveVideoId__c
    //     FROM PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c =: offeringId
    //     AND PMP_Offering_Gallery_Video_Ind__c = true AND PMP_Delete_BrightCove_Video_Ind__c=false
    //     AND PMP_Resource_Type_Nm__c ='Video'];
    //     Integer galleryVideosCount =offeringGalleryVideoResourcesList.size();
    //     return galleryVideosCount;
    // }
    /*---------------------------End US357476-----------------------------------------------------------------------------------------------*/
    
    //Added by Nikhil as part of US583440
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*@AuraEnabled
    public static void updateBannerMapping(String eventId, String lang, String docId){
        PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__c();
        if(Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){ //Apex CRUD Violation Fix
        event = [SELECT Id,PMP_Event_Banner_Language__c,PMP_Event_Banner_Language_Mapping__c FROM PMP_Marketplace_Event__c WHERE Id =: eventId];
        }
        String langCode = PMP_StaticConstants_Partner.languageCodeMap.get(lang);
        
        Map<String,String> langLogoMap = new Map<String,String>();
        if(event.PMP_Event_Banner_Language_Mapping__c != NULL){
            try{
                langLogoMap = (Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class);
            }catch(Exception e){
                //System.debug('Error while parsing Json file : ' + e);
            }
        }
        
        if(langLogoMap.get(langCode) != NULL){
            
            List<sObject> objToBeDeleted = new List<sObject>();
            
            List<ContentDocument> cdlist = [SELECT id FROM ContentDocument WHERE ContentAsset.DeveloperName =: langLogoMap.get(langCode)];
            if(!cdlist.isEmpty()){
                
                List<ContentAsset> assets = [SELECT id FROM ContentAsset WHERE ContentDocumentId IN :cdlist];
                objToBeDeleted.addAll(assets);
                objToBeDeleted.addAll(cdlist);
                
            }
            if(!objToBeDeleted.isEmpty()){
                delete objToBeDeleted;
            }
            
        }
        
        ContentAsset ca;
        
        List<ContentAsset> assets = [SELECT id,DeveloperName FROM ContentAsset WHERE ContentDocumentId =: docId];
        
        if(assets.isEmpty()){
            ca= new ContentAsset();
            ca.DeveloperName = langCode + docId;
            ca.MasterLabel = langCode  + docId;
            ca.isVisibleByExternalUsers = TRUE;
            ca.language = langCode;
            insert ca;
            
            ContentDocument cd = [select id,title from ContentDocument WHERE id =: docId];
            cd.ContentAssetId = ca.Id;
            cd.Title = '['+lang +'] ' + cd.Title; 
            update cd;
        }else{
            ca = assets[0];
            ca.language = langCode;
            update ca;
        }
        
        langLogoMap.put(langCode,ca.DeveloperName);
        
        event.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langLogoMap);
		event.PMP_Event_Banner_Language__c = lang;
        if(Schema.sObjectType.PMP_Marketplace_Event__c.isUpdateable()){  //Apex CRUD Violation Fix
        update event;
        }
    }*/
    
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*@AuraEnabled
    public static void deleteBannerMapping(String eventId, String docId){
        PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__c();
        if(Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){ //Apex CRUD Violation Fix
        event = [SELECT id, PMP_Event_Banner_Language_Mapping__c FROM PMP_Marketplace_Event__c WHERE Id=: eventId];
        }
        Map<String,String> langLogoMap = new Map<String,String>();
        try{
            langLogoMap = (Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class);
                
        }catch(Exception e){
            //System.debug('Error while parsing JSON');
        }
        Map<String,String> updatedLogoMap = new Map<String,String>();
        for(String key: langLogoMap.keySet()){
            if(!langLogoMap.get(key).contains(docId)){
                updatedLogoMap.put(key,langLogoMap.get(key));
            }
        }
        
        event.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(updatedLogoMap);
        if(Schema.sObjectType.PMP_Marketplace_Event__c.isUpdateable()){  //Apex CRUD Violation Fix
        update event;
        }
    }*/
    
    @AuraEnabled
    public static Boolean updateContDocOwnerInfo(String companyId) {
    	
        if(String.isNotBlank(companyId)) {
            List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
            for(ContentDocumentLink cdl : [select ContentDocumentId,Id,ShareType,Visibility,LinkedEntityId from ContentDocumentLink where LinkedEntityId = :companyId]){
                if(cdl.Visibility!='AllUsers'){
                    cdl.Visibility = 'AllUsers';
                    cdl.ShareType = 'I';
                    cdls.add(cdl);
                }
            }
            if(cdls.size() > 0) {
                update cdls;
            }
        }
        return true;
    }
}