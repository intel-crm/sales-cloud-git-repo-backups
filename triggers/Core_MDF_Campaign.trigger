trigger Core_MDF_Campaign on Campaign (before insert, before update, after insert, after update, before delete) {            
    
    if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Campaign_Trigger') == null || !Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Campaign_Trigger').Core_Active__c || (Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && !Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
        
        new Core_MDF_CampaignTriggerHandler().run();
    }
}