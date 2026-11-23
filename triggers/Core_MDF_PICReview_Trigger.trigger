/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PICReview_Trigger 
* Version           : 1.0 
* Created Date      : 01-16-2022
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - BD       01-16-2022        Trigger on PIC Review object.
*****************************************************************************************************************************************/
trigger Core_MDF_PICReview_Trigger on Core_MDF_PIC_Review__c (before insert,after insert,before update,
                                                              after update, before delete,after delete) {
                                                                  
                                                          Core_MDF_PICReview_TriggerHandler picReviewTriggerHandler = new Core_MDF_PICReview_TriggerHandler();
                                                                  picReviewTriggerHandler.run();
                                                                  
                                                                  
                                                              }