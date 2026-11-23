@istest
Public class PRM_LoginHistoryCheckBatchTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        PRM_LoginHistoryCheckScheduler testsche = new PRM_LoginHistoryCheckScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}