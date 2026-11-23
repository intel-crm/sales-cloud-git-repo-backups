/*********************************************************************************************************************
   Apex Class Name  : PRM_aba_TriggerHandler
   Version       : 1.0
   Created Date  : DEC 2018
   Function      :

   Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Utkarsh                 12/14/2018
* Anand TB                09-Apr-2020                Added changes for setting Account.PRM_IPA_Integration_Status__c to 
*                                                   pending on after insert and after update

*********************************************************************************************************************/
public without sharing class PRM_aba_TriggerHandler extends TriggerHandler {
  /*  /**
   *  @description      : calls 'partnerBenefitCheck' method of 'PRM_accBenefitAssociationUtility'.
   *  @name             : beforeInsert
   *  @param            : NONE
   *  @throws exception : NONE
   **/
  //To prevent calling handler class twice
  //Please make use of different variable for before/delete scenarios
  public static boolean firstRun = true;
  public static boolean iPAFirstRun = true;
  public override void afterInsert() {
    if(isActive('Partner_Benefit')) {
      //PRM_accBenefitAssociationUtility.onManualBenefitInsert(Trigger.new);
    }

    if(isActive('ABA_Insert_ERPM_Integration_Trigger') && firstRun) {
      System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountBenefitAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
      firstRun = false;
        }
        //Set IPA integration status to pending - IPA integration
        //Added by Anand TB - US607581
    //if(isActive('ABA_Insert_IPA_Integration_Trigger') && iPAFirstRun) {
            //system.enqueueJob(new PRM_SalesCloudAccountIntStatus_Handler((List<PRM_AccountBenefitAssociation__c>)Trigger.new, null, null));
        //    PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending( (List<PRM_AccountBenefitAssociation__c>) Trigger.new);
        //    iPAFirstRun = false;
    //}
  }
  public override void afterUpdate() {
    if(isActive('ABA_After_Update')) {
      //ContactERPMIntegrationStatusHandler.parseInputList((List<PRM_AccountBenefitAssociation__c>)Trigger.new);
      System.debug('accBenefitAssociation trigger handler inside IsActive');
      if(trigger.Isupdate && PRM_accBenefitAssociationUtility.firstRun) {
        PRM_accBenefitAssociationUtility.firstRun = false;
        PRM_accBenefitAssociationUtility.onStatusInactive(Trigger.new);
      }
    }

    if(isActive('ABA_Update_ERPM_Integration_Trigger') && firstRun) {
      System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountBenefitAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
      firstRun = false;
    }

    //Set IPA integration status to pending - IPA integration
        //Added by Anand TB - US607581
        /*if(isActive('ABA_Update_IPA_Integration_Trigger') && iPAFirstRun){
            boolean isUpdated = false;
            for(PRM_AccountBenefitAssociation__c newAba : (List<PRM_AccountBenefitAssociation__c>)Trigger.new) {
                PRM_AccountBenefitAssociation__c oldAba = (PRM_AccountBenefitAssociation__c)Trigger.oldMap.get(newAba.Id);
                if(newAba.PRM_Status_Nm__c != oldAba.PRM_Status_Nm__c ||
                newAba.PRM_Partner_Benefit_Id__c != oldAba.PRM_Partner_Benefit_Id__c) {
                    isUpdated = true;
                    break;
                }
            }
            if(isUpdated) {
                system.enqueueJob(new PRM_SalesCloudAccountIntStatus_Handler((List<PRM_AccountBenefitAssociation__c>)Trigger.new, null, null));
                iPAFirstRun = false;
            }      
        }*/
  }
  public override void beforeInsert(){
    System.debug('accBenefitAssociation trigger handler');
    if(isActive('Partner_Benefit')) {
      System.debug('accBenefitAssociation trigger handler inside IsActive');
      // PRM_accBenefitAssociationUtility.partnerBenefitCheckOnInsert(Trigger.new, Trigger.old, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
      PRM_accBenefitAssociationUtility.duplicateRecordCheck(Trigger.new);
      PRM_accBenefitAssociationUtility.benefitassignmentcheck(Trigger.new,(Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
      //PRM_accBenefitAssociationUtility.onStatusInactive(Trigger.new, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
      //PRM_accBenefitAssociationUtility.benefitStatusCheck(Trigger.new);
      //benefitStatusCheck(List<PRM_AccountBenefitAssociation__c> lstAccBenefit)
      //sheetal Changes start 27/1/2020
      //PRM_accBenefitAssociationUtility.updateSourceField(Trigger.new);
      //sheetal Changes end 27/1/2020
    }
  }

  public override void beforeupdate(){
    System.debug('accBenefitAssociation trigger handler');
    if(isActive('Partner_Benefit_Update')) {
      System.debug('accBenefitAssociation trigger handler inside IsActive');
      //PRM_accBenefitAssociationUtility.partnerBenefitCheck(Trigger.new, Trigger.old, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
      //PRM_accBenefitAssociationUtility.partnerBenefitCheck(Trigger.new, Trigger.old, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
      PRM_accBenefitAssociationUtility.duplicateRecordCheck(Trigger.new);
      PRM_accBenefitAssociationUtility.benefitassignmentcheck(Trigger.new,(Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
      //PRM_accBenefitAssociationUtility.onStatusInactive(Trigger.new, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
      //sheetal Changes start 27/1/2020
      //PRM_accBenefitAssociationUtility.updateSourceField(Trigger.new);
      //sheetal Changes end 27/1/2020
    }
  }
}