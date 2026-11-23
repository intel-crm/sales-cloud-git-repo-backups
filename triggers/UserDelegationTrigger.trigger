/****************************************************************************************************
Apex Class Name : UserDelegationTrigger
Version         : 1.0 
Function        : User Delegation Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema		                  4/11/2021               Created
*****************************************************************************************************/
trigger UserDelegationTrigger on core_user_delegation__c (before insert, before update) {
    new UserDelegationTriggerHandler().run();
}