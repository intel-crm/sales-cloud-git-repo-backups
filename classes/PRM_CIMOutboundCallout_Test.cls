@isTest
public class PRM_CIMOutboundCallout_Test {
    @testSetup
    private static void createData(){
        Core_Integration_Outbound_Message__c intObjRec = new Core_Integration_Outbound_Message__c();
        intObjRec.Core_Retry_Number__c = 1;
        intObjRec.Core_Status__c = 'Successful';
        intObjRec.Core_Payload__c = '<![CDATA[{"roles":["Sales-PRM-External-Customers Employee","ISG_Partner_Basic","Sales-PRM-External-IPA-MP User","SFDC ISVC Cloud Webticketing users","Sales-PRM-Partner University User","Sales-PRM-Partner Marketing Studio User","SFDC Intel Partner External","Sales-PSG(Salesforce)-Licensing User"],"loginID":"robertp082020@mailinator.com","lastName":"082020","language":"ENG","justification":"Role required for","InProgressRoles":[],"firstName":"robertp","enterpriseId":"300002702851","email":"robertp082020@mailinator.com","country":"IND"}]]>';
        intObjRec.Core_MessageType__c = 'OPID Request';
        insert intObjRec;
    }
    static testmethod void sendPayloadToCIM(){
        List<Core_Integration_Outbound_Message__c> obmRecs = [SELECT Id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                              FROM Core_Integration_Outbound_Message__c];        
        Test.startTest();
        PRM_CIMOutboundCallout.invokeCalloutToCIM(obmRecs[0]);
        Test.stopTest();
    }
    static testmethod void testmakeCallout(){
        List<Core_Integration_Outbound_Message__c> obmR = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                           FROM Core_Integration_Outbound_Message__c LIMIT 1];
        //TCW729-Agate-Start
        List<id> ObmIds = new List<id>();
        for(Core_Integration_Outbound_Message__c Outbnd: obmR){
            ObmIds.add(Outbnd.id);
        }
       //TCW729-Agate-End
        Test.startTest();
         System.enqueueJob(new PRM_makeCallout(ObmIds)); //TCW729-Agate
       // PRM_CIMOutboundCallout.makeCallout(obmR[0].Id);
        Test.stopTest();
    }
    static testmethod void testUpdateStatus(){
        List<Core_Integration_Outbound_Message__c> obm = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                          FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        PRM_CIMOutboundCallout.updateStatus(obm[0],obm[0].Core_Status__c);//TCW729-Agate
        Test.stopTest();
    }
    static testmethod void testUpdateStatusForFailed(){
        List<Core_Integration_Outbound_Message__c> obm = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Status__c 
                                                          FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        obm[0].Core_Status__c='Failed';
        obm[0].Core_Retry_Number__c= 2;
        PRM_CIMOutboundCallout.updateStatus(obm[0],obm[0].Core_Status__c);//TCW729-Agate
        Test.stopTest();
    }
    static testmethod void testsendPayload(){
        List<Core_Integration_Outbound_Message__c> obm = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Last_Retried_Date__c,Core_Retry_Number__c,Core_Status__c 
                                                          FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new CIM_SendPayloadMock());
        PRM_CIMOutboundCallout.invokeCalloutToCIM(obm[0]);
        Test.stopTest();
    }   
    static testmethod void testCreateLogEntry(){
        List<Core_Integration_Outbound_Message__c> obmLog = [SELECT id,Core_MessageType__c,Core_Payload__c,Core_Retry_Number__c,Core_Last_Retried_Date__c,Core_Status__c 
                                                             FROM Core_Integration_Outbound_Message__c LIMIT 1];
        Test.startTest();
        Core_Log_Entry.logEntryWithException('SFDC', 'Entitlement', 'CIM_Outbound_Integration', 'Error',
                                             'Error sending CIM outbound message', '', obmLog[0].Id, 'Core_Integration_Outbound_Message__c', '', null);
        Test.stopTest();
    }
    
    Public class CIM_SendPayloadMock implements HttpCalloutMock{
        Public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('Request processed at CIM');
            return res;
        }
    }   
}