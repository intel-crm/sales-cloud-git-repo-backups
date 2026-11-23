public with sharing class PSG_FileUploadController {

    /*@AuraEnabled
    public static list<ContentVersion> returnFiles(list<String> lstFileIds){
        return [SELECT Id, Title FROM ContentVersion WHERE Id IN :lstFileIds];
    }*/
    
    
    
/*
    @AuraEnabled
    public static list<ContentVersion> getFiles(String recId){
        return [SELECT Id, ContentDocumentId, IsLatest,ContentBodyId, Title, FileType, PublishStatus, VersionData, ContentSize, FileExtension, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId =:recId];
    }
    @AuraEnabled
    public static void removeAttachment(Id recId){
        //return [SELECT Id, ContentDocumentId, IsLatest,ContentBodyId, Title, FileType, PublishStatus, VersionData, ContentSize, FileExtension, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId =:recId];
        try{
            database.delete(recId);
        }catch(Exception ex){
            System.debug(ex);
        }
        
    }
*/    
 
 
    
    
/*
    @AuraEnabled
    public static list<Id> saveFiles(list<Object> filesToInsert){
        
        list<Id> lstCntVerIds = new list<Id>();
        List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
        for (Object file : filesToInsert) {
            FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
            ContentVersion objCntVersion = new ContentVersion();
            objCntVersion.PathOnClient = fileData.Title;
            objCntVersion.Title = fileData.Title;
            objCntVersion.VersionData = fileData.VersionData;
            lstVersionsToInsert.add(objCntVersion);
        }

        list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
        for (Database.SaveResult saveResult : res) {
            if(saveResult.isSuccess()) {
                lstCntVerIds.add(saveResult.getId());
            }
        }
        return lstCntVerIds;
    }


    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }*/
}