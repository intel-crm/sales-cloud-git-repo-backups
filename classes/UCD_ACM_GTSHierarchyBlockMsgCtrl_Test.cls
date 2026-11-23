@isTest
public with sharing class UCD_ACM_GTSHierarchyBlockMsgCtrl_Test {
   /* @TestSetup 
    static void createRecordsForTest() {
        
        Account acct=UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestECBMsgAcct', 'Intel Account', 'UNFD_CTRY_CUST');
        insert acct;
    }
    @isTest
    public static void testunified() {
        
        Test.startTest();
        List<Account> allHeirarchyAccounts = [SELECT id,Name,Core_Business_Party_Id__c,Core_Export_Compliance_Block__c,Core_Data_Simplified_Account_Nm__c FROM Account Where Name='TestECBMsgAcct' ];
        UCD_ACM_GTSHierarchyBlockMsgController.getAllHeirarchyRecords(allHeirarchyAccounts[0].Id);
        Test.stopTest();
    }*/
}