/**************************************************************************************
Apex Class Name:  Core_IPS_AccountTeam_DeletedRecSch_Test
Version     : 1.0 
Created Date: 5/10/16
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              5/10/16                Initial Revision
*************************************************************************************/
@istest
public class Core_IPS_AccountTeam_DeletedRecSch_Test {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
    
   //Updated the Year by Sowmya - Start - 10/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
   public static String CRON_EXP = '0 0 0 15 10 ? 2042';
 	//Sowmya -End - 10/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
    		
   static Core_Batch_Header__c batchHeader;
 
   static testmethod void test() {

      batchHeader                = new Core_Batch_Header__c();
      batchHeader.Description__c = 'Batch delete';
      batchHeader.Name           = 'Core_IPS_AccountTeam_DeletedRecords_Bulk';        
      insert batchHeader;   
   
      Test.startTest();
 
      // Schedule the test job
      String jobId = System.schedule('Core_IPS_AccountTeam_DeletedRecords_Schd',
                        CRON_EXP,
                        new Core_IPS_AccountTeam_DeletedRecords_Schd());
          
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
 
      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, ct.CronExpression);
 
      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);
 
      // Verify the next time the job will run
      System.assertEquals('2042-10-15 00:00:00', String.valueOf(ct.NextFireTime));
         
      Test.stopTest(); 
   }
        
}