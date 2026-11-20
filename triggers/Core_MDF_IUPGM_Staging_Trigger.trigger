/*****************************************************************************************************
Trigger Name        :    Core_MDF_IUPGM_Staging_Trigger
Handler Class       :    Core_MDF_IUPGMReqStaging_TriggerHandler
Description         :    Delegates Core_MDF_IUPGM_Request_Staging__c lifecycle events to the trigger
                         handler so validation, orchestration, and async handoff logic stay outside
                         the trigger body.
Created By          :    Ramapriya
******************************************************************************************************/
trigger Core_MDF_IUPGM_Staging_Trigger
on Core_MDF_IUPGM_Request_Staging__c
(
    before insert,
    before update,
    after insert,
    after update
) {

    Core_MDF_IUPGMReqStaging_TriggerHandler handler =
        new Core_MDF_IUPGMReqStaging_TriggerHandler();

    // Before-context logic prepares and validates staging records before they are committed.
    if (Trigger.isBefore) {

        if (Trigger.isInsert) {

            handler.beforeInsert(
                Trigger.new
            );
        }

        if (Trigger.isUpdate) {

            handler.beforeUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }
    }

    // After-context logic starts downstream processing once the staging records have been saved.
    if (Trigger.isAfter) {

        if (Trigger.isInsert) {

            handler.afterInsert(
                Trigger.new
            );
        }

        if (Trigger.isUpdate) {

            handler.afterUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }
    }
}