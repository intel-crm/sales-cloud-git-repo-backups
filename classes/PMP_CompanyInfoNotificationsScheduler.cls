/*************************************************************************************************************************************************************************
* Class Name  : PMP_CompanyInfoNotificationsScheduler 
* Version     : 1.0 
* Created Date: 06/11/2020
* Modification Log :
* Developer:Abhishek
* Description : Scheduler class for PMP_CompanyInfoNotificationsBatch 
* batch Size: Batch size should always be 1.[Very Important] 
*******************************************************************************************************************************************************************************/

global with sharing class PMP_CompanyInfoNotificationsScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        PMP_CompanyInfoNotificationsBatch b = new PMP_CompanyInfoNotificationsBatch();
        Id batchProcessId = Database.executeBatch(b,1); //batch size should always be 1!

    }
}