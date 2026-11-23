/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_Escalation 
* Created Date      : 15-05-2019
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - NP           15-05-2019       Trigger on Escalation custom object
*****************************************************************************************************************************************/
trigger Core_MDF_Escalation on Core_MDF_Escalation__c (after insert, after update, before insert, before update) {
    new Core_MDF_Escalation_TriggerHandler().run();
}