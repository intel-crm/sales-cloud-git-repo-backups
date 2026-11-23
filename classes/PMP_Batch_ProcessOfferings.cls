/****************************************************************************************************************************************
* Class Name  : PMP_Batch_ProcessOfferings 
* Version     : 1.0 
* Created Date: 06/28/2019 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                          06/28/2019                    This class is a Scheduler class for PMP_Batch_ProcessOfferings class
*****************************************************************************************************************************************/
global with sharing class PMP_Batch_ProcessOfferings implements schedulable  {
	global void execute(SchedulableContext sc)  
    { 
        PMP_PublishFutureOfferings objScheduler = new PMP_PublishFutureOfferings();   
        Database.executebatch(objScheduler,1);   
        // Reduced the chunk size from 35 to 10 to avoid the error : Too many queueable jobs added to the queue
        // This error is because as we are inserting/creating new records for published, even these newly created offerings are getting added to the queue. to avoid it reduced the chunk size to 10
    } 
}