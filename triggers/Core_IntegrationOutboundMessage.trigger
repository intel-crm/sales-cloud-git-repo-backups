/******************************************************************************************************************************************
Trigger Name: Core_IntegrationOutboundMessage
Version     : 1.0
Created Date: 15 SEP 2021
Function    : Trigger for the object Integration Outbound Message

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Sankarshana               09/15/2021              Original version
*****************************************************************************************************************************************/
trigger Core_IntegrationOutboundMessage on Core_Integration_Outbound_Message__c (after insert) {

if (Trigger.isAfter)
       Core_IntegrationOutboundMessageHandler.afterMethod(trigger.new);
}