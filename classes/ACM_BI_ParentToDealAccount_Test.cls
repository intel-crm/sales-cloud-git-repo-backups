@isTest
public with sharing class ACM_BI_ParentToDealAccount_Test {

    private static UCD_ACM_ServiceContracts.IBeforeInsertAccountTrigger accountServiceInstance = new ACM_BI_ParentToDealAccount();


    @TestSetup
    private static void setCommonData(){
        Account dealAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ECDChild1','End Customer Deal Account','UNFD_CTRY_CUST');
        dealAccount.Core_Account_Reference_Source_Name__c = 'IQR' ;
        dealAccount.Core_Business_Party_Id__c = '1234567';
        insert dealAccount;
    }


    @isTest
    private static void setParentForIntelAccountException(){
        Account dealAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ECDChild2','End Customer Deal Account','UNFD_CTRY_CUST');
        dealAccount.Core_Account_Reference_Source_Name__c = 'IQR' ;
        dealAccount.Core_Parent_Business_Party_Id__c = '1234567';
		
        Test.startTest();
        	accountServiceInstance.execute( new List<Account>{dealAccount});
        Test.stopTest();   
        
        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'ECDChild2'];
       // System.assertNotEquals(parentAccount[0].Id, null, 'Account is not Created.');
    }

}