/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_CMF_Map_Trigger 
* Version     : 1.0 
* Created Date: 15-06-2023
* Modification Log :
* Description:                                                
* Developer                Date                           Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture- Mayuri      15-06-2023                     Trigger on Core_MDF_Comarketing_CMF_Map__c
*****************************************************************************************************************************************/
trigger Core_MDF_CMF_Map_Trigger on Core_MDF_Comarketing_CMF_Map__c (before insert, before update, before delete, after insert, after update, after delete) {
    new Core_MDF_CMF_Map_TriggerHandler().run();
}