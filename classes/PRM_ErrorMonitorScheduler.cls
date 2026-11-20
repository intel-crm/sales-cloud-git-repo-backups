global with sharing class PRM_ErrorMonitorScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        //Invoke the batch class
        Database.executeBatch(new PRM_ErrorMonitor_Batch());
    }
}