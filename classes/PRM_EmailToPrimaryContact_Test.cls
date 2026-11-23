/*********************************************************************************************************************
Class Name    : PRM_EmailToPrimaryContact_Test
Version       : 1.0
Created Date  : 06 April 2020
Function      : Test Class for 'PRM_EmailToPrimaryContact'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Prasant Sahu             April 2020              Test Class for 'PRM_EmailToPrimaryContact'
*********************************************************************************************************************/

@isTest
public class PRM_EmailToPrimaryContact_Test {
    @isTest
    static void insertNewACRForPrimaryContact()
    {
        Account acc = PRM_TestUtility.getAccount();
       	acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);    
        
        Contact con = PRM_TestUtility.getContact();
        con.Email='testrequest@mailinator.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_Partner_Role__c = 'Service Provider';
        con.Core_Login_Id__c = 'abc';
        insert con;
        System.debug(con);
     
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='New Partner Program';
        cprogram.PRM_programCode__c='NPP';
        insert(cprogram);
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        
        PRM_PartnerAgreement__c pa = PRM_TestUtility.getPartnerAgreement();
        pa.PRM_Channel_Program_Id__c = cp.Id;
        insert pa;
        
        PRM_PartnerAgreement__c pa1 = PRM_TestUtility.getPartnerAgreement();
        pa1.PRM_Channel_Program_Id__c = cp.Id;
        pa1.Name='CSP_ACK_EMEA_ENG';
        pa1.PRM_Language_Codes__c='ENG';
        pa1.PRM_Agreement_Cd__c='CSP_ACK_EMEA_ENG';
        pa1.PRM_Partner_Role__c = 'Service Provider';
        insert pa1;
        
        PRM_PartnerAgreement__c pa2 = PRM_TestUtility.getPartnerAgreement();
        pa2.PRM_Channel_Program_Id__c = cp.Id;
        pa2.Name='PA2';
        pa2.PRM_Language_Codes__c='';
        pa2.PRM_Agreement_Cd__c='PA2';
        insert pa2;
        
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cprogram.Id;
        membership.PRM_Account_Id__c=acc.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Partner_Role__c='Seller';
        insert(membership);  
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=acc.Id;
        membership1.PRM_Status_Nm__c = 'Pending';
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        insert(membership1);
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
   
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name='Trainee';
        cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr);
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Primary Contact';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Works for';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=acc.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=con.Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Nm__c ='Pending Action';
        insert acr;
        System.debug('acr--1>'+acr); 
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=acc.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=con.Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c ='Pending Action';
        insert acr1;
        System.debug('acr1-->'+acr);
        
        Test.startTest();
        
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testuser@gmail.com';
        newRequest.PRM_Channel_Program__c = cp.Id;
        newRequest.PRM_Legal_Agreements__c = 'CSP_ACK_EMEA_ENG';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Preferred_Language__c = '';
        newRequest.PRM_Matching_Contact__c = con.Id;
        newRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRequest.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        insert(newRequest);
                
        PRM_Registration_Request__c newRequest2 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest2.PRM_Legal_Agreement_Criteria__c = 'PENDING';
        newRequest2.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        newRequest2.PRM_Preferred_Language__c = 'DEU';
        newRequest2.PRM_Legal_Agreements__c = 'CSP_ACK_EMEA_ENG';
        newRequest2.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRequest2.PRM_Channel_Program__c = cp.Id;
        insert newRequest2;
       
        PRM_Registration_Request__c newAdminRequestNegative = PRM_TestUtility.getPRMRegistrationRequest();
        newAdminRequestNegative.PRM_Partner_Role__c='Service Provider';
        newAdminRequestNegative.PRM_Preferred_Language__c='ENG';
        newAdminRequestNegative.PRM_CIM_ID__c='CIM1234';
        newAdminRequestNegative.PRM_Salesforce_ID__c=acc.Id;
        newAdminRequestNegative.PRM_Email_Verification_Criteria__c = 'PENDING';
        newAdminRequestNegative.PRM_Legal_Agreements__c = 'CSP_ACK_EMEA_ENG';
        newAdminRequestNegative.PRM_Subscriptions__c = 'CSPx2_Sub2';
        newAdminRequestNegative.PRM_Channel_Program__c = cp.Id;
        newAdminRequestNegative.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
        newAdminRequestNegative.PRM_Profile_Response__c = '{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_AIAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_AIAAS}{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_FnAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_FnAAS}{QuestionCode : CSPx2_ServicePlanTodayOrNext_Others | ResponseCode : CSPx2_ServicePlanTodayOrNext_Others | ResponseValue : TESTING}';
        insert(newAdminRequestNegative);
       
        PRM_Registration_Request__c newRegistrationRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        newRegistrationRequest.PRM_Person_Phone_Number__c ='444444';
        newRegistrationRequest.PRM_EmailVerifiedDateTime__c = null;
        newRegistrationRequest.PRM_EV_Token__c = '768688';
        newRegistrationRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        insert newRegistrationRequest;
        
        PRM_Registration_Request__c newRegistrationRequest2 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest2.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest2.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest2.PRM_Email_ID__c = 'testrequest@mailinator.com';
        newRegistrationRequest2.PRM_Person_Phone_Number__c ='555555';
        newRegistrationRequest2.PRM_EmailVerifiedDateTime__c = System.now();
        newRegistrationRequest2.PRM_Matching_Contact__c = con.Id;
        newRegistrationRequest2.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        insert newRegistrationRequest2;
        
        Test.stopTest();

        System.assertEquals(con.Email, 'testrequest@mailinator.com','Value not found');
        
    }
    
    
   	@isTest
    static void updateExistingACRForPrimaryContact()
    {
        Account acc = PRM_TestUtility.getAccount();
       	acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        
        insert(acc);    
        
        Contact con = PRM_TestUtility.getContact();
        con.Email='testrequest@mailinator.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_Partner_Role__c = 'Service Provider';
        con.Core_Login_Id__c = 'abc';
        insert con;
        System.debug(con);
        
        Contact con1 = new Contact();
        con1.FirstName='Geralt';
        con1.LastName='Rivia';
        con1.Phone = '666699000';
        con1.Email='test@mailinator.com';
        con1.AccountId = acc.Id;
        con1.Core_Job_Function__c='Branch Manager';
        con1.Core_eRPM_Language_Code__c='Eng';
        con1.Core_IPA_Partner_Role__c = 'Service Provider';
        con1.Core_Login_Id__c = 'test';
        insert con1;
        System.debug(con1);
     
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='New Partner Program';
        cprogram.PRM_programCode__c='NPP';
        insert(cprogram);
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        
        PRM_PartnerAgreement__c pa = PRM_TestUtility.getPartnerAgreement();
        pa.PRM_Channel_Program_Id__c = cp.Id;
        insert pa;
        
        PRM_PartnerAgreement__c pa1 = PRM_TestUtility.getPartnerAgreement();
        pa1.PRM_Channel_Program_Id__c = cp.Id;
        pa1.Name='CSP_ACK_EMEA_ENG';
        pa1.PRM_Language_Codes__c='ENG';
        pa1.PRM_Agreement_Cd__c='CSP_ACK_EMEA_ENG';
        pa1.PRM_Partner_Role__c = 'Service Provider';
        insert pa1;
        
        PRM_PartnerAgreement__c pa2 = PRM_TestUtility.getPartnerAgreement();
        pa2.PRM_Channel_Program_Id__c = cp.Id;
        pa2.Name='PA2';
        pa2.PRM_Language_Codes__c='';
        pa2.PRM_Agreement_Cd__c='PA2';
        insert pa2;
        
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cprogram.Id;
        membership.PRM_Account_Id__c=acc.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Partner_Role__c='Seller';
        insert(membership);  
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=acc.Id;
        membership1.PRM_Status_Nm__c = 'Pending';
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        insert(membership1);
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
   
       List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name='Trainee';
        cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr);
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Primary Contact';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Works for';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=acc.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=con.Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Nm__c ='Pending Action';
        insert acr;
        System.debug('acr--1>'+acr); 
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=acc.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=con.Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c ='Pending Action';
        insert acr1;
        System.debug('acr1-->'+acr);
        
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=acc.Id;
        acr2.PRM_Relationship_Id__c = crList[1].Id;
        acr2.PRM_Contact_Id__c=con1.Id;
        acr2.PRM_execute_trigger__c=true;
        acr2.PRM_Status_Nm__c ='Complete';
        insert acr2;
        
        Test.startTest();
        
        acr.PRM_Status_Nm__c ='Pending Action';
        acr.PRM_InActive_Ind__c= true;
        
        acr1.PRM_Status_Nm__c ='Pending Action';
        acr1.PRM_InActive_Ind__c= true;
        
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        acrList.add(acr);
        acrList.add(acr1);
        update acrList;
        
        Test.stopTest();

        System.assertEquals(con.Email, 'testrequest@mailinator.com','Value not found');
                
    }
}