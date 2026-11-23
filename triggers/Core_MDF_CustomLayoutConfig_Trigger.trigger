/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_CustomLayoutConfig_Trigger 
* Version           : 1.0 
* Created Date      : 12/13/2021
* Modification Log  : 
* Developer            Date(MM/DD/YYYY)  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       12/13/2021        Trigger on Custom Layout Configuration object.
*****************************************************************************************************************************************/
trigger Core_MDF_CustomLayoutConfig_Trigger on Core_MDF_Custom_Layout_Configurations__c (before insert, 
                                                                                        after insert,
                                                                                        before update,
                                                                                        after update,
                                                                                        before delete, 
                                                                                        after delete) {
    new Core_MDF_CustomLayout_TriggerHandler().run();
}