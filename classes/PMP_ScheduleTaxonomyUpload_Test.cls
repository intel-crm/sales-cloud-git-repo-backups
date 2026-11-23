/****************************************************************************************************************************************
* Class Name  : PMP_ScheduleTaxonomyUpload_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     04/11/2019                    US329999 - Test class for PMP_ScheduleTaxonomyUpload
* ****************************************************************************************************************************************/

@isTest
public class PMP_ScheduleTaxonomyUpload_Test {
    
    @isTest
    public static void testSchedule()
    {
        Test.startTest();
       
        Core_Batch_Header__c testbatchheader = new Core_Batch_Header__c();
        List<String> staticResourceNames = new List<String>();
        testbatchheader.Name = 'PMP_TaxonomyUploadQueueable';
        testbatchheader.Email_Distribution_List__c = 'abc@test.com';
        insert testbatchheader;
                
		PMP_ScheduleTaxonomyUpload scheduleUpload = new PMP_ScheduleTaxonomyUpload();
		
        String CRON_EXP = '0 0 0 15 3 ? *';
		
	    String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, scheduleUpload);
	    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	    System.assertEquals(CRON_EXP, ct.CronExpression);
	    System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        
    }
    
 }