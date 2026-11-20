/******************************************************************************************************************************************
Trigger Name: Core_IntegrationInboundMessage
Version     : 1.0
Created Date: 03 NOV 2016
Function    : Trigger for the object Integration Inbound Message

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/03/2016              Original version
* Dave Hood                 12/02/2016              Updated to also fire on UPDATE, so we can re-process messages
* Dave Hood                 01/26/2017              Added "after" method since we had to move A&E code to fire after
*****************************************************************************************************************************************/
trigger Core_IntegrationInboundMessage on Core_Integration_Inbound_Message__c (before insert, before update,
                                                                               after insert, after update) {

    if (Trigger.isBefore)
        Core_IntegrationInboundMessageHandler.beforeMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);

    if (Trigger.isAfter)
        Core_IntegrationInboundMessageHandler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
}