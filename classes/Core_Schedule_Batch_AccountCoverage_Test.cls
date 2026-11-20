@isTest
public class Core_Schedule_Batch_AccountCoverage_Test{
      @isTest
    static void testSchedulableJob() {
        // Start test context
        Test.startTest();

        // Schedule the batch job to run immediately
        String cronExpression = '0 0 0 15 3 ? 2025'; // A cron expression to schedule for a future time (can be adjusted)
        String jobName = 'Core_Schedule_Batch_AccountCoverage_Test_Job';
        Core_Schedule_Batch_AccountCoverage job = new Core_Schedule_Batch_AccountCoverage();
        
        // Schedule the job
        String jobId = System.schedule(jobName, cronExpression, job);
        
        // Stop test context
        Test.stopTest();
      }
/*
    public static testMethod void testScheduleFailedCase(){
        
        Profile sysAdminProfile = [select id, name from Profile where name = 'System Administrator' Limit 1];
        UserRole testuserRole = new UserRole(Name = 'UnitTest-Customer-User');
        insert testuserRole;
           User sysAdminUser= new User(Alias = 'std455',
                            Email = 'poojax.khanna@intel.com',
                            EmailEncodingKey = 'UTF-8',
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US',
                            UserRoleId= testuserRole.id,
                            LocaleSidKey = 'en_US',
                            ProfileId = sysAdminProfile .Id,Phone='8764657467',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = 'standard123@systestorg.com');
        insert sysAdminUser;
        System.runAS(sysAdminUser)
        {
        Test.StartTest();
        Core_AccountCoverage_Batch_Status__c coreAB = new Core_AccountCoverage_Batch_Status__c ();
        coreAB.Name = 'Core_Batch_AccountCoverage_MuleService';
        coreAB.Core_Batch_Status__c = 'FAILED';
        insert coreAB;
        Core_Schedule_Batch_AccountCoverage scheduleaccount = new Core_Schedule_Batch_AccountCoverage();  
        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('ScheduleApexClassTest',sch, scheduleaccount);
        Test.stopTest();
        }
    }
    public static testMethod void testScheduleSuccessCase(){
        
        Profile sysAdminProfile = [select id, name from Profile where name = 'System Administrator' Limit 1];
        UserRole testuserRole = new UserRole(Name = 'UnitTest-Customer-User');
        insert testuserRole;
           User sysAdminUser= new User(Alias = 'std455',
                            Email = 'poojax.khanna@intel.com',
                            EmailEncodingKey = 'UTF-8',
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US',
                            UserRoleId= testuserRole.id,
                            LocaleSidKey = 'en_US',
                            ProfileId = sysAdminProfile .Id,Phone='8764657467',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = 'standard123@systestorg.com');
        insert sysAdminUser;
        System.runAS(sysAdminUser)
        {
        Test.StartTest();
        Core_AccountCoverage_Batch_Status__c coreAB = new Core_AccountCoverage_Batch_Status__c ();
        coreAB.Name = 'Core_Batch_AccountCoverage_MuleService';
        coreAB.Core_Batch_Status__c = 'SUCCESS';
        insert coreAB;
        Core_Schedule_Batch_AccountCoverage scheduleaccount = new Core_Schedule_Batch_AccountCoverage();  
        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('ScheduleApexClassTest',sch, scheduleaccount);
        Test.stopTest();
        }
    }*/
    
}