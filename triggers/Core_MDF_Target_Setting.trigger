trigger Core_MDF_Target_Setting on Core_MDF_Target_Setting__c (before insert, after insert, before update, after update) {
    if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_TargetSetting_Trigger') == null || !(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_TargetSetting_Trigger').Core_Active__c && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
        new Core_MDF_Target_Setting_TriggerHandler().run();
    }
}