global with sharing class PRM_ACMAutomationBatchSchedular implements Schedulable{
    global void execute(SchedulableContext sc) {
        //invoke the batch class
        Database.executeBatch(new PRM_ACMUpdateBatchUtility(),1);
    }
}