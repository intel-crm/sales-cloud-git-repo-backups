/****************************************************************************************************
Apex Class Name : CORE_DDR_TriggerHandler
Version         : 1.0 
Created Date    : 24/07/2023
Function        : Handler class for the trigger 'Core_DDR_Design_Trigger'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Utkarsh                  24/07/2023                Created
*****************************************************************************************************/
public class CORE_DDR_TriggerHandler extends TriggerHandler{
    @TestVisible static Boolean executeTrigger = true;
    public static boolean afterupdaterun = true;
    
    Boolean newTrigger = Boolean.valueOf(System.Label.CORE_DDR_New_Trigger_Switch);
    public override void beforeInsert() {
        if(executeTrigger)
        {
            if(isActive('DDR_Before_Insert') && Core_DDR_Design_Handler_Utility.firstRunBeforeInsert){ 
                if(Trigger.isInsert){
                    Core_DDR_Design_Handler_Utility.firstRunBeforeInsert = false;                    
                    Core_DDR_Design_Handler_Utility.processBeforeInsert(Trigger.old,Trigger.new,(Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap);
                }
            }
        }
    }
    public override void beforeUpdate() {
        if(isActive('DDR_Before_Update') && Core_DDR_Design_Handler_Utility.firstRunBeforeUpdate){//Retrieved from Custom labels            
            if(Trigger.isUpdate){
                Core_DDR_Design_Handler_Utility.firstRunBeforeUpdate = false;
                system.debug('Inside DDR Before update trigger');
                Core_DDR_Design_Handler_Utility.processBeforeUpdate(Trigger.old,Trigger.new,(Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap);
            }
        }
    }
    public override void afterInsert() {
        if(executeTrigger)
        {
            if(isActive('DDR_After_Insert')){
                if(trigger.IsInsert && Core_DDR_Design_Handler_Utility.firstRunAfterInsert){
                    Core_DDR_Design_Handler_Utility.firstRunAfterInsert = false;
                    Core_DDR_Design_Handler_Utility.processAfterInsert(Trigger.old,Trigger.new,(Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap);                
                    
                }
            } 
        }
    }
    public override void afterUpdate() {
        if(executeTrigger)
        {
            if(isActive('DDR_After_Update')){
                if(trigger.isUpdate && Core_DDR_Design_Handler_Utility.AfterUpdateIterated){//afterupdaterun
                    //afterupdaterun = false;
                    Core_DDR_Design_Handler_Utility.postApprovalFromResubmittedDR(Trigger.old,Trigger.new,(Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap); 
                    Core_DDR_Design_Handler_Utility.processAfterUpdate(Trigger.old,Trigger.new, (Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap);        
                    Core_DDR_Design_Handler_Utility.lockEditsDRP((Map<Id,Core_Design_Registration__c>)Trigger.oldMap,Trigger.New);
		            Core_DDR_Design_Handler_Utility.fetchPartnerEndCustMapping((Map<Id,Core_Design_Registration__c>)Trigger.oldMap,Trigger.New);
                }
            } 
        }
    }
}