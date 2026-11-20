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
*Prabuddh(Tanzanite)     06/05/2020        Added changes for the creation, update and removal of "Partners/Marketing Profile Info"
                          with the changes in benefit association
*Prabuddh(Tanzanite)    19/08/2020        Added recursive check and switches for marketplace logic
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
    public static boolean mpFirstInsertRun = true;
    public static boolean mpFirstUpdateRun = true;
    public static boolean mpFirstDeleteRun = true;
    @TestVisible static Boolean executeTrigger = true;
    
    public override void afterInsert() {
        if(executeTrigger && isActive('Partner_Benefit')&& PRM_accBenefitAssociationUtility.firstRunAfterInsert && Trigger.isInsert){
            PRM_accBenefitAssociationUtility.firstRunAfterInsert = false;
            PRM_accBenefitAssociationUtility.onManualBenefitInsert((List<PRM_AccountBenefitAssociation__c>)Trigger.new, (Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.OldMap,false);
            PRM_accBenefitAssociationUtility.opidBenefitInactivation((List<PRM_AccountBenefitAssociation__c>)Trigger.new, (Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.OldMap); //Sheetal 14/5/2020
        }

        if(isActive('ABA_Insert_ERPM_Integration_Trigger') && firstRun) {
            if(system.isBatch()){
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountBenefitAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
            }
            else{
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountBenefitAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
            }
            firstRun = false;
        } 
         
        //Do not add firstRun check here,it will leads to failure of MPI records creation during select benefit scenario.
        //first run flag will make the method to be exectuted once and when the same ABA record fails in validation the method won't be executed again for the next ABA record.
      List<PRM_AccountBenefitAssociation__c> abaNewList= PRM_accBenefitAssociationUtility.getABAList((List<PRM_AccountBenefitAssociation__c>)Trigger.new);
        if(isActive('ABA_Insert_PartnerUtility_Trigger')){
            PMP_AccountBenefitPartnerUtility.insertUtility(abaNewList);
                      
        } 
       
       PRM_accBenefitAssociationUtility.createTrackerMilestonesForBenefits(abaNewList,null);
    }
    
    public override void afterUpdate() {
        if(isActive('ABA_After_Update') && trigger.Isupdate && PRM_accBenefitAssociationUtility.firstRun) {
            PRM_accBenefitAssociationUtility.firstRun = false;
            PRM_accBenefitAssociationUtility.onManualBenefitInsert((List<PRM_AccountBenefitAssociation__c>)Trigger.new, (Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.OldMap,false);
            PRM_accBenefitAssociationUtility.onOPIDBenefitStatusInactive((List<PRM_AccountBenefitAssociation__c>)Trigger.new, (Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.OldMap); 
            PRM_accBenefitAssociationUtility.onStatusInactiveParent((List<PRM_AccountBenefitAssociation__c>)Trigger.new, (Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.OldMap);
            PRM_accBenefitAssociationUtility.opidBenefitInactivation((List<PRM_AccountBenefitAssociation__c>)Trigger.new, (Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.OldMap); //Sheetal 14/5/2020
            PRM_accBenefitAssociationUtility.onStatusInactive((List<PRM_AccountBenefitAssociation__c>)Trigger.new);
        }
        List<PRM_AccountBenefitAssociation__c> abaNewList= PRM_accBenefitAssociationUtility.getABAList((List<PRM_AccountBenefitAssociation__c>)Trigger.new);
        if(isActive('ABA_Update_PartnerUtility_Trigger') /*&& PRM_aba_TriggerHandler.mpFirstUpdateRun*/){
            PRM_aba_TriggerHandler.mpFirstUpdateRun = false;
          
            PMP_AccountBenefitPartnerUtility.updateUtility(abaNewList, (Map<Id,PRM_AccountBenefitAssociation__c>) Trigger.oldMap);
        }
        
        if(isActive('ABA_Update_ERPM_Integration_Trigger') && firstRun) {
            
            if(system.isBatch()){
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountBenefitAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
            }
            else{
                //Id jobid = 
                    System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountBenefitAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
            }
            firstRun = false;
        }

        PRM_accBenefitAssociationUtility.createTrackerMilestonesForBenefits(abaNewList,(Map<Id,PRM_AccountBenefitAssociation__c>) Trigger.oldMap);

        
    }
    
    public override void beforeInsert(){
        if(executeTrigger)
        {
            if(System.isBatch())
            {
                firstRun = true;
            }
            if(isActive('Partner_Benefit') && PRM_accBenefitAssociationUtility.firstRunBeforeInsert) {
                //Validate MP benefit Modification on UI - Restrict user to Activate/Inactivate the MPI benefits
                //IPA 2.0 TWC729-7887
                //PRM_accBenefitAssociationUtility.validateMPBenefits((List<PRM_AccountBenefitAssociation__c>)Trigger.new, (Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.OldMap); 
                
                // PRM_accBenefitAssociationUtility.partnerBenefitCheckOnInsert(Trigger.new, Trigger.old, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
                PRM_accBenefitAssociationUtility.firstRunBeforeInsert = false;
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
    }

    public override void beforeupdate(){
        if(isActive('Partner_Benefit_Update') && PRM_accBenefitAssociationUtility.firstRunBeforeUpdate){
            //Validate MP benefit Modification on UI -Validate MP benefit Modification on UI - Restrict user to Activate/Inactivate the MPI benefits
           //IPA 2.0 TWC729-7887
           //  PRM_accBenefitAssociationUtility.validateMPBenefits((List<PRM_AccountBenefitAssociation__c>)Trigger.new, (Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.OldMap); 
  
            //PRM_accBenefitAssociationUtility.partnerBenefitCheck(Trigger.new, Trigger.old, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
            //PRM_accBenefitAssociationUtility.partnerBenefitCheck(Trigger.new, Trigger.old, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
            PRM_accBenefitAssociationUtility.firstRunBeforeUpdate = false;
            //Retaining Membercard till OPID MPI published logic 
            PMP_AccountBenefitPartnerUtility.checkBeforeDeactivateIntelAccountBenefit(Trigger.new,(Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
            PRM_accBenefitAssociationUtility.duplicateRecordCheck(Trigger.new);
            
                PRM_accBenefitAssociationUtility.benefitassignmentcheck(Trigger.new,(Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
           //  PRM_accBenefitAssociationUtility.profileResponseOnBenefitUpdate(Trigger.new,(Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
            //PRM_accBenefitAssociationUtility.onStatusInactive(Trigger.new, (Map<Id, PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
            //sheetal Changes start 27/1/2020
            //PRM_accBenefitAssociationUtility.updateSourceField(Trigger.new);
            //sheetal Changes end 27/1/2020
            PRM_accBenefitAssociationUtility.updateSuppressEmail(Trigger.new,(Map<Id,PRM_AccountBenefitAssociation__c>)Trigger.oldMap);
        }
    }
    
  public override void beforeDelete() {
        if(isActive('ABA_Delete_PartnerUtility_Trigger') && PRM_aba_TriggerHandler.mpFirstDeleteRun){
            PRM_aba_TriggerHandler.mpFirstDeleteRun = false;
            PMP_AccountBenefitPartnerUtility.deleteUtility((List<PRM_AccountBenefitAssociation__c>)Trigger.old);
        }
      
    }
}