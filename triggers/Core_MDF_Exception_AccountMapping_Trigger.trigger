/****************************************************************************************************************************************
* Trigger Name        : Core_MDF_Exception_AccountMapping_Trigger
* Created Date        : 24-03-2025
* Developer Name      : Mohit Sharma
* Object Name         : Exception Account Mapping(Core_MDF_Exception_Account_Mapping__c)
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture MS      24-03-2025       Created Trigger on Exception Account Mapping     
*****************************************************************************************************************************************/
trigger Core_MDF_Exception_AccountMapping_Trigger on Core_MDF_Exception_Account_Mapping__c (before insert,before update, after insert, after update) {
     if(Core_Trigger_Executions__c.getValues('Core_MDF_ByPass_Expt_AcctMap_Trigger') == null || !(Core_Trigger_Executions__c.getValues('Core_MDF_ByPass_Expt_AcctMap_Trigger').Core_Active__c && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){    
        new Core_MDF_Expt_AccMap_TriggerHandler().run();
     }
}