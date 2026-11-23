/****************************************************************************************************
Apex Class Name : DPA_ALNTrigger
Version         : 1.0 
Created Date    : 01/05/2021
Function        : DPA/ALN Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshadeep                     01/05/2021               Created
*****************************************************************************************************/
trigger DPA_ALNTrigger on core_cpq_dpa_aln__c (before insert,after insert, after update,before update) {
    new DPA_ALNTriggerHandler().run();
}