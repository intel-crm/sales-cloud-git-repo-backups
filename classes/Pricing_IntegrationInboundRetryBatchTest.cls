@isTest
private class Pricing_IntegrationInboundRetryBatchTest {
    
    @isTest
    private static void testPricing_IntegrationInboundRetryBatch()
    {
        List<Core_Integration_Inbound_Message__c> listToInsert = new List<Core_Integration_Inbound_Message__c>();
        Core_Integration_Inbound_Message__c integrationInboundRecord1 = new Core_Integration_Inbound_Message__c();
        integrationInboundRecord1.Core_Retry_Counter__c = 3;
        integrationInboundRecord1.Core_Processing_Status__c = 'Failed';
        integrationInboundRecord1.Core_Message_Type__c = 'Tender';
        listToInsert.add(integrationInboundRecord1);
        Core_Integration_Inbound_Message__c integrationInboundRecord2 = new Core_Integration_Inbound_Message__c();
        integrationInboundRecord2.Core_Retry_Counter__c = 2;
        integrationInboundRecord2.Core_Processing_Status__c = 'Pending';
        listToInsert.add(integrationInboundRecord2);
        integrationInboundRecord2.Core_Message_Type__c = 'Tender';
        insert listToInsert;
        
        Test.startTest();
        	Pricing_IntegrationInboundRetryBatch integrationBatch = new Pricing_IntegrationInboundRetryBatch();
        	Database.executeBatch(integrationBatch);
        Test.stopTest();
    }

}