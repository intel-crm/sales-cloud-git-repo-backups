global class SchedulableBatchDR implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Instantiate your batch class
        BatchClassforDR myBatch = new BatchClassforDR();

        // Start the batch job
        Database.executeBatch(myBatch);
    }
}