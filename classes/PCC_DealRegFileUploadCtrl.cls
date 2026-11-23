public with sharing class PCC_DealRegFileUploadCtrl {
    
    @AuraEnabled
    public static String uploadFiles(String recordId, String filedata) {
        try {
            if(String.isNotBlank(FileData)) {
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                system.debug('@@Reco=='+recordId);
                List<ContentVersion> cvList = new List<ContentVersion>();
                for(FileDataWP file : files) {
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                    conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
                    conVer.Title = file.fileName;
                    conVer.PathOnClient = file.fileName;
                    cvList.add(conVer);
                }
                Insert cvList;

                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = recordId;
                    conDocLink.ContentDocumentId = cv.ContentDocumentId;
                    conDocLink.Visibility = 'AllUsers';
                    conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                    cdList.add(conDocLink);
                }
                system.debug('@@insert=='+cdList);
                Insert cdList;        
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString()+ '==='+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
        public static Map<ID, ContentVersion> getRelatedFilesByRecordId(String recordId) {
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT Id,ContentDocumentId, FileExtension, Title 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
            Map<ID, ContentVersion> mapIdTitle = new Map<ID, ContentVersion>();
            for (ContentVersion docLink : docs) {
                //mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
                mapIdTitle.put(docLink.Id, docLink);
            }
            return mapIdTitle;
        }

    @AuraEnabled
    public static String deleteSelectedfile(Id docIds){
        try{
            delete [SELECT Id FROM ContentDocument WHERE Id=:docIds];
            return 'SUCCESS';
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
}