/****************************************************************************************************************************************
* Trigger Name        : Core_MDF_Exception_Trigger
* Created Date      : 19-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SS        19-06-2019          Exception Trigger on after insert and update        
*****************************************************************************************************************************************/
trigger Core_MDF_Exception_Trigger on Core_MDF_Exception__c (after insert, after update, before insert, before update) {
   if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Exception_Trigger') == null || !(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Exception_Trigger').Core_Active__c && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
       new Core_MDF_Exception_TriggerHandler().run();
   }
}