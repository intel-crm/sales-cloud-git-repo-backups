@isTest
public class UCD_ACM_AccountDeactivationBatchTest {
    @TestSetup
    private static void setCommonData() {
                
      Account inactiveAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestInactiveAccount','Inactive Account','UNFD_GLBL_CUST');
        inactiveAccount.Core_Deactivated__c = true;
        inactiveAccount.Core_Deactivation_Reason__c = 'Salesforce Cleanup';
        insert inactiveAccount;
        System.debug('account'+inactiveAccount);
     insert new AccountHistory(AccountId=inactiveAccount.Id, Field = 'Core_Deactivated__c');
        
      Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
       logEntry.Core_Details__c = inactiveAccount.id;
       logEntry.Core_Project__c = 'ACM';
       logEntry.Core_When__c = dateTime.now();
       logEntry.Core_Origin__c = 'UCD_ACM_AccountDeactivation_Batch';
       logEntry.Core_Severity__c = 'Error';
 		insert logEntry;
          
    } 
      @isTest
    private static void whenbatchClassRunning(){
      UCD_ACM_AccountDeactivation_Batch batchExe = new UCD_ACM_AccountDeactivation_Batch();
      DataBase.executeBatch(batchExe); 
        }
    
     @isTest
    private static void whenbatchClassReRun(){
        List<Account> inactiveRetry = [select id from Account where name = 'TestInactiveAccount'];
     	Map<id,Account> newAcntMap= new Map<id,Account>(inactiveRetry);
      UCD_ACM_AccountDeactivation_Batch batchExe = new UCD_ACM_AccountDeactivation_Batch(newAcntMap);
       DataBase.executeBatch(batchExe); 
     }
    
    


}