/****************************************************************************************************
Apex Class Name : DistyVisibilityTrigger
Version         : 1.0 
Function        : Disty Visibility Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sushmita		                  4/11/2021               Created
*****************************************************************************************************/
trigger DistyVisibilityTrigger on core_cpq_disty_visibility__c (before insert,after insert, after update,before update, before delete, after delete) {
    new DistyVisibilityTriggerHandler().run();
}