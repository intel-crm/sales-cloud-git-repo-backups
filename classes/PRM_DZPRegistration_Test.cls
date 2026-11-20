/*************************************************************************************************************************************
Apex Class Name     : PRM_DZPRegistration_Test
Created Date        : 28 Aug 2023
Function            : Test class for PRM_DZPRegistration
Developer           : Shraddha More
************************************************************************************************************************************************/
@isTest
public class PRM_DZPRegistration_Test {
    
    @testSetup static void setupmethod() {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a2 = PRM_TestUtility.getAccount();
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account';
        a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert a2;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.FirstName = 'Test';
        c1.LastName = 'Data';
        c1.Core_English_Only_First_Name__c = 'Test';
        c1.Core_English_Only_Last_Name__c = 'Data';
        insert c1;
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='test.diqhwqi1@test.com',
                                    UserName='test2udwvgsr1@xyz.com', ContactId=c1.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        insert partnerUser;
    }

    @isTest
    static void createDZPReg1(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a2 = [Select id,RecordTypeId,Core_Account_Type__c,Industry,BillingCity, BillingCountryCode,BillingStreet, BillingPostalCode,
                      BillingStateCode, Core_IPA_Partner_Role__c, Core_Intel_Partner_Alliance_PartnerGroup__c
                      from Account WHERE name = 'New Account'];
        
        Contact c1 = [Select id, AccountId, Email, Core_Preferred_Language__c, Core_eRPM_Language_Code__c , RecordTypeId, Core_IPA_Partner_Role__c,
                      FirstName, LastName
                      FROM Contact WHERE Email = 'test.user@intel.com'];
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Partner';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=a2.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Distributor';
        acctChnlMem.PRM_Status_Reason_Txt__c='Test';
        insert acctChnlMem;
        
        Core_Entitlement__c ce = new Core_Entitlement__c();
        ce.Name = 'Resource & Design Center for Secure Content';
        ce.Core_IsActive__c = true;
        ce.Core_Display_Name__c = 'Resource & Design Center for Secure Content';
        insert ce;
                
        User partnerUser = [Select Id, Email from User where Email =: 'test.diqhwqi1@test.com'];
        
        System.runAs(partnerUser){
            Test.startTest();
            PRM_DZPRegistration.CheckDZPRegEntryCriteria();
            PRM_DZPRegistration.createDZPRegistrationEntry();
            Test.stopTest();
        }
    }
   
    
    @isTest
    static void createDZPReg2(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a1 = [Select id,RecordTypeId,Core_Account_Type__c,Industry,BillingCity, BillingCountryCode,BillingStreet, BillingPostalCode,
                      BillingStateCode, Core_IPA_Partner_Role__c, Core_Intel_Partner_Alliance_PartnerGroup__c
                      from Account WHERE name = 'New Account'];
        
        Contact c1 = [Select id, AccountId, Email, Core_Preferred_Language__c, Core_eRPM_Language_Code__c , RecordTypeId, Core_IPA_Partner_Role__c,
                      FirstName, LastName
                      FROM Contact WHERE Email = 'test.user@intel.com'];
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Partner';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=a1.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Distributor';
        acctChnlMem.PRM_Status_Reason_Txt__c='Test';
        insert acctChnlMem;
        
        Core_Entitlement__c ce = new Core_Entitlement__c();
        ce.Name = 'Resource & Design Center for Secure Content';
        ce.Core_IsActive__c = true;
        ce.Core_Display_Name__c = 'Resource & Design Center for Secure Content';
        insert ce;
        
        PRM_Registration_Request__c regReq = new PRM_Registration_Request__c();
        regReq.Entitlement_Details__c = ce.Id;
        regReq.PRM_Contact_Salesforce_Id__c = (String)c1.id;
        regReq.PRM_Salesforce_ID__c = (String)a1.id;
        regReq.PRM_Status__c = 'New';
        regReq.PRM_Email_ID__c = c1.Email;
        regReq.PRM_First_Name__c = 'Test Data';
        regReq.PRM_Last_Name__c = 'Test Data1';
        insert regReq;
        
        User partnerUser = [Select Id, Email from User where Email =: 'test.diqhwqi1@test.com'];
        
        System.runAs(partnerUser){
            Test.startTest();
            PRM_DZPRegistration.CheckDZPRegEntryCriteria();
            PRM_DZPRegistration.createDZPRegistrationEntry();
            Test.stopTest();
        }
    }
    
    @isTest
    static void createDZPReg3(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a2 = [Select id,RecordTypeId,Core_Account_Type__c,Industry,BillingCity, BillingCountryCode,BillingStreet, BillingPostalCode,
                      BillingStateCode, Core_IPA_Partner_Role__c, Core_Intel_Partner_Alliance_PartnerGroup__c
                      from Account WHERE name = 'New Account'];
        
        Contact c1 = [Select id, AccountId, Email, Core_Preferred_Language__c, Core_eRPM_Language_Code__c , RecordTypeId, Core_IPA_Partner_Role__c,
                      FirstName, LastName
                      FROM Contact WHERE Email = 'test.user@intel.com'];
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Partner';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=a2.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Distributor';
        acctChnlMem.PRM_Status_Reason_Txt__c='Test';
        insert acctChnlMem;
        
        Core_Entitlement__c ce = new Core_Entitlement__c();
        ce.Name = 'Resource & Design Center for Secure Content';
        ce.Core_IsActive__c = true;
        ce.Core_Display_Name__c = 'Resource & Design Center for Secure Content';
        insert ce;
        
        User partnerUser = [Select Id, Email from User where Email =: 'test.diqhwqi1@test.com'];
        
        Business_Types__c bt = new Business_Types__c();
        bt.Name = 'Developer Zone Premier';
        bt.Is_Active__c = true;
        bt.Business_Type_Code__c = 'DZP';
        insert bt;
        
        Contact_Business_Types__c cbt = new Contact_Business_Types__c();
        cbt.Contact__c = c1.Id;
        cbt.Status__c = 'Approval - Pending';
        cbt.Business_Types__c = bt.Id;
        insert cbt;
        
        System.runAs(partnerUser){
            Test.startTest();
            PRM_DZPRegistration.CheckDZPRegEntryCriteria();
            PRM_DZPRegistration.createDZPRegistrationEntry();
            Test.stopTest();
        }
    }
   

}