/****************************************************************************************************************************************
* Class Name        : Core_MDF_RMFNotification_Scheduler
* Created Date      : 10/21/2021
*****************************************************************************************************************************************/
public without sharing class Core_MDF_RMFNotification_Scheduler implements Schedulable{
   String geo;
    public Core_MDF_RMFNotification_Scheduler(String geo){
        geo= this.geo;
    }
    public void execute (SchedulableContext sc){
        Core_MDF_RMF_ScheduledNotification_Batch schBatchObj = new  Core_MDF_RMF_ScheduledNotification_Batch(geo);
        Database.executeBatch(schBatchObj,20);
    }
}