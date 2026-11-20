@isTest
public class Pricing_IntegrationStagingHandlerTest {
    static testmethod void testUpdateRetryNumber() {
        Pricing_Integration_Staging__c pis = new Pricing_Integration_Staging__c();
        pis.Pricing_Message_Type__c = 'Tender';
        pis.Pricing_Status__c = 'Failed';
        Test.startTest();
        insert pis;
        pis.Pricing_Retry_Number__c = 1;
        update pis;
        System.assertEquals(pis.Pricing_Retry_Time_Stamp__c,null,'Retry timstamp not updated');
        Test.stopTest();
        
    }
}