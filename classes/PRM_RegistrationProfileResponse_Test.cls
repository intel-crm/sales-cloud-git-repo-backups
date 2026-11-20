/*********************************************************************************************************************
Class Name    : PRM_RegistrationProfileResponse_Test
Version       : 1.0
Created Date  : Aug 2019
Function      : Test Class for 'PRM_RegistrationProfileResponse'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Rahul Kainth              7 Aug,2019              Test Class for 'PRM_RegistrationProfileResponse'
*********************************************************************************************************************/

@isTest
public class PRM_RegistrationProfileResponse_Test {
    
    @testSetup
    static void setupDataCreation(){
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        profileQues.PRM_Question_Type_Nm__c = 'Textarea';
        profileQues.PRM_Partner_Role__c = 'Manufacturer';
        insert profileQues;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        profileAns.PRM_Answer_Display_Txt__c = '';
        insert profileAns;
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
         Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        account acc1 = PRM_TestUtility.getaccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc1.Core_IPA_Partner_Role__c = 'Manufacturer';
        acc1.Core_account_Type__c = 'Original Design Manufacturer (ODM)';
        acc1.Industry = '';
        acc1.RecordTypeId = accountRecordType;
        insert acc1;
        
        Contact con = PRM_TestUtility.getContact();
        con.AccountId = acc1.Id;
        con.Email = 'clayanderson99@outlook.com';
        con.Core_eRPM_Language_Code__c  = 'ENG';
        con.Core_IPA_PartnerRole__c = '';
        con.MailingCountryCode='IND';
        con.Mailing_Country_Region__c='IND';
        insert con; 
        /*PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
        rr.PRM_Enterprise_ID__c = '300002199713';
        rr.PRM_Preferred_Language__c = 'ENG';
        rr.recordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        rr.PRM_Profile_Response__c='{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        insert rr;*/
       
        PRM_Registration_Request__c rr2 = PRM_TestUtility.getPRMRegistrationRequest();
        rr2.PRM_First_Name__c = 'Test Request2';
        rr2.PRM_Last_Name__c = 'New';
        rr2.PRM_Email_ID__c = 'testrequest@mailinator.com';
        rr2.PRM_Preferred_Language__c='ENG';
        rr2.PRM_Account_Name__c='Intel2';
        rr2.PRM_Company_Email_Domain__c='intel.com';
        rr2.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr2.PRM_Address_Line_2__c='Bengaluru,India'; 
        rr2.PRM_City__c='Las Vegas';
        rr2.PRM_State_Province__c='NY';
        rr2.PRM_Country__c='USA';
        rr2.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rr2.PRM_Enterprise_ID__c = '76567';
        //rr2.PRM_Job_Function__c = 'OPER';
        rr2.PRM_Profession__c = 'PROFESSOR';
        rr2.PRM_Person_Phone_Number__c = '436575765';
        rr2.PRM_Subscriptions__c = 'CSP_Sub';
        rr2.PRM_Matching_Contact__c = con.Id;
        rr2.PRM_Salesforce_ID__c = acc1.Id;
        rr2.RecordTypeId = accountCreateRequestRT;
        rr2.PRM_Partner_Role__c = 'Manufacturer';
        rr2.PRM_Channel_Program__c = cprogram.Id;
        insert rr2;
        
        PRM_Registration_Profile_Response__c regResponse = new PRM_Registration_Profile_Response__c();
        regResponse.PRM_Profile_Question_Id__c = profileQues.Id;
        regResponse.PRM_Profile_Answer_Id__c = profileAns.Id;
        regResponse.PRM_Response_Txt__c = 'AI-as-a-Service';
        regResponse.PRM_Registration_Request_Id__c = rr2.id;
        insert regResponse;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = recordTypeIdAccount;
        acc.Name='John Rick';
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='India';
        acc.BillingPostalCode='Postal code';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        //acc.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
        insert acc;
         Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
          Contact contact = PRM_TestUtility.getContact();
          contact.Core_Enterprise_Id__c='300002199713';
          contact.Core_Preferred_Language__c='ENG';
          contact.RecordTypeId=recordTypeIdContact;
          contact.AccountId = acc.Id;
          contact.MailingCountryCode='IND';
          contact.Mailing_Country_Region__c='IND';
          insert contact;
        
        
        /*PRM_Registration_Request__c rev = PRM_TestUtility.getPRMRegistrationRequest();
        rev.PRM_Email_ID__c = 'testrequest1@mailinator.com';
        rev.PRM_Enterprise_ID__c = '300002199714';
        rev.PRM_Preferred_Language__c = 'ENG';
        rev.recordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert rev;*/
        
                PRM_Registration_Request__c rev = PRM_TestUtility.getPRMRegistrationRequest();
        rev.PRM_First_Name__c = 'Test Request2';
        rev.PRM_Last_Name__c = 'New';
        rev.PRM_Email_ID__c = 'testrequest1@mailinator.com';
        rev.PRM_Preferred_Language__c='ENG';
        rev.PRM_Account_Name__c='Intel2';
        rev.PRM_Company_Email_Domain__c='intel.com';
        rev.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rev.PRM_Address_Line_2__c='Bengaluru,India'; 
        rev.PRM_City__c='Las Vegas';
        rev.PRM_State_Province__c='NY';
        rev.PRM_Country__c='USA';
        rev.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rev.PRM_Enterprise_ID__c = '76567';
        //rev.PRM_Job_Function__c = 'OPER';
        rev.PRM_Profession__c = 'PROFESSOR';
        rev.PRM_Person_Phone_Number__c = '436575765';
        rev.PRM_Subscriptions__c = 'CSP_Sub';
        rev.PRM_Matching_Contact__c = con.Id;
        rev.PRM_Salesforce_ID__c = acc1.Id;
        rev.RecordTypeId = accountCreateRequestRT;
        rev.PRM_Partner_Role__c = 'Manufacturer';
        rev.PRM_Channel_Program__c = cprogram.Id;
         rev.recordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert rev;
    }
    static testMethod void testRegistrationResponse(){
        
        Test.startTest();
         string acrecordTypeID=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        PRM_Registration_Request__c rr = [Select Id,Name from PRM_Registration_Request__c where recordTypeId= :acrecordTypeID];
        ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        PRM_RegistrationProfileResponse.displayResponse(recordId.Id);
        Test.stopTest();
        
        System.assertEquals(rr.Name, 'RR1', 'Value does not match');
    }
    

    @isTest static void evReTriggerTest(){
        Test.setMock(HttpCalloutMock.class, new PRM_ReTriggerEVMock());
        
        Test.startTest();
         string acrecordTypeID=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        PRM_Registration_Request__c rr = [Select Id,Name from PRM_Registration_Request__c where recordTypeId= :acrecordTypeID];
        ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        PRM_RegistrationProfileResponse.retriggerEv(recordId.Id,false);
        Test.stopTest();
        System.assertEquals(rr.Name, 'RR1', 'Value does not match');
    }
     /*@isTest static void evReTriggerTestforEVRecordType(){
        Test.setMock(HttpCalloutMock.class, new PRM_ReTriggerEVMock());
        
        Test.startTest();
         string evrecordTypeID=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        PRM_Registration_Request__c rr = [Select Id,Name from PRM_Registration_Request__c where recordTypeId= :evrecordTypeID];
       ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
       ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        PRM_RegistrationProfileResponse.retriggerEv(rr.Id,false);
        Test.stopTest();
        //System.assertEquals(rr.Name, 'RR1', 'Value does not match');
    }*/
     @isTest static void evReTriggerTestFromContact(){
        Test.setMock(HttpCalloutMock.class, new PRM_ReTriggerEVMock());
        
        Test.startTest();
        Contact ct = [Select Id,Name,FirstName,Core_Preferred_Language__c,Core_Enterprise_Id__c,Email from Contact limit 1];
        //ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        //ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        PRM_RegistrationProfileResponse.retriggerEv(ct.Id,true);
        Test.stopTest();
        System.assertEquals(ct.FirstName, 'Matt', 'Value does not match');
    }
}