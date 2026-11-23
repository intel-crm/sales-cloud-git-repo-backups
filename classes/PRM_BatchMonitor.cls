global class PRM_BatchMonitor implements Database.Batchable<sObject> {
    
    Private static final string STATUS_REP = 'Reprocessed';
    Private static final string STATUS_NEW = 'New';
    Private static final string STATUS_QUEUED = 'Queued';
    Private static final string BATCH_APEX = 'BatchApex';
    Private static final string SCH_APEX = 'ScheduledApex';
    Private static final string STATUS_COMPELETED = 'Completed';
    Private static final string INTEGRATION_TYPE_FAILURE = 'OPID Inbound Failure';
    Private static final string INTEGRATION_TYPE_MISSING = 'OPID Not Received';
    Private static final string INTEGRATION_TYPE_BATCH_FAILURE = 'Batch Failure';
    Private static final Integer BatchMonitor_Date = -1;

    global static Database.QueryLocator start(Database.BatchableContext context){
        List<String> jobName = System.label.ApexJobName.split(';');
        
        DateTime dt = DateTime.Now().AddDays(BatchMonitor_Date);  
        String jobInfo = 'Select id,ApexClass.Name,JobType, NumberOfErrors,Status,ExtendedStatus, CreatedDate from AsyncApexJob where  (JobType =\'BatchApex\' or JobType = \'ScheduledApex\') and CreatedDate >= :dt'+(Test.isRunningTest()? ' and ExtendedStatus!=NULL ':'')+' and ApexClass.Name = :jobName';
        return Database.getQueryLocator(jobInfo);
    } 
    
    global void execute(Database.BatchableContext context, List<AsyncApexJob> scope){
        PRM_BatchMonitor_Utility.checkBatchStatus(scope);
    }
    
    global void finish(Database.BatchableContext BC){
        //Set<Id> jobId = new Set<Id>();
        List<Monitor_Log__c> updateBatchLogs = new List<Monitor_Log__c>();
        Map<Id,Monitor_Log__c> batchLog = new Map<Id,Monitor_Log__c>();
        
        for(Monitor_Log__c log : [SELECT id,Job_Id__c, Apex_Class__c,Error_Message__c, Integration_Type__c,Status__c,CreatedDate from Monitor_Log__c where Status__c = :STATUS_QUEUED and Integration_Type__c = :INTEGRATION_TYPE_BATCH_FAILURE]){
            if(!batchLog.containsKey(log.Job_Id__c)){
                batchLog.put(log.Job_Id__c,log);
            }
        }
        List<AsyncApexJob> jobQueue = [select id,ApexClass.Name,JobType, NumberOfErrors,Status,ExtendedStatus,CreatedDate from AsyncApexJob  where (JobType = :SCH_APEX OR JobType = :BATCH_APEX) and Id = :batchLog.keyset()];
        if(jobQueue.size()>0){
            for(AsyncApexJob rec : jobQueue){
                if(batchLog.containsKey(rec.Id) && rec.Status == STATUS_COMPELETED){
                    batchLog.get(rec.Id).Status__c = rec.Status;
                    updateBatchLogs.add(batchLog.get(rec.Id));
                }
            }    
        }
        try{
            if(updateBatchLogs.size()>0 && updateBatchLogs != NULL){
                update updateBatchLogs;
            }    
        }catch(DmlException e) {
            //System.debug('Exception: ' + e.getMessage());   
        }
    }
}