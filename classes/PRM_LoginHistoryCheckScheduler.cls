public with sharing class PRM_LoginHistoryCheckScheduler implements Schedulable {
    public IPA_Batch_Configurations__mdt mdt=IPA_Batch_Configurations__mdt.getInstance('PRM_LoginHistoryCheckBatch');
    public integer batchsize=(mdt!=null && mdt.Batch_Size__c!=null)?integer.valueof(mdt.Batch_Size__c):200;
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new PRM_LoginHistoryCheckBatch(), batchsize);
    }
}