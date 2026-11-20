/****************************************************************************************************************************************
* Class Name  : Core_MDF_PGM_TriggerHandler 
* Version     : 1.0 
* Created Date: 09/03/2018 
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       09/03/2018         Created for extending Trigger framework to process Partner Group Mapping business logic methods.
* Intel - NP(11630236) 10/14/2019         Introduced After insert,update,delete to add the CCP subgroup to the corresponding CCP Master group   
*****************************************************************************************************************************************/
public class Core_MDF_PGM_TriggerHandler extends TriggerHandler{
    public override void beforeInsert() {
        if (isActive('Core_MDF_PGMProcessesOnBeforeInsert')) {
           
            //To update unique AccountIdGroupName and Group ID field
            Core_MDF_PGM_ServiceHandler.populateAccountIdGroupNameAndGroupId((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new, null);
          Core_MDF_PGM_ServiceHandler.populateAccountProgramId((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new,null);
        }
    }
    public override void beforeUpdate(){
       
        if (isActive('Core_MDF_PGMProcessesOnBeforeUpdate')) {
            Core_MDF_PGM_ServiceHandler.populateAccountProgramId((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new,(Map<id,Core_MDF_Partner_Group_Mapping__c>) Trigger.oldMap);   
            //To update unique AccountIdGroupName adn Group ID field
            Core_MDF_PGM_ServiceHandler.populateAccountIdGroupNameAndGroupId((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new, (Map<id,Core_MDF_Partner_Group_Mapping__c>) Trigger.oldMap);
        	
        }
    }
    
    public override void afterInsert() {
        if(isActive('Core_MDF_PGMProcessToAddToMasterGroup')){
            //To add the Sub Group to their corresponding Master Groups
            Core_MDF_PGM_ServiceHandler.identifyMasterGroup((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new, new Set<Id>());
        }

        if(Core_MDF_Utility.byPassFeature('Core_MDF_AddOrRemoveUserFromPgmGrp')){
            //Add users to PGM Account group for co-marketing False accounts.
            Core_MDF_PGM_ServiceHandler.addUsersToPGMAccountGroupForExternal((Map<Id,Core_MDF_Partner_Group_Mapping__c>) Trigger.newMap);  
        }
        
        if(isActive('Core_MDF_CallBatchOnPGMInsert')){
            //To call the batch for sharing PGM's group
            Core_MDF_PGM_BatchHelper.createObjectShareRecords((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new);
           }
    }
    
    public override void afterUpdate() {
        if(isActive('Core_MDF_PGMProcessToAddToMasterGroup')){
            //Identify if the PGM record has changed Channel Program, Type of Access or Group Name fields
            Core_MDF_PGM_ServiceHandler.checkIfValidUpdate((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new, (Map<id,Core_MDF_Partner_Group_Mapping__c>) Trigger.oldMap);            
        }
    }

    public override void beforeDelete(){
        if(isActive('Core_MDF_BeforeDeletePGM')){
            Core_MDF_PGM_ServiceHandler.restrictDeletion((Map<id,Core_MDF_Partner_Group_Mapping__c>) Trigger.oldMap);            
        }
    }  
}