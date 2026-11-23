@isTest
public class PRM_Retrigger_EV_UtilityTest {
    @isTest
    public static void testvalidateone(){
 		          
       	Test.startTest();
        
        PRM_EmailLog__c newlog=new PRM_EmailLog__c();
        newlog.Email_Template_Name__c='SCRRENGENRLREV';
        newlog.PRM_ToEmailID__c='jasmine12345@mailinator.com';
        newlog.Language__c='ENG';
        newlog.PRM_Email_API_Response__c='Mail sent successfully !!';
        newlog.PRM_Subject__c='Your Intel Partner Program Application';
        insert newlog;
  
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        Id regreqId;
        regreq.PRM_First_Name__c='Jasmine';
        regreq.PRM_Last_Name__c	='Narula';
        regreq.PRM_Person_Phone_Number__c='7654321908';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='jasmine12345@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
       	regreq.PRM_Email_Log__c=newlog.Id;
        regreq.CreatedDate=date.today().addDays(-10);
        insert regreq;
		regreqId=regreq.Id;       
        date d1 = date.today().addDays(2);
        PRM_Retrigger_EV_Utility.retrigger_EV(d1,'jasmine12345@mailinator.com','Cloud Service Provider (CSP)',true, regreqId);       
        Test.stopTest();
  
    }
    
     @isTest
    public static void testvalidateThree(){
 		          
       	Test.startTest();
        
        PRM_EmailLog__c newlog=new PRM_EmailLog__c();
        newlog.Email_Template_Name__c='SCRRENGENRLREV';
        newlog.PRM_ToEmailID__c='jasmine12345@mailinator.com';
        newlog.Language__c='ENG';
        newlog.PRM_Email_API_Response__c='Mail sent successfully !!';
        newlog.PRM_Subject__c='Your Intel Partner Program Application';
        insert newlog;
  
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        Id regreqId;
        regreq.PRM_First_Name__c='Jasmine';
        regreq.PRM_Last_Name__c	='Narula';
        regreq.PRM_Person_Phone_Number__c='7654321908';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='jasmine12345@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
       	regreq.PRM_Email_Log__c=newlog.Id;
        regreq.PRM_EV_Token__c='TOKEN';
        insert regreq;
        
		regreqId=regreq.Id;       
        date d1 = date.today().addDays(2);
        PRM_Retrigger_EV_Utility.retrigger_EV(d1,'jasmine12345@mailinator.com','Cloud Service Provider (CSP)',true, regreqId);       
        Test.stopTest();
  
    }
    
    @isTest
    public static void testvalidatetwo(){
     
       Test.startTest();
   
        PRM_EmailLog__c newlog=new PRM_EmailLog__c();
        newlog.Email_Template_Name__c='SCRRENGENRLREV';
        newlog.PRM_ToEmailID__c='jasmine12345@mailinator.com';
        newlog.Language__c='ENG';
        newlog.PRM_Email_API_Response__c='Mail sent successfully !!';
        newlog.PRM_Subject__c='Your Intel Partner Program Application';
        
        insert newlog;
        
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        Id regreqId;
        regreq.PRM_First_Name__c='Jasmine';
        regreq.PRM_Last_Name__c	='Narula';
        regreq.PRM_Person_Phone_Number__c='7654321908';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='jasmine12345@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
        regreq.PRM_Email_Log__c=newlog.Id;
        insert regreq;
		regreqId=regreq.Id;       
        date d1 = date.today().addDays(-2);
        PRM_Retrigger_EV_Utility.retrigger_EV(d1,'jasmine12345@mailinator.com','Cloud Service Provider (CSP)',false, null);       
        
        Test.stopTest();
    }               
}