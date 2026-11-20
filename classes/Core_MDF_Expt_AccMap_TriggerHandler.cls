/****************************************************************************************************************************************
* Class Name        : Core_MDF_Expt_AccMap_TriggerHandler
* Created Date        : 24-03-2025
* Developer Name      : Mohit Sharma
* Last Modified Name  : 
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture MS      24-03-2025       Created Trigger Handler for Exception Account Mapping Trigger class
*****************************************************************************************************************************************/
public class Core_MDF_Expt_AccMap_TriggerHandler extends TriggerHandler{
    public override void beforeInsert(){
        if(!Core_MDF_Utility.byPassFeature('ByPass_ExptAccMapValidation')){
            Core_MDF_Expt_AccMap_ServiceHandler.initializeEAM((List<Core_MDF_Exception_Account_Mapping__c>) Trigger.new);
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassAccountTypeMap_Excep')){
            Core_MDF_Expt_AccMap_ServiceHandler.prepareAccountTypeForException((List<Core_MDF_Exception_Account_Mapping__c>) Trigger.new, (Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.oldMap);
        }
    }
    
    public override void beforeUpdate(){
        if(!Core_MDF_Utility.byPassFeature('ByPass_EAM_Inactivation_Validation')){
            Core_MDF_Expt_AccMap_ServiceHandler.validateActiveEAM((Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.newMap, (Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.oldMap);
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassAccountTypeMap_Excep')){
            Core_MDF_Expt_AccMap_ServiceHandler.prepareAccountTypeForException((List<Core_MDF_Exception_Account_Mapping__c>) Trigger.new, (Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.oldMap);
        }
    }
    
    public override void afterInsert(){
        if(!Core_MDF_Utility.byPassFeature('ByPass_ExptAccountMappingSharing')){
            Core_MDF_Expt_AccMap_ServiceHandler.shareEAM((Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.newMap);
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPass_EAM_Expt_Ext_Sharing')){
          Core_MDF_Expt_AccMap_ServiceHandler.shareRecordsWithExtUsers((Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.newMap);
        }
    }
    
    public override void afterUpdate(){
        if(!Core_MDF_Utility.byPassFeature('ByPass_ExptAccountMappingSharing')){
            Core_MDF_Expt_AccMap_ServiceHandler.shareEAMonHostGeoUpdate((Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.newMap, (Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.oldMap);
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPass_EAM_Expt_Ext_Sharing')){
            Core_MDF_Expt_AccMap_ServiceHandler.refreshExternalSharingForUpdatedEAM(
                (Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.newMap,
                (Map<Id,Core_MDF_Exception_Account_Mapping__c>) Trigger.oldMap
            );
        }
    }
    
}