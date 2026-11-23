global class Core_Schedule_Batch_Int_Inbound_Msgs implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_Delete_Int_Inbound_Msgs());
    }
}