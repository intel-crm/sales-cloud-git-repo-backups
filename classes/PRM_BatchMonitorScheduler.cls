global with sharing class PRM_BatchMonitorScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        //Invoke the batch class
        Database.executeBatch(new PRM_BatchMonitor());
    }
}