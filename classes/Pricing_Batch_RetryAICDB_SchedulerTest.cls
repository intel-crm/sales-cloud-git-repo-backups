/****************************************************************************************************************************************************
 * Class Name           : Pricing_Batch_RetryAICDB_SchedulerTest
 * Version              : 1.0
 * Created Date         : 07-07-2026
 * Modification Log     :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Sinduja                07-07-2026       Test class for Pricing_Batch_RetryAICDB_Scheduler
 ******************************************************************************************************************************************************/
@isTest
public class Pricing_Batch_RetryAICDB_SchedulerTest {
	@isTest
    static void testScheduler() {
        Test.startTest();
        Pricing_Batch_RetryAICDB_Scheduler scheduler = new Pricing_Batch_RetryAICDB_Scheduler();
        String cronExp = '0 0 0 1 1 ? 2030';
        System.schedule('TestRetryAICDBScheduler', cronExp, scheduler);
        Test.stopTest();
    }
}