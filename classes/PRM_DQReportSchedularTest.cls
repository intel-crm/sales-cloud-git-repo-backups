@IsTest
public class PRM_DQReportSchedularTest {
    @IsTest
    static void testScheduleBatch() {
        
        
        String className = 'PRM_ProfileReponseMismatchReportBatch';
        String cronExpression = '0 0 0 * * ?';
        String jobName = 'Job1';
        
        Test.startTest();
        
        PRM_DQReportSchedular.scheduleBatch(className, cronExpression, jobName);
        
        Test.stopTest();
        
        
    }
}