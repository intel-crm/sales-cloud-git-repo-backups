global class Core_AGSRetryScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Database.executeBatch(
            new Core_AGSRetryBatch(),
            200
        );
    }
}