/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_Payment_Trigger 
* Version           : 1.0 
* Created Date      : 03-24-2020
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD       03-24-2019        Trigger on Payment object.
*****************************************************************************************************************************************/
trigger Core_MDF_Payment_Trigger on Core_MDF_Payment__c (before update,after update) 
{                                                                            
    //Payment Trigger Handler
    Core_MDF_Payment_TriggerHandler paymentTriggerHandler = new Core_MDF_Payment_TriggerHandler();
    paymentTriggerHandler.run();
}