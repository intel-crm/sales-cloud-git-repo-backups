/****************************************************************************************************
Apex Class Name : ForwardCostTrigger
Version         : 1.0 
Function        : Forward Cost Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema		                  4/11/2021               Created
*****************************************************************************************************/
trigger ForwardCostTrigger on price_forward_cost__c (before insert,after insert, after update, before update) {
    new ForwardCostTriggerHandler().run();
}