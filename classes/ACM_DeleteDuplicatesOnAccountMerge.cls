global class ACM_DeleteDuplicatesOnAccountMerge implements Database.Batchable<sObject>,Schedulable  {
    global void execute(SchedulableContext sc) {
        ACM_DeleteDuplicatesOnAccountMerge delDupBatch = new ACM_DeleteDuplicatesOnAccountMerge(); 
        Database.executeBatch(delDupBatch);
     }
  
    Set<String> accountIds;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime dt;
        if(!String.isBlank(System.label.ACM_DuplicateJobSchedule)) {
             dt = System.now().addDays(Integer.valueOf(System.label.ACM_DuplicateJobSchedule));
        } else {
             dt = System.now().addDays(-7);
        }
       String query;
        query='SELECT Id, Field, AccountId,CreatedDate FROM AccountHistory where Field=\'accountMerged\''+
            ' and CreatedDate >: dt'; 
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<AccountHistory> accountHistory) {
        Set<String> accountIds= new Set<String>();
        for(AccountHistory ah:accountHistory) {
            accountIds.add(ah.AccountId);
        }
        if(!accountIds.isEmpty()) {
            ACM_DeleteDupsOnAccountMergeHandler.deleteDuplicates(accountIds);
            UCD_ACM_Logger.setLogDetails();
        } 
    }    

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }    
}