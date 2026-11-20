/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-16-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_ManageCPQLicense_Scheduler_Test {
    static testmethod void testPricingManageCPQLicense(){
        Pricing_ManageCPQLicense_Scheduler prsch = new Pricing_ManageCPQLicense_Scheduler();
        String sch = '0 0 2 * * ?'; 
        test.startTest();
        String jobId = System.schedule('Pricing_ManageCPQLicense_Scheduler_Test', sch, prsch);
        test.stopTest();
        System.assertNotEquals(null, jobId, 'System.schedule should return a non-null job Id for the scheduled job.');
    }   
}