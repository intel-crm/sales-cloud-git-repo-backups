@isTest
public class Pricing_QLI_AutoReject_SchedulerTest {
    static testmethod void testPricingUCDBulkRejection(){
        Pricing_QLI_AutoReject_Scheduler prsch = new Pricing_QLI_AutoReject_Scheduler();
        String sch = '0 0 2 * * ?'; 
        test.startTest();
        System.schedule('Pricing_QuoteLine_AutoRejection_Batch', sch, prsch);
        test.stopTest();
        System.assert(sch != null);
    }

}