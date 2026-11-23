global class Core_Schedule_Batch_Delete_Dup_Accounts implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_Delete_Dup_Accounts());
    }
}