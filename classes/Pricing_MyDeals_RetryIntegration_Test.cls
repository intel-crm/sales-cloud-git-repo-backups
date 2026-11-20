/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-16-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_MyDeals_RetryIntegration_Test {
    @testSetup
    public static void createTestData(){
        Pricing_Integration_Staging__c ps = new Pricing_Integration_Staging__c();
        ps.Pricing_Retry_Number__c = 3;
        ps.Pricing_Status__c = 'Failed';
        insert ps;
        Pricing_Integration_Staging__c ps1 = new Pricing_Integration_Staging__c();
        ps1.Pricing_Retry_Number__c = 6;
        ps1.Pricing_Status__c = 'Failed';
        insert ps1;
    }
	static testmethod void testQueueableMyDealsRetryIntegrationTest(){
        List<Pricing_Integration_Staging__c> stagingList = [SELECT Id,Name,Pricing_Retry_Number__c,Pricing_Status__c,Pricing_SObject__c,
                              Pricing_SObjectId__c,Pricing_Payload__c FROM Pricing_Integration_Staging__c 
                              WHERE Pricing_Status__c = 'Failed' AND Pricing_Retry_Number__c >= 3];
        System.assert(stagingList != null, 'stagingList should not be null');
        System.assert(stagingList.size() > 0, 'stagingList should not be empty');
        Pricing_MyDeals_RetryIntegration intQueue = new Pricing_MyDeals_RetryIntegration(stagingList);
        test.startTest();
        Id jobId = System.enqueueJob(intQueue);
        System.assert(jobId != null, 'jobId should not be null');
        test.stopTest();
    }
}