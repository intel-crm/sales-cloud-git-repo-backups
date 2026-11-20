@istest
public class PRM_RetriggerEVAPITest {
    @isTest
    public static void testvalidateone(){
 		        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        Test.startTest();
        req.requestURI = '/RegistrationRequest/RetriggerEV';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        PRM_EmailLog__c newlog=new PRM_EmailLog__c();
        newlog.Email_Template_Name__c='SCRRENGENRLREV';
        newlog.PRM_ToEmailID__c='jasmine12345@mailinator.com';
        newlog.Language__c='ENG';
        newlog.PRM_Email_API_Response__c='Mail sent successfully !!';
        newlog.PRM_Subject__c='Your Intel Partner Program Application';
        
        insert newlog;
        
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        regreq.PRM_First_Name__c='Jasmine';
        regreq.PRM_Last_Name__c	='Narula';
        regreq.PRM_Person_Phone_Number__c='7654321908';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='CIPtest_23@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
        regreq.PRM_Email_Log__c=newlog.Id;
        insert regreq;
        
        PRM_RetriggerEV_API.doPost('CIPtest_23@mailinator.com','Cloud Service Provider (CSP)'); 
        
        Test.stopTest();
  
    }
    @isTest
    public static void testvalidatetwo(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        Test.startTest();
        req.requestURI = '/RegistrationRequest/RetriggerEV';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        PRM_EmailLog__c newlog=new PRM_EmailLog__c();
        newlog.Email_Template_Name__c='SCRRENGENRLREV';
        newlog.PRM_ToEmailID__c='jasmine12345@mailinator.com';
        newlog.Language__c='ENG';
        newlog.PRM_Email_API_Response__c='Mail sent successfully !!';
        newlog.PRM_Subject__c='Your Intel Partner Program Application';
        
        //insert newlog;
        
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        regreq.PRM_First_Name__c='Jasmine';
        regreq.PRM_Last_Name__c	='Narula';
        regreq.PRM_Person_Phone_Number__c='7654321908';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='CIPtest_23@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
        regreq.PRM_Email_Log__c=newlog.Id;
        //insert regreq;
        
        
        PRM_RetriggerEV_API.doPost('CIPtest_23@mailinator.com','ABCD'); 
        
        Test.stopTest();
        
        List<PRM_EmailLog__c> emailLogs = [SELECT Id FROM PRM_EmailLog__c WHERE PRM_ToEmailID__c = 'jasmine12345@mailinator.com'];
        System.assertEquals(0, emailLogs.size(), 'Insert stmt commented, so size should be 0');
    }
}