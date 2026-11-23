/**************************************************************************************
Apex Class Name : Core_Draco_PartnerLicenseCleanupBatch
Version     : 1.0 
Created Date: 18th Nov 2024
Description : Batch to cleanup partner user licenses
* Modification Log : 
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Sharmila-Team Draco       18-Nov-2024             	Original Version
*************************************************************************************/
global without sharing class Core_Draco_PartnerLicenseCleanupBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<User> deactivationLst = new List<User>();
    Set<Id> contactIds = new Set<Id>();
    Set<String> permissionSetNameSetting = new Set<String>();
    List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    String partnerLicenseMdt='Core_PartnerLicenseReclaim__mdt';
    Integer queryLimit = Integer.valueOf(Label.Core_Draco_PartnerLicenseCleanupBatchLimit);
    Integer conUpdLimit = Integer.valueOf(Label.Core_PartnerLicenseConUpdBatchLimit);
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Getting excluded permissionsets from custommetadataobject
        List<Core_CustomMetadata_Object__c> permissionSetAPINames = [Select Id,Metadata_Name__c, Category__c,DeveloperName__c, Field_1_Text_Area__c from Core_CustomMetadata_Object__c  where Metadata_Name__c=:partnerLicenseMdt];
        for(Core_CustomMetadata_Object__c permissionSetAPINm : permissionSetAPINames){
            if (String.isNotBlank(permissionSetAPINm.Field_1_Text_Area__c)) {
                List<String> permissionSetNames = permissionSetAPINm.Field_1_Text_Area__c.split(';');
                permissionSetNameSetting.addAll(permissionSetNames);
            }
        }
        
        // Getting excluded profiles from custom settings
        List<String> excludedProfileLst = System.Label.Core_Draco_PartnerLicExcludedProfiles.split(';');
        
        String query = '';
        if(Test.isRunningTest()){
            query='Select Id,Email,LastName,LastLoginDate, ContactId, Profile.Name,IsActive,Partner_License_Reclaimed__c from User Where IsActive =TRUE AND UserType = \'PowerPartner\' AND FederationIdentifier !=null AND Id not in (select AssigneeId from PermissionSetAssignment where PermissionSet.Name IN :permissionSetNameSetting) AND ((LastLoginDate=null AND CreatedDate < LAST_N_DAYS:182)  or LastLoginDate < LAST_N_DAYS:182) AND (Profile.Name NOT IN :excludedProfileLst) LIMIT 1';
        } else{
            query='Select Id,Email,LastName,LastLoginDate, ContactId, Profile.Name,IsActive,Partner_License_Reclaimed__c from User Where IsActive =TRUE AND UserType = \'PowerPartner\' AND FederationIdentifier !=null AND Id not in (select AssigneeId from PermissionSetAssignment where PermissionSet.Name IN :permissionSetNameSetting) AND ((LastLoginDate=null AND CreatedDate < LAST_N_DAYS:182)  or LastLoginDate < LAST_N_DAYS:182) AND (Profile.Name NOT IN :excludedProfileLst) LIMIT :queryLimit';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> partnerUsers) { 
        // Deactivating the users and setting Partner_License_Reclaimed__c to true
        for (User usr : partnerUsers) {
            usr.IsActive = false;
            usr.Partner_License_Reclaimed__c = true;
            deactivationLst.add(usr);
            contactIds.add(usr.ContactId);
        }
                
        if (!deactivationLst.isEmpty()) {
            try {
                List<Database.SaveResult> saveResults = Database.update(deactivationLst, false);
                for (Integer i = 0; i < saveResults.size(); i++) {
                    Database.SaveResult saveResult = saveResults[i];
                    if (!saveResult.isSuccess()) {
                        // If the update failed for a user, log the error
                        for (Database.Error error : saveResult.getErrors()) {
                            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_XID__c = deactivationLst[i].Id, Core_Message__c = 'Error updating users',Core_Project__c = 'PartnerLicenseCleanupBatch',Core_Origin__c = 'PartnerLicenseCleanupBatch',Core_Details__c = error.getMessage(),Core_Severity__c = 'info',Core_When__c = System.now());
                            logEntries.add(logEntry); 
                        }
                    }
                }
                
            } catch (Exception e) {
                // Creating a log entry for the exception
                Core_Log_Entry__c coreLogEntry = new Core_Log_Entry__c(Core_Message__c = 'Exception updating users',Core_Project__c = 'PartnerLicenseCleanupBatch',Core_Origin__c = 'PartnerLicenseCleanupBatch',Core_Details__c = e.getMessage(),Core_Severity__c = 'Error',Core_When__c = System.now());
                logEntries.add(coreLogEntry); 
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        Set<Id> existingLogIds = new Set<Id>();
        List<Core_Log_Entry__c> logsToInsert = new List<Core_Log_Entry__c>();
        for (Core_Log_Entry__c log : logEntries) {
            if (!existingLogIds.contains(log.Core_XID__c)) { existingLogIds.add(log.Core_XID__c); logsToInsert.add(log);
            }
        }
        
        if (!logsToInsert.isEmpty()) {
             Database.insert(logsToInsert, false);
        }
                
        if(!Test.isRunningTest()){
            Core_PartnerLicenseConUpdBatch contactUpdateBatch = new Core_PartnerLicenseConUpdBatch(contactIds);
            Database.executebatch(contactUpdateBatch,conUpdLimit);
        }
    }
}