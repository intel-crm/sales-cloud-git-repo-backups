public class TestBatchSH implements Database.Batchable<sObject>,Database.Stateful{
	private Integer retryCount;
    public TestBatchSH() {
        this.retryCount = 0;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(retryCount>0){
            return Database.getQueryLocator([SELECT Id,Name,AccountId__c,Account_Action_Refrence__c,Core_Action__c,Core_Status__c,Status_Details__c,Core_Retry_Counter__c FROM Core_ACM_Account_Staging__c limit 1]);
        }else{
            return Database.getQueryLocator([SELECT Id from Account where Id = '001D300000pddYOIAY']);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accList){
        try{
            for(Account ac : accList){
                ac.Name = 'Test ACC1';
            }
            update accList;
        }
        catch(Exception ex){
           System.debug(ex);
        }
    }
    public void finish(Database.BatchableContext BC){
        
    }

}