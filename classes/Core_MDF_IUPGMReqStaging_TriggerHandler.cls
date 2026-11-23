/*****************************************************************************************************
Class Name          :    Core_MDF_IUPGMReqStaging_TriggerHandler
Test Class Name     :    Core_MDF_IUPGMReqStaging_SH_Test
Description         :    Trigger handler for Core_MDF_IUPGM_Request_Staging__c. It normalizes
                          request data, blocks invalid status regressions, and routes records into
                          the asynchronous AGS/IUPGM processing flow.
Created By          :    Ramapriya
******************************************************************************************************/
public class Core_MDF_IUPGMReqStaging_TriggerHandler {
/** Initializes new staging records with defaults and trimmed values. */
   public void beforeInsert(
        List<Core_MDF_IUPGM_Request_Staging__c> newList
    ) {
        for (Core_MDF_IUPGM_Request_Staging__c rec : newList) {

            // Copy_Pending rows are internal previews of a Copy User Access and must keep their status.
            if (rec.Core_MDF_Request_Status_nm__c != 'Copy_Pending') {
                rec.Core_MDF_Request_Status_nm__c = 'New';
            }
            rec.Core_MDF_Is_IUPGM_Processed__c = false;

            if (String.isNotBlank(rec.Core_MDF_IUPGM_Role_nm__c)) {
                rec.Core_MDF_IUPGM_Role_nm__c = rec.Core_MDF_IUPGM_Role_nm__c.trim();
            }
            if (String.isNotBlank(rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c)) {
                rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c =
                    rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c.trim();
            }
            if (String.isNotBlank(rec.Core_MDF_IUPGM_Program__c)) {
                rec.Core_MDF_IUPGM_Program__c = rec.Core_MDF_IUPGM_Program__c.trim();
            }

            // If AllAccounts = true and account is set, clear account
            if (rec.Core_MDF_IUPGM_All_Account_Access__c == true
                && rec.Core_MDF_IUPGM_Account__c != null) {
                rec.Core_MDF_IUPGM_Account__c = null;
            }
        }
    }
/******************************************************************************************************
    Method Name:        beforeUpdate   
    Description:        Prevents invalid terminal-state changes while allowing controlled field updates.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public void beforeUpdate(
        List<Core_MDF_IUPGM_Request_Staging__c> newList,
        Map<Id, Core_MDF_IUPGM_Request_Staging__c> oldMap
    ) {
        for (Core_MDF_IUPGM_Request_Staging__c rec : newList) {
            String oldStatus = oldMap.get(rec.Id).Core_MDF_Request_Status_nm__c;
            String newStatus = rec.Core_MDF_Request_Status_nm__c;

            // Completed is terminal — status cannot be changed
            if (oldStatus == 'Completed' && newStatus != 'Completed') {
                rec.addError(
                    'This request is already Completed and cannot be re-opened. '
                    + 'Please submit a new request if access changes are needed.'
                );
            }

            // External_User_Blocked — only block status field changes.
            if (oldStatus == 'External_User_Blocked'
                && newStatus != 'External_User_Blocked') {
                rec.addError(
                    'This request was blocked because the user has an '
                    + 'external/partner profile. Submit a new request '
                    + 'for a different user.'
                );
            }
        }
    }
/******************************************************************************************************
    Method Name:        afterInsert   
    Description:        Enqueues initial processing for newly inserted staging records.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public void afterInsert(
        List<Core_MDF_IUPGM_Request_Staging__c> newList
    ) {
        // Copy_Pending previews are not requests yet - they must not enter processing before confirmation.
        Map<Id, Core_MDF_IUPGM_Request_Staging__c> nonPending = new Map<Id, Core_MDF_IUPGM_Request_Staging__c>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : newList) {
            if (rec.Core_MDF_Request_Status_nm__c != 'Copy_Pending') nonPending.put(rec.Id, rec);
        }
        Set<Id> ids = nonPending.keySet();
        System.debug('afterInsert: dispatching ' + ids.size() + ' records');
        if (!ids.isEmpty()) {
            System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(
                ids,
                Core_MDF_IUPGMReqStaging_Queueable.Operation.INITIATE
            ));
        }
    }
/******************************************************************************************************
    Method Name:        afterUpdate   
    Description:        Reacts to AGS approval transitions and finalizes request processing.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public void afterUpdate(
        List<Core_MDF_IUPGM_Request_Staging__c> newList,
        Map<Id, Core_MDF_IUPGM_Request_Staging__c> oldMap
    ) {
        Set<Id> userCreationApproved = new Set<Id>();
        Set<Id> psApproved           = new Set<Id>();

        for (Core_MDF_IUPGM_Request_Staging__c rec : newList) {
            Core_MDF_IUPGM_Request_Staging__c old = oldMap.get(rec.Id);

            // Only fire when AGS_Status changes TO Approved
            // AND record is not yet processed
            Boolean agsJustApproved =
                rec.Core_MDF_AGS_Status_nm__c == 'Approved'
                && old.Core_MDF_AGS_Status_nm__c != 'Approved'
                && !rec.Core_MDF_Is_IUPGM_Processed__c;

            if (!agsJustApproved) continue;

            if (rec.Core_MDF_Request_Status_nm__c == 'AGS_User_Creation_Pending') {
                userCreationApproved.add(rec.Id);
            } else if (rec.Core_MDF_Request_Status_nm__c == 'AGS_PS_Pending') {
                psApproved.add(rec.Id);
            }
        }
        if (!userCreationApproved.isEmpty() || !psApproved.isEmpty()) {
            Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>> ops =
                new Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>>();

            if (!userCreationApproved.isEmpty()) {
                ops.put(Core_MDF_IUPGMReqStaging_Queueable.Operation.USER_CREATED,
                    userCreationApproved);
            }
            if (!psApproved.isEmpty()) {
                ops.put(Core_MDF_IUPGMReqStaging_Queueable.Operation.PS_APPROVED,
                    psApproved);
            }
            System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(ops));
        }

        // Email the requested user whenever a request reaches a terminal status.
        // COPY requests are routed to a separate, consolidated "operation complete"
        Set<Id> notifyIds = new Set<Id>();
        Set<String> copyOperationIdsToCheck = new Set<String>();
        Set<Id> coreAccessCompletedWithPendingRole = new Set<Id>();
        Set<String> terminal = Core_MDF_CCP_ConstantClass.IUPGM_TERMINAL_STATUSES;
        for (Core_MDF_IUPGM_Request_Staging__c rec : newList) {
            String oldStatus = oldMap.get(rec.Id).Core_MDF_Request_Status_nm__c;
            String newStatus = rec.Core_MDF_Request_Status_nm__c;
            if (newStatus != oldStatus && newStatus == 'Completed'
                && String.isNotBlank(rec.Core_MDF_Pending_Dependent_Role_txt__c)) {
                coreAccessCompletedWithPendingRole.add(rec.Id);
            }
            if (newStatus != oldStatus && terminal.contains(newStatus)) {
                if (rec.Core_MDF_Request_Type_nm__c == 'COPY'
                    && String.isNotBlank(rec.Core_MDF_Copy_Operation_Id__c)) {
                    copyOperationIdsToCheck.add(rec.Core_MDF_Copy_Operation_Id__c);
                } else {
                    notifyIds.add(rec.Id);
                }
            }
        }
        if (!notifyIds.isEmpty()) {
            Core_MDF_IUPGMReqStaging_ServiceHandler.notifyRequestedUsers(notifyIds);
        }
        if (!copyOperationIdsToCheck.isEmpty()) {
            Core_MDF_IUPGMReqStaging_ServiceHandler.notifyCopyOperationIfComplete(copyOperationIdsToCheck);
        }
        if (!coreAccessCompletedWithPendingRole.isEmpty()) {
            Core_MDF_IUPGMReqStaging_ServiceHandler.submitPendingDependentRoles(
                coreAccessCompletedWithPendingRole);
        }
    }
}