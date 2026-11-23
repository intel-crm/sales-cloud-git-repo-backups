global class Core_Schedule_Batch_Delete_Old_Logs implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_Delete_Old_Log_Entries());
    }
}