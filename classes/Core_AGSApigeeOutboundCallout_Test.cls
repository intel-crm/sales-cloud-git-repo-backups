@isTest
public class Core_AGSApigeeOutboundCallout_Test {
    @testSetup
    private static void createData(){
        Core_Integration_Outbound_Message__c intObjRec = new Core_Integration_Outbound_Message__c();
        intObjRec.Core_Retry_Number__c = 1;
        intObjRec.Core_Status__c = 'Successful';
        intObjRec.Core_Payload__c = '<![CDATA[{"roles":["Sales-PRM-External-Customers Employee","ISG_Partner_Basic","Sales-PRM-External-IPA-MP User","SFDC ISVC Cloud Webticketing users","Sales-PRM-Partner University User","Sales-PRM-Partner Marketing Studio User","SFDC Intel Partner External","Sales-PSG(Salesforce)-Licensing User"],"loginID":"robertp082020@mailinator.com","lastName":"082020","language":"ENG","justification":"Role required for","InProgressRoles":[],"firstName":"robertp","enterpriseId":"300002702851","email":"robertp082020@mailinator.com","country":"IND"}]]>';
        intObjRec.Core_MessageType__c = 'AGS Contact Entitlement 2.0';
        insert intObjRec;
    }
    static testmethod void testSendPayloadToApigee(){
        List<Core_Integration_Outbound_Message__c> obmRecs = [SELECT Id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                        FROM Core_Integration_Outbound_Message__c];
        List<Id> obmId = new List<Id>();
        obmId.add(obmRecs[0].Id);
        Test.startTest();
        Core_AGSApigeeOutboundCallout.sendPayloadToApigee(obmId);
        Test.stopTest();
    }
    static testmethod void testmakeCallout(){
        List<Core_Integration_Outbound_Message__c> obmR = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                     FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        Core_AGSApigeeOutboundCallout.makeCallout(obmR[0].Id);
        Test.stopTest();
    }
    static testmethod void testUpdateStatus(){
        List<Core_Integration_Outbound_Message__c> obm = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                     FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        Core_AGSApigeeOutboundCallout.updateStatus(obm[0],obm[0].Core_Status__c);
        Test.stopTest();
    }
    static testmethod void testUpdateStatusForFailed(){
        List<Core_Integration_Outbound_Message__c> obm = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                     FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        obm[0].Core_Status__c='Failed';
        obm[0].Core_Retry_Number__c= 2;
        Core_AGSApigeeOutboundCallout.updateStatus(obm[0],obm[0].Core_Status__c);
        Test.stopTest();
    }
    static testmethod void testsendPayload(){
        List<Core_Integration_Outbound_Message__c> obm = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                     FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new Apigee_SendPyloadMock());
        Core_AGSApigeeOutboundCallout.sendPayload(obm[0],Integer.valueOf(obm[0].Core_Retry_Number__c));
        Test.stopTest();
    }   
        static testmethod void testCreateLogEntry(){
        List<Core_Integration_Outbound_Message__c> obmLog = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                     FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        Core_Log_Entry.logEntryWithException('SFDC', 'Entitlement', 'AGS_Apigee_Outbound_Integration', 'Error',
                                                 'Error sending AGS Apigee outbound message', '', obmLog[0].Id, 'Core_Integration_Outbound_Message__c', '', null);
        Test.stopTest();
    }
}