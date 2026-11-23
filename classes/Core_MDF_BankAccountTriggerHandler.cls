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
        
            //To delete Bank Share records for External Account Groups.
            if(!Core_MDF_Utility.byPassFeature('Bypass_Delete_Sharing_Records'))
                Core_MDF_BankAccountServiceHandler.deleteBankShareRecordsExternalGroups((List<Core_MDF_Account_Bank_Mapping__c>) Trigger.old,true);
        }
    }
    public override void beforeDelete(){
        if(isActive('Core_MDF_ABMOnBeforeDelete')){
            Core_MDF_BankAccountServiceHandler.beforeDeleteABMRecords((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.oldMap);
        
            //To delete Bank Share records for External Account Groups.
            if(!Core_MDF_Utility.byPassFeature('Bypass_Delete_Sharing_Records'))
                Core_MDF_BankAccountServiceHandler.deleteBankShareRecordsExternalGroups((List<Core_MDF_Account_Bank_Mapping__c>) Trigger.old, false);
        }
    }
    public override void afterInsert(){
        if(isActive('Core_MDF_ABMOnAfterInsert')){
            if(!Core_MDF_Utility.byPassFeature('Bypass_ABM_External_Sharing'))
                Core_MDF_BankAccountServiceHandler.shareBankAndABMRecordsWithAccountExternalGroup((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap, null);
            if(!Core_MDF_Utility.byPassFeature('Bypass_ABM_Internal_Sharing'))
                Core_MDF_BankAccountServiceHandler.createABMShareForInternalUsers((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap);
            if(!Core_MDF_Utility.byPassFeature('Bypass_ABM_NodeGroup_Sharing'))
                Core_MDF_BankAccountServiceHandler.shareBankAndABMRecordsWithAccNodeGroup((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap);
                
        }
    }
    public override void afterUpdate(){
        if(isActive('Core_MDF_ABMOnAfterUpdate')){
            if(!Core_MDF_Utility.byPassFeature('Bypass_ABM_External_Sharing'))
                Core_MDF_BankAccountServiceHandler.shareBankAndABMRecordsWithAccountExternalGroup((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap, (Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.oldMap);
            if(!Core_MDF_Utility.byPassFeature('Bypass_ABM_Internal_Sharing'))
                Core_MDF_BankAccountServiceHandler.createABMShareForInternalUsers((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap);
            if(!Core_MDF_Utility.byPassFeature('Bypass_ABM_NodeGroup_Sharing'))
                Core_MDF_BankAccountServiceHandler.shareBankAndABMRecordsWithAccNodeGroup((Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.newMap);
            //if(!Core_MDF_Utility.byPassFeature('Bypass_Delete_Sharing_Records'))
                //Core_MDF_BankAccountServiceHandler.deleteBankShareRecordsExternalGroupsOnInactivation((List<Core_MDF_Account_Bank_Mapping__c>) Trigger.new, (Map<Id,Core_MDF_Account_Bank_Mapping__c>) Trigger.oldMap);
        }
    }
    public override void afterDelete(){
        if(isActive('Core_MDF_ABMOnAfterDelete')){
            Core_MDF_BankAccountServiceHandler.deleteBankRecordsWithUsers((List<Core_MDF_Account_Bank_Mapping__c>) Trigger.old);

        }
    }
}