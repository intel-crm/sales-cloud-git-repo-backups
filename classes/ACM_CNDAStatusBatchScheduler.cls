public class ACM_CNDAStatusBatchScheduler implements Schedulable{
    
    // Execute method to run the batch job
    public void execute(SchedulableContext SC) {
        // Instantiate the batch class
        ACM_CNDAStatusBatch batch = new ACM_CNDAStatusBatch();
        
        // Set the batch size to 25 and execute the batch
        Database.executeBatch(batch, 25);
    }

}