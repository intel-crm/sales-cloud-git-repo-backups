/****************************************************************************************************************************************
* Class Name  : PMP_RetryFailedCalloutScheduler 
* Version     : 1.0 
* Created Date: 08-01-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Prakash                         Aug-01-2019                    Scheduler to re-process failed callout records
* ****************************************************************************************************************************************/
global with sharing class PMP_RetryFailedCalloutScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        PMP_RetryFailedCalloutBatch retryCalloutBatch = new PMP_RetryFailedCalloutBatch (); 
        database.executebatch(retryCalloutBatch,1);
    }
}