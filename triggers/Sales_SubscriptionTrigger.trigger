/*********************************************************************************************************************
Class Name    : Sales_SubscriptionTrigger
Version       : 1.0
Created Date  : Jan 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           11-Jan-2021              Subscription Trigger 
* *********************************************************************************************************************/
trigger Sales_SubscriptionTrigger on SBQQ__Subscription__c (before insert, after insert) {
    
    new Sales_SubscriptionTriggerHandler().run();
    
}