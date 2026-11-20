@istest
public class Core_Batch_PG_Trtry_Assign_Schduler_Test {
    
    public static testMethod void testschedule() {
	Test.StartTest();
	Core_Batch_PG_Territory_Assign_Scheduler sh1 = new Core_Batch_PG_Territory_Assign_Scheduler();

	String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1);
        system.assertEquals('0 0 23 * * ?', sch);
    Test.stopTest(); }
    
}