public without sharing class Core_Contact_EntitlementTriggerHandler extends TriggerHandler {
    public static boolean IPAfirstRunInsert = true;
    public static boolean IPAfirstRunUpdate = true;
    public static boolean IPAfirstentUpdate = true;
    public static boolean isFirstRun = true;
    //  public static boolean isSecond_RDC = true;
    public static String logEntryMsg = '';
    public static final String LOG_ENTRY_ORIGIN = 'Core_Contact_EntitlementTriggerHandler';
    public static final String LOG_ENTRY_PROJECT = 'IPA';
    public static final String LOG_ENTRY_SCOPE = 'Cont_Ent';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';

    public override void afterInsert() {

        if (
            isActive('ContEnt_Insert_IPA_Integration_Trigger') &&
            IPAfirstRunInsert
        ) {
            PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingContEnt(
                (List<Core_Contact_Entitlement__c>) Trigger.New
            );
            IPAfirstRunInsert = false;
        }
        //Added by Sai As part of EBR development
          if (isActive('ER_Update_Contact_Business_Type_Check')){
            Core_Contact_Ent_BT_Handler.upsertContactBusinessTypes((List<Core_Contact_Entitlement__c>) Trigger.new);
                
        }
        //Added by Gaurav - Quest for Creation on CBT from Grant Access
        //Commented by Sai As part of EBR development
      /*  if (
            isActive('ER_Update_Contact_Business_Type_Check') && isFirstRun_RDC
        ) {
            Set<Id> entIds = new Set<Id>();
            Map<Id, Id> getBusinessTypeIdMap = new Map<Id, Id>();

            List<Core_Contact_Entitlement__c> entitlementList = new List<Core_Contact_Entitlement__c>();
            boolean isInsert = false;
            for (
                Core_Contact_Entitlement__c newContEnt : (List<Core_Contact_Entitlement__c>) Trigger.new
            ) {
                if (newContEnt.Core_Source__c == System.Label.ER_EntSource) {
                    entIds.add(newContEnt.Core_Entitlement_Id__c);
                    entitlementList.add(newContEnt);
                }
            }

            if (entIds != null) {
                for (PRM_VXEnttlmntMatrix__c mat : [
                    SELECT
                        Id,
                        Name,
                        PRM_Entitlement_Id__c,
                        PRM_Entitlement_Id__r.Name,
                        Business_Types__c,
                        Business_Types__r.Name
                    FROM PRM_VXEnttlmntMatrix__c
                    WHERE PRM_Entitlement_Id__c IN :entIds
                ]) {
                    if (
                        mat.Business_Types__c != null &&
                        mat.PRM_Entitlement_Id__c != null
                    ) {
                        
                        getBusinessTypeIdMap.put(
                            Id.valueof(mat.PRM_Entitlement_Id__c),
                            Id.valueof(mat.Business_Types__c)
                        );
                        isInsert = true;
                        break;
                    }
                }
            }
            if (isInsert) {
                Core_Contact_Ent_BT_Handler.insertContactBusinessTypes(
                    entitlementList,
                    getBusinessTypeIdMap
                );
                isFirstRun_RDC = false;
            }
        } */
    }
    
    public override void afterUpdate() {
	logEntryMsg += '\nTotal records: ' + Trigger.new;
        //Added by Sai As part of EBR development
        if (isActive('ER_Update_Contact_Business_Type_Check')) {
            Core_Contact_Ent_BT_Handler.upsertContactBusinessTypes((List<Core_Contact_Entitlement__c>) Trigger.New);
        }
        //Commented by Sai As part of EBR development
      /*  if (
            isActive('ER_Update_Contact_Business_Type_Check') && isFirstRun_RDC
        ) {
            boolean isUpdated = false;
            for (
                Core_Contact_Entitlement__c newContEnt : (List<Core_Contact_Entitlement__c>) Trigger.new
            ) {
                 
                if (newContEnt.Core_Status__c == System.Label.ER_Complete) {
                    isUpdated = true;
                    break;
                }
            }
            if (isUpdated) {
                Core_Contact_Ent_BT_Handler.updateContactBusinessTypes(
                    Trigger.new,
                    (Map<id, Core_Contact_Entitlement__c>) Trigger.OldMap
                );
                isFirstRun_RDC = false;
            }
        } */

       
        if (isActive('Core_ContactEntitlementAudienceUpdate')) {
            //  Core_ContactEntitlementAudienceUpdate.updateContactAudience((List<Core_Contact_Entitlement__c>)Trigger.old,
            //  (List<Core_Contact_Entitlement__c>)Trigger.new,
            // (Map<Id,Core_Contact_Entitlement__c>)Trigger.oldMap,
            // (Map<Id, Core_Contact_Entitlement__c>)Trigger.newMap);
        }
        
        // IPA Integration Update Logic
        if (!isActive('ContEnt_Update_IPA_Integration_Trigger') || !IPAfirstRunUpdate) {
            // Early return to reduce nesting
        } else {
            boolean isUpdated = false;
            for (Core_Contact_Entitlement__c newContEnt : (List<Core_Contact_Entitlement__c>) Trigger.new) {
                Core_Contact_Entitlement__c oldContEnt = (Core_Contact_Entitlement__c) Trigger.oldMap.get(newContEnt.Id);
                
                boolean hasSelectedChanged = newContEnt.Core_Selected__c != oldContEnt.Core_Selected__c;
                boolean hasStatusChanged = newContEnt.Core_Status__c != oldContEnt.Core_Status__c;
                boolean isEntitlementType = newContEnt.Core_Type__c == 'Entitlement';
		
				logEntryMsg += '\nProcessing record: ' + newContEnt.Id;
				logEntryMsg += '\nStatusChanged: ' + hasStatusChanged;
				logEntryMsg += '\nSelectedChanged: ' + hasSelectedChanged;

                
                if ((hasSelectedChanged || hasStatusChanged) && isEntitlementType) {
		    
                    logEntryMsg += '\nRecord eligible for IPA update: ' + newContEnt.Id;
                    isUpdated = true;
                    break;
                }
            }
            if (isUpdated) {
                logEntryMsg += '\nExecuting IPA Integration Status Update';
                PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingContEnt(
                    (List<Core_Contact_Entitlement__c>) Trigger.New
                );
                IPAfirstRunUpdate = false;
            }
        }
        
        // Welcome Email Processing
        if (!isActive('WelcomeEmailUponEntitlementCompletion')) {
			logEntryMsg += '\nWelcome Email disabled';
			PRM_RegistrationApprovalEmail.createLogEntry(logEntryMsg,LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY);

    	

            return; // Early return to reduce complexity
        }
        
        // Welcome Email Notifications
        if (isActive('WelcomeEmailUponEntitlementCompletion') && isFirstRun) {
            logEntryMsg += '\nSending Welcome Email';
            isFirstRun = ER_WelcomeEmailUtility.SendWelcomeEmailNotifications(
                (List<Core_Contact_Entitlement__c>) Trigger.new,
                (Map<Id, Core_Contact_Entitlement__c>) Trigger.oldMap
            );
        }
        
        // Process IPA Welcome Emails
        Map<Id, Core_Contact_Entitlement__c> mapOldContactEnt = (Map<Id, Core_Contact_Entitlement__c>) Trigger.oldMap;
        Set<Id> setContacIdForIPAWelcomeEmail = new Set<Id>();
        Set<Id> setContacIdForMpWelcomeEmail = new Set<Id>();
        for (Core_Contact_Entitlement__c contactEnt : (List<Core_Contact_Entitlement__c>) Trigger.new) {
            Core_Contact_Entitlement__c oldContactEnt = mapOldContactEnt.containsKey(contactEnt.id) 
                ? mapOldContactEnt.get(contactEnt.id) 
                : null;
                
            boolean isValidOldRecord = oldContactEnt != null;
            boolean hasStatusChanged = isValidOldRecord && oldContactEnt.Core_Status__c != contactEnt.Core_Status__c;
            boolean isCompleteStatus = contactEnt.Core_Status__c == 'Complete';
            boolean hasContactId = contactEnt.Core_Contact_Id__c != null;
         
            if (isValidOldRecord && hasStatusChanged && isCompleteStatus && hasContactId) {
                setContacIdForIPAWelcomeEmail.add(contactEnt.Core_Contact_Id__c);
                logEntryMsg += '\nContact eligible for IPA welcome email: ' + contactEnt.Core_Contact_Id__c;
            }
           if (isValidOldRecord && hasStatusChanged && isCompleteStatus && hasContactId && 
               (contactEnt.Core_Display_Nm__c == system.label.PRM_Partner_Admin || contactEnt.Core_Display_Nm__c == system.label.PRM_Partner_Admin_Delegate || contactEnt.Core_Display_Nm__c == system.label.PRM_MarketingSpecialist)) {
                setContacIdForMpWelcomeEmail.add(contactEnt.Core_Contact_Id__c);
                logEntryMsg += '\nContact eligible for MP welcome email: ' + contactEnt.Core_Contact_Id__c;
            }
        }
        
        // MP logic
		logEntryMsg += '\nTotal contacts for MP email: ' + setContacIdForMpWelcomeEmail.size();
        if (setContacIdForMpWelcomeEmail != null && !setContacIdForMpWelcomeEmail.isEmpty()) {
            PMP_Utility.sendWelcomeEmailForMP(setContacIdForMpWelcomeEmail);
            logEntryMsg += '\nPMP welcome email triggered';
        }
        
        Map<Id,Set<Id>> AccountContactMap = new Map<Id,Set<Id>>();
        Set<Id> FinalContactsSet = new Set<Id>();

        //rrt - Welcome email Fix --
        for (PRM_Account_Contact_Relationship__c acr : [
            SELECT id,PRM_Account_Id__c,PRM_Contact_Id__c 
            FROM PRM_Account_Contact_Relationship__c 
            WHERE PRM_Status_Nm__c = 'Complete' 
            AND PRM_InActive_Ind__c = FALSE 
            AND PRM_Contact_Id__c IN: setContacIdForIPAWelcomeEmail
        ]) {
            if (!AccountContactMap.containskey(acr.PRM_Account_Id__c)) { Set<Id> ContactSet = new Set<Id>();ContactSet.add(acr.PRM_Contact_Id__c);AccountContactMap.put(acr.PRM_Account_Id__c, ContactSet);
            } else { Set<Id> contids = AccountContactMap.get(acr.PRM_Account_Id__c);
                if (!contids.contains(acr.PRM_Contact_Id__c)) {contids.add(acr.PRM_Contact_Id__c);AccountContactMap.put(acr.PRM_Account_Id__c, contids);
                }
            }
        }
        
        for (PRM_AccountChannelMembership__c acm : [
            SELECT id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__r.name 
            FROM PRM_AccountChannelMembership__c 
            WHERE PRM_Status_Nm__c = 'Approved' 
            AND PRM_Account_Id__c in: AccountContactMap.keySet()
        ]) {
            Set<Id> contids = AccountContactMap.get(acm.PRM_Account_Id__c);FinalContactsSet.addAll(contids);
        }
        //rrt-welcome email fix - end

        if (FinalContactsSet.isEmpty()) {
			logEntryMsg += '\nNo contacts available for EmailQueue';
    	    PRM_RegistrationApprovalEmail.createLogEntry(logEntryMsg,LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY);
    	    
            return; // Early return if no contacts to process
        }
        
        List<PRM_EmailQueue__c> listEmailQueue = [
            SELECT
                Id,
                PRM_Business_Event__c,
                PRM_Contact__c,
                PRM_Contact__r.AccountId,
                PRM_Contact__r.Account.Core_IPA_Badge_Tier__c,
                PRM_Contact__r.Core_Preferred_Language__c,
                PRM_Contact__r.Email,
                PRM_Contact__r.Core_Do_Not_Contact__c,
                PRM_Status__c,
                PRM_Tier__c,
                PRM_PartnerRole__c,
                PRM_Registration_Request__c,
                CreatedDate
            FROM PRM_EmailQueue__c
            WHERE
                PRM_Status__c = 'PENDING'
                AND PRM_Business_Event__c != ''
                AND PRM_Contact__c IN :FinalContactsSet
            ORDER BY PRM_Priority__c NULLS LAST, CreatedDate
        ];
        
        logEntryMsg += '\nEmailQueue records found: ' + listEmailQueue.size();
        if (!listEmailQueue.isEmpty()) {
            PRM_RegistrationApprovalEmail.sendWelcomeEmail(listEmailQueue);
            isFirstRun = false;
            logEntryMsg += '\nEmail Queue processed';
        }
        
        //Updated code by Draco - according to new A&E trigger framework, added new helper class reference - START
        // Unused code : Commented by DINESH - 30/04/2025 : IPA 2.0 Refresh
        // if (
        //     isActive('PRM_Send_Email_On_Ent_Completion') &&
        //     Core_ContactEntitlementHelper.IPAfirstentUpdate
        // ) {
        //     Core_ContactEntitlementHelper.sendEmailOnCEUpdateToComplete(
        //         (Map<Id, Core_Contact_Entitlement__c>) Trigger.newMap,
        //         (Map<Id, Core_Contact_Entitlement__c>) Trigger.OldMap
        //     );
        //     Core_ContactEntitlementHelper.IPAfirstentUpdate = false;
        // }
        //Updated code by Draco - according to new A&E trigger framework, added new helper class reference - END
	
		logEntryMsg += '\n*** AFTER UPDATE END ***';
		PRM_RegistrationApprovalEmail.createLogEntry(logEntryMsg,LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY);
		

    
    }
}