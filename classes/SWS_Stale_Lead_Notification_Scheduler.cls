/****************************************************************************************************
Apex Class Name : SWS_Stale_Lead_Notification_Scheduler
Version         : 1.0
Created Date    : 2026-11-09
Function        : Weekly schedule entry point to kick off SWS_Stale_Lead_Notification_Batch.
Created By      : Naveen Muthuramalingam
Test Class      : SWS_Stale_Lead_Notification_BatchTest
*****************************************************************************************************/
global without sharing class SWS_Stale_Lead_Notification_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new SWS_Stale_Lead_Notification_Batch(), 200);
    }
}