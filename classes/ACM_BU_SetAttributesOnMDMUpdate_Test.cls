@isTest
public class ACM_BU_SetAttributesOnMDMUpdate_Test {
   
    private static UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger accountServiceInstance = new ACM_BU_SetAttributesOnMDMUpdate();

    @TestSetup
    private static void setCommonData() {
        Account iAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account1','Intel Account','UNFD_GLBL_CUST');
        iAccount.Core_MDM_Status__c = 'APRV';
        iAccount.Core_Account_Reference_Source_Name__c = 'IQR' ;
        insert iAccount;

        Account rejAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account2','Rejected Account','UNFD_CTRY_CUST');
        rejAccount.Core_MDM_Status__c = 'APRV';
        rejAccount.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        insert rejAccount;

        Account dealAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account3','End Customer Deal Account','UNFD_GLBL_CUST');
        dealAccount.Core_Business_Party_Id__c = '123456';
        dealAccount.Core_Account_Reference_Source_Name__c = '' ;
        insert dealAccount;
        
        Account intelAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account4','Intel Account','UNFD_GLBL_CUST');
        intelAccount.BillingCountryCode = 'IND';
        insert intelAccount;
        
    }

    @isTest
    private static void whenExecute() {
        List<Account> accountsBeforeUpdate = [Select Id,Name,Core_MDM_Status__c,RecordTypeId,Core_Data_Simplified_Account_Nm__c,Core_Account_Reference_Source_Name__c  from account where (Name IN ('Account1','Account2','Account3'))];
        
        List<Account> iAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'Account1' )];
        iAccount[0].Core_Data_Simplified_Account_Nm__c = 'Changed Name 1';

        List<Account> rejAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name =  'Account2')];
        rejAccount[0].Core_Data_Simplified_Account_Nm__c = 'Changed Name 2';

        List<Account> dealAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name =  'Account3')];
        dealAccount[0].Core_Data_Simplified_Account_Nm__c = 'Changed Name 3';
        
        List<Account> intelAccount = [Select Id,Core_Business_Party_Id__c,BillingCountryCode,Core_Geo__c,Core_Sub_Geo__c,RecordTypeId   from account where (Name =  'Account4')];

        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(iAccount);
        accountsAfterUpdate.addAll(rejAccount);
        accountsAfterUpdate.addAll(dealAccount);
        accountsAfterUpdate.addAll(intelAccount);

        accountServiceInstance.execute(new Map<Id, Account>(accountsBeforeUpdate), new Map<Id, Account>(accountsAfterUpdate));
    }
}