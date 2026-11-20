@isTest
public class Pricing_UCD_BulkRejection_Scheduler_Test {
    static testmethod void testPricingUCDBulkRejection(){
        Pricing_UCD_BulkRejection_Scheduler prsch = new Pricing_UCD_BulkRejection_Scheduler();
        String sch = '0 0 2 * * ?'; 
        test.startTest();
        System.schedule('Pricing_UCD_BulkRejection_Scheduler_Test', sch, prsch);
        test.stopTest();
        System.assert(sch != null);
    }
}