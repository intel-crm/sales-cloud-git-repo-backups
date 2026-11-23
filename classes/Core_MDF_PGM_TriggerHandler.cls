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
        }
    }
    public override void beforeUpdate(){
        if (isActive('Core_MDF_PGMProcessesOnBeforeUpdate')) {
            //To update unique AccountIdGroupName adn Group ID field
            Core_MDF_PGM_ServiceHandler.populateAccountIdGroupNameAndGroupId((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new, (Map<id,Core_MDF_Partner_Group_Mapping__c>) Trigger.oldMap);
        }
    }
    
    public override void afterInsert() {
        system.debug('After Insert');
        
        if(isActive('Core_MDF_PGMProcessToAddToMasterGroup')){
            //To add the Sub Group to their corresponding Master Groups
            Core_MDF_PGM_ServiceHandler.identifyMasterGroup((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new);
        }
        
        if(isActive('Core_MDF_CallBatchOnPGMInsert')){
            //To call the batch for sharing PGM's group
            Core_MDF_PGM_BatchHelper.createObjectShareRecords((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new);
        }
    }
    
    public override void afterUpdate() {
        system.debug('After Update');
        if(isActive('Core_MDF_PGMProcessToAddToMasterGroup')){
            //Identify if the PGM record has changed Channel Program, Type of Access or Group Name fields
            Core_MDF_PGM_ServiceHandler.checkIfValidUpdate((List<Core_MDF_Partner_Group_Mapping__c>) Trigger.new, (Map<id,Core_MDF_Partner_Group_Mapping__c>) Trigger.oldMap);
        }
    }

    public override void afterDelete(){
        system.debug('After Delete');
        if(isActive('Core_MDF_PGMProcessToAddToMasterGroup')){
            List<id> toBeRemoved = new List<id>();
            for(Core_MDF_Partner_Group_Mapping__c record: (List<Core_MDF_Partner_Group_Mapping__c>) Trigger.Old){
                toBeRemoved.add(id.valueof(record.Core_MDF_Group_Id__c));                         
            }
            if(toBeRemoved.size()>0){
                //Remove the Sub group from all the Master groups
                Core_MDF_PGM_ServiceHandler.removeGroupFromGroupMember(toBeRemoved);
            }
        }
    }  
}