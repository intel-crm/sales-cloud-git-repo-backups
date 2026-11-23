/****************************************************************************************************
Apex Class Name : BmAssignmentConfigTrigger
Version         : 1.0 
Function        : BM Assignment config trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Tushar		                  4/11/2021               Created
*****************************************************************************************************/
trigger BmAssignmentConfigTrigger on core_cpq_bm_assignment_config__c (before insert,after insert, after update,before update) {
    new BmAssignmentConfigTriggerHandler().run();
}