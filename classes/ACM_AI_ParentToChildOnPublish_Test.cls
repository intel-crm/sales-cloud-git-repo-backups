@isTest
public class ACM_AI_ParentToChildOnPublish_Test {
    private static UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger accountServiceInstance = new ACM_AI_ParentToChildOnPublish();
    @TestSetup
    private static void setCommonData(){
        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ECDParentAcct','End Customer Deal Account','UNFD_GLBL_CUST');
        account1.Core_Business_Party_Id__c = '10970654';
        account1.Core_MDM_Status__c = 'APRV';
        account1.Core_Account_Reference_Source_Name__c = 'IQR' ;
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ECDChildAcct','End Customer Deal Account','UNFD_CTRY_CUST');
        account2.Core_Business_Party_Id__c = '1234198';
        account2.Core_MDM_Status__c = 'APRV';
        account2.Core_Account_Reference_Source_Name__c = 'IQR' ;
        account2.Core_Parent_Business_Party_Id__c ='10970654';
        insert account2;
    }
    @isTest
    private static void setParentForEcdChildAccount(){
        List<Account> parentAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'ECDParentAcct' )];

        List<Account> parentnewAccounts = new List<Account>();
        parentnewAccounts.addAll(parentAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(null, null, new Map<Id,Account>(parentnewAccounts));
        Test.stopTest();
    }
}