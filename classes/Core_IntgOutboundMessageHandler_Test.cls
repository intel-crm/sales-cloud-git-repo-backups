@istest
public class Core_IntgOutboundMessageHandler_Test {
    static testmethod void validateCIOMH(){
        List<Core_Integration_Outbound_Message__c> lstIOM = new List<Core_Integration_Outbound_Message__c>();
        Core_Integration_Outbound_Message__c objIom = new Core_Integration_Outbound_Message__c(Core_Status__c='Pending',Core_Retry_Number__C=1,Core_MessageType__C='AGS Contact Entitlement 2.0'); 
        lstIom.add(objIom);
        insert lstIom;
        test.startTest();
        Core_IntegrationOutboundMessageHandler.afterMethod(lstIom);
        test.stopTest();
    }
    static testmethod void validateIfCondition(){
        Integer intCount = 0;
        List<Core_Integration_Outbound_Message__c> lstIOM = new List<Core_Integration_Outbound_Message__c>();
        Core_Integration_Outbound_Message__c objIom = new Core_Integration_Outbound_Message__c(Core_Status__c='Pending',Core_Retry_Number__C=1,Core_MessageType__C='AGS Contact Entitlement 2.0'); 
        lstIom.add(objIom);
        insert lstIom;
        system.assertEquals(1, lstIom.size());
        List<Core_Integration_Outbound_Message__c> lstIomNew = [SELECT Id, Core_MessageType__c,Core_Status__c,Core_Retry_Number__C FROM Core_Integration_Outbound_Message__c WHERE Id =: lstIom[0].Id AND Core_MessageType__C='AGS Contact Entitlement 2.0' AND Core_Status__c='Pending'];
        system.assertEquals(1,lstIomNew.size());  
        intCount = 100;
        test.startTest();        
        Core_IntegrationOutboundMessageHandler.afterMethod(lstIomNew);
        //system.enqueueJob(new ContactERPMIntegrationStatusHandler(lstIom,objIom));
        test.stopTest();
    }
}