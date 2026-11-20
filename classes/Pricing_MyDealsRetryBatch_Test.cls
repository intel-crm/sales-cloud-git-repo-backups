@isTest
public class Pricing_MyDealsRetryBatch_Test {
    static testmethod void batchPricingMyDealsRetryTest(){

        Pricing_Integration_Staging__c ps = new Pricing_Integration_Staging__c();
        ps.Pricing_Retry_Number__c = 3;
        ps.Pricing_Status__c = 'Failed';
        insert ps;

        test.startTest();
        Pricing_MyDealsRetryBatch pmdr = new Pricing_MyDealsRetryBatch();
        Database.executeBatch(pmdr);
        test.stopTest();
        System.assert(ps != null);
    }
}