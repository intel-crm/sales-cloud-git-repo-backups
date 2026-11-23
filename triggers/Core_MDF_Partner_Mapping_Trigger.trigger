/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_Partner_Mapping_Trigger 
* Version           : 1.0 
* Created Date      : 03/01/2024
* Modification Log  : 
* Developer            Date(MM/DD/YYYY)  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - NB       03/01/2024        Trigger on Primary to Activating Partner Map
*****************************************************************************************************************************************/
trigger Core_MDF_Partner_Mapping_Trigger on Core_MDF_Partner_Mapping__c (before insert) {
    List<Core_MDF_Partner_Mapping__c> paMapList = new List<Core_MDF_Partner_Mapping__c>();
    if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_IUPGM_Trigger') == null || 
             !(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_IUPGM_Trigger').Core_Active__c &&
               Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
                   for(Core_MDF_Partner_Mapping__c paMapRec : Trigger.New){
                       List<Core_MDF_Partner_Mapping__c> pRecList = [select id,Name, Core_MDF_Primary_Partner_Account_id__c,  Core_MDF_Activating_Partner_Account_id__c  from Core_MDF_Partner_Mapping__c where 
                                                          Core_MDF_Primary_Partner_Account_id__c=:paMapRec.Core_MDF_Activating_Partner_Account_id__c and Core_MDF_Activating_Partner_Account_id__c=:paMapRec.Core_MDF_Primary_Partner_Account_id__c limit 1];
                       if(pRecList!=null){
                           paMapRec.addError(pRecList[0].Name+' already exists for this combination of accounts. Please change one/both partner accounts.');
                       }
                   }
           }
}