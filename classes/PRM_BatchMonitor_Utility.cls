public with sharing class PRM_BatchMonitor_Utility {
   
  	Private static final string STATUS_FAILED = 'Failed';
    Private static final string BATCH_APEX = 'BatchApex';
    Private static final string SCH_APEX = 'ScheduledApex';
    Private static final string STATUS_QUEUED = 'Queued';
    Private static final string STATUS_REP = 'Reprocessed';
    Private static final string INTEGRATION_TYPE_BATCH_FAILURE = 'Batch Failure';
    Private static final Integer BatchMonitor_Time = -2;
    
    public static void checkBatchStatus(List<AsyncApexJob> scope){
        
        List<Monitor_Log__c> batchRecords = new List<Monitor_Log__c>();
       
        
        DateTime dt1 = DateTime.Now().Addhours(BatchMonitor_Time);
        
         for(AsyncApexJob job : scope){
        	if(job.JobType == BATCH_APEX && String.isNotBlank(job.ExtendedStatus)){     
                Monitor_Log__c batchFailed = new Monitor_Log__c();
                batchFailed = getMonitorLogInstance(job.Id,INTEGRATION_TYPE_BATCH_FAILURE,job.ApexClass.Name,job.NumberOfErrors,job.ExtendedStatus,STATUS_FAILED,job.CreatedDate);
                batchRecords.add(batchFailed);
            }
             else if((job.JobType == SCH_APEX  || job.JobType == BATCH_APEX) && job.Status == STATUS_QUEUED && job.CreatedDate <= dt1 ){
                 Monitor_Log__c batchQueue = new Monitor_Log__c();
                 batchQueue = getMonitorLogInstance(job.Id,INTEGRATION_TYPE_BATCH_FAILURE,job.ApexClass.Name,job.NumberOfErrors,job.ExtendedStatus,STATUS_QUEUED,job.CreatedDate);
                 batchRecords.add(batchQueue);
            } 
           
             
        }
        
     
        try{
        	 if(batchRecords.size()>0 && batchRecords != NULL){
            	Database.insert(batchRecords);
    		}    
        }catch(DMLException ex){
            System.debug('Exception: ' + ex.getMessage());
        }
        
        
    }
    

    
    public static Monitor_Log__c getMonitorLogInstance (Id jobId, String integType, String className, Integer numberOfError, String extStatus, String status, Datetime dtm ) {
       	Monitor_Log__c batchLog = new Monitor_Log__c();
        batchLog.Job_Id__c = jobId;
        batchLog.Integration_Type__c = integType;
        batchLog.Apex_Class__c = className;
        batchLog.Number_Of_Errors__c = numberOfError;
        batchLog.Error_Message__c = extStatus;
        batchLog.Status__c = status;
        batchLog.Submitted_Date_Time__c = dtm;
        
        return batchLog;
      
    }
}