@isTest
public class UCD_ACM_AccountReqQueueHandlerTest {
    
    @TestSetup
    Private static void setCommonData(){
        
        
      Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ParentAccount','Intel Account','UNFD_CTRY_CUST');
	  Insert parentAccount;
        
      Account intelAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account6','Intel Account','UNFD_CTRY_CUST');
	  IntelAccount.ParentId = parentAccount.Id;
        Insert intelAccount;
       
      Account_Create_Request__c AccountReq = UCD_ACM_Cntrlr_TestDataInitialization.createAccountRequest('Accountnew', 'Approved',intelAccount);
      Insert AccountReq;  
              
      Account_Create_Request__c AccountReq1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountRequest('Account1','Approved',intelAccount);
      AccountReq1.Status__c = 'Rejected';
      Insert AccountReq1;
        
      Account_Create_Request__c AccountReq2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountRequest('Account2','Rejected',null);
      Insert AccountReq2;
      
      Account_Create_Request__c AccountReq3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountRequest('Account3','Rejected',null);
      AccountReq3.Status__c = 'Approved';
      Insert AccountReq3;
        System.debug('AccountReq3'+AccountReq3);
        
       
    }
    @isTest
    private static void checkForRejectedStatus(){
        List<Account_Create_Request__c> AccountreqRejected = [Select Id,Name,Account_Name__c,Status__c,Rejected_Reason__c,Requested_Account__c from Account_Create_Request__c where (Account_Name__c = 'Account2' )];       
        
        List<Account_Create_Request__c> accountsBeforeUpdate = [Select Id,Name,Account_Name__c,Status__c,Rejected_Reason__c,Requested_Account__c from Account_Create_Request__c where (Account_Name__c = 'Account3' )];       
        
        List<Account_Create_Request__c> accountsAfterUpdate = [Select Id,Name,Account_Name__c,Status__c,Rejected_Reason__c,Requested_Account__c from Account_Create_Request__c where (Account_Name__c =  'Account3')];
        accountsAfterUpdate[0].Status__c = 'Rejected';
        
        Test.startTest();
        	UCD_ACM_AccountReqQueueTriggerHandler.triggerPlatformEventOnUpdate(new List<Account_Create_Request__c>(accountsAfterUpdate), new Map<Id,Account_Create_Request__c>(accountsBeforeUpdate));
        Test.stopTest();
        
        System.assertEquals(AccountreqRejected[0].Status__c, accountsAfterUpdate[0].Status__c, 'Status Assignment is not correct.');	        
    }  
    
    @isTest
    private static void checkForApprovedStatus(){
        List<Account_Create_Request__c> AccountreqRejected = [Select Id,Name,Account_Name__c,Status__c,Rejected_Reason__c,Requested_Account__c,Requested_Account__r.ParentId from Account_Create_Request__c where (Account_Name__c = 'Accountnew' )];       
        
        List<Account_Create_Request__c> accountsBeforeUpdate = [Select Id,Name,Account_Name__c,Status__c,Rejected_Reason__c,Requested_Account__c,Requested_Account__r.ParentId from Account_Create_Request__c where (Account_Name__c = 'Account1' )];       
        
        List<Account_Create_Request__c> accountsAfterUpdate = [Select Id,Name,Account_Name__c,Status__c,Rejected_Reason__c,Requested_Account__c,Requested_Account__r.ParentId from Account_Create_Request__c where (Account_Name__c =  'Account1')];
        accountsAfterUpdate[0].Status__c = 'Approved';
        
        Test.startTest();
        	UCD_ACM_AccountReqQueueTriggerHandler.triggerPlatformEventOnUpdate(new List<Account_Create_Request__c>(accountsAfterUpdate), new Map<Id,Account_Create_Request__c>(accountsBeforeUpdate));
        Test.stopTest();
        
        System.assertEquals(AccountreqRejected[0].Status__c, accountsAfterUpdate[0].Status__c, 'Status Assignment is not correct.');	        
    }  
    
    
    

}