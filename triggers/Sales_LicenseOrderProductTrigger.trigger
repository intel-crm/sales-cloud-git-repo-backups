/*********************************************************************************************************************
Class Name    : Sales_LicenseOrderProductTrigger
Version       : 1.0
Created Date  : Apr 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain       24-Apr-2021             Order Trigger  
* *********************************************************************************************************************/
trigger Sales_LicenseOrderProductTrigger on Sales_License_Order_Product__c (before insert) {
    new Sales_LicenseOrderProductTriggerHandler().run();
}