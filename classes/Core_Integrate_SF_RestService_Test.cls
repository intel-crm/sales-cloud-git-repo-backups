/******************************************************************************************************************************************
Class Name:  Core_Integrate_SF_RestService_Test
Version     : 1.0 
Created Date: 04 SEP 2020
Function    : Test class of Core_Integrate_SF_RestService
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             04/09/2020              Original Version
*****************************************************************************************************************************************/
@isTest
public class Core_Integrate_SF_RestService_Test {

    static testMethod void testPost1(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/v1.0/utils/inboundintegration';
        req.httpMethod = 'POST';
        req.addParameter('sourceType', 'CIM');
        req.requestBody = Blob.valueOf('Test Cim rest service');
        RestContext.request = req;
        RestContext.response= res;
        Core_Integrate_SF_RestService.doPost();
        Core_Integrate_SF_RestService.SalesforceError sfError = (Core_Integrate_SF_RestService.SalesforceError)JSON.deserialize(RestContext.response.responseBody.toString(), Core_Integrate_SF_RestService.SalesforceError.class);
        system.debug('sfError '+sfError);
        system.assertEquals(sfError.STATUS, 'SUCCESS');
    }
    
    static testMethod void testPost2(){
        Core_Trigger_Executions__c triggerEntry_CIM = new Core_Trigger_Executions__c(
            Name='xmlAttachNParse', Core_Object__c='Core_CIM_Staging__c', Core_Class_Name__c='Core_CIMIntegraton',
            Core_Trigger_Events__c='after insert', Core_Active__c=true, Core_Description__c='test cim stage trigger');
        insert triggerEntry_CIM;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1.0/utils/inboundintegration';
        req.httpMethod = 'POST';
        req.addParameter('sourceType', 'CIM');
        //req.requestBody = Blob.valueOf('<Organization xmlns="http://www.example.org/INFAAutoPublishSchema"><Header><MsgSource>CUSTMD</MsgSource><MsgId>34357053</MsgId><MsgType>UPSERT</MsgType><EventType>MERGE</EventType><MsgVersion>1.0</MsgVersion></Header></Organization>');
        req.requestBody = Blob.valueOf('Test Cim rest service');
        RestContext.request = req;
        RestContext.response= res;
        try{
            Core_Integrate_SF_RestService.doPost();
            Core_Integrate_SF_RestService.SalesforceError sfError = (Core_Integrate_SF_RestService.SalesforceError)JSON.deserialize(RestContext.response.responseBody.toString(), Core_Integrate_SF_RestService.SalesforceError.class);
            system.debug('sfError '+sfError);
            system.assertEquals(sfError.STATUS, 'SUCCESS');
        }catch(Exception e){
            system.debug('error '+e.getStackTraceString());
        }
    }
}