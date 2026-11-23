/*********************************************************************************************************************
Class Name    : Sales_BypassCPQTrigger
Version       : 1.0
Created Date  : Sept 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           21-Sept-2021             This trigger is created only for data migration purpose to switch off cpq trigger for data load transaction
*/
trigger Sales_BypassCPQTrigger on Order (after update,before update) {
 new Sales_BypassCPQTriggerHandler().run();
}