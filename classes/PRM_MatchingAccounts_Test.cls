/*********************************************************************************************************************
Class Name    : PRM_MatchingAccounts_Test
Version       : 1.0
Created Date  : June 2019
Function      : Test Class for 'PRM_MatchingAccounts'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth              14 June,2019            Test Class for 'PRM_MatchingAccounts'
*********************************************************************************************************************/
@isTest
public class PRM_MatchingAccounts_Test {
    
    @testSetup
    /*Test data creation*/
    static void setupDataCreation(){  
        
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        acc.RecordTypeId = accountRecordType;
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Goldner and Sons';
        acc2.BillingCity='New Delhi';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='WZ-256,F/2';
        acc2.BillingPostalCode='560038';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Service Provider';
        acc2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acc2.Industry = 'Energy';
        acc2.RecordTypeId = accountRecordType;
        insert acc2;
        
        Account acc3 = new Account();
        acc3.Name = 'Hauck, Ankunding and Kuhlman';
        acc3.BillingCity='Mumbai';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='WZ-256,F/2';
        acc3.BillingPostalCode='560038';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc3.Core_IPA_Partner_Role__c = 'Service Provider';
        acc3.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acc3.Industry = 'Communications';
        acc3.RecordTypeId = accountRecordType;
        insert acc3;          
        
                
        Contact con = PRM_TestUtility.getContact();
        con.AccountId = acc.Id;
        con.Email = 'clayanderson99@outlook.com';
        con.Core_eRPM_Language_Code__c  = 'ENG';
        insert con;
        
        PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
        rr.PRM_First_Name__c = 'Test Request';
        rr.PRM_Last_Name__c = 'New';
        rr.PRM_Email_ID__c = 'testrequest@mailinator.com';
        rr.PRM_Preferred_Language__c='ENG';
        rr.PRM_Account_Name__c='Intel';
        rr.PRM_Company_Email_Domain__c='intel.com';
        rr.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr.PRM_Address_Line_2__c='Bengaluru,India'; 
        rr.PRM_City__c='Las Vegas';
        rr.PRM_State_Province__c='NY';
        rr.PRM_Country__c='USA';
        rr.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rr.PRM_Enterprise_ID__c = '76567';
        rr.PRM_Job_Function__c = 'OPER';
        rr.PRM_Person_Phone_Number__c = '9876846543';
        rr.PRM_Subscriptions__c = 'CSP_Sub';
        rr.PRM_Matching_Contact__c = con.Id;
        rr.PRM_Salesforce_ID__c = acc.Id;
        rr.RecordTypeId = accountCreateRequestRT;
        rr.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        rr.PRM_Account_Partner_Type__c = 'Distributor';
        //rr.PRM_Partner_Role__c = 'Service Provider';
        insert rr;
        system.debug('rr'+rr);
        
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
        rr2.PRM_Job_Function__c = 'OPER';
        rr2.PRM_Person_Phone_Number__c = '436575765';
        rr2.PRM_Subscriptions__c = 'CSP_Sub';
        rr2.PRM_Matching_Contact__c = con.Id;
        rr2.PRM_Salesforce_ID__c = acc.Id;
        rr2.RecordTypeId = accountCreateRequestRT;
        rr2.PRM_Partner_Role__c = 'Service Provider';
        insert rr2;
        system.debug('rr2 '+rr2);
        
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        cim.PRM_RegReq_Id__c = rr.Id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_SearchScore_Nbr__c = 90;
        //cim.PRM_CIM_Id__c = 'CIM482429';
        insert cim;

        PRM_Registration_Request__c rr3 = PRM_TestUtility.getPRMRegistrationRequest();
        rr3.PRM_First_Name__c = 'Clay';
        rr3.PRM_Last_Name__c = 'Batey';
        rr3.PRM_Email_ID__c = 'claybatey@mailinator.com';
        rr3.PRM_Preferred_Language__c='ENG';
        rr3.PRM_Account_Name__c='Intel2';
        rr3.PRM_Company_Email_Domain__c='intel.com';
        rr3.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr3.PRM_Address_Line_2__c='Bengaluru,India'; 
        rr3.PRM_City__c='Las Vegas';
        rr3.PRM_State_Province__c='NY';
        rr3.PRM_Country__c='USA';
        rr3.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rr3.PRM_Enterprise_ID__c = '76567';
        rr3.PRM_Job_Function__c = 'OPER';
        rr3.PRM_Person_Phone_Number__c = '9999999999';
        rr3.PRM_Subscriptions__c = 'CSP_Sub';
        rr3.RecordTypeId = accountCreateRequestRT;
        rr3.PRM_Partner_Role__c = 'Service Provider';
        insert rr3;
        system.debug('rr3 '+rr3);

        PRM_CIMSearchResults__c cim2 = new PRM_CIMSearchResults__c();
        cim2.PRM_RegReq_Id__c = rr3.Id;
        cim2.PRM_Account_Id__c = acc.Id;
        cim2.PRM_SearchScore_Nbr__c = 90;
        cim2.PRM_CIM_Id__c = 'CIM482429';
        insert cim2;

        PRM_Registration_Request__c rr4 = PRM_TestUtility.getPRMRegistrationRequest();
        rr4.PRM_First_Name__c = 'Albert';
        rr4.PRM_Last_Name__c = 'Martinez';
        rr4.PRM_Email_ID__c = 'claybatey@mailinator.com';
        rr4.PRM_Preferred_Language__c='ENG';
        rr4.PRM_Account_Name__c='Intel2';
        rr4.PRM_Company_Email_Domain__c='intel.com';
        rr4.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr4.PRM_Address_Line_2__c='Bengaluru,India'; 
        rr4.PRM_City__c='Las Vegas';
        rr4.PRM_State_Province__c='NY';
        rr4.PRM_Country__c='USA';
        rr4.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rr4.PRM_Enterprise_ID__c = '76567';
        rr4.PRM_Job_Function__c = 'OPER';
        rr4.PRM_Person_Phone_Number__c = '9999999999';
        rr4.PRM_Subscriptions__c = 'CSP_Sub';
        rr4.RecordTypeId = accountCreateRequestRT;
        rr4.PRM_Partner_Role__c = 'Service Provider';
        insert rr4;
        system.debug('rr4 '+rr4);

        PRM_CIMSearchResults__c cim3 = new PRM_CIMSearchResults__c();
        cim3.PRM_RegReq_Id__c = rr4.Id;
        cim3.PRM_Account_Id__c = acc.Id;
        cim3.PRM_SearchScore_Nbr__c = 90;
        //cim3.PRM_CIM_Id__c = 'CIM482429';
        insert cim3;

        PRM_Registration_Request__c rr5 = PRM_TestUtility.getPRMRegistrationRequest();
        rr5.PRM_First_Name__c = 'Kenneth';
        rr5.PRM_Last_Name__c = 'Hollingsworth';
        rr5.PRM_Email_ID__c = 'kenneth.hollingsworth@mailinator.com';
        rr5.PRM_Preferred_Language__c='ENG';
        rr5.PRM_Account_Name__c='Intel2';
        rr5.PRM_Company_Email_Domain__c='intel.com';
        rr5.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr5.PRM_Address_Line_2__c='Bengaluru,India'; 
        rr5.PRM_City__c='Las Vegas';
        rr5.PRM_State_Province__c='NY';
        rr5.PRM_Country__c='USA';
        rr5.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rr5.PRM_Enterprise_ID__c = '76567';
        rr5.PRM_Job_Function__c = 'OPER';
        rr5.PRM_Person_Phone_Number__c = '9999999999';
        rr5.PRM_Subscriptions__c = 'CSP_Sub';
        rr5.RecordTypeId = accountCreateRequestRT;
        rr5.PRM_Partner_Role__c = 'Service Provider';
        insert rr5;
        system.debug('rr5 '+rr5);

        PRM_CIMSearchResults__c cim4 = new PRM_CIMSearchResults__c();
        cim4.PRM_RegReq_Id__c = rr5.Id;
        cim4.PRM_Account_Id__c = acc3.Id;
        cim4.PRM_SearchScore_Nbr__c = 90;
        //cim3.PRM_CIM_Id__c = 'CIM482429';
        insert cim4;

        ChannelProgram chanProg = PRM_TestUtility.getChannelPrograms();
        insert chanProg;
           
		PRM_AccountChannelMembership__c acmList = new PRM_AccountChannelMembership__c();
        acmList.PRM_Partner_Role__c = acc.Core_IPA_Partner_Role__c;
        acmList.PRM_Status_Nm__c = 'Approved';
        acmList.PRM_Account_Id__c = acc.Id;
        acmList.PRM_Channel_Program_Id__c = chanProg.Id;
        insert acmList;
        
        PRM_AccountChannelMembership__c acmList2 = new PRM_AccountChannelMembership__c();
        acmList2.PRM_Partner_Role__c = acc3.Core_IPA_Partner_Role__c;
        acmList2.PRM_Status_Nm__c = 'Approved';
        acmList2.PRM_Account_Id__c = acc3.Id;
        acmList2.PRM_Channel_Program_Id__c = chanProg.Id;
        insert acmList2;

        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
        
        
        
        
        
        
        
   
    }
    
    // method covering if part of showAccounts
    @isTest 
    static void testAccounts(){
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                         where PRM_Person_Phone_Number__c = '9876846543'];
       	ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        Test.startTest();
        PRM_MatchingAccounts.showAccounts(recordId.Id);
        Test.stopTest();
        System.assertEquals(rr.PRM_First_Name__c, 'Test Request','Value does not match');
        
    }
    //method covering else part of showAccounts
    @isTest
    static void displayAccount(){
         PRM_Registration_Request__c rr2 = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                          where PRM_Person_Phone_Number__c='436575765'];
        ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr2.Id];
        System.debug('@@ pI'+pI);
        ProcessInstanceWorkitem recordId = [Select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        Account act = [Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,Core_Account_Type__c,Industry from Account where Industry='Energy'];
		Test.startTest();
        PRM_MatchingAccounts.showAccounts(recordId.Id);
        PRM_MatchingAccounts.searchAccount('mm');
        PRM_MatchingAccounts.insertRecords('mmmmmm',act,recordId.Id);
        Test.stopTest();
		System.assertEquals(rr2.PRM_First_Name__c, 'Test Request2','Value does not match');
    }
    
    
      
    //method covering insertion of records on click of reuse account
    @isTest
    static void recordReuse(){
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                         where PRM_Person_Phone_Number__c = '9876846543'];
       	ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        Account act = [Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,Core_Account_Type__c,Industry from Account where Industry=''];
        Test.startTest();
        PRM_MatchingAccounts.searchAccount(act.Id);
        PRM_MatchingAccounts.insertRecords(rr.Id,act,recordId.Id);
        Test.stopTest();
        System.assertEquals(rr.PRM_First_Name__c, 'Test Request','Value does not match');
        
    }
    
    @isTest 
    static void newCimCallout(){
        Test.startTest();
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,Name,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                         where PRM_First_Name__c = 'Clay'];
       	ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        PRM_MatchingAccounts.showAccounts(recordId.Id);
		Test.stopTest();
    }
    
    @isTest 
    static void newCimCallout2(){
        Test.startTest();
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,Name,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                         where PRM_First_Name__c = 'Albert'];
       	ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        PRM_MatchingAccounts.showAccounts(recordId.Id);
		Test.stopTest();
    }
    
    @isTest 
    static void newCimCallout3(){
        Test.startTest();
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,Name,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                         where PRM_First_Name__c = 'Kenneth'];
       	ProcessInstance pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI.Id];
        PRM_MatchingAccounts.showAccounts(recordId.Id);
		Test.stopTest();
    }
    

}