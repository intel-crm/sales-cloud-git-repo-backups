/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_RecallApprovalTrigger 
* Version     : 1.0 
* Created Date: 4-26-2021
* Modification Log :
* Description:                                                 
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Prashant Dhanagar       4/26/2021                     Trigger to handle Core MDF Recall Approval functionalities. 
*/
trigger Core_MDF_RecallApprovalTrigger on Core_MDF_Recall_Approval__e (after insert) {
    new Core_MDF_RecallApprovalTriggerHandler().run(); 
   Core_MDF_RecallApprovalServiceHandler.recallApprovalProcess (Trigger.New);
}