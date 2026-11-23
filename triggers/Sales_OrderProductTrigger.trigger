/*********************************************************************************************************************
Class Name    : Sales_OrderProductTrigger
Version       : 1.0
Created Date  : Dec 2020
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           30-Dec-2020              Order Product Trigger  
* *********************************************************************************************************************/
trigger Sales_OrderProductTrigger on OrderItem (before insert,after insert, after update, before update,before delete, after delete) {
    new Sales_OrderProductTriggerHandler().run();
}