@isTest
public class PMP_RetryFailedCalloutScheduler_Test {
	
    static testMethod void testMethod1(){
        Test.startTest();
        Core_Batch_Header__c testbatchheader = new Core_Batch_Header__c();
        List<String> staticResourceNames = new List<String>();
        testbatchheader.Name = 'PMP_FailedCalloutQueueable';
        testbatchheader.Email_Distribution_List__c = 'abc@test.com';
        insert testbatchheader;
                
		PMP_RetryFailedCalloutScheduler retryCallout = new PMP_RetryFailedCalloutScheduler();
		
        String CRON_EXP = '0 0 0 15 3 ? *';
		
	    String jobId = System.schedule('RetryCalloutApexClassTest',  CRON_EXP, retryCallout);
	    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	    System.assertEquals(CRON_EXP, ct.CronExpression);
	    System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}