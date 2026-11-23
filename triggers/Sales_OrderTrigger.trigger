/*********************************************************************************************************************
Class Name    : Sales_OrderTrigger
Version       : 1.0
Created Date  : Jan 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           20-Jan-2021             Order Trigger  
* *********************************************************************************************************************/
trigger Sales_OrderTrigger on Order (before insert, after insert, before update, after update) {
    new Sales_OrderTriggerHandler().run();
}