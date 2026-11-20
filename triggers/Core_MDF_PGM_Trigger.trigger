/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_PGM_Trigger 
* Version     : 1.0 
* Created Date: 30-09-2019
* Modification Log :
* Description:                                                
* Developer                Date                           Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-Vaishali       30-09-2019                     Trigger on Core_MDF_Partner_Group_Mapping__c
* Intel - NP(11630236)     09-10-2019                     Added After insert/update/delete
*****************************************************************************************************************************************/
trigger Core_MDF_PGM_Trigger on Core_MDF_Partner_Group_Mapping__c (before insert, before update, before delete, after insert, after update, after delete) {
    new Core_MDF_PGM_TriggerHandler().run();
}