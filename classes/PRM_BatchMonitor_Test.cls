@isTest(SeeAllData = True)
public class PRM_BatchMonitor_Test {
    @isTest
    public static void testBatchFailure(){
        
        List<Monitor_Log__c> testRec = new List<Monitor_Log__c>();
        Monitor_Log__c mLog = new Monitor_Log__c();
        mLog.Status__c = 'Queued';
        mLog.Integration_Type__c = 'Batch Failure';
        mLog.Error_Message__c = 'ERROR TEST';
        testRec.add(mlog);
        
        Monitor_Log__c mLog1 = new Monitor_Log__c();
        mLog1.Status__c = 'Queued';
        mLog1.Integration_Type__c = 'Batch Failure';
        mLog1.Error_Message__c = 'INVALID TEST';
        testRec.add(mlog1);
        
        insert testRec;
        
        Test.startTest();
        PRM_BatchMonitorScheduler batchschedule1 = new PRM_BatchMonitorScheduler();
        String cronExpression1 = '0 0 0/2 1/2 * ? *';
        system.schedule('Batch Test' , cronExpression1 , batchschedule1);
        Test.stopTest();        
    }   
}