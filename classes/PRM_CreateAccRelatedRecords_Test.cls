/*********************************************************************************************************************
Class Name  : PRM_CreateAccRelatedRecords_Test
Version       : 1.0
Created Date  : NOV 2018
Function      : Test Class for 'PRM_CreateAccountAndRelatedRecords'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Utkarsh/Rahul             11/12/2018              PRM_CreateAccountAndRelatedRecords

*********************************************************************************************************************/
@isTest
public class PRM_CreateAccRelatedRecords_Test{
    
    @isTest static void createAccount()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
         Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        List<PRM_Registration_Request__c> requestList = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c>();
        
        QueueableContext currentContext;
        
        
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
        
        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        insert a;
        
        Account a1 = PRM_TestUtility.getAccount();
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='Bernier Group';
        a1.Core_Account_Type__c ='Distributor';
        a1.Industry='Agriculture';
        a1.BillingCity='New Delhi';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4th Floor,New Road';
        a1.BillingPostalCode='110067';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'Distributor';
        insert a1;
        
        

        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a1.Id;
        c.Email='hariharasudhan.meiyappan@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        insert c;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        insert c1;

        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = a2.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
        acm2.PRM_Status_Nm__c ='Pending';
        insert acm2;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = a.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c= System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Pending';
        insert acm;
        
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = a1.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c='Distributor';
        acm1.PRM_Status_Nm__c ='Pending';
        insert acm1;
        
        

        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        /*PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a1.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        insert acr;*/
        
        PRM_PartnerAgreement__c p = PRM_TestUtility.getPartnerAgreement();
        p.Name='CSP_ACK_APAC_ENG';
        insert p;
        
        PRM_AccountLegalAgreemntAssociation__c alaa = PRM_TestUtility.getAccountAgreementAssociation();
        alaa.PRM_Account_Id__c = a1.Id;
        alaa.PRM_Partner_Agreement_Id__c = p.Id;
        alaa.PRM_Contact__c = c.Id;
        insert alaa;
        
        PRM_Partner_Subscription__c pS = new PRM_Partner_Subscription__c();
        pS.Name ='Intel® Cloud Insider Events and Tradeshows';
        pS.PRM_Subscription_Cd__c = 'CSPx2_Sub2';
        insert pS;
        
        PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c();
        csa.PRM_Partner_Subscription_Id__c = pS.Id;
        csa.PRM_Contact_Id__c = c.Id;
        csa.PRM_Status_Nm__c = 'Active';
        insert csa;
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
        
        Test.startTest();
        
        Core_Country_Code_Mapping__c codeMap = new Core_Country_Code_Mapping__c();
        codeMap.Name = 'CP1';
        codeMap.Country_Code__c = 'US';
        codeMap.ISO_Code__c = 'USA';
        insert codeMap;
        
        PRM_Registration_Request__c regRequest = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest.PRM_Country__c = 'US';
        regRequest.PRM_Contact_Country__c = 'USA';
        regRequest.PRM_Phy_Country__c = 'USA';
        regRequest.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest.PRM_Phy_State_Province__c = 'NY';
        regRequest.PRM_Phy_City__c = 'Las Vegas';
        regRequest.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest.PRM_Zip_Postal_Code__c = '32521';
        regRequest.PRM_Partner_Relationship__c = 'Primary Contact;Works For';
        regRequest.PRM_Partner_Type__c = 'FPGA Design Services';
        regRequest.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';//Distributor
        regRequest.PRM_Account_URL__c = 'www.sample.com';
        regRequest.PRM_Account_Phone__c = '76687437';
        regRequest.PRM_Company_Size__c ='10000+';
        //regRequest.PRM_Legal_Agreements__c = 'CSP_ACK_APAC_ENG';
        //regRequest.PRM_Subscriptions__c = 'CSPx2_Sub2';
        insert regRequest;
        requestList.add(regRequest);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(requestList);
        
        PRM_Registration_Request__c regRequest2 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest2.PRM_Matching_Contact__c = c.Id;
        regRequest2.PRM_Phy_Country__c = 'USA';
        regRequest2.PRM_Contact_Country__c = 'USA';
        regRequest2.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest2.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest2.PRM_Phy_State_Province__c = 'NY';
        regRequest2.PRM_Phy_City__c = 'Las Vegas';
        regRequest2.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest2.PRM_Zip_Postal_Code__c = '32521';
        regRequest2.PRM_Channel_Program__c = cprogram.Id;
        regRequest2.PRM_Channel_Program_Level__c = level.Id;
        regRequest2.PRM_Legal_Agreements__c = 'CSP_ACK_APAC_ENG';
        regRequest2.PRM_Subscriptions__c = 'CSPx2_Sub2';
        regRequest2.PRM_Partner_Relationship__c = 'Primary Contact';
        regRequest2.PRM_Profile_Response__c = '{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        regList.add(regRequest2);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(regList);
        List<Account> accList = new List<Account>();
        accList.add(a);
        List<Contact> contList = new List<Contact>();
        contList.add(c);
        System.debug('@@@c '+contList);
        
        List<PRM_Registration_Request__c> listToInsert = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest3 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest3.PRM_Phy_Country__c = 'US';
         regRequest3.PRM_Contact_Country__c = 'US';
        regRequest3.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest3.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest3.PRM_Phy_State_Province__c = 'NY';
        regRequest3.PRM_Phy_City__c = 'Las Vegas';
        regRequest3.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest3.PRM_Zip_Postal_Code__c = '32521';
        regRequest3.PRM_Salesforce_ID__c = a1.Id;
        regRequest3.PRM_Channel_Program__c = cprogram.Id;
        regRequest3.PRM_Partner_Role__c = 'Service Provider';//Distributor
        regRequest3.PRM_Partner_Relationship__c = 'Primary Contact';
        regRequest3.PRM_Legal_Agreements__c = 'CSP_ACK_APAC_ENG';
        regRequest3.PRM_Preferred_Language__c = 'ENG';
        regRequest3.PRM_Subscriptions__c ='CSPx2_Sub2';
        insert regRequest3;
        System.debug('regRequest3'+regRequest3);
        listToInsert.add(regRequest3);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert);

        List<PRM_Registration_Request__c> listToInsert2 = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest4 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest4.PRM_Phy_Country__c = 'US';
         regRequest4.PRM_Contact_Country__c = 'US';
        regRequest4.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest4.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest4.PRM_Phy_State_Province__c = 'NY';
        regRequest4.PRM_Phy_City__c = 'Las Vegas';
        regRequest4.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest4.PRM_Zip_Postal_Code__c = '32521';
        regRequest4.PRM_Salesforce_ID__c = a2.Id;
        regRequest4.PRM_Channel_Program__c = cprogram.Id;
        regRequest4.PRM_Partner_Role__c = 'Service Provider';
        regRequest4.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest4.PRM_Partner_Relationship__c = 'Primary Contact;Works For';
        insert regRequest4;
        System.debug('regRequest4'+regRequest4);
        listToInsert2.add(regRequest4);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert2);

        List<PRM_Registration_Request__c> listToInsert3 = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest5 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest5.PRM_Matching_Contact__c = c1.Id;
        regRequest5.PRM_Phy_Country__c = 'US';
         regRequest5.PRM_Contact_Country__c = 'US';
        regRequest5.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest5.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest5.PRM_Phy_State_Province__c = 'NY';
        regRequest5.PRM_Phy_City__c = 'Las Vegas';
        regRequest5.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest5.PRM_Zip_Postal_Code__c = '32521';
        regRequest5.PRM_Channel_Program__c = cprogram.Id;
        regRequest5.PRM_Partner_Role__c = 'Service Provider';
        regRequest5.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest5.PRM_Partner_Relationship__c = 'Primary Contact';
        insert regRequest5;
        System.debug('regRequest5'+regRequest5);
        listToInsert3.add(regRequest5);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert3);

        Test.stopTest();
        
        System.assertEquals(regRequest2.Name, 'RR1', 'Value does not match');
        
    }
    
   /* @isTest static void newUserExistingAccount(){
        Test.startTest();
        List<PRM_Registration_Request__c> listToInsert = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c rr = [Select Id,Name,PRM_Salesforce_ID__c,PRM_Channel_Program__c,PRM_Partner_Role__c,PRM_Person_Phone_Number__c
                                         from PRM_Registration_Request__c where PRM_Person_Phone_Number__c = '8937'];
        Test.stopTest();
    }*/
}