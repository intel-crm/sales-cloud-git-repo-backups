@isTest
public class Core_ScheduledOppoForecast_Test {
    static testmethod void testOppForecast(){
        Core_ScheduledOppoForecast prsch = new Core_ScheduledOppoForecast();
        String sch = '0 0 2 * * ?'; 
        test.startTest();
        System.schedule('Core_ScheduledOppoForecast', sch, prsch);
        test.stopTest();
    }
}