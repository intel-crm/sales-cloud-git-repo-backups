/*********************************************************************************************************************
Class Name    : PRM_RegistrationProfileResponse_Test
Version       : 1.0
Created Date  : Aug 2019
Function      : Test Class for 'PRM_RegistrationProfileResponse'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Rahul Kainth              7 Aug,2019            	Test Class for 'PRM_RegistrationProfileResponse'
*********************************************************************************************************************/

@isTest
public class PRM_RegistrationProfileResponse_Test {
    
    @testSetup
    static void setupDataCreation(){
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        profileQues.PRM_Question_Type_Nm__c = 'Textarea';
        insert profileQues;
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        profileAns.PRM_Answer_Display_Txt__c = '';
        insert profileAns;
        
        
            
        PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
        rr.PRM_Enterprise_ID__c = '300002199713';
        rr.PRM_Preferred_Language__c = 'ENG';
        rr.recordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        rr.PRM_Profile_Response__c='{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        insert rr;
        
        PRM_Registration_Profile_Response__c regResponse = new PRM_Registration_Profile_Response__c();
        regResponse.PRM_Profile_Question_Id__c = profileQues.Id;
        regResponse.PRM_Profile_Answer_Id__c = profileAns.Id;
        regResponse.PRM_Response_Txt__c = 'AI-as-a-Service';
        regResponse.PRM_Registration_Request_Id__c = rr.id;
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
          insert contact;
        
        
        PRM_Registration_Request__c rev = PRM_TestUtility.getPRMRegistrationRequest();
        rev.PRM_Email_ID__c = 'testrequest1@mailinator.com';
        rev.PRM_Enterprise_ID__c = '300002199714';
        rev.PRM_Preferred_Language__c = 'ENG';
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
     @isTest static void evReTriggerTestforEVRecordType(){
        Test.setMock(HttpCalloutMock.class, new PRM_ReTriggerEVMock());
        
        Test.startTest();
         string evrecordTypeID=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        PRM_Registration_Request__c rr = [Select Id,Name from PRM_Registration_Request__c where recordTypeId= :evrecordTypeID];
       // ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        //ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
		PRM_RegistrationProfileResponse.retriggerEv(rr.Id,false);
        Test.stopTest();
        System.assertEquals(rr.Name, 'RR1', 'Value does not match');
    }
     @isTest static void evReTriggerTestFromContact(){
        Test.setMock(HttpCalloutMock.class, new PRM_ReTriggerEVMock());
        
        Test.startTest();
        Contact ct = [Select Id,Name,FirstName,Core_Preferred_Language__c,Core_Enterprise_Id__c,Email from Contact];
        //ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        //ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
		PRM_RegistrationProfileResponse.retriggerEv(ct.Id,true);
        Test.stopTest();
        System.assertEquals(ct.FirstName, 'Matt', 'Value does not match');
    }
}