global without sharing class Core_Schedule_Batch_Unlock_Opportunities implements Schedulable { //TWC3123-5376: code scan fix
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_Unlock_Opportunities());
    }
}