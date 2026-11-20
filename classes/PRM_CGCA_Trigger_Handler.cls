/***************************************************************************************************************************************
Apex Class Name     : PRM_CGCA_Trigger_Handler 
Version             : 1.0
Created Date        : March 2020
Function            : PRM_CGCA_Trigger_Handler for trigger PRM_CGCA_Trigger 
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        17-June-2020                     US695552-Create trigger on contact group contact association
*************************************************************************************************************************************/

public class PRM_CGCA_Trigger_Handler  extends TriggerHandler{
    public override void afterUpdate(){
        if(isActive('PRM_CGCA_Trigger_Switch')){
            Map<Id,PRM_Contact_Group_Contact_Association__c> cgcaOldMap = (Map<Id,PRM_Contact_Group_Contact_Association__c>) trigger.oldMap;
            PRM_CGCA_Trigger_Utility.checkInactiveContactGroupAssociations(trigger.new, cgcaOldMap);            
        }
    }

	public override void beforeUpdate() {
        if(isActive('PRM_CGCA_Trigger_Switch')){
            //Map<Id,PRM_Contact_Group_Contact_Association__c> cgcaOldMap = (Map<Id,PRM_Contact_Group_Contact_Association__c>) trigger.oldMap;
            PRM_CGCA_Trigger_Utility.updateStartandEndDates(trigger.new,(Map<Id,PRM_Contact_Group_Contact_Association__c>) Trigger.oldMap);
        }
    }
}