public with sharing class MarketplaceImageUploader {

    public class ImageWrapper {
        public String id { get; set; }
        public String url { get; set; }
        public String title { get; set; }
        public Integer size { get; set; }
        public String versionId { get; set; }
    }

    @AuraEnabled
    public static String getImages(String offeringId){
        // Network myNetwork = [SELECT Id FROM Network WHERE Name ='Intel Style Guide' ];
        // ConnectApi.Community myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
        // String baseUrl = myCommunity.siteUrl;
        System.debug('inside servers get image');
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

        List<ContentDocumentLink> links = [SELECT ContentDocumentId,LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId = :offeringId];
     
        List<Id> linkIds = new List<Id>();
        for (ContentDocumentLink l : links) {
           linkIds.add(l.ContentDocumentId);
        }
        
        List<ContentVersion> versions = [SELECT Id, Title, FileExtension, ContentSize, ContentDocumentId, CreatedDate FROM ContentVersion WHERE ContentDocumentId IN :linkIds AND IsLatest = true ORDER BY CreatedDate];
        List<ImageWrapper> images = new List<ImageWrapper>();
       	
            for (ContentVersion version : versions) {
                ImageWrapper i = new ImageWrapper();
                i.id = version.ContentDocumentId;
                i.url = baseUrl + System.Label.PMP_CommunityURLSuffix + 'sfc/servlet.shepherd/version/download/' + version.Id;
                i.title = version.Title + '.' + version.FileExtension;
                i.size = version.ContentSize;
                i.versionId=version.Id;
                images.add(i);
            }
        return JSON.serialize(images);
    }

    //Modified by Nikhil on 12-Feb-2020 to delete Content Assets also when ContentDocument is deleted
    @AuraEnabled
    public static Boolean deleteImage(String contentDocumentId) {
        
        List<sObject> objToBeDeleted = new List<sObject>();
        
        ContentDocument document = [SELECT Id FROM ContentDocument WHERE Id =: contentDocumentId];
        List<ContentAsset> assets = [SELECT id FROM ContentAsset WHERE ContentDocumentId =:contentDocumentId];
        
        objToBeDeleted.addAll(assets);
        objToBeDeleted.add(document);
        if(!objToBeDeleted.isEmpty()){
            delete objToBeDeleted;
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
        system.debug('dosc id'+documentID);
        ContentDocument contentDocument = [select id,title,FileType,FileExtension,ContentSize from ContentDocument where id = :documentID];
        system.debug('dosc'+contentDocument);
        return contentDocument;
    }
    /*---------------------------End US357476-----------------------------------------------------------------------------------------------*/
    
    //Added by Nikhil as part of US583440
    @AuraEnabled
    public static void updateBannerMapping(String eventId, String lang, String docId){
        
        PMP_Marketplace_Event__c event = [SELECT Id,PMP_Event_Banner_Language__c,PMP_Event_Banner_Language_Mapping__c FROM PMP_Marketplace_Event__c WHERE Id =: eventId];
        
        String langCode = PMP_StaticConstants_Partner.languageCodeMap.get(lang);
        
        Map<String,String> langLogoMap = new Map<String,String>();
        if(event.PMP_Event_Banner_Language_Mapping__c != NULL){
            try{
                langLogoMap = (Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class);
            }catch(Exception e){
                System.debug('Error while parsing Json file : ' + e);
            }
        }
        
        if(langLogoMap.get(langCode) != NULL){
            
            List<sObject> objToBeDeleted = new List<sObject>();
            
            List<ContentDocument> cd = [SELECT id FROM ContentDocument WHERE ContentAsset.DeveloperName =: langLogoMap.get(langCode)];
            if(!cd.isEmpty()){
                
                List<ContentAsset> assets = [SELECT id FROM ContentAsset WHERE ContentDocumentId IN :cd];
                objToBeDeleted.addAll(assets);
                objToBeDeleted.addAll(cd);
                
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
        update event;
    }
    
    @AuraEnabled
    public static void deleteBannerMapping(String eventId, String docId){
        PMP_Marketplace_Event__c event = [SELECT id, PMP_Event_Banner_Language_Mapping__c FROM PMP_Marketplace_Event__c WHERE Id=: eventId];
        Map<String,String> langLogoMap = new Map<String,String>();
        try{
            langLogoMap = (Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class);
                
        }catch(Exception e){
            System.debug('Error while parsing JSON');
        }
        Map<String,String> updatedLogoMap = new Map<String,String>();
        for(String key: langLogoMap.keySet()){
            if(!langLogoMap.get(key).contains(docId)){
                updatedLogoMap.put(key,langLogoMap.get(key));
            }
        }
        
        event.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(updatedLogoMap);
        update event;
    }
    
    //End
}