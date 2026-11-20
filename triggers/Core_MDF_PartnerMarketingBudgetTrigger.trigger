/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PartnerMarketingBudgetTrigger 
* Version           : 1.0 
* Created Date      : 03-09-2018
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       03-09-2018        Trigger on Partner Marketing Budget object.
*****************************************************************************************************************************************/
trigger Core_MDF_PartnerMarketingBudgetTrigger on PartnerMarketingBudget (before insert, before update, after insert,
                                                                          after update) {
 
    
    if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_PMB_Trigger') == null || !(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_PMB_Trigger').Core_Active__c && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
                 new Core_MDF_PMBTriggerHandler().run();   
   }                                                                            
}