global class Core_Batch_Del_Old_Inbnd_Msgs_Scheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_Del_Old_Inbnd_Msgs());
    }
}