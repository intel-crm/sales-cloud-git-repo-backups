global class Core_GEC_Summary_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_FailedGEC_Summary_Email());
    }
}