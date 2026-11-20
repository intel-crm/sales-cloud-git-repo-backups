/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_BudgetTransferLogTrigger 
* Version           : 1.0 
* Created Date      : 4-29-2018
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Krishna Kulkarni       4/29/2018        Trigger on Budget Transfer Log object.
*****************************************************************************************************************************************/
trigger Core_MDF_BudgetTransferLogTrigger on Core_MDF_Budget_Transfer_Log__c (before insert,
                                                                                  before update,
                                                                                  before delete,
                                                                                  after insert,
                                                                                  after update,
                                                                                  after delete,
                                                                                  after undelete) {
    new Core_MDF_BudgetTransferLogTriggerHandler().run();                                                                                   
}