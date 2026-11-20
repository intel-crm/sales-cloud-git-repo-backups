/****************************************************************************************************************************************
* Class Name  : Core_MDF_PNUMappingTriggerHandler 
* Version     : 1.0 
* Created Date: 7-23-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       7/23/2018          Created for extending Trigger framework to process 
                                          Partner Node User Mapping business logic methods.
* Accenture - KK       12/13/2019         Modified based on Batch Design
*****************************************************************************************************************************************/
public class Core_MDF_PNUM_Mapping_TriggerHandler extends TriggerHandler{
    
    public override void beforeUpdate() {
        if(!Core_MDF_RecursiveTrigger.isRecursive){
            Core_MDF_PNUM_Mapping_ServiceHandler.clearErrorField((Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap);

            //To check if duplicate entries available
            if(!Core_MDF_Utility.byPassFeature('Bypass_Duplicate_AcctUserMapping_Check'))
                Core_MDF_PNUM_Mapping_ServiceHandler.checkDuplicateRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new, (Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.oldMap);
            
            //To validate account user mapping correspoding to program and cross account user mapping
            if (isActive('Core_MDF_validateAccountUserAccess')) {
                Core_MDF_PNUM_Mapping_ServiceHandler.validateAccountUserMapping((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new);
            }
        }
    }
    
    public override void beforeInsert() {
        //To check if duplicate entries available
        if(!Core_MDF_Utility.byPassFeature('Bypass_Duplicate_AcctUserMapping_Check'))
            Core_MDF_PNUM_Mapping_ServiceHandler.checkDuplicateRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new, null);
        
        //To validate account user mapping correspoding to program and cross account user mapping
        if (isActive('Core_MDF_validateAccountUserAccess')) {
            Core_MDF_PNUM_Mapping_ServiceHandler.validateAccountUserMapping((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new);
        }
    }

    public override void afterInsert(){
        //To add external users to Account node group.
        if(!Core_MDF_Utility.byPassFeature('Bypass_AcctUserMapping_Obj_Share')){
            Core_MDF_PNUM_Mapping_ServiceHandler.addUsersToNodeGroupOnInsert(Trigger.new);
        }

        //To create share records(Case, Escalation and Campaign)
        if(!Core_MDF_Utility.byPassFeature('Bypass_AcctUserMapping_Obj_Share') && !System.isBatch())
        Core_MDF_PNUM_Mapping_ServiceHandler.createObjectShareRecords((Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap);

        //Sharing of Account User
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Manual_Share')){
            Core_MDF_ManualSharing.sharingAccountUser((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new);// Accenture - Krishna Kulkarni Date - 04-30-2019
        }
    }
    
    public override void afterUpdate(){
        //To check Recursion, if coming from batch block it.
            Boolean flagRecursion = Core_MDF_PNUM_Mapping_ServiceHandler.isAccountUserUpdated((Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.oldMap, (Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap);
            if(flagRecursion && !Core_MDF_RecursiveTrigger.isRecursive){
                //Deleting share records & then Creating for new mapping(Case, Escalation and Campaign)
                if(!System.isBatch()){
                if(!Core_MDF_Utility.byPassFeature('Bypass_AcctUserMapping_Obj_Del_Share'))
                Core_MDF_PNUM_Mapping_ServiceHandler.deleteObjectShareRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.old, (Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap, true);
            
                //Resharing of Account User after Owner Change
                Core_MDF_ManualSharing.recalculateSharePnumWhenOwnerChange((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.NEW,(Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.oldMap); // Accenture - Krishna Kulkarni Date - 04-30-2019    
                }
                if(!Core_MDF_Utility.byPassFeature('Bypass_AcctUserMapping_Obj_Share')){
                    Core_MDF_PNUM_Mapping_ServiceHandler.removeAndAddUsersToNodeGroup(Trigger.new, Trigger.old);
                }
            }
    }
    
    public override void afterDelete(){
        //To remove external users from Account node group.
        if(!Core_MDF_Utility.byPassFeature('Bypass_AcctUserMapping_Obj_Del_Share')){
            Core_MDF_PNUM_Mapping_ServiceHandler.removeUsersFromNodeGroupOnDelete(Trigger.old);
        }

        //To delete Share Records
        if(!Core_MDF_Utility.byPassFeature('Bypass_AcctUserMapping_Obj_Del_Share'))
            Core_MDF_PNUM_Mapping_ServiceHandler.deleteObjectShareRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.old, (Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap, false);
    }
}