/**************************************************************************************
Apex Class Name : Core_Draco_EntitlementCleanup_Batch
Version     : 1.0 
Created Date: 08th Feb 2023
Description : Batch class for Entitlements cleanup and Republishing Contacts failed due to specific errors. 
Test Class  : xxxxxxxxxxxxxxxxxxxxxx
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shreyas[Team Draco]     08 Feb 2023               Original Version
* Shreyas[Team Draco]     23 Feb 2023               Added logic for Daily Entitlement cleanup of Contact level failures
*************************************************************************************/

global class Core_Draco_EntitlementCleanup_Batch implements Database.Batchable<sObject>,Database.Stateful{
    
    global static Integer max_entitlementLevel_retry;
    global static Integer max_contactLevel_retry;
    global static String error_entitlementLevel = '';
    global static String error_contactLevel = '';
    global Set<Contact> conSet = new Set<Contact>();

    global static Database.QueryLocator start(Database.BatchableContext context){    
        /********Getting the max retry value and list of error for the Batch**********/
        Map<String, Core_AE_Retry_and_Reprocess_Logics__c> mapMetadata =  Core_AE_Retry_and_Reprocess_Logics__c.getAll();
        for(String currentdata : mapMetadata.keySet()){
            if(mapMetadata.get(currentdata).Core_Logic_Name__c == 'Daily Entitlement Cleanup - Entitlement Based'){
                max_entitlementLevel_retry = Integer.valueOf(mapMetadata.get(currentdata).Core_Maximum_Attempts__c);
                error_entitlementLevel = mapMetadata.get(currentdata).Core_Error_Contains__c;
                
            }
            if(mapMetadata.get(currentdata).Core_Logic_Name__c == 'Daily Entitlement Cleanup - Contact Based'){
                max_contactLevel_retry = Integer.valueOf(mapMetadata.get(currentdata).Core_Maximum_Attempts__c);
                error_contactLevel = mapMetadata.get(currentdata).Core_Error_Contains__c;
                
            }
        }
        
        /********Getting The list of failed Contact Entitlements in Past N days**********/
        String queryFailedCE = Test.isRunningTest()? 'SELECT Id, Core_Entitlement_Nm__c, Core_Contact_Id__c, Core_Status_of_Assignment_Failure__c,Core_Retrigger_Attempt__c, Core_Selected__c, Core_Status__c,Core_Update_Reason__c,Core_Contact_Id__r.Account.Core_Deactivated__c FROM Core_Contact_Entitlement__c WHERE Core_Status_of_Assignment_Failure__c IN (\'Failed Removal\', \'Failed Assignment\') AND (Core_Retrigger_Attempt__c = null OR Core_Retrigger_Attempt__c  <: max_entitlementLevel_retry)'
            : 'SELECT Id, Core_Entitlement_Nm__c, Core_Contact_Id__c, Core_Status_of_Assignment_Failure__c,Core_Retrigger_Attempt__c, Core_Selected__c, Core_Status__c,Core_Update_Reason__c,Core_Contact_Id__r.Account.Core_Deactivated__c FROM Core_Contact_Entitlement__c WHERE LastModifiedDate = LAST_N_DAYS:2 AND Core_Status_of_Assignment_Failure__c IN (\'Failed Removal\', \'Failed Assignment\') AND (Core_Retrigger_Attempt__c = null OR Core_Retrigger_Attempt__c  <: max_entitlementLevel_retry)';                 
        return Database.getQueryLocator(queryFailedCE);
    }
    
    global void execute(Database.BatchableContext context, List<Core_Contact_Entitlement__c> lstAllFailedCERecords){

        Map<String, Core_AE_Retry_and_Reprocess_Logics__c> mapMetadata =  Core_AE_Retry_and_Reprocess_Logics__c.getAll();
        for(String currentdata : mapMetadata.keySet()){
            if(mapMetadata.get(currentdata).Core_Logic_Name__c == 'Daily Entitlement Cleanup - Entitlement Based'){
                max_entitlementLevel_retry = Integer.valueOf(mapMetadata.get(currentdata).Core_Maximum_Attempts__c);
                error_entitlementLevel = mapMetadata.get(currentdata).Core_Error_Contains__c;
                
            }
        }

          
        /*****************[START] - Update CE records and Republish Contacts for Entitlement Level Failures **************/
        Map<Id, Id> CERecordContactMap = new Map<Id, Id>();
        List<Core_Contact_Entitlement__c> EntitlementToUpdate = new List<Core_Contact_Entitlement__c>();
        List<String> EntLevel_ErrorList = string.isNotBlank(error_entitlementLevel) ? error_entitlementLevel.split(';') : null;
        
        //Iterate across failed CE records and update their Selected-Status if eligible
        for(Core_Contact_Entitlement__c contEnt : lstAllFailedCERecords){
            for(String ErrString : EntLevel_ErrorList){
                if(contEnt.Core_Update_Reason__c != NULL && contEnt.Core_Update_Reason__c != '' && contEnt.Core_Update_Reason__c.contains(ErrString) && contEnt.Core_Contact_Id__r.Account.Core_Deactivated__c==false){
                    if(contEnt.Core_Status_of_Assignment_Failure__c == 'Failed Assignment'){
                        contEnt.Core_Selected__c = True;
                        contEnt.Core_Status__c = 'Pending';
                        contEnt.Core_Retrigger_Attempt__c = contEnt.Core_Retrigger_Attempt__c == null ? 1 : contEnt.Core_Retrigger_Attempt__c + 1;
                        contEnt.Core_Status_of_Assignment_Failure__c = 'Pending Assignment';
                        contEnt.Core_Update_Reason__c = 'Daily entitlement cleaup batch job';
                        EntitlementToUpdate.add(contEnt);
                        CERecordContactMap.put(contEnt.Id, contEnt.Core_Contact_Id__c);
                    }
                    if(contEnt.Core_Status_of_Assignment_Failure__c == 'Failed Removal'){
                        contEnt.Core_Selected__c = False;
                        contEnt.Core_Status__c = 'Pending';
                        contEnt.Core_Retrigger_Attempt__c = contEnt.Core_Retrigger_Attempt__c == null ? 1 : contEnt.Core_Retrigger_Attempt__c + 1;
                        contEnt.Core_Status_of_Assignment_Failure__c = 'Pending Removal';
                        contEnt.Core_Update_Reason__c = 'Daily entitlement cleaup batch job';
                        EntitlementToUpdate.add(contEnt);
                        CERecordContactMap.put(contEnt.Id, contEnt.Core_Contact_Id__c);
                    }  
                }      
            }
        }
        if(EntitlementToUpdate != NULL){
            Database.SaveResult[] srList = Database.Update(EntitlementToUpdate, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed and its contact Id
                    
                    conSet.add(new Contact(Id = CERecordContactMap.get(sr.getId()), Core_Republish_OBM_s__c = true));
                }
            }
        }
        /*****************[END] - Update CE records and Republish Contacts for Entitlement Level Failures **************/
    }
    
    // Chain the batch job in Finish Method to Republish the contacts in Batch Size of 1
    global void finish(Database.BatchableContext context){ 
        
        Map<String, Core_AE_Retry_and_Reprocess_Logics__c> mapMetadata =  Core_AE_Retry_and_Reprocess_Logics__c.getAll();
        for(String currentdata : mapMetadata.keySet()){
            if(mapMetadata.get(currentdata).Core_Logic_Name__c == 'Daily Entitlement Cleanup - Contact Based'){
                max_contactLevel_retry = Integer.valueOf(mapMetadata.get(currentdata).Core_Maximum_Attempts__c);
                error_contactLevel = mapMetadata.get(currentdata).Core_Error_Contains__c;
               
            }
        }

        
        /*****************[START] - Update Retry counter and directly Republish Contacts for Contact Level Failures **************/
        List<String> ConLevel_ErrorList = string.isNotBlank(error_contactLevel) ? error_contactLevel.split(';') : null;
        List<Contact> conLevelFailures = !Test.isRunningTest() ? [SELECT Id, Core_AGS_Retry_Count__c, Core_AGS_Integration_Message__c,Account.Core_Deactivated__c  FROM Contact WHERE (Core_AGS_Retry_Count__c = NULL OR Core_AGS_Retry_Count__c <: max_contactLevel_retry) AND Core_AGS_Integration_Status__c = 'Failed' AND LastModifiedDate = LAST_N_DAYS:2]
        : [SELECT Id, Core_AGS_Retry_Count__c, Core_AGS_Integration_Message__c,Account.Core_Deactivated__c  FROM Contact WHERE (Core_AGS_Retry_Count__c = NULL OR Core_AGS_Retry_Count__c <: max_contactLevel_retry) AND Core_AGS_Integration_Status__c = 'Failed'];
        for(Contact failedCon : conLevelFailures){
            for(String ErrString : ConLevel_ErrorList){
                if(failedCon.Core_AGS_Integration_Message__c.contains(ErrString)&& failedCon.Account.Core_Deactivated__c==false){
                    failedCon.Core_AGS_Retry_Count__c = failedCon.Core_AGS_Retry_Count__c == null ? 0 : failedCon.Core_AGS_Retry_Count__c + 1;
                    failedCon.Core_Republish_OBM_s__c = true;
                    conSet.add(failedCon);
                }
            }
        }
       
        /*****************[END] - Update Retry counter and directly Republish Contacts for Contact Level Failures **************/
     
        
        if(!Test.isRunningTest()){
            Core_Draco_ContactUpdate_Batch contactUpdateBatch = new Core_Draco_ContactUpdate_Batch(conSet);
            database.executebatch(contactUpdateBatch, 1); 
        }
    }
}