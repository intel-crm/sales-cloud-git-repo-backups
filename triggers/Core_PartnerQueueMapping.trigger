/********************************************************************************************************************
Apex Class Name:  Core_PartnerQueueMapping
Version     : 1.0 
Created Date: 26 May 2022
Function    : Trigger on Core_Partner_Queue_Mapping__c
Modification Log :
* Developer                   Date                   
* ----------------------------------------------------------------------------                 
*Megha Kumari                05/26/22               
*********************************************************************************************************************/
trigger Core_PartnerQueueMapping on Core_Partner_Queue_Mapping__c (after insert, after update) {
    new Core_PartnerQueueMappingTriggerHandler().run();
}