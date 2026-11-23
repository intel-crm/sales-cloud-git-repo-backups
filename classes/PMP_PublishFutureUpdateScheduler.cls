/****************************************************************************************************************************************
* Class Name  : PMP_PublishFutureUpdateScheduler 
* Version     : 1.0 
* Created Date: 06/28/2019 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                          06/28/2019                    This class is a Scheduler class for PMP_PublishFutureUpdateScheduler class
*****************************************************************************************************************************************/
//IPA2.0 - As part of TWC729-7977 commented the entire class 
global with sharing class PMP_PublishFutureUpdateScheduler{
	public static Boolean isWorking() {
        return true;
    }

 /*implements schedulable  {
	global void execute(SchedulableContext sc)  
    { 
        PMP_PublishFutureUpdateOfferings objScheduler = new PMP_PublishFutureUpdateOfferings();   
        Database.executebatch(objScheduler,1);   
        // Reduced the chunk size from 35 to 10 to avoid the error : Too many queueable jobs added to the queue
        // This error is because as we are inserting/creating new records for published, even these newly created offerings are getting added to the queue. to avoid it reduced the chunk size to 10
    }*/
}