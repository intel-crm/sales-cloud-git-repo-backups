public class TestBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        TestBatch tBatch=new TestBatch();
        Database.executeBatch(tBatch);
    }
}