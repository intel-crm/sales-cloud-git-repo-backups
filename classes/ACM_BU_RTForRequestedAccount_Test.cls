@isTest
public class ACM_BU_RTForRequestedAccount_Test {
   
    private static UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger accountServiceInstance = new ACM_BU_RTForRequestedAccount();

    @TestSetup
    private static void setCommonData(){

        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account1','Requested Account','UNFD_GLBL_CUST');
        account1.Core_Business_Party_Id__c = '12345678';
        account1.Core_MDM_Status__c = 'APRV';
        account1.Core_Account_Reference_Source_Name__c = 'IQR' ;
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account2','Requested Account','UNFD_GLBL_CUST');
        account2.Core_Business_Party_Id__c = '1234';
        account2.Core_MDM_Status__c = 'APRV';
        account2.Core_Account_Reference_Source_Name__c = 'IQR' ;
        insert account2;

        Account account3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account3','Requested Account','UNFD_GLBL_CUST');
        account3.Core_Business_Party_Id__c = '12345';
        account3.Core_MDM_Status__c = 'REJ';
        account3.Core_Account_Reference_Source_Name__c = 'IQR' ;
        insert account3;

        Account dealAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account4','End Customer Deal Account','UNFD_GLBL_CUST');
        dealAccount.Core_Business_Party_Id__c = '123456';
        insert dealAccount;

    }

    @isTest
    private static void whenExecute(){
        List<Account> childAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'Account1' OR Name = 'Account2' OR Name = 'Account3')];

        List<Account> parentAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'Account1' )];
        parentAccount[0].Core_Business_Party_Id__c = '123456';

        List<Account> parentAccount2 = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name =  'Account2')];
        parentAccount2[0].Core_Business_Party_Id__c = '12345';

        List<Account> parentAccount3 = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name =  'Account3')];
        parentAccount3[0].Core_Business_Party_Id__c = '123456';

        List<Account> finalAccounts = new List<Account>();
        finalAccounts.addAll(parentAccount);
        finalAccounts.addAll(parentAccount2);
        finalAccounts.addAll(parentAccount3);

        accountServiceInstance.execute(new Map<Id,Account>(childAccount) ,new Map<Id,Account>(finalAccounts));

    }
}