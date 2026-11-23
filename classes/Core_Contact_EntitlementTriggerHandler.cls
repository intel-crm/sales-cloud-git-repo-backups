public without sharing class Core_Contact_EntitlementTriggerHandler extends TriggerHandler {
    public static boolean IPAfirstRunInsert = true;
    public static boolean IPAfirstRunUpdate = true;
    public static boolean IPAfirstentUpdate = true;
    public static boolean isFirstRun = true;
    //  public static boolean isSecond_RDC = true;

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
        if (
            isActive('ContEnt_Update_IPA_Integration_Trigger') &&
            IPAfirstRunUpdate
        ) {
            boolean isUpdated = false;
            for (
                Core_Contact_Entitlement__c newContEnt : (List<Core_Contact_Entitlement__c>) Trigger.new
            ) {
                Core_Contact_Entitlement__c oldContEnt = (Core_Contact_Entitlement__c) Trigger.oldMap
                    .get(newContEnt.Id);
                
                if (
                    (newContEnt.Core_Selected__c !=
                    oldContEnt.Core_Selected__c ||
                    newContEnt.Core_Status__c != oldContEnt.Core_Status__c) &&
                    newContEnt.Core_Type__c == 'Entitlement'
                ) {
                     
                    isUpdated = true;
                    break;
                }
            }
            if (isUpdated) {
                
                PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingContEnt(
                    (List<Core_Contact_Entitlement__c>) Trigger.New
                );

                IPAfirstRunUpdate = false;
            }
        }
        if (isActive('WelcomeEmailUponEntitlementCompletion')) {
            
            if (
                isActive('WelcomeEmailUponEntitlementCompletion') && isFirstRun
            ) {
                isFirstRun = ER_WelcomeEmailUtility.SendWelcomeEmailNotifications(
                    (List<Core_Contact_Entitlement__c>) Trigger.new,
                    (Map<Id, Core_Contact_Entitlement__c>) Trigger.oldMap
                );
            }
            Map<Id, Core_Contact_Entitlement__c> mapOldContactEnt = (Map<Id, Core_Contact_Entitlement__c>) Trigger.oldMap;
            Set<Id> setContacIdForIPAWelcomeEmail = new Set<Id>();
            List<PRM_EmailQueue__c> listEmailQueue = new List<PRM_EmailQueue__c>();
            for (
                Core_Contact_Entitlement__c contactEnt : (List<Core_Contact_Entitlement__c>) Trigger.new
            ) {
                 
                Core_Contact_Entitlement__c oldContactEnt = mapOldContactEnt.containsKey(
                        contactEnt.id
                    )
                    ? mapOldContactEnt.get(contactEnt.id)
                    : null;
                if (
                    oldContactEnt != null &&
                    oldContactEnt.Core_Status__c != contactEnt.Core_Status__c &&
                    contactEnt.Core_Status__c == 'Complete' &&
                    contactEnt.Core_Contact_Id__c != null
                ) {
                    setContacIdForIPAWelcomeEmail.add(
                        contactEnt.Core_Contact_Id__c
                    );
                }
            }
	//mp logic
            if(setContacIdForIPAWelcomeEmail!=null && !setContacIdForIPAWelcomeEmail.isempty()){
            		PMP_Utility.sendWelcomeEmailForMP(setContacIdForIPAWelcomeEmail);
                }

            if (!setContacIdForIPAWelcomeEmail.isEmpty()) {
                listEmailQueue = [
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
                        PRM_PartnerRole__c,
                        PRM_Registration_Request__c,PRM_Tier__c,
                        CreatedDate
                    FROM PRM_EmailQueue__c
                    WHERE
                        PRM_Status__c = 'PENDING'
                        AND PRM_Business_Event__c != ''
                        AND PRM_Contact__c IN :setContacIdForIPAWelcomeEmail
                    ORDER BY PRM_Priority__c NULLS LAST, CreatedDate
                ];
            }
            if (!listEmailQueue.isEmpty()) {
                PRM_RegistrationApprovalEmail.sendWelcomeEmail(listEmailQueue);
                isFirstRun = false;
                
            }
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
    }
}