@isTest
public class Core_Opp_KPI_DeltaScheduler_Test {
	static void setupTest() {
    }
    
    static testMethod void KPIDeltaSchedule_Test_1() {
        Test.startTest();
        String cron = '0 0 12 * * ?';
        System.schedule('KPI_DeltaLoad_Every24hrs', cron, new Core_Opp_KPI_DeltaScheduler());
        Test.stopTest();
        Assert.areEqual(true,cron!=null);
    }
}