/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_CoMarketing_Activity_Inc_Rule 
* Version           : 1.0 
* Created Date      : 3-11-2020
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Nuzhath  3-11-2020        Trigger on Core_MDF_CoMarketing_Activity_Inc_Rule__c 
*****************************************************************************************************************************************/
trigger Core_MDF_CoMarketing_Activity_Inc_Rule on Core_MDF_CoMarketing_Activity_Inc_Rule__c (before insert,
                                                                                  before update,
                                                                                  before delete,
                                                                                  after insert,
                                                                                  after update,
                                                                                  after delete,
                                                                                  after undelete) {
    new Core_MDF_CAIC_TriggerHandler().run();
}