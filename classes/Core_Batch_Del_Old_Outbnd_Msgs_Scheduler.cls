global class Core_Batch_Del_Old_Outbnd_Msgs_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_Del_Old_Outbnd_Msgs());
    }
}