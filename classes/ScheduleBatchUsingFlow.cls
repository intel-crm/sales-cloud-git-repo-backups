public class ScheduleBatchUsingFlow {
 @InvocableMethod
     public static void BatchFlow() {
        PSG_BatchUpdatePRIDs job = new PSG_BatchUpdatePRIDs();
        Id jobId=Database.executeBatch(job, 1);
    }
}