/******************************************************************************************************
 * Class Name  : Core_MDF_BatchErrorEvent_ServiceHandler
 * Version     : 1.0
 * Created Date: 1/17/2020
 * Modification Log :
 * Developer            Date               Description
 * -----------------------------------------------------------------------------------------------------
 * Accenture - VK      1/17/2020           Service Class for handling trigger related functions on BatchApexErrorEvent.
 *******************************************************************************************************/
public class Core_MDF_BatchErrorEvent_ServiceHandler {
    
    /*****************************************************************************************************
       Method Name :   insertLogEntryRecord
       @return     :   Void
       @parameters :   List<BatchApexErrorEvent> from trigger
       Description :   Create/Update batch apex error log record
       Added By    :   Accenture - VK - 1/17/2020 
       Modified By :                               Date:                   Changes:
     ******************************************************************************************************/
    public static void insertLogEntryRecord(List<BatchApexErrorEvent> errorList){
        
        //Log entry records to insert/update
        Map<Id,Core_MDF_Batch_Apex_Error_Log__c> errorLogsById = new Map<Id,Core_MDF_Batch_Apex_Error_Log__c>();

        Set<Id> jobIdSet = new Set<Id>();
        Set<Id> scopeIdSet = new Set<Id>();
        
        //key : log record Id , in case of retry the log record Id will be the scope from event
        Map<Id,Core_MDF_Batch_Apex_Error_Log__c> logRecordIdMap = new Map<Id,Core_MDF_Batch_Apex_Error_Log__c>();


        for(BatchApexErrorEvent event : errorList) {
            jobIdSet.add(event.AsyncApexJobId);
            //if the error is from retry, the job scope will be the record id of the batch apex error log
            if(event.JobScope.startsWith('a4g')){
                scopeIdSet.add(event.JobScope);
            }
        }
        
        Map<Id, JobInfo> jobs = new RuntimeJobInfoResolver().resolveById(jobIdSet);
        
        if(scopeIdSet != NULL && scopeIdSet.Size() > 0){
            for(Core_MDF_Batch_Apex_Error_Log__c log : [SELECT Id,Core_MDF_Status_nm__c,Core_MDF_Scope_txt__c,Core_MDF_Counter_nbr__c,Core_MDF_Job_Id__c,
                                                        Core_MDF_Exception_Message_txt__c, Core_MDF_Type_of_exception_txt__c,Core_MDF_Details_txt__c
                                                        FROM Core_MDF_Batch_Apex_Error_Log__c 
                                                        WHERE Id =:scopeIdSet]){
                logRecordIdMap.put(log.Id,log);
            }
        }
        
        for(BatchApexErrorEvent event : errorList) {
            Id jobId = event.AsyncApexJobId;
            JobInfo asyncApexJob = jobs.get(jobId);
            if(asyncApexJob != null) {
                String apexClassName = asyncApexJob.ApexClassName;
                String jobScope = event.JobScope;
                // From retry job?
                if(apexClassName == 'GenericRetryBatchClass') {
                    if(logRecordIdMap.containsKey(jobScope) && logRecordIdMap.get(jobScope) != NULL){
                        logRecordIdMap.get(jobScope).Core_MDF_Counter_nbr__c += 1;
                        logRecordIdMap.get(jobScope).Core_MDF_Exception_Message_txt__c = event.Message;
                        logRecordIdMap.get(jobScope).Core_MDF_Type_of_exception_txt__c = event.ExceptionType;
                        logRecordIdMap.get(jobScope).Core_MDF_Details_txt__c = event.StackTrace;
                        errorLogsById.put(event.AsyncApexJobId, logRecordIdMap.get(jobScope));
                    }
                }
                else{
                    Core_MDF_Batch_Apex_Error_Log__c log = new Core_MDF_Batch_Apex_Error_Log__c();
                    log.Core_MDF_Job_Id__c  = jobId;
                    log.Core_MDF_Exception_Message_txt__c = event.Message;
                    log.Core_MDF_Type_of_exception_txt__c = event.ExceptionType;
                    log.Core_MDF_Apex_Class_txt__c = asyncApexJob.ApexClassName;
                    log.Core_MDF_Scope_txt__c = event.JobScope;
                    log.Core_MDF_Details_txt__c = event.StackTrace;
                    log.Core_MDF_Status_nm__c = 'Failed';
                    log.Core_MDF_Counter_nbr__c = 0;
                    errorLogsById.put(event.AsyncApexJobId, log);
                }
            }
        }
        
        upsert errorLogsById.values() Core_MDF_Job_Id__c;
        //List of class names obtained from Job Id i.e. to get the batch class name
    }

    //Abstract queries made against AsyncApexJob to aid testability
    public abstract class JobInfoResolver {
        public abstract Map<Id, JobInfo> resolveById(Set<Id> jobIds);
    }
    public class RuntimeJobInfoResolver extends JobInfoResolver {
        public override Map<Id, JobInfo> resolveById(Set<Id> jobIds) {
            Map<Id, JobInfo> jobsById = new Map<Id, JobInfo>();
            for(AsyncApexJob job : [select id, CreatedDate, ApexClass.Name from AsyncApexJob where Id IN :jobIds]) {
                JobInfo jobInfo = new JobInfo();
                jobInfo.Id = job.Id;
                jobInfo.ApexClassName = job.ApexClass.Name;
                jobInfo.CreatedDate = job.CreatedDate;
                jobsById.put(jobInfo.Id, jobInfo);
            }
            return jobsById;
        }
    }

    public class JobInfo {
        public Id Id;
        public String ApexClassName;
        public DateTime CreatedDate;
    }
}