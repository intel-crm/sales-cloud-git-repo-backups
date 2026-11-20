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
        
        ChannelProgram cprogram1 = new ChannelProgram();
        cprogram1.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram1.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram1;
  
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        Id regreqId;
        regreq.PRM_First_Name__c='Jasmine';
        regreq.PRM_Last_Name__c ='Narula';
        regreq.PRM_Person_Phone_Number__c='7654321908';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='jasmine12345@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
        regreq.PRM_Email_Log__c=newlog.Id;
        regreq.PRM_EV_Token__c='Test Token';
        regreq.PRM_Channel_Program__c = cprogram1.Id;
        regreq.CreatedDate=date.today().addDays(-10);
        insert regreq;
        regreqId=regreq.Id;       
        date d1 = date.today().addDays(2);
        PRM_Retrigger_EV_Utility.Retrigger_EVWrapper obj_EV1=new PRM_Retrigger_EV_Utility.Retrigger_EVWrapper();
        obj_EV1.endDate=d1;
        obj_EV1.LoginID='jasmine12345@mailinator.com';
        obj_EV1.BizOrgType='Cloud Service Provider (CSP)';
        obj_EV1.fromComponent=true;
        obj_EV1.regRequestId=regreqId;
        PRM_Retrigger_EV_Utility.retrigger_EV(obj_EV1);//Athr fixes
        //PRM_Retrigger_EV_Utility.retrigger_EV(d1,'jasmine12345@mailinator.com','Cloud Service Provider (CSP)',true, regreqId);    
        PRM_Retrigger_EV_Utility.isEVSuccess(regreqId); 
        PRM_Retrigger_EV_Utility.sendInviteEmail(regreqId);    
        Test.stopTest();
        System.assertequals(regreq.PRM_Email_ID__c,'jasmine12345@mailinator.com','Email not matched');
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
        
        ChannelProgram cprogram1 = new ChannelProgram();
        cprogram1.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram1.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram1;
  
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        Id regreqId;
        regreq.PRM_First_Name__c='Jasmine';
        regreq.PRM_Last_Name__c ='Narula';
        regreq.PRM_Person_Phone_Number__c='7654321908';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='jasmine12345@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
        regreq.PRM_Email_Log__c=newlog.Id;
        regreq.PRM_EV_Token__c='TOKEN';
        regreq.PRM_Channel_Program__c = cprogram1.Id;
        insert regreq;
        
        regreqId=regreq.Id;       
        date d1 = date.today().addDays(2);
        PRM_Retrigger_EV_Utility.Retrigger_EVWrapper obj_EV2=new PRM_Retrigger_EV_Utility.Retrigger_EVWrapper();
        obj_EV2.endDate=d1;
        obj_EV2.LoginID='jasmine12345@mailinator.com';
        obj_EV2.BizOrgType='Cloud Service Provider (CSP)';
        obj_EV2.fromComponent=true;
        obj_EV2.regRequestId=regreqId;
        PRM_Retrigger_EV_Utility.retrigger_EV(obj_EV2);//Athr fixes
        //PRM_Retrigger_EV_Utility.retrigger_EV(d1,'jasmine12345@mailinator.com','Cloud Service Provider (CSP)',true, regreqId);  
        system.assert(regreqId != null);
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
        
        ChannelProgram cprogram1 = new ChannelProgram();
        cprogram1.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram1.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram1;
        
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        Id regreqId;
        regreq.PRM_First_Name__c='Jasmine';
        regreq.PRM_Last_Name__c ='Narula';
        regreq.PRM_Person_Phone_Number__c='7654321908';
        regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='jasmine12345@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
        regreq.PRM_Email_Log__c=newlog.Id;
        regreq.PRM_EV_Token__c='TOKEN';
        regreq.PRM_Channel_Program__c = cprogram1.Id;
        insert regreq;
        regreqId=regreq.Id;       
        date d1 = date.today().addDays(-2);
        PRM_Retrigger_EV_Utility.Retrigger_EVWrapper obj_EV=new PRM_Retrigger_EV_Utility.Retrigger_EVWrapper();
        obj_EV.endDate=d1;
        obj_EV.LoginID='jasmine12345@mailinator.com';
        obj_EV.BizOrgType='Cloud Service Provider (CSP)';
        obj_EV.fromComponent=false;
        obj_EV.regRequestId=null;
        PRM_Retrigger_EV_Utility.retrigger_EV(obj_EV);//Athr fixes
        //PRM_Retrigger_EV_Utility.retrigger_EV(d1,'jasmine12345@mailinator.com','Cloud Service Provider (CSP)',false, null);       
        system.assert(regreqId != null);
        Test.stopTest();
    }      
    
    @isTest
    public static void testvalidatefour(){
                  
        Test.startTest();       
        PRM_Registration_Request__c regreq=new PRM_Registration_Request__c();
        String regreqId;              
        PRM_Retrigger_EV_Utility.sendInviteEmail(regreqId);    
        Test.stopTest();
        //System.assertequals(regreq.PRM_Email_ID__c,'jasmine12345@mailinator.com','Email not matched');
    }
}