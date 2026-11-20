@isTest
public with sharing class UCD_AccountHierarchyBatch_Test {

    @TestSetup
    private static void createCommonData(){
        
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        parentAccount.Core_Reltio_Integration_Status__c += 'PENDING';
        parentAccount.Core_Business_Party_Id__c = '22334455';
        insert parentAccount;
        
        // Create End Customer Deal Account Intermediate1 child
        Account intChildAcc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount1','Intel Account','UNFD_INTRMD_CUST');
        intChildAcc1.Core_Parent_Business_Party_Id__c = parentAccount.Core_Business_Party_Id__c;
        intChildAcc1.Core_Reltio_Integration_Status__c += 'PARENT_UPDATE';
        insert intChildAcc1;

        // Create Intel Account Intermediate1 child
        Account IntelintChildAcc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelTestIntChildAccount1','Intel Account','UNFD_INTRMD_CUST');
        IntelintChildAcc1.parentId = parentAccount.Id;
        insert IntelintChildAcc1;
        
        // Create End Customer Deal Account Intermediate2 child
        Account intChildAcc2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount2','Intel Account','UNFD_INTRMD_CUST');
        intChildAcc2.parentId = intChildAcc1.Id;
        insert intChildAcc2;
        
        // Create End Customer Deal Account Country child
        Account ctryChildAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestCtryChildAccount','Intel Account','UNFD_CTRY_CUST');
        ctryChildAcc.parentId = intChildAcc2.Id;
        ctryChildAcc.Core_Reltio_Integration_Status__c += 'PENDING';
        insert ctryChildAcc;
        
        Account locChildAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestLocChildAccount','Intel Account','UNFD_LOC_CUST');
        locChildAcc.Core_Parent_Business_Party_Id__c = parentAccount.Core_Business_Party_Id__c;
        locChildAcc.Core_Reltio_Integration_Status__c += 'PARENT_UPDATE';
        insert locChildAcc;
        

        Account updateTest = new Account();
        updateTest.Id = parentAccount.Id;
        updateTest.Core_Reltio_Integration_Status__c += 'CHILD_UPDATE';
        update updateTest;
        
    }
    
    @isTest
    static void testBatch(){
     	Test.startTest();
        UCD_AccountHierarchyBatch ucd = new UCD_AccountHierarchyBatch();
        Database.ExecuteBatch(ucd);
        Test.stopTest();
    }
    
}