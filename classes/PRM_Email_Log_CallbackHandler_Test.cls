/******************************************************************************************************************************
Apex Class Name:  PRM_Email_Log_CallbackHandler_Test
Version     : 1.0 
Created Date: 01 JUN 2021
Function    : Test Class for PRM_Email_Log_CallbackHandler

Modification Log :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/06/2021               Test Class for PRM_Email_Log_CallbackHandler 

*******************************************************************************************************************************/
@isTest
public class PRM_Email_Log_CallbackHandler_Test {   
    
    @testSetup
    static void setupTestData() {
        Test.startTest();
        PRM_EmailLog__c testemailObj = createTestEmailLog();
        Test.stopTest();
    } 
    
    @isTest
    private static void postEmailLogData(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();  
        test.startTest();
        String recordId = [select id, name from PRM_EmailLog__c].name;
        List<String> recordIdList = new List<String>();
        recordIdList.add(recordId);
        PRM_Email_Log_CallbackHandler.EmailLogDetails emaillogparser =new PRM_Email_Log_CallbackHandler.EmailLogDetails();
        emaillogparser.MessageReadInd=true;
        emaillogparser.MessageId = recordIdList;
        //system.debug('MessageId'+recordId);
        String emailMsgInJsonFormat = JSON.serialize(emaillogparser);        
        request.requestUri = '/services/apexrest/myIntel/EmailUpdate';
        request.httpMethod = 'POST';
        
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_Email_Log_CallbackHandler.emailLogCallbackHandler();
        test.stopTest();
    } 
    
     @isTest
    private static void postReadEmailLogData(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();  
        test.startTest();
        String recordId = [select id, name from PRM_EmailLog__c].name;
        List<String> recordIdList = new List<String>();
        recordIdList.add(recordId);
        PRM_Email_Log_CallbackHandler.EmailLogDetails emaillogparser =new PRM_Email_Log_CallbackHandler.EmailLogDetails();
        emaillogparser.MessageReadInd=false;
        emaillogparser.MessageId = recordIdList;
        //system.debug('MessageId'+recordId);
        String emailMsgInJsonFormat = JSON.serialize(emaillogparser);        
        request.requestUri = '/services/apexrest/myIntel/EmailUpdate';
        request.httpMethod = 'POST';
        
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_Email_Log_CallbackHandler.emailLogCallbackHandler();
        test.stopTest();
    }    
    
     
     @isTest
    private static void postDeleteEmailLogData(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();  
        test.startTest();
        String recordId = [select id, name from PRM_EmailLog__c].name;
        List<String> recordIdList = new List<String>();
        recordIdList.add(recordId);
        PRM_Email_Log_CallbackHandler.EmailLogDetails emaillogparser =new PRM_Email_Log_CallbackHandler.EmailLogDetails();
        emaillogparser.MessageDeleteInd=true;
        emaillogparser.MessageId = recordIdList;
        //system.debug('MessageId'+recordId);
        String emailMsgInJsonFormat = JSON.serialize(emaillogparser);        
        request.requestUri = '/services/apexrest/myIntel/EmailUpdate';
        request.httpMethod = 'POST';
        
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_Email_Log_CallbackHandler.emailLogCallbackHandler();
        test.stopTest();
    }   
    @isTest
    private static void postIdenticalEmailLogData(){
        test.startTest();  
        List<String> recordIdList = new List<String>();
 		String recordId = [SELECT Id,Name from PRM_EmailLog__c].Name;
        recordIdList.add('EL-123');
        PRM_Email_Log_CallbackHandler.EmailLogDetails emaillogparser =new PRM_Email_Log_CallbackHandler.EmailLogDetails();
        emaillogparser.MessageReadInd=false;
        emaillogparser.MessagedeleteInd=false;
        emaillogparser.MessageId = recordIdList;
        //system.debug('MessageId'+recordIdList);
        String emailMsgInJsonFormat = JSON.serialize(emaillogparser);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();        
        request.requestUri = '/services/apexrest/myIntel/EmailUpdate';
        request.httpMethod = 'POST';
        
        //Condition of Email
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_Email_Log_CallbackHandler.emailLogCallbackHandler();
        test.stopTest();
    } 
    
    
     @isTest
    private static void invalidEmailLogData(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();  
        test.startTest();        
        List<String> recordIdList = new List<String>();       
        recordIdList.add('EL-123');
        PRM_Email_Log_CallbackHandler.EmailLogDetails emaillogparser =new PRM_Email_Log_CallbackHandler.EmailLogDetails();
        emaillogparser.MessageReadInd=false;
        emaillogparser.MessageId = recordIdList;       
        String emailMsgInJsonFormat = JSON.serialize(emaillogparser);        
        request.requestUri = '/services/apexrest/myIntel/EmailUpdate';
        request.httpMethod = 'POST';
        
        //Condition of Email
        request.requestBody = Blob.valueOf(emailMsgInJsonFormat);
        RestContext.request = request;
        RestContext.response= response;
        PRM_Email_Log_CallbackHandler.emailLogCallbackHandler();
        test.stopTest();
    } 
    
    
    public static PRM_EmailLog__c createTestEmailLog() 
    {        
        PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
        emaillog.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog.PRM_ToEmailID__c='ebert123@mailinator.com';
        emaillog.PRM_EmailContent__c='htmlbody';
        emaillog.Email_Template_Name__c='SCRRENGENRLREV';
        emaillog.Language__c='ENG';
        emaillog.PRM_Read__c=false;
        //emaillog.PRM_Contact__c ='EOJFDQ';
        insert emaillog;        
        //recordId = [select id, name from PRM_EmailLog__c].name; 
        return emaillog;       
    }
    
}