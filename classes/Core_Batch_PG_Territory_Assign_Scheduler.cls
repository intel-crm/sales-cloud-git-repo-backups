global without sharing class Core_Batch_PG_Territory_Assign_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_PG_To_Territory_Assignment());
    }
}