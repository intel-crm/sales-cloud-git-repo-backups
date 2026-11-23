@isTest
public class ER_RetriggerEVMail_Test {
	
    @isTest 
    public static  void  ValidateEntitlementBasedEVRetriggerTest(){
 		String reqBody = '';       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
      	Test.startTest();
        req.requestURI = '/RegistrationRequest/V2/RetriggerEV';  // sample Endpoint
        req.httpMethod = 'POST';
        reqBody = '{"KeyInput": {"LoginId": "GeorgeMatt@mailinator.com","EmailId": "","IsProgramBased": "false","Name": "Resource & Design Center for Secure Content"}}';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res; 
        
        Core_Entitlement__c entitlement= new Core_Entitlement__c();
        entitlement.Name='Resource & Design Center for Secure Content';
        entitlement.Core_Display_Name__c='Secure Content (CNDA required)';
        insert entitlement;
        
        PRM_EmailLog__c newlog=new PRM_EmailLog__c();
        newlog.Email_Template_Name__c='SCRRENGENRLREV_DZP';
        newlog.PRM_ToEmailID__c='GeorgeMatt@mailinator.com';
        newlog.Language__c='ENG';
        newlog.PRM_Email_API_Response__c='Mail sent successfully !!';
        newlog.PRM_Subject__c='Please verify your Email';
        
        insert newlog;
        
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        regreq.PRM_First_Name__c='George';
        regreq.PRM_Last_Name__c	='Matt';
         regreq.PRM_Preferred_Language__c='ENG';
        regreq.PRM_Person_Phone_Number__c='5455466455';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='GeorgeMatt@mailinator.com'; 
        regreq.PRM_Contact_Login_ID__c ='GeorgeMatt@mailinator.com'; 
        regreq.Entitlement_Details__c =entitlement.Id;
        regreq.PRM_Email_Log__c=newlog.Id;
        insert regreq;
        ER_RetriggerEVMail.RetriggerEV(); 
        Test.stopTest();
  
    }
    @isTest 
    public static void  ValidateProgramtBasedEVRetriggerTest(){
 		String reqBody = '';       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
      	Test.startTest();
        req.requestURI = '/RegistrationRequest/V2/RetriggerEV';  // sample Endpoint
        req.httpMethod = 'POST';
        reqBody = '{"KeyInput": {"LoginId": "GeorgeMatt@mailinator.com","EmailId": "","IsProgramBased": "true","Name": "IPA"}}';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res; 
        
        ChannelProgram channelPgm= new ChannelProgram();
        channelPgm.Name='Intel Partner Alliance';
        channelPgm.PRM_programCode__c='IPA';
        insert channelPgm;
        
        PRM_EmailLog__c newlog=new PRM_EmailLog__c();
        newlog.Email_Template_Name__c='SCRRENGENRLREV_DZP';
        newlog.PRM_ToEmailID__c='GeorgeMatt@mailinator.com';
        newlog.Language__c='ENG';
        newlog.PRM_Email_API_Response__c='Mail sent successfully !!';
        newlog.PRM_Subject__c='Please verify your Email';
        
        insert newlog;
        
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        regreq.PRM_First_Name__c='George';
        regreq.PRM_Last_Name__c	='Matt';
         regreq.PRM_Preferred_Language__c='ENG';
        regreq.PRM_Person_Phone_Number__c='5455466455';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='GeorgeMatt@mailinator.com'; 
        regreq.PRM_Contact_Login_ID__c ='GeorgeMatt@mailinator.com'; 
        regreq.PRM_Channel_Program__c =channelPgm.Id;
        regreq.PRM_Email_Log__c=newlog.Id;
        insert regreq;
        ER_RetriggerEVMail.RetriggerEV(); 
        Test.stopTest();
  
    }
    @isTest 
    public static void  NegativeRetriggerTest(){
 		String reqBody = '';       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
      	Test.startTest();
        req.requestURI = '/RegistrationRequest/V2/RetriggerEV';  
        req.httpMethod = 'POST';
        reqBody = '{"KeyInput": {"LoginId": "GeorgeMatt@mailinator.com","EmailId": "","IsProgramBased": "false","Name": ""}}';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res; 
        ER_RetriggerEVMail.RetriggerEV(); 
        Test.stopTest();
  
    }
    @isTest 
     public static void  NegativeNoRequestRetriggerTest(){
 		String reqBody = '';       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
      	Test.startTest();
        req.requestURI = '/RegistrationRequest/V2/RetriggerEV'; 
        req.httpMethod = 'POST';
        reqBody = '{"KeyInput": {"LoginId": "GeorgeMatt@mailinator.com","EmailId": "","IsProgramBased": "false","Name": "Resource & Design Center for Secure Content"}}';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res; 
        ER_RetriggerEVMail.RetriggerEV(); 
        Test.stopTest(); 
    }
    @isTest 
     public static void  NegativeExceptionRequestRetriggerTest(){
 		String reqBody = '';       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
      	Test.startTest();
        req.requestURI = '/RegistrationRequest/V2/RetriggerEV'; 
        req.httpMethod = 'POST';
        reqBody = '{"KeyInput": {"LoginId": GeorgeMatt@mailinator.com","EmailId": "","IsProgramBased": "false","Name": "Resource & Design Center for Secure Content"}}';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res; 
        ER_RetriggerEVMail.RetriggerEV(); 
        Test.stopTest(); 
    }
}