/********************************************************************************************************************
    Class Name: Core_Daily_Weekly_BUBatch_Schedule_Test
    Version     : 1.0 
    Created Date: 15 Sept 2020
    Function    : Test Class to cover the Daily, weekly and weekend schedule classes 
    *******************************************************************************************************************/
    @isTest
    public class Core_Daily_Weekly_BUBatch_Schedule_Test {
        
         public static testMethod void testschedule() {
            Test.StartTest();
            Core_Daily_BatchToUpdateBU_Schedule Daily = new Core_Daily_BatchToUpdateBU_Schedule();
            String cron = '0 0 4 * * ?';
            String JobId=system.schedule('BU Short Name Daily Batch', cron, Daily );
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(cron, ct.CronExpression,'0 0 3 * * ?');
            Test.stopTest();
        }
        
         public static testMethod void BUupdateWeekly() {
            Test.StartTest();
            Core_Weekly_BatchToUpdateBU_Schedule Weekly1 = new Core_Weekly_BatchToUpdateBU_Schedule();
            String cron1 = '0 0 4 ? * WED *';
             String JobId=system.schedule('BU Short Name Weekly Batch', cron1, Weekly1 );
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
             System.assertEquals(cron1, ct.CronExpression,'0 0 4 * * ?');
            Test.stopTest();
        }
        
         public static testMethod void BUupdateOnWeekend() {
            Test.StartTest();
            Core_Weekly1_BatchToUpdateBU_Schedule sch = new Core_Weekly1_BatchToUpdateBU_Schedule();
            String cron2 = '0 0 4 ? * SAT *';
            String JobId=system.schedule('BU Short Name Weekend Batch', cron2, sch );
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
             System.assertEquals(cron2, ct.CronExpression,'0 0 4 * * ?');
            Test.stopTest();
        }
        
    }