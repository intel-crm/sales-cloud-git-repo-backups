global class ACM_Update_B2BFlag_On_Account implements Database.Batchable<sObject>,Schedulable  {
    global void execute(SchedulableContext sc) {
        ACM_Update_B2BFlag_On_Account updateb2bFlagOnAcc = new ACM_Update_B2BFlag_On_Account();
        Database.executeBatch(updateb2bFlagOnAcc);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([
        SELECT Id, Name ,Core_B2B_Entitlement__c,RecordType.Name
        FROM Account WHERE Id NOT IN (SELECT AccountId FROM Contact) and Core_B2B_Entitlement__c=true and RecordType.Name='Intel Account'  limit 5
            ]);
    }
    global void execute(Database.BatchableContext BC, List<Account> accounts) {
        try{
            List<Account> accountsToUpdate = new List<Account>();
            system.debug('accounts'+accounts.size());
            for (Account acc : accounts) {
                // Check if the Account has no related Contacts
                system.debug('check the size '+acc.Contacts.size());
                if (acc.Contacts.size() == 0) {
                    acc.Core_B2B_Entitlement__c = FALSE; 
                    accountsToUpdate.add(acc);
                }
            }
            // Update Accounts if there are any to update
            
            if (!accountsToUpdate.isEmpty()) {
                Database.update(accountsToUpdate,false);
            }
        }
        catch (Exception ex) {
            System.debug('Exception ==>'+ ex.getMessage());
            System.debug('Exception ==>'+ ex.getStackTraceString());
            String accountIds = '' ;
            for(Account accRec : accounts){
                accountIds += accRec.Id + ',';
            }
            
            if(String.isNotBlank(accountIds)){
                //UCD_ACM_Logger.setLogDetails();
                UCD_ACM_Logger.error('ACM_Update_B2BFlag_On_Account','Failed Records',accountIds,ex.getMessage());
                
            }
        }
        
        finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
    // Finish method
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}