@isTest
public class ACM_CNDAStatusBatchScheduler_Test {

    @isTest
    static void testBatchClass() 
    {
        Account iAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Amazon','Intel Account','UNFD_GLBL_CUST');
        iAccount.Core_CNDA_Number__c = (9632584).toString();
        iAccount.OwnerId = [select id from user where email = 'harshitha.shreeka@intel.com' LIMIT 1].ID;
        insert iAccount;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ACM_MockCNDAHttpResponse());
        String cronExp = '0 0 0 1,15 * ?'; // Example: runs at midnight on January 1st, 2024
        ACM_CNDAStatusBatchScheduler batch = new ACM_CNDAStatusBatchScheduler();
        String jobId = System.schedule('Account Scheduler Test Job', cronExp, batch);
        Test.stopTest();
    }
}