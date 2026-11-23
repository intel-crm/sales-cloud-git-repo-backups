/****************************************************************************************************************************
Apex Class Name     : PRM_Account_Specialty_Assoc_Handler
Version             : 1.0
Created Date        : Nov 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      27-Nov-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events
* Anand TB          09-Apr-2020                  Added changes for setting Account.PRM_IPA_Integration_Status__c to 
*                                                 pending on after insert and after update

****************************************************************************************************************************/
public class PRM_Account_Specialty_Assoc_Handler extends TriggerHandler {
    public static boolean iPAFirstRun = true;
    
    /*public override void beforeInsert() {
        if(isActive('PRM_Account_Specialty_Assoc_Switch') && PRM_Account_Specialty_Assoc_Utility.firstRunBeforeInsert){     //Retrieved from Custom Metadata
            PRM_Account_Specialty_Assoc_Utility.firstRunBeforeInsert = false;
            PRM_Account_Specialty_Assoc_Utility.specialtyDuplicateCheck(Trigger.new,null);
            PRM_Account_Specialty_Assoc_Utility.updateStartandEndDates(Trigger.new,null);
            PRM_Account_Specialty_Assoc_Utility.suppressEmail(Trigger.new);
        }
    }
    public override void beforeUpdate() {
        if(isActive('PRM_Account_Specialty_Assoc_Switch') && PRM_Account_Specialty_Assoc_Utility.firstRunBeforeUpdate) {     //Retrieved from Custom Metadata
            PRM_Account_Specialty_Assoc_Utility.firstRunBeforeUpdate = false;
            PRM_Account_Specialty_Assoc_Utility.specialtyDuplicateCheck(Trigger.new,(Map<Id,PRM_Account_Specialty_Association__c>) Trigger.oldMap);
            PRM_Account_Specialty_Assoc_Utility.updateStartandEndDates(Trigger.new,(Map<Id,PRM_Account_Specialty_Association__c>) Trigger.oldMap);
            PRM_Account_Specialty_Assoc_Utility.updateSuppressEmail(Trigger.new,(Map<Id,PRM_Account_Specialty_Association__c>) Trigger.oldMap);
            PRM_Account_Specialty_Assoc_Utility.suppressEmail(Trigger.new);
        }
    }*/
    public override void afterInsert(){
        //system.debug('Entered  ASA afterInsert records');
        /*if(isActive('PRM_Account_Specialty_Assoc_Switch') && PRM_Account_Specialty_Assoc_Utility.firstRunAfterInsert) {     //Retrieved from Custom Metadata
            PRM_Account_Specialty_Assoc_Utility.firstRunAfterInsert = false;
        //    PRM_Account_Specialty_Assoc_Utility.updatePartnerSpecialityOnAccount(trigger.New, (map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap);
         //   PRM_EmailUtility.sendEmailToPrimaryContacts(trigger.New,(map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap);//Vijay - US554284 As part of this story, need to send emails to Primary contacts of the Account
            PRM_Account_Specialty_Assoc_Utility.opidSpecialityRollup(trigger.New, (map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap); 
        }
        //Set IPA integration status to pending - IPA integration
        //Added by Anand TB - US607581
        if(isActive('ASA_Insert_IPA_Integration_Trigger') && iPAFirstRun) {
            PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending( (List<PRM_Account_Specialty_Association__c>) Trigger.new);
            //system.enqueueJob(new PRM_SalesCloudAccountIntStatus_Handler((List<PRM_Account_Specialty_Association__c>)Trigger.new, null, null));
            iPAFirstRun = false;
        }*/

        if(isActive('Core_MDF_AfterInsert_AccSpecialityAssoc')){
            //PRM_Account_Specialty_Assoc_Utility.callAccountAndPgmSyncPlatformEvent((Map<Id,PRM_Account_Specialty_Association__c>)Trigger.newMap, (Map<Id,PRM_Account_Specialty_Association__c>)Trigger.oldMap, 'Insert');
        }
    }
    public override void afterUpdate(){
        /*if(isActive('PRM_Account_Specialty_Assoc_Switch')) {     //Retrieved from Custom Metadata
             
            if(trigger.IsUpdate && PRM_EmailUtility.firstRun) {//Vijay - US554284 As part of this story, need to send emails to Primary contacts of the Account
                PRM_EmailUtility.firstRun = false;
               // PRM_EmailUtility.sendEmailToPrimaryContacts(trigger.New, (map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap);
            }
            if(trigger.IsUpdate && PRM_Account_Specialty_Assoc_Utility.firstRunAfterUpdate) {
                //System.debug('PRM_Account_Specialty_Assoc_Utility.firstRunAfterUpdate-->'+PRM_Account_Specialty_Assoc_Utility.firstRunAfterUpdate);
                PRM_Account_Specialty_Assoc_Utility.firstRunAfterUpdate = false;
                PRM_Account_Specialty_Assoc_Utility.InactiveASAOnParentAcc(trigger.New, (map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap); //UTKARSH - US706417
              //  PRM_Account_Specialty_Assoc_Utility.updatePartnerSpecialityOnAccount(trigger.New, (map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap);
                PRM_Account_Specialty_Assoc_Utility.inactivateQualitativeCriteria(trigger.New, (map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap);
                PRM_Account_Specialty_Assoc_Utility.inactivateBenefitAssociation(trigger.New, (map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap);
                PRM_Account_Specialty_Assoc_Utility.opidSpecialityRollup(trigger.New, (map<id, PRM_Account_Specialty_Association__c>)trigger.oldMap);
            }
        }
        
        //Set IPA integration status to pending - IPA integration
        //Added by Anand TB - US607581
        if(isActive('ASA_Update_IPA_Integration_Trigger') && iPAFirstRun) {
            boolean isUpdated = false;
            for(PRM_Account_Specialty_Association__c newAsa : (List<PRM_Account_Specialty_Association__c>)Trigger.new) {
                PRM_Account_Specialty_Association__c oldAsa = (PRM_Account_Specialty_Association__c)Trigger.oldMap.get(newAsa.Id);
                if(newAsa.PRM_Partner_Role__c != oldAsa.PRM_Partner_Role__c ||
                   newAsa.PRM_InActive_Ind__c != oldAsa.PRM_InActive_Ind__c) {
                       isUpdated = true;
                       break;
                   }
            }
            if(isUpdated) {
                PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending( (List<PRM_Account_Specialty_Association__c>) Trigger.new);
                iPAFirstRun = false;
            }
        }*/

        if(isActive('Core_MDF_AfterUpdate_AccSpecialityAssoc')){
            //PRM_Account_Specialty_Assoc_Utility.callAccountAndPgmSyncPlatformEvent((Map<Id,PRM_Account_Specialty_Association__c>)Trigger.newMap, (Map<Id,PRM_Account_Specialty_Association__c>)Trigger.oldMap, 'Update');
        }
    }
    
}