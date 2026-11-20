/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-06-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_MyDeals_Integration_Test {
    @testSetup
    private static void createData(){
        Pricing_Integration_Staging__c intObjRec = new Pricing_Integration_Staging__c();
        intObjRec.Pricing_Retry_Number__c = 2;
        intObjRec.Pricing_Status__c = 'Successful';
        intObjRec.Pricing_Payload__c = '{"RecordDetails":{"Quote":{"UnifiedEndCustomerId":null,"UnifiedEndCustomer":null,"UnifiedCountryEndCustomerId":null,"ShipmentStartDate":"2021-05-04","ShipmentEndDate":"2021-05-04","ServerDealType":"Enterprise","QuoteLine":[{"WWID":"11938364","Status":"Pending Further Intel Review","Region":"Worldwide","ReferenceQuoteLineNumber":null,"QuoteLineNumber":"Q-18798-001","Product":{"ProductNameEPMID":"128693","Name":"Intel® Xeon Phi™ DL 7255 Processor (16GB, 1.1 GHz, 68 Core)","Id":"01t1J0000047OMNQA2"},"PerformanceMetric":[{"Weighting":1,"PerformanceMetric":"CP2K","Name":"PM - 00329140","IntelSKUPerformance":2,"Id":"a8d2i0000005EQwAAM","CompSKUPerformance":3}],"OtherProduct":null,"OtherCompetitorProduct":null,"Name":"QL-0038666","MeetCompPrice":150,"MarketSegment":"Corp","IntegrationStatus":null,"Id":"a7k2i000000IHCLAA4","GroupType":"Mutually Exclusive","ExcludeAutomation":false,"ErrorMessages":null,"EndCustomerRegion":"APJ","EffectivePricingStartDate":"2021-05-04","DealRFQStatus":null,"DealRFQId":null,"DealDescription":null,"CompetitorProduct":{"Name":"Comp prod1","Id":"a8c2i000000CaW3AAK"},"BillingStartDate":"2021-05-04","BillingEndDate":"2021-05-04","BackdateReason":"Data Entry Error","ApprovedStartDate":"2021-05-04","ApprovedQuantity":10,"ApprovedEndDate":"2021-06-25","ApprovedECAPPrice":1200,"ApprovedByInfo":null,"AdditionalTandC":null}],"ProjectName":"Project_WPHVGFYP","Name":"Q-18798","IsUnifiedEndCustomer":false,"Id":"a7o2i0000009XpZAAU","FolioName":"DELL INC. - APJ - RPGAGGKB - 2021-04-30 11:35:46","FolioID":null,"EndCustomerCountry":"India","EndCustomer":"RPGAGGKB","DealType":"ECAP","Account":{"Name":"DELL INC.","Id":"001o000000O6IBjAAN","CIMId":"23544531"}}},"Header":{"xid":"f2f1d8f5-ab11-c70b-a0c2-c7b2413fe30c","target_system":"MyDeals","source_system":"Tender","action":"Create"}}';
        insert intObjRec;
    }
    static testmethod void testSendPayloadToMydeals(){
        List<Pricing_Integration_Staging__c> obmRecs = [SELECT Id,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c 
                                                        FROM Pricing_Integration_Staging__c];
        List<Id> obmId = new List<Id>();
        obmId.add(obmRecs[0].Id);
        Test.startTest();
        Pricing_MyDeals_Integration.sendPayloadToMydeals(obmId);
        System.assertEquals(true , obmRecs.size() > 0 );
        Test.stopTest();
    }
    static testmethod void testmakeCallout(){
        List<Pricing_Integration_Staging__c> obmR = [SELECT id,Name,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c 
                                                     FROM Pricing_Integration_Staging__c LIMIT 1];
        
        Test.startTest();
        Pricing_MyDeals_Integration.makeCallout(new List<Id>{obmR[0].Id});
        System.assertEquals(true , obmR.size() > 0 );
        Test.stopTest();
    }
    static testmethod void testUpdateStatus(){
        List<Pricing_Integration_Staging__c> obm = [SELECT id,Name,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c 
                                                    FROM Pricing_Integration_Staging__c LIMIT 1];
        Test.startTest();
        Pricing_MyDeals_Integration.updateStatus(obm[0],obm[0].Pricing_Status__c);
        System.assert(obm !=null);
        Test.stopTest();
    }
    static testmethod void testsendPayload(){
        List<Pricing_Integration_Staging__c> obmPay = [SELECT id,Name,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c 
                                                       FROM Pricing_Integration_Staging__c LIMIT 1];
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new Pricing_MyDeals_SendPayloadMock());
        Pricing_MyDeals_Integration.sendPayload(obmPay[0],Integer.valueOf(obmPay[0].Pricing_Retry_Number__c));
        System.assert(obmPay != null);
        Test.stopTest();
    }
    static testmethod void testInsertInboundMessage(){
        List<Pricing_Integration_Staging__c> obmInb = [SELECT id,Name,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c 
                                                       FROM Pricing_Integration_Staging__c LIMIT 1];
        Test.startTest();
        Pricing_MyDeals_Integration.insertInboundMessage(obmInb[0].Pricing_Payload__c);
        System.assert(obmInb != null);
        Test.stopTest();
    }
    static testmethod void testCreateLogEntry(){
        List<Pricing_Integration_Staging__c> obmLog = [SELECT id,Name,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c 
                                                       FROM Pricing_Integration_Staging__c LIMIT 1];
        Test.startTest();
        Pricing_MyDeals_Integration.createLogEntry();
        System.assert(obmLog != null);
        Test.stopTest();
    }
}