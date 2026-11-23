/****************************************************************************************************
Apex Class Name : PortalRequestTrigger
Version         : 1.0 
Created Date    : 12/16/2022
Function        : PortalRequest Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ranjit                     12/16/2022               Created
*****************************************************************************************************/
trigger PortalRequestTrigger on core_cpq_portalrequest__c (before insert,after insert, after update,before update) {    
    new PortalRequestTriggerHandler().run(); 
}