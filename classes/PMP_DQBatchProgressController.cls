public with sharing class PMP_DQBatchProgressController {
    @AuraEnabled
    public static Id executeBatchJob(){
        Id batchJobId = Database.executeBatch(new PMP_GenerateDQReportBatch('PMP_Company__c'),2);
        return batchJobId;
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [Select Status, NumberOfErrors,JobItemsProcessed,TotalJobItems from AsyncApexJob where Id = :jobID];
        return jobInfo;
    }
    
    @AuraEnabled
    public static Integer getBatchJobInfo(){
        List<AsyncApexJob> jobInfo = [Select Status, NumberOfErrors,JobItemsProcessed,TotalJobItems,ApexClass.Name from AsyncApexJob 
                                      where ApexClass.Name='PMP_GenerateDQReportBatch' and CreatedDate = today];
        if(jobInfo!=null)
        {
            return jobInfo.size();
        }
        else
        {
            return 0;
        }
    }
}