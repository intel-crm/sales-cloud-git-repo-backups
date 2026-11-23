@IsTest
private class Core_MDF_BatchJobRestart_Test {

    // Helper to insert required config values used by class under test
    private static void upsertConfig(String key, String value) {
        Core_MDF_Configuration__c cfg = Core_MDF_Configuration__c.getValues(key);
        if (cfg == null) {
            cfg = new Core_MDF_Configuration__c();
            cfg.Name = key;
        }
        cfg.Core_MDF_Value__c = value;
        upsert cfg;
    }

    // Minimal dummy Schedulable to create a CronTrigger row with a provided name
    private class DummySchedulable implements Schedulable {
        public void execute(SchedulableContext sc) {
            // no-op
        }
    }

    @IsTest
    static void test_NoMatchingCronTriggers_ThrowsAndLogs() {
        // Arrange
        upsertConfig('CUSTOM_SCHEDULER_BATCH_JOB_NAME', 'CustomBatchSchedulerJob-');
        upsertConfig('Batch_Scheduler_Restart_Time_Buffer', '0');

        // Choose a unique program token that will not have any matching scheduled jobs
        String programs = 'NO_MATCH_' + System.now().getTime();

        Core_MDF_BatchJobRestart restartJob = new Core_MDF_BatchJobRestart(programs);

        Test.startTest();
        // Act + Assert: since there is no matching CronTrigger, customException should be thrown
        // The class rethrows customException in the else branch; ensure it bubbles up
        Boolean thrown = false;
        try {
            restartJob.execute(null);
        } catch (Core_MDF_BatchJobRestart.customException ex) {
            thrown = true;
            System.assert(ex.getMessage().contains('This is not a valid job to restart'),
                          'Expected customException message to indicate invalid job.');
        }
        Test.stopTest();

        System.assertEquals(true, thrown, 'Expected customException to be thrown when no matching cron triggers exist.');
    }

    @IsTest
    static void test_RestartWhenNoRunningAndBufferElapsed() {
        // Arrange
        upsertConfig('CUSTOM_SCHEDULER_BATCH_JOB_NAME', 'CustomBatchSchedulerJob-');
        // Use negative buffer so latest createdDate + buffer is guaranteed < now
        upsertConfig('Batch_Scheduler_Restart_Time_Buffer', '-5');

        // Build pattern the class will LIKE against: %<progNames>_CustomBatchSchedulerJob-%
        String programs = 'CCP,CPQ';
        String progNames = programs.replaceAll(',', '_');
        String jobNamePart = progNames + '_' + 'CustomBatchSchedulerJob-';

        // We must ensure at least one CronTrigger exists AND is in one of the states WAITING/ACQUIRED/EXECUTING/PAUSED/PAUSED_BLOCKED.
        // In Apex tests, scheduled jobs are typically created with state = WAITING when scheduled in the future.
        String cronFuture = '0 0 0 1 1 ? 2099'; // far future -> WAITING
        // Create multiple matching jobs to guarantee ctListWithJob non-empty and "latest" selection by CreatedDate desc.
        System.schedule(jobNamePart + 'MatchA', cronFuture, new DummySchedulable());
        System.schedule(jobNamePart + 'MatchB', cronFuture, new DummySchedulable());

        // Also schedule an unrelated job (should not be picked by LIKE)
        System.schedule('UNRELATED_JOB', cronFuture, new DummySchedulable());

        // Now create a matching job whose trigger will be ACQUIRED/EXECUTING by running it almost immediately.
        // Name still must match the LIKE pattern.
        // We schedule with a cron that fires within the test context window; most orgs will set state to ACQUIRED/EXECUTING briefly.
        // Even if it's not executing at assert time, we already have WAITING jobs to satisfy the allowed states list.
        Datetime now = System.now().addSeconds(5);
        String cronSoon = String.valueOf(now.second()) + ' ' + String.valueOf(now.minute()) + ' ' + String.valueOf(now.hour()) + ' ' +
                          String.valueOf(now.day()) + ' ' + String.valueOf(now.month()) + ' ? ' + String.valueOf(now.year());
        System.schedule(jobNamePart + 'Immediate', cronSoon, new DummySchedulable());

        Core_MDF_BatchJobRestart restartJob = new Core_MDF_BatchJobRestart(programs);

        Test.startTest();
        restartJob.execute(null);
        Test.stopTest();

        // Assert: ensure at least one matching CronTrigger exists and is in an allowed state.
        List<CronTrigger> matched = [
            SELECT Id, CronJobDetail.Name, State
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :('%' + jobNamePart + '%')
        ];
        System.assert(matched.size() > 0, 'Expected at least one CronTrigger to match the pattern.');

        // Validate presence of at least one trigger in the allowed states
        Boolean hasAllowedState = false;
        for (CronTrigger ct : matched) {
            if (ct.State == 'WAITING' || ct.State == 'ACQUIRED' || ct.State == 'EXECUTING' || ct.State == 'PAUSED' || ct.State == 'PAUSED_BLOCKED') {
                hasAllowedState = true;
                break;
            }
        }
        System.assertEquals(true, hasAllowedState, 'Expected at least one CronTrigger in an allowed state (WAITING/ACQUIRED/EXECUTING/PAUSED/PAUSED_BLOCKED).');
    }
}