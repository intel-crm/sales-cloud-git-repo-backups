/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PaymentRun_Trigger 
* Version           : 1.0 
* Created Date      : 01-30-2019
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD       01-30-2019        Trigger on Partner Run object.
*****************************************************************************************************************************************/
trigger Core_MDF_PaymentRun_Trigger on Core_MDF_Payment_Run__c (before insert,after insert,before update,
                                                                after update, before delete,after delete) {
                                                                     
        Core_MDF_PaymentRun_TriggerHandler paymentRunTriggerHandler = new Core_MDF_PaymentRun_TriggerHandler();
        paymentRunTriggerHandler.run();

}