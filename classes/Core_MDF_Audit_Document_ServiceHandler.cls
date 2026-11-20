/****************************************************************************************************************************************
* Class Name  : Core_MDF_Audit_Document_ServiceHandler
* Test Class  : Core_MDF_Audit_Document_Trigger_Test
* Version     : 1.0 
* Created Date: 15-02-2022   
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – NK    		15-02-2022                  Trigger service handler for on Core_MDF_Audit_Document trigger
*****************************************************************************************************************************************/


public without sharing class Core_MDF_Audit_Document_ServiceHandler {
    
 /****************************************************************************************************************************************
    Method Name:                                             dulpicateCheck
    Description:                                             method to check if duplicate Audit doc exist
    Added By:                                                Accenture – NK 15-02-2022
    Modified By:                  Date:                      Changes: 
    *****************************************************************************************************************************************/
    
    Public static void dulpicateCheck(List<Core_MDF_Audit_Document__c> newAuditDocList){
        List<Id> claimIdList = new List<Id>();
        Map<Id,List<Id>> claimIdToDocIdsMap = new Map<Id,List<Id>>();
        for(Core_MDF_Audit_Document__c newAuditDoc :newAuditDocList){
            claimIdList.add(newAuditDoc.Core_MDF_Claim__c);           
        }
        List<Core_MDF_Audit_Document__c> existingAuditDocList = [SELECT id,Core_MDF_Document_Id__c,Core_MDF_Claim__c FROM Core_MDF_Audit_Document__c where Core_MDF_Claim__c in:claimIdList];
        for(Core_MDF_Audit_Document__c auditDocExist :existingAuditDocList){
            if(claimIdToDocIdsMap.containsKey(auditDocExist.Core_MDF_Claim__c)){
                list<id> docList = claimIdToDocIdsMap.get(auditDocExist.Core_MDF_Claim__c);
                docList.add(auditDocExist.Core_MDF_Document_Id__c);
                claimIdToDocIdsMap.put(auditDocExist.Core_MDF_Claim__c,docList);                
            }
            else{
                claimIdToDocIdsMap.put(auditDocExist.Core_MDF_Claim__c,new List<Id>{auditDocExist.Core_MDF_Document_Id__c});   
            }
        }
        for(Core_MDF_Audit_Document__c auditDoc :newAuditDocList){
            if(claimIdToDocIdsMap.containsKey(auditDoc.Core_MDF_Claim__c) && claimIdToDocIdsMap.get(auditDoc.Core_MDF_Claim__c).contains(auditDoc.Core_MDF_Document_Id__c)){
                auditDoc.addError('Selected document is already attached to this claim');
            }
        }
    }
    
    public static void auditDocProcessesOnAfterInsert(List<Core_MDF_Audit_Document__c> newAuditDocList){
        Map<ID,Core_MDF_Audit_Document__c> auditDocIdToAuditDocMap = new Map<ID,Core_MDF_Audit_Document__c>(newAuditDocList);
            Core_MDF_Audit_Document_Sharing.shareAuditDocToclaim(auditDocIdToAuditDocMap);
        Set<Id> processedRecordIds = new Set<Id>();
        for (Core_MDF_Audit_Document__c audit_doc_rec : newAuditDocList) {
            // Check if the record has already been processed
            if (!processedRecordIds.contains(audit_doc_rec.Id)) {
                // Add the record Id to the set of processed records
                processedRecordIds.add(audit_doc_rec.Id);
                
            }
        }
        if (!processedRecordIds.isEmpty()) {
            updateAuditDocRecAsync(processedRecordIds);
    	}
            
   }
    
    
    public static void auditDocProcessesOnAfterUpdate(List<Core_MDF_Audit_Document__c> newAuditDocList){
        Map<ID,Core_MDF_Audit_Document__c> auditDocIdToAuditDocMap = new Map<ID,Core_MDF_Audit_Document__c>(newAuditDocList);
            Core_MDF_Audit_Document_Sharing.shareAuditDocToclaim(auditDocIdToAuditDocMap);
    }
    
    @future
    public static void updateAuditDocRecAsync(set<Id> recordIds) {
        List<Core_MDF_Audit_Document__c> auditDocRecToUpdate = [SELECT Id,Name, Core_MDF_Download_Document_Title_txt__c,Core_MDF_Encoded_Document_Title_txt__c  FROM Core_MDF_Audit_Document__c WHERE Id IN :recordIds];
        List<Core_MDF_Audit_Document__c> auditDocRecToUpdateWithChanges = new List<Core_MDF_Audit_Document__c>(); // Separate list for records to be updated
		try{ 
            for (Core_MDF_Audit_Document__c audit_doc_rec : auditDocRecToUpdate) {
                    string downloadTitle = audit_doc_rec.Core_MDF_Download_Document_Title_txt__c;
                    integer extPosition = downloadTitle.lastindexOf('.');//extention position 
                    string fileExt = downloadTitle.substring(extPosition);
                    string uploadedFileNameWithoutExt = downloadTitle.substring(0, extPosition);
    				uploadedFileNameWithoutExt = uploadedFileNameWithoutExt.replace('|', '_').replace('\'', '_').replace('`', '_').replace('~', '_');
                    String auditDocDownloadTitle = uploadedFileNameWithoutExt+'_' + audit_doc_rec.Name + fileExt;
                    audit_doc_rec.Core_MDF_Download_Document_Title_txt__c = auditDocDownloadTitle;
                    audit_doc_rec.Core_MDF_Encoded_Document_Title_txt__c = EncodingUtil.URLENCODE(auditDocDownloadTitle,'UTF-8').replace ('+', '%20');
    
                    
                    auditDocRecToUpdateWithChanges.add(audit_doc_rec);
            }
                
            
            // Perform bulk update
            update auditDocRecToUpdateWithChanges;
        }Catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}  
	}
    
}