/**************************************************************************************
Apex Class Name : Core_Account_ERPMEngagement_Trigger
Version     : 1.0 
Created Date: 31st July, 2019
Description : Trigger  for Core_Account_ERPM_Engagement__c
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Uday                 31/07/2019               Original Version
*************************************************************************************/
trigger Core_Account_ERPMEngagement_Trigger on Core_Account_ERPM_Engagement__c (before insert, after insert, before update, after update,
                                                                                before delete, after delete) {
    new Core_Acct_erpm_eng_TriggerHandler().run();
}