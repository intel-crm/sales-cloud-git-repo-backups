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
        if(executeTrigger && Trigger.isInsert && isActive('DDR_Before_Insert') && Core_DDR_Design_Handler_Utility.firstRunBeforeInsert)
        {
           // if(isActive('DDR_Before_Insert') && Core_DDR_Design_Handler_Utility.firstRunBeforeInsert){ 
                //if(Trigger.isInsert){
                    Core_DDR_Design_Handler_Utility.firstRunBeforeInsert = false;                    
                    Core_DDR_Design_Handler_Utility.processBeforeInsert(Trigger.old,Trigger.new,(Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap);
                //}
            //}
        }
    }
    public override void beforeUpdate() {
        if(isActive('DDR_Before_Update') && Core_DDR_Design_Handler_Utility.firstRunBeforeUpdate && Trigger.isUpdate){//Retrieved from Custom labels            
           // if(Trigger.isUpdate){
                Core_DDR_Design_Handler_Utility.firstRunBeforeUpdate = false;
                system.debug('Inside DDR Before update trigger');
                Core_DDR_Design_Handler_Utility.processBeforeUpdate(Trigger.old,Trigger.new,(Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap);
           // }
        }
    }
    public override void afterInsert() {
        if(executeTrigger && isActive('DDR_After_Insert') && trigger.IsInsert && Core_DDR_Design_Handler_Utility.firstRunAfterInsert)
        {
            //if(isActive('DDR_After_Insert')){
               // if(trigger.IsInsert && Core_DDR_Design_Handler_Utility.firstRunAfterInsert){
                    Core_DDR_Design_Handler_Utility.firstRunAfterInsert = false;
                    Core_DDR_Design_Handler_Utility.processAfterInsert(Trigger.old,Trigger.new,(Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap);                
                    
                //}
           // } 
        }
    }
    public override void afterUpdate() {
        if(executeTrigger && isActive('DDR_After_Update') && trigger.isUpdate && Core_DDR_Design_Handler_Utility.AfterUpdateIterated )
        {
           // if(isActive('DDR_After_Update')){
               // if(trigger.isUpdate && Core_DDR_Design_Handler_Utility.AfterUpdateIterated){//afterupdaterun
                    //afterupdaterun = false;
                    System.debug('before calling function 55--');
                    Core_DDR_Design_Handler_Utility.postApprovalFromResubmittedDR(Trigger.old,Trigger.new,(Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap); 
                    Core_DDR_Design_Handler_Utility.processAfterUpdate(Trigger.old,Trigger.new, (Map<Id,Core_Design_Registration__c>) Trigger.oldMap,(Map<Id,Core_Design_Registration__c>)Trigger.newMap);        
                    Core_DDR_Design_Handler_Utility.lockEditsDRP((Map<Id,Core_Design_Registration__c>)Trigger.oldMap,Trigger.New);
                    System.debug('before calling function 59--');
                    Core_DDR_Design_Handler_Utility.fetchPartnerEndCustMapping((Map<Id,Core_Design_Registration__c>)Trigger.oldMap,Trigger.New);
                //}
           // } 
        }
    }
}