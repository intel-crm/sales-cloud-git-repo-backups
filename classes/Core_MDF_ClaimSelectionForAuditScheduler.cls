/****************************************************************************************************************************************
* Class Name        : Core_MDF_ClaimSelectionForAuditScheduler
* Created Date      : 7/12/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VK       7/12/2020         It is the Schedulable class which calls the batch job to pick up claims for audit
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ClaimSelectionForAuditScheduler implements Schedulable{
    public void execute (SchedulableContext sc){
        Core_MDF_ClaimSelectionForAudit_Batch auditBatch = new  Core_MDF_ClaimSelectionForAudit_Batch();
        Database.executeBatch(auditBatch);
    }
}