/*********************************************************************************************************************
Class Name    : Sales_License_Group_Switch_configTrigger
Version       : 1.0
Created Date  : May 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           31-May-2021              Sales License Group Switch Config Trigger 
* *****************************************************************************************************************/
trigger Sales_License_Group_Switch_configTrigger on Sales_License_Group_Switch_config__c (Before insert, After insert,After Update,After delete) {
        new Sales_License_Group_configTriggerHandler().run();
}