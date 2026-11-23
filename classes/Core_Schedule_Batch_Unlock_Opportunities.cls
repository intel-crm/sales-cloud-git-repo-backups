global class Core_Schedule_Batch_Unlock_Opportunities implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_Unlock_Opportunities());
    }
}