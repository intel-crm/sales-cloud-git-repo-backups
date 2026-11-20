/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-10-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
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
        	Id asyncJobId = Database.executeBatch(integrationBatch);
            System.assertEquals(true, asyncJobId != null, 'Database.executeBatch should return a non-null AsyncApexJob Id.');
        Test.stopTest();
    }

}