/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_Escalation 
* Created Date      : 15-05-2019
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - NP           15-05-2019       Trigger on Escalation custom object
*****************************************************************************************************************************************/
trigger Core_MDF_Escalation on Core_MDF_Escalation__c (after insert, after update, before insert, before update) {
    if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Escalation_Trigger') == null || !(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Escalation_Trigger').Core_Active__c && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
                 new Core_MDF_Escalation_TriggerHandler().run();
   }
}