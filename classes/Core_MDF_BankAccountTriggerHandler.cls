/****************************************************************************************************************************************
* Class Name  : Core_MDF_BankAccountTriggerHandler 
* Version     : 1.0 
* Created Date: 24-11-2018
* Modification Log :
* Developer            Date               Description
*****************************************************************************************************************************************/
public class Core_MDF_BankAccountTriggerHandler extends TriggerHandler {
	public override void beforeUpdate() {
        if(isActive('Core_MDF_ABMOnBeforeUpdate')){
             Core_MDF_BankAccountServiceHandler.beforeUpdateABMCondition((List<Core_MDF_Account_Bank_Mapping__c>) Trigger.old,(Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap); 
            //Core_MDF_BankAccountServiceHandler.deleteBankRecordsWithUsers((List<Core_MDF_Account_Bank_Mapping__c>) Trigger.old,Map<Id,Core_MDF_Account_Bank_Mapping__c> Trigger.newMap); 
         }
    }
    
   
    public override void beforeDelete(){
        if(isActive('Core_MDF_ABMOnBeforeDelete')){
            Core_MDF_BankAccountServiceHandler.validateIfClaimExist((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.oldMap);
        }  
    }

   public override void afterInsert(){
        if(isActive('Core_MDF_ABMOnAfterInsert')){
            Core_MDF_BankAccountServiceHandler.shareBankAndABMRecordsWithExternalUsers((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap);
            Core_MDF_BankAccountServiceHandler.createABMShareForInternalUsers((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap);
        }
    }
    
    public override void afterUpdate(){
        if(isActive('Core_MDF_ABMOnAfterUpdate')){
            Core_MDF_BankAccountServiceHandler.shareBankAndABMRecordsWithExternalUsers((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap);
            Core_MDF_BankAccountServiceHandler.createABMShareForInternalUsers((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap);
        }
    }
    
    
    public override void afterDelete(){
        if(isActive('Core_MDF_ABMOnAfterDelete')){
            Core_MDF_BankAccountServiceHandler.deleteBankRecordsWithUsers((List<Core_MDF_Account_Bank_Mapping__c>) Trigger.old);   
        } 
    }
	/*
    public override void beforeInsert() {
    }

    public override void afterUndelete(){        
    }*/
}