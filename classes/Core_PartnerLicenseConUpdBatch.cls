/**************************************************************************************
Apex Class Name : Core_PartnerLicenseConUpdBatch
Version     : 1.0 
Created Date: 18th Nov 2024
Description : Batch to remove Partner Portal on Contact
* Modification Log : 
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Sharmila-Team Draco       18-Nov-2024             	Original Version
*************************************************************************************/
global without sharing class Core_PartnerLicenseConUpdBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Set<Id> conSetNew = new Set<Id>();
    public Core_PartnerLicenseConUpdBatch(Set<Id> conSet)
    {
        conSetNew = conSet;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Core_Contact_Id__c, Core_Entitlement_Id__r.Name, Core_Selected__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c IN :conSetNew AND Core_Entitlement_Id__r.Name =\'Partner Portal\' AND Core_Selected__c=true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Contact_Entitlement__c> conEntlst) {
        //removing partner portal entitlement for the contact 
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        List<Core_Contact_Entitlement__c> conEntToUpdate = new List<Core_Contact_Entitlement__c>();
        for(Core_Contact_Entitlement__c conEnt : conEntlst) {
            conEnt.Core_Status__c = 'Pending';
            conEnt.Core_Selected__c = false;
            conEnt.Core_Data_Loaded__c=true;
            conEnt.Core_Update_Reason__c='Removing as part of License Reclaimed';
            conEnt.Removal_as_part_of_License_Reclaim__c=true;
            conEntToUpdate.add(conEnt);
        }
        
        if (!conEntToUpdate.isEmpty()) {
            try {
                List<Database.SaveResult> saveResults = Database.update(conEntToUpdate, false);
                for (Integer i = 0; i < saveResults.size(); i++) {
                    Database.SaveResult saveResult = saveResults[i];
                    if (!saveResult.isSuccess()) {
                        // If the update failed for a contact entitlement, log the error
                        for (Database.Error error : saveResult.getErrors()) {
                            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_XID__c = conEntToUpdate[i].Id, Core_Message__c = 'Error updating CE',Core_Project__c = 'Core_PartnerLicenseConUpdBatch',Core_Origin__c = 'Core_PartnerLicenseConUpdBatch',Core_Details__c = error.getMessage(),Core_Severity__c = 'info',Core_When__c = System.now());
                            logEntries.add(logEntry); 
                        }
                    }
                }
                
                // Insert all log entries if there were any failures
                if (!logEntries.isEmpty()) {
                    Database.insert(logEntries, false);
                }
                
            } catch (Exception e) {
                // Creating a log entry for the exception
                Core_Log_Entry__c coreLogEntry = new Core_Log_Entry__c(Core_Message__c = 'Error updating CE',Core_Project__c = 'Core_PartnerLicenseConUpdBatch',Core_Origin__c = 'Core_PartnerLicenseConUpdBatch',Core_Details__c = e.getMessage(),Core_Severity__c = 'Error',Core_When__c = System.now());
                Database.insert(coreLogEntry, false);
            }
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {    
        
    }
}