public class Core_Batch_UnCovered_Acc_CleanupFlow{
    
    //@InvocableVariable    
    //public list<account> acflagupdatelist=new list<account>();
     

    @InvocableMethod(label='Get AccountCleanUpRecs' description='')
    public static List<AccountWrapResult> updateAccOwnerFlag(List<Account> uncoveredAccounts){
        DateTime jobRunTime;
        Set<Id> markDeleteAccSetId = (new Map<Id,SObject>(uncoveredAccounts)).keySet(); 
        Set<Id>successfulAccountIds=new set<Id>();        
        Integer failedRecordCount=0;
        String errorString='';
        list<account> acflagupdatelist=new list<account>();
        
        //try {  
            jobRunTime= System.Now();          
            // subquery to get all Account related child records.
            List<Account> accList = [Select Id,Core_Business_ID__c, Core_Uncover_Marked_for_Clean_Up__c,Core_Batch_Run_Date__c, (Select Id from Opportunities), (select Id from cases ),(Select Id from AccountTeamMembers),
            (select id from contacts),(select id from Notes), (select id from Attachments),(select id from Account_ERPM_Engagements__r),(select id from Account_Meeting_Briefs__r ),
            (select id from Account_Teams__r  ), (select id from CCV__r ),(Select Id From Tasks),(select id from events),(select id from Account_Engagements__r),(select id from Account_Profiles__r) from Account where Id IN:uncoveredAccounts ];                
            // Check if any child record present            
            if(accList != null && !accList.isEmpty()){
                for(Account acc : accList){
                    if(acc.Opportunities.size() >0 || acc.cases.size()>0 || acc.contacts.size()>0 || acc.Attachments.size()>0 || acc.Notes.size()>0 ||acc.AccountTeamMembers.size()>0 ||
                    acc.Account_ERPM_Engagements__r.size()>0 || acc.Account_Meeting_Briefs__r.size()>0 || acc.Account_Teams__r.size()>0 || acc.CCV__r.size()>0 || acc.Account_Engagements__r.size()>0 || acc.Account_Profiles__r.size()>0 || acc.Tasks.size()>0 || acc.events.size()>0 || String.isNotBlank(acc.Core_Business_ID__c)){                        
                        if( acc.Core_Uncover_Marked_for_Clean_Up__c){                       
                          acc.Core_Uncover_Marked_for_Clean_Up__c =false; 
                          acc.Core_Batch_Run_Date__c= jobRunTime;
                          acflagupdatelist.add(acc);                          
                        }                      
                    }
                    else{
                       acc.Core_Uncover_Marked_for_Clean_Up__c =true;
                       acc.Core_Batch_Run_Date__c= jobRunTime;
                       acflagupdatelist.add(acc);                      
                    }
                }
            }  
            /**accountCleanUpReq acc = new accountCleanUpReq(); 
            acc.cleanupAcc =  acflagupdatelist;   **/ 
            // Update the flag to the accounts
           /** if(acflagupdatelist != null && !acflagupdatelist.isEmpty() ){           
               // update(acflagupdatelist);
               Database.SaveResult[] lsr = Database.update(acflagupdatelist, false);
               // Iterate through the Save Results 
                for(Database.SaveResult sr:lsr)
                {
                    // fetch all success DML id's in this set
                    if(sr.isSuccess())
                    {
                        successfulAccountIds.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) { 
                          errorString=errorString +err.getStatusCode() + ': ' + err.getMessage(); 
                           
                        }                        
                    }
                }
                // Get all the failed Ids by iterating through all the Account Ids and check with success IDs.
                for(Account a: acflagupdatelist)
                {
                    if(!successfulAccountIds.contains(a.Id) ){
                        errorString=errorString + String.valueOf(a.Id)+';';
                        failedRecordCount=failedRecordCount+1;                      
                    }
                }
            }**/
            AccountWrapResult accResult = new AccountWrapResult();
            accResult.cleanupAcc = acflagupdatelist;
            List<AccountWrapResult> listAccResult = new List<AccountWrapResult>();
            listAccResult.add(accResult);
            return listAccResult;
        //}
        //catch(Exception e){      
          
        //}
    }
    
    public class AccountWrapResult{
        @InvocableVariable
        public List<Account> cleanupAcc;
    }

}