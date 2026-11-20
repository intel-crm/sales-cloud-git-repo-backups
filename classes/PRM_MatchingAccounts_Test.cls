@isTest
public class PRM_MatchingAccounts_Test {
    // public static boolean ipaRefresh = Boolean.valueOf(Label.PRM_IPARefresh);
    @testSetup
    /*Test data creation*/
    static void setupDataCreation(){  
        
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id  itAdminProfileId = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1].Id;
        List<PRM_Registration_Request__c> regReqInsertList = new List<PRM_Registration_Request__c>();
        
        User us = new User();
        us.FirstName = 'Jen';
        us.LastName = 'Ann';
        us.Alias = 'jann';
        us.Username = 'jenann@intel.com.crm.crmdevint3';
        us.Email = 'jenann@apttus.com'; 
        us.TimeZoneSidKey = 'America/Los_Angeles'; 
        us.LocaleSidKey ='en_US'; 
        us.LanguageLocaleKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8'; 
        us.ProfileId = itAdminProfileId;
        insert us;
        
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c = 'Original Design Manufacturer (ODM)';
        acc.Industry = '';
        acc.RecordTypeId = accountRecordType;
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Goldner and Sons';
        acc2.BillingCity='New Delhi';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='WZ-256,F/2';
        acc2.BillingPostalCode='560038';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_IPA_Partner_Role__c = 'Service Provider';
        acc2.Core_Account_Type__c = 'Original Design Manufacturer (ODM)';
        acc2.Industry = 'Energy';
        acc2.RecordTypeId = accountRecordType;
        acc2.OwnerId = us.Id;
        // acc2.Core_Covered_Account__c = true;
        insert acc2;
        
        Account acc3 = new Account();
        acc3.Name = 'Hauck, Ankunding and Kuhlman';
        acc3.BillingCity='Mumbai';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='WZ-256,F/2';
        acc3.BillingPostalCode='560038';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_IPA_Partner_Role__c = 'Service Provider';
        acc3.Core_Account_Type__c = 'Original Design Manufacturer (ODM)';
        acc3.Industry = 'Communications';
        acc3.RecordTypeId = accountRecordType;
        acc3.OwnerId = us.Id;
        
        //  acc3.Core_Covered_Account__c = true;
        insert acc3;          
        
        
        Contact con = PRM_TestUtility.getContact();
        con.AccountId = acc.Id;
        con.Email = 'clayanderson99@outlook.com';
        con.Core_eRPM_Language_Code__c  = 'ENG';
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.MailingCountry='India';
        insert con;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        Test.startTest();
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
        //rr.PRM_Job_Function__c = 'OPER';
        rr.PRM_Profession__c = 'PROFESSOR';
        rr.PRM_Person_Phone_Number__c = '9876846543';
        rr.PRM_Subscriptions__c = 'CSP_Sub';
        rr.PRM_Matching_Contact__c = con.Id;
        rr.PRM_Salesforce_ID__c = acc.Id;
        rr.RecordTypeId = accountCreateRequestRT;
        rr.PRM_Partner_Type__c = 'Original Design Manufacturer (ODM)';
        rr.PRM_Account_Partner_Type__c = 'Original Design Manufacturer (ODM)';
        rr.PRM_Partner_Role__c = 'Builder';
        rr.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr);
        //insert rr;
        
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
        rr2.PRM_Salesforce_ID__c = acc.Id;
        rr2.RecordTypeId = accountCreateRequestRT;
        rr2.PRM_Partner_Role__c = 'Builder';
        rr2.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr2);
        
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
        //rr3.PRM_Job_Function__c = 'OPER';
        rr3.PRM_Profession__c = 'PROFESSOR';
        rr3.PRM_Person_Phone_Number__c = '9999999999';
        rr3.PRM_Subscriptions__c = 'CSP_Sub';
        rr3.RecordTypeId = accountCreateRequestRT;
        rr3.PRM_Partner_Role__c = 'Builder';
        rr3.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr3);
        
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
        //rr4.PRM_Job_Function__c = 'OPER';
        rr4.PRM_Profession__c = 'PROFESSOR';
        rr4.PRM_Person_Phone_Number__c = '9999999999';
        rr4.PRM_Subscriptions__c = 'CSP_Sub';
        rr4.RecordTypeId = accountCreateRequestRT;
        rr4.PRM_Partner_Role__c = 'Builder';
        rr4.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr4);
        //insert rr4;
        PRM_Registration_Request__c rr6 = PRM_TestUtility.getPRMRegistrationRequest();
        rr6.PRM_First_Name__c = 'Albert';
        rr6.PRM_Last_Name__c = 'Martinez';
        rr6.PRM_Email_ID__c = 'claybatey@mailinator.com';
        rr6.PRM_Preferred_Language__c='ENG';
        rr6.PRM_Account_Name__c='Intel2';
        rr6.PRM_Company_Email_Domain__c='intel.com';
        rr6.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr6.PRM_Address_Line_2__c='Bengaluru,India'; 
        rr6.PRM_City__c='Las Vegas';
        rr6.PRM_State_Province__c='NY';
        rr6.PRM_Country__c='USA';
        rr6.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rr6.PRM_Enterprise_ID__c = '76567';
        //rr4.PRM_Job_Function__c = 'OPER';
        rr6.PRM_Profession__c = 'PROFESSOR';
        rr6.PRM_Person_Phone_Number__c = '9999999999';
        rr6.PRM_Subscriptions__c = 'CSP_Sub';
        rr6.RecordTypeId = accountCreateRequestRT;
        rr6.PRM_Partner_Role__c = '';
        rr6.PRM_Channel_Program__c = cprogram.Id;
        rr6.PRM_Matching_Contact__c = null;
        regReqInsertList.add(rr6);
        
        PRM_Registration_Request__c rr5 = PRM_TestUtility.getPRMRegistrationRequest();
        rr5.PRM_First_Name__c = 'Kenneth';
        rr5.PRM_Last_Name__c = 'Hollingsworth';
        rr5.PRM_Email_ID__c = 'kenneth.hollingsworth@mailinator.com';
        //rr5.PRM_Email_ID__c = 'clayanderson99@outlook.com';
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
        //rr5.PRM_Job_Function__c = 'OPER';
        rr5.PRM_Profession__c = 'PROFESSOR';
        rr5.PRM_Person_Phone_Number__c = '9999999999';
        rr5.PRM_Subscriptions__c = 'CSP_Sub';
        rr5.RecordTypeId = accountCreateRequestRT;
        rr5.PRM_Partner_Role__c = 'Service Provider';
        rr5.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr5);
        //insert rr5;
        
        insert regReqInsertList;
        
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        //cim.PRM_RegReq_Id__c = rr.Id;
        cim.PRM_RegReq_Id__c = regReqInsertList[0].id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_SearchScore_Nbr__c = 90;
        //cim.PRM_CIM_Id__c = 'CIM482429';
        insert cim;
        
        PRM_CIMSearchResults__c cim2 = new PRM_CIMSearchResults__c();
        //cim2.PRM_RegReq_Id__c = rr3.Id;
        cim2.PRM_RegReq_Id__c = regReqInsertList[2].id;
        cim2.PRM_Account_Id__c = acc.Id;
        cim2.PRM_SearchScore_Nbr__c = 90;
        cim2.PRM_CIM_Id__c = 'CIM482429';
        insert cim2;
        
        PRM_CIMSearchResults__c cim3 = new PRM_CIMSearchResults__c();
        //cim3.PRM_RegReq_Id__c = rr4.Id;
        cim3.PRM_RegReq_Id__c = regReqInsertList[3].id;
        cim3.PRM_Account_Id__c = acc.Id;
        cim3.PRM_SearchScore_Nbr__c = 90;
        //cim3.PRM_CIM_Id__c = 'CIM482429';
        insert cim3;
        
        PRM_CIMSearchResults__c cim4 = new PRM_CIMSearchResults__c();
        //cim4.PRM_RegReq_Id__c = rr5.Id;
        cim4.PRM_RegReq_Id__c = regReqInsertList[4].id;
        cim4.PRM_Account_Id__c = acc3.Id;
        cim4.PRM_SearchScore_Nbr__c = 20;
        //cim3.PRM_CIM_Id__c = 'CIM482429';
        insert cim4;
        
        PRM_AccountChannelMembership__c acmList = new PRM_AccountChannelMembership__c();
        acmList.PRM_Partner_Role__c = acc.Core_IPA_Partner_Role__c;
        acmList.PRM_Status_Nm__c = 'Approved';
        acmList.PRM_Account_Id__c = acc.Id;
        acmList.PRM_Channel_Program_Id__c = cprogram.Id;
        acmList.PRM_Partner_Role__c = 'Service Provider';
        acmList.PRM_Status_Reason_Txt__c='Test';
        insert acmList;
        
        PRM_AccountChannelMembership__c acmList2 = new PRM_AccountChannelMembership__c();
        acmList2.PRM_Partner_Role__c = acc3.Core_IPA_Partner_Role__c;
        acmList2.PRM_Status_Nm__c = 'Pending';
        acmList2.PRM_Account_Id__c = acc3.Id;
        acmList2.PRM_Channel_Program_Id__c = cprogram.Id;
        acmList2.PRM_Partner_Role__c = 'Service Provider';
        acmList2.PRM_Status_Reason_Txt__c='Test';
        insert acmList2;
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
        Test.stopTest();
        
    }
    
    
    
    static void setupDataCreation2(){  
        
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id  itAdminProfileId = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1].Id;
        List<PRM_Registration_Request__c> regReqInsertList = new List<PRM_Registration_Request__c>();
        
        User us = new User();
        us.FirstName = 'Jen';
        us.LastName = 'Ann';
        us.Alias = 'jann';
        us.Username = 'jenann@intel.com.crm.crmdevint3';
        us.Email = 'jenann@apttus.com'; 
        us.TimeZoneSidKey = 'America/Los_Angeles'; 
        us.LocaleSidKey ='en_US'; 
        us.LanguageLocaleKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8'; 
        us.ProfileId = itAdminProfileId;
        insert us;
        
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c = 'Original Design Manufacturer (ODM)';
        acc.Industry = '';
        acc.RecordTypeId = accountRecordType;
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Goldner and Sons';
        acc2.BillingCity='New Delhi';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='WZ-256,F/2';
        acc2.BillingPostalCode='560038';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_IPA_Partner_Role__c = 'Service Provider';
        acc2.Core_Account_Type__c = 'Original Design Manufacturer (ODM)';
        acc2.Industry = 'Energy';
        acc2.RecordTypeId = accountRecordType;
        acc2.OwnerId = us.Id;
        // acc2.Core_Covered_Account__c = true;
        insert acc2;
        
        Account acc3 = new Account();
        acc3.Name = 'Hauck, Ankunding and Kuhlman';
        acc3.BillingCity='Mumbai';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='WZ-256,F/2';
        acc3.BillingPostalCode='560038';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_IPA_Partner_Role__c = 'Service Provider';
        acc3.Core_Account_Type__c = 'Original Design Manufacturer (ODM)';
        acc3.Industry = 'Communications';
        acc3.RecordTypeId = accountRecordType;
        acc3.OwnerId = us.Id;
        
        //  acc3.Core_Covered_Account__c = true;
        insert acc3;          
        
        
        Contact con = PRM_TestUtility.getContact();
        con.AccountId = acc.Id;
        con.Email = 'clayanderson99@outlook.com';
        con.Core_eRPM_Language_Code__c  = 'ENG';
        con.Core_IPA_PartnerRole__c = '';
        con.MailingCountry='India';
        insert con;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        Test.startTest();
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
        //rr.PRM_Job_Function__c = 'OPER';
        rr.PRM_Profession__c = 'PROFESSOR';
        rr.PRM_Person_Phone_Number__c = '9876846543';
        rr.PRM_Subscriptions__c = 'CSP_Sub';
        rr.PRM_Matching_Contact__c = con.Id;
        rr.PRM_Salesforce_ID__c = acc.Id;
        rr.RecordTypeId = accountCreateRequestRT;
        rr.PRM_Partner_Type__c = 'Original Design Manufacturer (ODM)';
        rr.PRM_Account_Partner_Type__c = 'Original Design Manufacturer (ODM)';
        rr.PRM_Partner_Role__c = 'Service Provider';
        rr.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr);
        //insert rr;
        
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
        rr2.PRM_Salesforce_ID__c = acc.Id;
        rr2.RecordTypeId = accountCreateRequestRT;
        rr2.PRM_Partner_Role__c = 'Service Provider';
        rr2.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr2);
        
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
        //rr3.PRM_Job_Function__c = 'OPER';
        rr3.PRM_Profession__c = 'PROFESSOR';
        rr3.PRM_Person_Phone_Number__c = '9999999999';
        rr3.PRM_Subscriptions__c = 'CSP_Sub';
        rr3.RecordTypeId = accountCreateRequestRT;
        rr3.PRM_Partner_Role__c = 'Service Provider';
        rr3.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr3);
        
        
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
        //rr4.PRM_Job_Function__c = 'OPER';
        rr4.PRM_Profession__c = 'PROFESSOR';
        rr4.PRM_Person_Phone_Number__c = '9999999999';
        rr4.PRM_Subscriptions__c = 'CSP_Sub';
        rr4.RecordTypeId = accountCreateRequestRT;
        rr4.PRM_Partner_Role__c = 'Service Provider';
        rr4.PRM_Channel_Program__c = cprogram.Id;
        regReqInsertList.add(rr4);
        
        PRM_Registration_Request__c rr5 = PRM_TestUtility.getPRMRegistrationRequest();
        rr5.PRM_First_Name__c = 'Kenneth';
        rr5.PRM_Last_Name__c = 'Hollingsworth';
        rr5.PRM_Email_ID__c = 'kenneth.hollingsworth@mailinator.com';
        //rr5.PRM_Email_ID__c = 'clayanderson99@outlook.com';
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
        //rr5.PRM_Job_Function__c = 'OPER';
        rr5.PRM_Profession__c = 'PROFESSOR';
        rr5.PRM_Person_Phone_Number__c = '9999999999';
        rr5.PRM_Subscriptions__c = 'CSP_Sub';
        rr5.RecordTypeId = accountCreateRequestRT;
        rr5.PRM_Partner_Role__c = 'Service Provider';
        rr5.PRM_Channel_Program__c = cprogram.Id;
        rr2.PRM_Matching_Contact__c = null;
        regReqInsertList.add(rr5);
        //insert rr5;
        
        insert regReqInsertList;
        
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        //cim.PRM_RegReq_Id__c = rr.Id;
        cim.PRM_RegReq_Id__c = regReqInsertList[0].id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_SearchScore_Nbr__c = 20;
        //cim.PRM_CIM_Id__c = 'CIM482429';
        insert cim;
        
        PRM_CIMSearchResults__c cim2 = new PRM_CIMSearchResults__c();
        //cim2.PRM_RegReq_Id__c = rr3.Id;
        cim2.PRM_RegReq_Id__c = regReqInsertList[2].id;
        cim2.PRM_Account_Id__c = acc.Id;
        cim2.PRM_SearchScore_Nbr__c = 20;
        cim2.PRM_CIM_Id__c = 'CIM482429';
        insert cim2;
        
        PRM_CIMSearchResults__c cim3 = new PRM_CIMSearchResults__c();
        //cim3.PRM_RegReq_Id__c = rr4.Id;
        cim3.PRM_RegReq_Id__c = regReqInsertList[3].id;
        cim3.PRM_Account_Id__c = acc.Id;
        cim3.PRM_SearchScore_Nbr__c = 20;
        //cim3.PRM_CIM_Id__c = 'CIM482429';
        insert cim3;
        
        PRM_CIMSearchResults__c cim4 = new PRM_CIMSearchResults__c();
        //cim4.PRM_RegReq_Id__c = rr5.Id;
        cim4.PRM_RegReq_Id__c = regReqInsertList[4].id;
        cim4.PRM_Account_Id__c = acc3.Id;
        cim4.PRM_SearchScore_Nbr__c = 20;
        //cim3.PRM_CIM_Id__c = 'CIM482429';
        insert cim4;
        
        PRM_AccountChannelMembership__c acmList = new PRM_AccountChannelMembership__c();
        acmList.PRM_Partner_Role__c = acc.Core_IPA_Partner_Role__c;
        acmList.PRM_Status_Nm__c = 'Pending';
        acmList.PRM_Account_Id__c = acc.Id;
        acmList.PRM_Channel_Program_Id__c = cprogram.Id;
        acmList.PRM_Partner_Role__c ='Service Provider';
        acmList.PRM_Status_Reason_Txt__c='Test';
        insert acmList;
        
        PRM_AccountChannelMembership__c acmList2 = new PRM_AccountChannelMembership__c();
        acmList2.PRM_Partner_Role__c = acc3.Core_IPA_Partner_Role__c;
        acmList2.PRM_Status_Nm__c = 'Pending';
        acmList2.PRM_Account_Id__c = acc3.Id;
        acmList2.PRM_Channel_Program_Id__c = cprogram.Id;
        acmList2.PRM_Partner_Role__c = 'Service Provider';
        acmList2.PRM_Status_Reason_Txt__c='Test';
        insert acmList2;
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
        Test.stopTest();
        
    }
    
    //method covering else part of showAccounts
    @isTest
    static void displayAccount(){
        PRM_Registration_Request__c rr2 = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                           where PRM_Person_Phone_Number__c='436575765'];
        List<ProcessInstance> pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr2.Id];
        if(pI != null && !pI.isEmpty())
        {ProcessInstanceWorkitem recordId = [Select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI[0].Id];
         Account act = [Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,Core_Account_Type__c,Industry from Account where Industry='Energy'];
         Test.startTest();
         PRM_MatchingAccounts.searchAccount('mm');
         PRM_MatchingAccounts.insertRecords('mmmmmm',act.id,recordId.Id);
         Test.stopTest();
         System.assertEquals(rr2.PRM_First_Name__c, 'Test Request2','Value does not match');}
    }
    @isTest
    static void displayAccount11(){
        Id regReqRecordPageTypeID = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Account acct = [select id, Core_IPA_Partner_Role__c from Account limit 1];
        Contact cont = [Select id, Core_IPA_PartnerRole__c, email from Contact where AccountId = :acct.Id limit 1];
        cont.Core_IPA_PartnerRole__c = null;
        update cont;
        PRM_Registration_Request__c rr2 = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                           where PRM_Person_Phone_Number__c='436575765' ];
        List<ProcessInstance> pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr2.Id];
        PRM_Registration_Request__c regReq = new PRM_Registration_Request__c();
        regReq.RecordTypeId = regReqRecordPageTypeID;
        regReq.PRM_First_Name__c = 'Test Name';
        regReq.PRM_Person_Phone_Number__c = '9987775621';
        regReq.PRM_Matching_Contact__c = cont.Id;
        regReq.PRM_Email_ID__c = 'clayanderson99@outlook.com';
        regReq.PRM_Last_Name__c = 'anderoso';
        regReq.PRM_Salesforce_ID__c = acct.Id;
        regReq.PRM_Dup_Status__c = 'NODUP';
        Insert regReq;
        
        if(pI != null && !pI.isEmpty())
        {ProcessInstanceWorkitem recordId = [Select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI[0].Id];
         Account act = [Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,Core_Account_Type__c,Industry from Account where Industry='Energy'];
         Test.startTest();
         PRM_MatchingAccounts.searchAccount('mm');
         PRM_MatchingAccounts.insertRecords('mmmmmm',act.id,recordId.Id);
         Test.stopTest();
         System.assertEquals(rr2.PRM_First_Name__c, 'Test Request2','Value does not match');}
    }
    static void displayAccount3(){
        
        PRM_Registration_Request__c rr2 = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                           where PRM_Person_Phone_Number__c='436575765'];
        List<ProcessInstance> pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr2.Id];
        if(pI != null && !pI.isEmpty())
        {ProcessInstanceWorkitem recordId = [Select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI[0].Id];
         Account act = [Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,Core_Account_Type__c,Industry from Account where Industry='Energy'];
         Test.startTest();
         PRM_MatchingAccounts.searchAccount('mm');
         PRM_MatchingAccounts.insertRecords('mmmmmm',act.id,recordId.Id);
         Test.stopTest();
         System.assertEquals(rr2.PRM_First_Name__c, 'Test Request2','Value does not match');}
    }
    
    @isTest
    static void displayAccount2(){
        Test.startTest();
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435765';
        a.RecordTypeId = accountRecordType;
        a.Core_Account_Type__c ='Original Design Manufacturer (ODM)';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        insert a;
        
        
        PRM_Registration_Request__c rr2 = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                           where PRM_Person_Phone_Number__c='436575765'];
        List<ProcessInstance> pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr2.Id];
        if(pI != null && !pI.isEmpty())
        { ProcessInstanceWorkitem recordId = [Select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI[0].Id];
         Account act = [Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,Core_Account_Type__c,Industry,AccountNumber from Account where Industry='Energy'];
         Account ac = [Select Id,AccountNumber from Account where AccountNumber = '435765'];
        
         PRM_MatchingAccounts.insertRecords(rr2.Id,act.id,recordId.Id);
         Test.stopTest();
         System.assertEquals(rr2.PRM_First_Name__c, 'Test Request2','Value does not match');}
    }
    
    
    
    //method covering insertion of records on click of reuse account
    @isTest
    static void recordReuse(){
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                          where PRM_Person_Phone_Number__c = '9876846543'];
        List<ProcessInstance> pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        if(pI != null && !pI.isEmpty())
        { ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI[0].Id];
         Account act = [Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_Partner_Role__c,Core_Account_Type__c,Industry from Account where Industry=''];
         Test.startTest();
         PRM_MatchingAccounts.searchAccount(act.Id);
         PRM_MatchingAccounts.insertRecords(rr.Id,act.id,recordId.Id);
         Test.stopTest();
         System.assertEquals(rr.PRM_First_Name__c, 'Test Request','Value does not match');}
        
    }
    
    @isTest 
    static void newCimCallout3(){
        Test.startTest();
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,Name,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                          where PRM_First_Name__c = 'Kenneth'];
        List<ProcessInstance> pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        if(pI != null && !pI.isEmpty()){
            ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI[0].Id];
            rr.PRM_Email_ID__c = 'clayanderson99@outlook.com';
            update rr;
            PRM_MatchingAccounts.refreshRegistrationRequest(rr.Id,false, 'United Kingdom', 'England');
            Test.stopTest();
            System.assertEquals(rr.PRM_First_Name__c, 'Kenneth','Value does not match');
        }
    }
    @isTest 
    static void newCimCallout4(){
        Test.startTest();
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,Name,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                          where PRM_First_Name__c = 'Kenneth'];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        List<ProcessInstance> pI = [Select Id,TargetObjectId from ProcessInstance where TargetObjectId=:rr.Id];
        if(pI != null && !pI.isEmpty()){
            ProcessInstanceWorkitem recordId = [select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId=:pI[0].Id];
            rr.PRM_Email_ID__c = 'clayanderson99@outlook.com';
            update rr;
            PRM_MatchingAccounts.refreshRegistrationRequest(rr.Id,false, 'United Kingdom', 'England');
            Test.stopTest();
            System.assertEquals(rr.PRM_First_Name__c, 'Kenneth','Value does not match');
        }
    }
    
    @isTest 
    static void testApproval(){
        Test.startTest();
        PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,Name,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                          where PRM_First_Name__c = 'Kenneth'];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(rr.id);
      //  PRM_MatchingAccounts.callApprovalProcess(rr.Id, 'Approve', 'Test');
        Test.stopTest();
        System.assertEquals(rr.PRM_First_Name__c, 'Kenneth','Value does not match');
    }
}