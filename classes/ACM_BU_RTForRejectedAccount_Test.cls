@isTest
public with sharing class ACM_BU_RTForRejectedAccount_Test {
    private static UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger accountServiceInstance = new ACM_BU_RTForRejectedAccount();
    @TestSetup
    private static void setCommonData(){

        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account1','Rejected Account','UNFD_GLBL_CUST');
        account1.Core_Business_Party_Id__c = '12345678';
        account1.Core_MDM_Status__c = 'REJ';
        account1.Core_Account_Reference_Source_Name__c = 'IQR' ;
        account1.Core_Survivor_Account_Id__c = null;
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account2','Rejected Account','UNFD_GLBL_CUST');
        account2.Core_Business_Party_Id__c = '1234';
        account2.Core_MDM_Status__c = 'REJ';
        account2.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        insert account2;

        Account account3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account3','Rejected Account','UNFD_GLBL_CUST');
        account3.Core_Business_Party_Id__c = '12345';
        account3.Core_MDM_Status__c = 'REJ';
        account3.Core_Account_Reference_Source_Name__c = 'CoMarketing' ;
        insert account3;

        Account dealAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account4','End Customer Deal Account','UNFD_GLBL_CUST');
        dealAccount.Core_Business_Party_Id__c = '12345678';
        dealAccount.Core_MDM_Status__c = 'APRV';
        dealAccount.Core_Account_Reference_Source_Name__c = 'IQR' ;
        dealAccount.Core_Survivor_Account_Id__c = null;
 
        insert dealAccount;
        Account account5 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account5','Rejected Account','UNFD_GLBL_CUST');
        account5.Core_Business_Party_Id__c = '12345777';
        account5.Core_MDM_Status__c = 'REJ';
        account5.Core_Account_Reference_Source_Name__c = 'IQR' ;
        insert account5;


    }

    @isTest
    private static void executeTestScenarioOne(){
        // If survivor is null, check duplicate. If duplicate is there, no change in record type but set survivor for the account
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Survivor_Account_Id__c from account where (Name = 'account1' OR Name = 'dealAccount')];

        List<Account> newAccounts = new List<Account> ();
        for(Account a : oldAccounts){
            if(a.Core_MDM_Status__c != 'APRV'){
                a.Core_MDM_Status__c = 'APRV'; 
            }
            newAccounts.add(a);
        }
        Test.startTest();
        accountServiceInstance.execute(new Map<Id,Account>(newAccounts) ,new Map<Id,Account>(oldAccounts));
        Test.stopTest();
    }

    @isTest
    private static void executeTestScenarioTwo(){
        // If SBR Account and status updated rejected to Approved in reltio, then recordtype updates to Intel Account
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Survivor_Account_Id__c from account where (Name = 'account2' OR Name = 'account3')];

        List<Account> newAccounts = new List<Account> ();
        for(Account a : oldAccounts){
            if(a.Core_MDM_Status__c != 'APRV'){
                a.Core_MDM_Status__c = 'APRV'; 
            }
            newAccounts.add(a);
        }
        Test.startTest();
        accountServiceInstance.execute(new Map<Id,Account>(newAccounts) ,new Map<Id,Account>(oldAccounts));
        Test.stopTest();
    }

    @isTest
    private static void executeTestScenarioThree(){
         List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Survivor_Account_Id__c from account where (Name = 'account5')];

        List<Account> newAccounts = new List<Account> ();
        for(Account a : oldAccounts){
            if(a.Core_MDM_Status__c != 'APRV'){
                a.Core_MDM_Status__c = 'APRV'; 
            }
            newAccounts.add(a);
        }
        Test.startTest();
        accountServiceInstance.execute(new Map<Id,Account>(newAccounts) ,new Map<Id,Account>(oldAccounts));
        Test.stopTest();
    }
}