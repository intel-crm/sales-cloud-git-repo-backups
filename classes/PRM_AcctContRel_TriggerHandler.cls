/******************************************************************************************************************************
Apex Class Name:  PRM_AccountContactRel_Trigger
Version     : 1.0 
Created Date: 21 NOV 2018
Function    : Trigger handler for the object PRM_Account_Contact_Relationship__c

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Anupam Agarwal    06-Dec-2018          Overridden the beforeInsert(), beforeUpdate() and beforeDelete() methods 
* Teja Munagala       17-Dec-2018              Overridden the BeforeInsert(), BeforeUpdate()
* Teja Munagala       09-AUG-2019              Overridden the AfterUpdate()
******************************************************************************************************************************/

public without sharing class PRM_AcctContRel_TriggerHandler extends TriggerHandler {
    //To prevent calling handler class twice
    //Please make use of different variable for before/delete scenarios
    public static boolean firstRun = true;
    public static boolean IPAfirstRun = true;
    public override void afterInsert() {
        System.debug('Calling>>>>>');
        if(isActive('AcctCtRel_Insert_ERPM_Integration_Trgr') && firstRun) {
            //ContactERPMIntegrationStatusHandler.parseInputList((List<PRM_Account_Contact_Relationship__c>)Trigger.new);
            System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Account_Contact_Relationship__c>)Trigger.new,  Trigger.new.getSObjectType()));
            firstRun = false;
        }
        /*if(isActive('ACR_Insert_IPA_Integration_Trigger') && IPAfirstRun) {
            //System.enqueueJob(new PRM_SalesCloudContactIntStatus_Handler((List<PRM_Account_Contact_Relationship__c>)Trigger.new, null, false));
            PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingACR((List<PRM_Account_Contact_Relationship__c>)Trigger.new);
            IPAfirstRun = false;
        }*/
        
        if(isActive('ACR_After_Insert')) {
            //UTKARSH - If block is to stop recurssion call insertContactEntitlement() method.
            System.debug('PRM_AcctContRelUtility.firstRunAfter-->'+PRM_AcctContRelUtility.firstRunAfter);
            System.debug('trigger.Isinsert-->'+trigger.Isinsert);
            PRM_AcctContRelUtility.updateStartandEndDates(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap);//Tejasree
            if(trigger.Isinsert && PRM_AcctContRelUtility.firstRunAfter){  
                PRM_AcctContRelUtility.firstRunAfter = false;
                PRM_AcctContRelUtility.insertContactEntitlement(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap); //Utkarsh 
                //[NN-31/10/2019]moved to after-  
                //PRM_AcctContRelUtility.upsertDefaultRelationship(Trigger.new); //Utkarsh 
                //System.debug('PRM_AcctContRelUtility.firstRun inside if-->'+PRM_AcctContRelUtility.firstRunAfter);

            }
			/*US575709 - Start - Expose new Get Profile API in SF for secondary contact, Admin registration & Account Request flows*/
			PRM_AGS_IdentityCreation.SendEmailVerificationAndCreateIdentityInAGS(Trigger.new);                
			/*Finish - US575709*/
        }
    }
    
    public override void afterUpdate() {
        system.debug('ACR afterUpdate');
        if(isActive('AcctCtRel_Update_ERPM_Integration_Trgr') && firstRun) {System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Account_Contact_Relationship__c>)Trigger.new,  Trigger.new.getSObjectType()));
                                                                            firstRun = false;
                                                                           }
        /*if(isActive('ACR_Update_IPA_Integration_Trigger') && IPAfirstRun) {
            boolean isUpdated = false; 
            for(PRM_Account_Contact_Relationship__c newACR : (List<PRM_Account_Contact_Relationship__c>)Trigger.new) {
                PRM_Account_Contact_Relationship__c oldACR = (PRM_Account_Contact_Relationship__c)Trigger.oldMap.get(newACR.Id);
                if(newACR.PRM_Status_Nm__c != oldACR.PRM_Status_Nm__c ||
                newACR.PRM_Partner_Role__c != oldACR.PRM_Partner_Role__c) {
                    isUpdated = true;
                    break;
                }
            }
            if(isUpdated)
            {
                //System.enqueueJob(new PRM_SalesCloudContactIntStatus_Handler((List<PRM_Account_Contact_Relationship__c>)Trigger.new, null, false));
                PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingACR((List<PRM_Account_Contact_Relationship__c>)Trigger.new);
                IPAfirstRun = false;
            }
        }*/
        if(isActive('ACR_After_Update')) {
            system.debug('PRM_AcctContRelUtility.firstRunAfterUpdate-->'+PRM_AcctContRelUtility.firstRunAfterUpdate);
            system.debug('ACR afterUpdate ===> 222');
            PRM_AcctContRelUtility.inactivateContactEntitlement(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap);//Utkarsh
            PRM_AcctContRelUtility.activateContactEntitlement(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap);//Utkarsh
            PRM_AcctContRelUtility.updateStartandEndDates(Trigger.new,(Map<Id,PRM_Account_Contact_Relationship__c>)Trigger.oldMap);//Tejasree
            if(trigger.Isupdate && PRM_AcctContRelUtility.firstRunAfterUpdate){
                PRM_AcctContRelUtility.firstRunAfterUpdate = false;
                PRM_AcctContRelUtility.insertContactEntitlement(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap);
            }
			//Email to primary contact when such incative operation of ACR happen
			PRM_AcctContRelUtility.emailForPrimaryContact(Trigger.oldMap,Trigger.newMap);			
        }

		
        
        /*
        if(trigger.IsUpdate && PRM_AcctContRelUtility.firstRun){PRM_AcctContRelUtility.firstRun = false;
                PRM_AcctContRelUtility.upsertDefaultRelationship(Trigger.new); //Utkarsh
        }*/
    }
    
    public override void beforeInsert(){
        if(isActive('Ags_Outbound_Msg')) { //Retrieved from Custom labels
            PRM_AcctContRelUtility.duplicateRecordCheck(Trigger.new); //Anupam Agrawal
            PRM_AcctContRelUtility.duplicateACRCheck(Trigger.new); // Teja Munagala
			PRM_AGS_IdentityCreation.updateAcctContRelation_StatusField(Trigger.new);
            /*if(trigger.Isinsert && PRM_AcctContRelUtility.firstRun){  //Utkarsh
                System.debug('come in beforeInsert');
                PRM_AcctContRelUtility.firstRun = false;
                //[NN-31/10/2019]moving to after-  PRM_AcctContRelUtility.upsertDefaultRelationship(Trigger.new);
            }*/
            
        }
    }
    public override void beforeUpdate() {
        system.debug('ACR beforeUpdate');
        if(isActive('Ags_Outbound_Msg')) { //Retrieved from Custom labels
            system.debug('ACR beforeUpdate ===> 111');
            PRM_AcctContRelUtility.mandatoryRelationshipCheck(Trigger.new, Trigger.old, (Map<Id, PRM_Account_Contact_Relationship__c>)Trigger.oldMap);
            PRM_AcctContRelUtility.duplicateUpdateACRCheck(trigger.new); //Teja Munagala
            /*if(trigger.IsUpdate && PRM_AcctContRelUtility.firstRun){PRM_AcctContRelUtility.firstRun = false;
                PRM_AcctContRelUtility.upsertDefaultRelationship(Trigger.new); //Utkarsh
            }*/
        }
    }
    
    public override void beforeDelete() {
        if(isActive('Ags_Outbound_Msg')) { //Retrieved from Custom labels
            PRM_AcctContRelUtility.mandatoryDeletionCheck(Trigger.old);
        }
    }
    
}