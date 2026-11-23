global without sharing class Core_MDF_SchBatch_AuditRetry implements Schedulable{

    global void execute(SchedulableContext sc) {
        String query='SELECT id,Title,Core_MDF_Program__c,Core_MDF_Audit_Hold__c,Core_MDF_Audit_Type__c,Core_MDF_FlaggedForAudit__c,'+
        'Core_MDF_Claim_Previous_Status__c,Core_MDF_Status__c,Amount,CreatedById,Core_MDF_Claim_Ref_Number__c,'+
        'createdDate,Core_MDF_Country_Location__c,Core_MDF_Activity_Types__c,Core_MDF_Activity_Category__c,'+
        'Core_MDF_AccountCompany__c,Core_MDF_Pred_IdealModelResult__c,Core_MDF_Pred_ModelTimeStamp__c,Core_MDF_Pred_PredictionResult__c,'+
        'Core_MDF_Pred_PredictionScore__c,Core_MDF_Pred_Probability__c,Core_MDF_Pred_ThresholdFlag__c,'+
        'Core_MDF_Predictive_Audit_Retries__c,Core_MDF_AuditSelectionInProgress__c,Core_MDF_Predictive_Audit_Error__c'+ 
        ' from partnerfundclaim where Core_MDF_Status__c not in : invalidStatusNotToBeRetried and Core_MDF_AuditSelectionInProgress__c = true and Core_MDF_Predictive_Audit_Error__c=true and Core_MDF_Predictive_Audit_Retries__c<4 limit 10000';
         
        Core_MDF_Batch_AuditRetry auditRetryBatch = new Core_MDF_Batch_AuditRetry();
        auditRetryBatch.queryActive = query;
        Database.executeBatch(auditRetryBatch, 100);
     }
}