/*****************************************************************************************************
Class Name          :    Core_MDF_AGS_PollStatus_Batch
Test Class Name     :    Core_MDF_AGS_PollStatus_Batch_Test
Description         :    Batchable wrapper that periodically polls AGS for the real approval/provisioning
                         status of pending IUPGM staging records (via
                         Core_MDF_IUPGMReqStaging_ServiceHandler.pollAgsPendingBatch). Registered in the
                         Core_MDF_Batch_Scheduler__c framework (Frequency = "Every X Hour") so it re-chains
                         itself automatically instead of relying on a manual/anonymous Apex invocation.
Created By          :    Ramapriya
******************************************************************************************************/
public class Core_MDF_AGS_PollStatus_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    /******************************************************************************************************
    Method Name:        start
    Description:        Provides the query locator for staging records currently awaiting an AGS outcome.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Returns all staging records currently awaiting an AGS user-creation/permission-set outcome. */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Core_MDF_IUPGMReqStaging_ServiceHandler.pollAgsPendingQueryLocator();
    }
    /******************************************************************************************************
    Method Name:        execute
    Description:        Polls AGS for each record in the current scope and advances its status accordingly.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Processes one batch scope of pending staging records against AGS. */
    public void execute(
        Database.BatchableContext bc,
        List<Core_MDF_IUPGM_Request_Staging__c> scope
    ) {
        Core_MDF_IUPGMReqStaging_ServiceHandler.pollAgsPendingBatch(scope);
    }
    /******************************************************************************************************
    Method Name:        finish
    Description:        Logs completion of the AGS status-polling batch job.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Logs job completion; the Core_MDF_Batch_Scheduler__c framework handles re-chaining the next run. */
    public void finish(Database.BatchableContext bc) {
        System.debug('Core_MDF_AGS_PollStatus_Batch finished. JobId=' + bc.getJobId());
    }
}