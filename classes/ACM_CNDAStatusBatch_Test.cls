@isTest
public class ACM_CNDAStatusBatch_Test {
    
    @isTest
    static void testBatchClass() 
    {
        Account iAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Amazon','Intel Account','UNFD_GLBL_CUST');
        iAccount.Core_CNDA_Number__c = (9632584).toString();
        iAccount.OwnerId = [select id from user where email = 'harshitha.shreeka@intel.com' LIMIT 1].ID;
        insert iAccount;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ACM_MockCNDAHttpResponse());
        ACM_CNDAStatusBatch batch = new ACM_CNDAStatusBatch();
        Database.executeBatch(batch, 1); 
        Test.stopTest();
    }
    
    @isTest
    static void testBatchClass2() 
    {
        Account iAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Amazon','Intel Account','UNFD_GLBL_CUST');
        iAccount.Core_CNDA_Number__c = '9632584;IPLA1392;';
        iAccount.OwnerId = [select id from user where email = 'harshitha.shreeka@intel.com' LIMIT 1].ID;
        insert iAccount;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ACM_MockCNDAStatusHttpResponse());
        ACM_CNDAStatusBatch batch = new ACM_CNDAStatusBatch();
        Database.executeBatch(batch, 1); 
        Test.stopTest();
    }

}