public without sharing class Pricing_QLI_AutoReject_Scheduler implements Schedulable {
    public void execute(SchedulableContext sc) {

        //schedule auto rejection batch which marks pending quotelines to rejected which has Intel Response Requested by Date and Last Submitted Date check
        Pricing_QuoteLine_AutoRejection_Batch autoRejectBatch = new Pricing_QuoteLine_AutoRejection_Batch();
        database.executeBatch(autoRejectBatch, Integer.valueof(Label.Pricing_QuoteLine_AutoReject_BatchSize));
    }
}