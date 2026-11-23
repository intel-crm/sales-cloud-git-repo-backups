/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-27-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_ManageCPQLicense_Scheduler_Test {
    static testmethod void testPricingManageCPQLicense(){
        Pricing_ManageCPQLicense_Scheduler prsch = new Pricing_ManageCPQLicense_Scheduler();
        String sch = '0 0 2 * * ?'; 
        test.startTest();
        System.schedule('Pricing_ManageCPQLicense_Scheduler', sch, prsch);
        test.stopTest();
        System.assert(sch != null);
    }
}