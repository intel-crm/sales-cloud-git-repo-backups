/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PICReviewResult_Trigger 
* Version           : 1.0 
* Created Date      : 12-21-2021
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - BD       12-21-2021        Trigger on PIC Review Result object.
*****************************************************************************************************************************************/
trigger Core_MDF_PICReviewResult_Trigger on core_MDF_PICReviewResult__c (before insert,after insert,before update,
                                                                        after update, before delete,after delete) {
    
    
    Core_MDF_PICReviewResult_TriggerHandler picReviewResultTriggerHandler = new Core_MDF_PICReviewResult_TriggerHandler();
    picReviewResultTriggerHandler.run();
    
   
    
    

}