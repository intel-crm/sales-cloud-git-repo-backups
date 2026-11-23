/*********************************************************************************************************************
Class Name    : Sales_ContractTrigger
Version       : 1.0
Created Date  : Mar 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain           12-Mar-2021              Subscription Trigger 
* *********************************************************************************************************************/
trigger Sales_ContractTrigger on Contract (after update,after insert,before update) {
    
    new Sales_ContractTriggerHandler().run();
    
}