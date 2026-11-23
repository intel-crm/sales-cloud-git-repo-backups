/****************************************************************************************************************************************
* Class Name      	    : Core_MDF_FileRepository
* Test Class Name       : Core_MDF_FileRepository_Test
* Version               : 1.0  
* Created By            : Accenture - Vikas Soni
* Created Date          : 19-01-2026
* Modification Log      : 
* Developer            Date             Description
*****************************************************************************************************************************************/
public without sharing class Core_MDF_FileRepository {
    
    /****************************************************************************************************** 
    Method Name:        getActivityStatusById
    @return  :          -
    @parameters:        String - PartnerFundRequest Status
    Description:        This method is get PartnerFundRequest Status by records Id
    Added By:           Accenture - Vikas Soni - 16/01/2026
    Modified By:        Date:         Changes:
    *******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getActivityStatusById(Id recordId) {
        List<PartnerFundRequest> activities = [SELECT Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE Id = :recordId LIMIT 1];
    
        if (activities != null && !activities.isEmpty()) {
            return activities[0].Core_MDF_Fund_Request_Status__c;
        }
        return null;
    }
    
    /****************************************************************************************************** 
    Method Name:        getRelatedMDFDocumentsByRecord
    @return  :          -
    @parameters:        List of MDFDocumentWrapper records
    Description:        This method is get Core_MDF_Documents__c records by PartnerFundClaim record Id
    Added By:           Accenture - Vikas Soni - 19/01/2026
    Modified By:        Date:         Changes:
    *******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<MDFDocumentWrapper> getRelatedMDFDocumentsByRecord(Id recordId) {
        List<MDFDocumentWrapper> results = new List<MDFDocumentWrapper>();
        Boolean isPartnerUser = (UserInfo.getUserType() == 'PowerPartner') ? true : false;
        
        for (Core_MDF_Documents__c cdl : [ SELECT Id, Core_MDF_Document_Id__c, Core_MDF_Document_Title_txt__c, Core_MDF_File_Extension_txt__c, Core_MDF_ContentVersion_Id__c, Core_MDF_SFT_File_Available_ind__c, Core_MDF_SFT_File_Download_URL__c, //HP:ATHR Fix
                                          Core_MDF_External_SF_File_Download_URL__c, CreatedDate, Core_MDF_Internal_SF_File_Download_URL__c
                                          FROM Core_MDF_Documents__c
                                          WHERE Core_MDF_Activity_id__c = :recordId AND Core_MDF_Is_Deleted_ind__c = false ORDER BY CreatedDate DESC
                                         ])
        {
            results.add(new MDFDocumentWrapper(
                cdl.Core_MDF_Document_Id__c,
                cdl.Core_MDF_Document_Title_txt__c,
                cdl.Core_MDF_File_Extension_txt__c,
                cdl.Core_MDF_ContentVersion_Id__c,
                cdl.CreatedDate,
                (cdl.Core_MDF_SFT_File_Available_ind__c ? cdl.Core_MDF_SFT_File_Download_URL__c : (isPartnerUser ? cdl.Core_MDF_External_SF_File_Download_URL__c : cdl.Core_MDF_Internal_SF_File_Download_URL__c))
            ));
        }
        return results;
    }
    
    /****************************************************************************************************** 
    Method Name:        insertMDFDocuments
    @return  :          -
    @parameters:        List of Core_MDF_Documents__c records
    Description:        This method is used to insert Core_MDF_Documents__c records (LWC: core_MDF_FileRepository)
    Added By:           Accenture - Vikas Soni - 19/01/2026
    Modified By:        Date:         Changes:
    *******************************************************************************************************/
    @AuraEnabled
    public static void insertMDFDocuments(List<Core_MDF_Documents__c> mdfDocuments) {
        Set<Id> contentDocIds = new Set<Id>();
        Map<Id, ContentVersion> docIdToVersionMap = new Map<Id, ContentVersion>();
        Set<Id> activityIds = new Set<Id>();
        Map<String, ContentDocumentLink> linkByDocAndEntity = new Map<String, ContentDocumentLink>();
        List<ContentDocumentLink> linksToUpdate = new List<ContentDocumentLink>();
        
        if (mdfDocuments == null || mdfDocuments.isEmpty()) {
            return;
        }
        for (Core_MDF_Documents__c document : mdfDocuments) {
            if (document.Core_MDF_Document_Id__c != null) {
                contentDocIds.add(document.Core_MDF_Document_Id__c);
            }
            if (document.Core_MDF_Activity_id__c != null) {
                activityIds.add(document.Core_MDF_Activity_id__c);
            }
        }
        //prepare map of documentKey-ContentDocumentLink
        for (ContentDocumentLink linkRec : [SELECT Id, ContentDocumentId, LinkedEntityId, Visibility FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocIds AND LinkedEntityId IN :activityIds]) {
            String key = String.valueOf(linkRec.ContentDocumentId) + ':' + String.valueOf(linkRec.LinkedEntityId);
            linkByDocAndEntity.put(key, linkRec);
        }
        //get contentversions related to MDF Document records
        for (ContentVersion cv : [
            SELECT ContentDocumentId,
                   ContentSize,
                   FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocIds
            AND IsLatest = true
        ]) {
            docIdToVersionMap.put(cv.ContentDocumentId, cv);
        }
        
        //update extension and file size of MDF Document records
        for (Core_MDF_Documents__c document : mdfDocuments) {
            ContentVersion cv = docIdToVersionMap.get(document.Core_MDF_Document_Id__c);
            if (cv != null) {
                document.Core_MDF_File_Extension_txt__c = cv.FileExtension;
                document.Core_MDF_File_Size_num__c = cv.ContentSize;
            }
            String key = String.valueOf(document.Core_MDF_Document_Id__c) + ':' + String.valueOf(document.Core_MDF_Activity_id__c);
            ContentDocumentLink existingLink = linkByDocAndEntity.get(key);
            if (existingLink != null && existingLink.Visibility != 'AllUsers') {
                existingLink.Visibility = 'AllUsers';
                linksToUpdate.add(existingLink);
            }
        }
        //insert MDF Document
        try{
            Database.insert(mdfDocuments);
            Database.update(linksToUpdate);
        } catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex); throw new AuraHandledException(ex.getMessage()); }
    }
    
    /****************************************************************************************************** 
    Method Name:        deleteMDFDocument
    @return  :          -
    @parameters:        ContentDocument Id
    Description:        This method is used to delete Core_MDF_Documents__c record by ContentDocument Id
    Added By:           Accenture - Vikas Soni - 19/01/2026
    Modified By:        Date:         Changes:
    *******************************************************************************************************/
    @AuraEnabled
    public static void deleteMDFDocument(Id contentDocumentId) {
        Core_MDF_Documents__c document = [
            SELECT Id, Core_MDF_Is_Deleted_ind__c
            FROM Core_MDF_Documents__c
            WHERE Core_MDF_Document_Id__c = :contentDocumentId LIMIT 1
        ];
        List<ContentDocument> contentDocument = [
            SELECT Id
            FROM ContentDocument
            WHERE Id = :contentDocumentId
            LIMIT 1
        ];
        // mark MDF document as deleted
        if(document != null){
            document.Core_MDF_Is_Deleted_ind__c = true;
            try{
                update document;
            } catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex); throw new AuraHandledException(ex.getMessage()); }
        }
        // delete content document
        if(!contentDocument.isEmpty()){
            try{
                delete contentDocument;
            } catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex); throw new AuraHandledException(ex.getMessage()); }
        }
    }

    public class MDFDocumentWrapper {
        @AuraEnabled public Id contentDocumentId;
        @AuraEnabled public String title;
        @AuraEnabled public String fileType;
        @AuraEnabled public Id versionId;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String documentDownloadURL;
        
        public MDFDocumentWrapper(Id docId, String title, String type, Id versionId, Datetime createdDate, String documentDownloadURL) {
            this.contentDocumentId = docId;
            this.title = title;
            this.fileType = type;
            this.versionId = versionId;
            this.createdDate = createdDate;
            this.documentDownloadURL = documentDownloadURL;
        }
    }
}