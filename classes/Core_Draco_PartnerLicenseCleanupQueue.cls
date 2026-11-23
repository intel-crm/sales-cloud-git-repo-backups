public class Core_Draco_PartnerLicenseCleanupQueue implements Queueable {
    public List<User> lstOfUser = new List<User>();    
    List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    
    
    public Core_Draco_PartnerLicenseCleanupQueue(List<User> records) {
        this.lstOfUser = records;        
    }
    
    //Method is used to update user's field values.    
    public void execute(QueueableContext context) {
        List<User> deactivationLst = new List<User>();
        Set<Id> contactIds = new Set<Id>();
        for(User usr : lstOfUser) {
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
                
                // Insert all log entries if there were any failures
                if (!logEntries.isEmpty()) {
                    insertLogEntriesCleanup(JSON.serialize(logEntries));
                }
                
            } catch (Exception e) {
                // Creating a log entry for the exception
                Core_Log_Entry__c coreLogEntry = new Core_Log_Entry__c(Core_Message__c = 'Exception updating users',Core_Project__c = 'LicenseCleanupBatch',Core_Origin__c = 'LicenseCleanupBatch',Core_Details__c = e.getMessage(),Core_Severity__c = 'Error',Core_When__c = System.now());
                insertLogEntriesCleanup(JSON.serialize(new List<Core_Log_Entry__c>{coreLogEntry}));
            }
        }
        updateContENTANDContact(JSON.serialize(contactIds));
    }
    
    @future
    public static void insertLogEntriesCleanup(String logEntry) {
        List<Core_Log_Entry__c> logEntries = (List<Core_Log_Entry__c>)JSON.deserialize(logEntry, List<Core_Log_Entry__c>.class);
        Set<Id> existingLogIds = new Set<Id>();
        List<Core_Log_Entry__c> logsToInsert = new List<Core_Log_Entry__c>();
        for (Core_Log_Entry__c log : logEntries) {
            if (!existingLogIds.contains(log.Core_XID__c)) {
                existingLogIds.add(log.Core_XID__c);
                logsToInsert.add(log);
            }
        }
        
        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }
    }
    
    @future
    public static void updateContENTANDContact(String contIds) {
        Set<Id> conSetNew = (Set<Id>)JSON.deserialize(contIds, Set<Id>.class);
        List<Core_Contact_Entitlement__c> conEntToUpdate = new List<Core_Contact_Entitlement__c>();
        
        //Query the Partner Portal Contact Entitlement to update the core selected and core status.
        List<Core_Contact_Entitlement__c> conEntlst = [SELECT Id, Core_Contact_Id__c, Core_Entitlement_Id__r.Name, Core_Selected__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c IN :conSetNew AND Core_Entitlement_Id__r.Name ='Partner Portal' AND Core_Selected__c=true];            
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
            }
            catch(exception e){
                
            }
        }
    }
}