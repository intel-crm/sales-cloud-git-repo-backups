/******************************************************************************************************************************************
Trigger Name: Core_IntegrationOutboundMessageHandler
Version     : 1.0
Created Date: 15 SEP 2021
Function    : Handler class for the trigger Core_Integration_Outbound_Message__c

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Sankarshana               09/15/2021              Original version
*****************************************************************************************************************************************/
public class Core_IntegrationOutboundMessageHandler {
    public static void afterMethod(List<Core_Integration_Outbound_Message__c> newlist){
        List<Core_Integration_Outbound_Message__c> lstIom = new List<Core_Integration_Outbound_Message__c>();
        Schema.SObjectType obIom = Schema.Core_Integration_Outbound_Message__c.getSObjectType();
        Integer intCount=0;
        if (!ContactERPMIntegrationStatusHandler.inFutureContext){
            system.debug('entering future check');
        for(Core_Integration_Outbound_Message__c objIom: newlist){
            if(objIom.Core_MessageType__c == 'AGS Contact Entitlement 2.0'){
                //lstIom.add(objIom);
                intCount++;
                if(intCount == 100){
                system.debug('entering if count');
                lstIom.add(objIom);
                System.enqueueJob(new ContactERPMIntegrationStatusHandler(lstIom,obIom));
                lstIom.clear();
                intCount=0;
                }else{
                    system.debug('entering else count');
                lstIom.add(objIom);
                }
            }
        }
    }
         if(lstIom.size() > 0){
             system.debug('entering listIOM');
        System.enqueueJob(new ContactERPMIntegrationStatusHandler(lstIom,obIom));
        }
         
    }
}