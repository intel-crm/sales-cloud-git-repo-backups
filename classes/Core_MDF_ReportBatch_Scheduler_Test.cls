@isTest
private class Core_MDF_ReportBatch_Scheduler_Test {

    @isTest
    static void testExecuteMethod() {
        // Create test data if necessary
        // Example: insert new Account(Name='Test Account');

        // Start test context
        Test.startTest();

        // Create an instance of the scheduler
        Core_MDF_ReportBatch_Scheduler scheduler = new Core_MDF_ReportBatch_Scheduler();

        // Execute the scheduler's execute method
        String jobId = System.schedule('Test Job', '0 0 0 * * ? *', scheduler);

        // Verify that the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];

        System.assertEquals('0 0 0 * * ? *', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        // End test context
        Test.stopTest();

        // Optionally, verify the results of the batch execution
        // Example: List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        // System.assertEquals(1, accounts.size());
    }

    @isTest
    static void testSchedulerMethod() {
        // Start test context
        Test.startTest();

        // Call the SchedulerMethod
        Core_MDF_ReportBatch_Scheduler.SchedulerMethod();

        // Since SchedulerMethod is commented out, you might want to uncomment it for testing purposes
        // Verify that the job was scheduled if SchedulerMethod is active

        // End test context
        Test.stopTest();
    }
}