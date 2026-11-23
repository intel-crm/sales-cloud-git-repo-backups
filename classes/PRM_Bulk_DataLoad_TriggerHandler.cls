public class PRM_Bulk_DataLoad_TriggerHandler extends TriggerHandler {
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_Bulk_DataLoad_TriggerHandler';
    public static final String LOG_ENTRY_PROJECT  = 'Bulk Data Upload';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_Bulk_DataLoad_TriggerHandler';
    public static final String LOG_ENTRY_SEVERITY = 'error';
    public static String sanitizedSearchKey = String.escapeSingleQuotes(UserInfo.getUserId());
    public static User user = [select Id, username,Core_IPA_One_Partner_Id__c,Core_IPS_AccountId__c,Email from User where Id = :sanitizedSearchKey];//where Id =: currentUserId  
    public static string userEmail=string.valueOf(user.email);
    public static String uniqueBatchId;

   
    boolean firstRun=true;
    public override void beforeInsert(){        
                
                uniqueBatchId = 'BATCH-' + system.now()+Integer.valueof((Math.random() * 10));
        uniqueBatchId=uniqueBatchId.remove('-').remove(':').remove(' ');
                system.debug('uniqueBatchId-->'+uniqueBatchId);
        if(isActive('Bulk_Data_Upload_Before_Insert') && firstRun){

            try{
            PRM_Bulk_DataLoad_Utility.checkContactExistance((List<PRM_Bulk_Data_Upload__c>)Trigger.new, uniqueBatchId); 
            firstRun=false;
            }
            catch(Exception e){
                System.debug('Exception'+e);
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);            
            }
            
        }
    }
    public override void afterInsert(){
        uniqueBatchId = string.valueOf(system.now()+Integer.valueof((Math.random() * 10)));
        uniqueBatchId=uniqueBatchId.remove('-').remove(':').remove(' ');
        system.debug('uniqueBatchId-->'+uniqueBatchId);  
        List<String> jobStatus = new list<String> {'Processing','Preparing','Queued'};
        List<AsyncApexJob> lstJobs = [SELECT Id FROM  AsyncApexJob
                             WHERE ApexClass.Name = 'PRM_BulkDataUpload_Batch' AND status in: jobStatus 
                             and CreatedBy.email=:userEmail];       
        if(lstJobs.size() == 0){
            System.debug('inside if');
            PRM_BulkDataUpload_Batch bulkBatch = new PRM_BulkDataUpload_Batch();
            System.debug('Executing batch');
            //database.executeBatch(bulkBatch, 14);
            try{
                System.scheduleBatch(bulkBatch, 'Bulk Data Upload'+uniqueBatchId, 1, 14);
            }
            catch(Exception e){
                System.debug('Exception'+e);
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
            }
            
        }                     
    }
}