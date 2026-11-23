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
       // Id accountRecordTypePartner = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();
         Id accountRecordTypePartner = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();

        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        List<PRM_Registration_Request__c> requestList = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c>();
        
        Account__c accNum = new Account__c();
        accNum.Name='AccountNumber';
        accNum.PRM_Max_Account_Number__c ='10000';
        insert accNum;

        QueueableContext currentContext;
        List<Core_Trigger_Executions__c> cteList = new List<Core_Trigger_Executions__c> ();
        
        Core_Trigger_Executions__c cte1 = new Core_Trigger_Executions__c();
        cte1.Name = 'AccountTriggerExecution';
    cte1.Core_Active__c = false;
    cte1.Core_Class_Name__c = 'Core_Account';
    cte1.Core_Description__c = 'To identify old and new Trigger';
    cte1.Core_Object__c = 'Account';
    cte1.Core_Trigger_Events__c = 'All';
        cteList.add(cte1);
        
        Core_Trigger_Executions__c cte2 = new Core_Trigger_Executions__c();
        cte2.Name = 'BypassAccTriggerOnSalesAssistUpdate';
    cte2.Core_Active__c = false;
    cte2.Core_Class_Name__c = 'Core_Account';
    cte2.Core_Description__c = 'Bypass account trigger logic on change of sales assist update.';
    cte2.Core_Object__c = 'Account';
    cte2.Core_Trigger_Events__c = 'Before Update, After Update';
        cteList.add(cte2);
        insert cteList;

        List<Account> acct = new List<Account>();
        
        Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '435765';
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
        a2.Core_IPA_Partner_Segment__c = 'Data Center';
       // insert a2;
       acct.add(a2);
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435766';
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
        a.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        a.Core_IPA_Partner_Segment__c = 'Data Center';
        acct.add(a);

      //  Triggerhandler.bypass('Core_AccountTriggerHandler');
        insert acct;
      //  Triggerhandler.clearBypass('Core_AccountTriggerHandler');
        a.Core_Intel_Partner_Alliance_PartnerGroup__c = 
        a.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        update a;
    List<Contact> conList = new List<Contact>();
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = acct[0].Id;
        c.Core_IPA_PartnerRole__c='Distributor';
        //c.Email='hariharasudhan.meiyappan@intel.com';
        c.email='harihar@malinator.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
  c.MailingCountry='USA';
        //insert c;
        conList.add(c);
        
        PRM_EmailLog__c eLog = new PRM_EmailLog__c();
        eLog.Email_Template_Name__c = 'SCRREQTOAPVDNEW';
        eLog.PRM_ToEmailID__c = c.Email;
        insert eLog;            
            
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c.Core_IPA_PartnerRole__c='Distributor';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_PartnerRole__c = 'Service Provider';
  c1.MailingCountry='USA';
       // insert c1;
       conList.add(c1);
        
        Contact con = PRM_TestUtility.getContact();
        con.AccountId = acct[0].Id;
        con.Core_IPA_PartnerRole__c='Distributor';
        //c.Email='hariharasudhan.meiyappan@intel.com';
        con.email='harihar123@malinator.com';
        con.Mailing_Country_Region__c='AUS';
        con.MailingCountry='USA';
        con.Core_Preferred_Language__c = ' ';
        con.Core_eRPM_Language_Code__c = ' ';
        con.RecordTypeId = contactRecordType;
        //insert con;
        conList.add(con);
       
        Triggerhandler.bypass('Core_ContactHandler');
        insert conList;
        Triggerhandler.clearBypass('Core_ContactHandler');
        
        PRM_EmailLog__c eLogs = new PRM_EmailLog__c();
        eLogs.Email_Template_Name__c = 'SCRREQTOAPVDNEW';
        eLogs.PRM_ToEmailID__c = con.Email;
        insert eLogs; 

        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;

        List<PRM_AccountChannelMembership__c> listAccountChannelMembership = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = a2.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
        acm2.PRM_Status_Nm__c ='Pending';
        acm2.PRM_Status_Reason_Txt__c = 'test';
        listAccountChannelMembership.add(acm2);
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = acct[0].Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c= System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Pending';
        acm.PRM_Status_Reason_Txt__c = 'test';
        listAccountChannelMembership.add(acm);
        
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = acct[0].Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c='Distributor';
        acm1.PRM_Status_Nm__c ='Pending';
        acm1.PRM_Status_Reason_Txt__c = 'test';
        listAccountChannelMembership.add(acm1);

        insert listAccountChannelMembership;
        
        List<PRM_ContactRelationships__c> listContactRelationships = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        listContactRelationships.add(contRelation);
        
        PRM_ContactRelationships__c contRelation1 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation1.Name=System.Label.PRM_WorksFor;
        contRelation1.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        contRelation1.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation1.PRM_Default_Relationship_Ind__c = true;
        listContactRelationships.add(contRelation1);

        insert listContactRelationships;
        //System.debug('Reached 1');
      //  Test.startTest();
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = acct[0].Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
      //  TriggerHandler.bypass('PRM_AcctContRel_TriggerHandler');
       // TriggerHandler.bypass('Core_AccountHandler');
       // insert acr;
        //System.debug('Reached 2');
        PRM_PartnerAgreement__c p = PRM_TestUtility.getPartnerAgreement();
        p.Name='IPA Terms & Condition';
        p.PRM_Agreement_Cd__c = 'IPA_TANDC';
        insert p;
        
        PRM_AccountLegalAgreemntAssociation__c alaa = PRM_TestUtility.getAccountAgreementAssociation();
        alaa.PRM_Account_Id__c = acct[0].Id;
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
        csa.PRM_Status_Reason_Txt__c = 'test';
        insert csa;
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
        
        
        
        Core_Country_Code_Mapping__c codeMap = new Core_Country_Code_Mapping__c();
        codeMap.Name = 'Samoa';
        codeMap.Country_Code__c = 'US';
        codeMap.ISO_Code__c = 'USA';
        insert codeMap;
        
        PRM_Registration_Request__c regRequest = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest.PRM_Country__c = 'Algeria';
        regRequest.PRM_Contact_Country__c = 'USA';
      /*  regRequest.PRM_Phy_Country__c = 'USA';
        regRequest.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest.PRM_Phy_State_Province__c = 'NY';
        regRequest.PRM_Phy_City__c = 'Las Vegas';
        regRequest.PRM_Phy_Zip_Postal_Code__c = '235351'; */
        regRequest.PRM_Country__c = 'USA';
        regRequest.PRM_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest.PRM_Address_Line_2__c = 'Bengaluru,India';
        regRequest.PRM_State_Province__c = 'NY'; 
        regRequest.PRM_City__c = 'Las Vegas';
        regRequest.PRM_Zip_Postal_Code__c = '235351';
        regRequest.PRM_Zip_Postal_Code__c = '32521';
        regRequest.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact+';'+System.Label.PRM_WorksFor;
        regRequest.PRM_Partner_Type__c = 'FPGA Design Services';
        regRequest.PRM_Partner_Role__c = 'Guest';
        regRequest.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';//Distributor
        regRequest.PRM_Account_URL__c = 'www.sample.com';
        regRequest.PRM_Account_Phone__c = '76687437';
        regRequest.PRM_Company_Size__c ='10000+';
        regRequest.PRM_Auto_Approve__c= True;
        regRequest.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';
      // regRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest.PRM_Subscriptions__c = 'CSPx2_Sub2';
        //insert regRequest;
        requestList.add(regRequest);
        //PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(requestList);
        
        PRM_Registration_Request__c regRequest2 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest2.PRM_Matching_Contact__c = c.Id;
        regRequest2.PRM_Phy_Country__c = 'US';
        regRequest2.PRM_Contact_Country__c = 'US';
        regRequest2.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest2.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest2.PRM_Phy_State_Province__c = 'NY';
        regRequest2.PRM_Phy_City__c = 'Las Vegas';
        regRequest2.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest2.PRM_Zip_Postal_Code__c = '32521';
        regRequest2.PRM_Channel_Program__c = cprogram.Id;
        regRequest2.PRM_Channel_Program_Level__c = level.Id;
        regRequest2.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest2.PRM_Partner_Type__c = 'FPGA Design Services';
        regRequest2.PRM_Partner_Role__c = 'Guest';
        regRequest2.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';//Distributor
        regRequest2.PRM_Subscriptions__c = 'CSPx2_Sub2';
        regRequest2.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest2.PRM_Profile_Response__c = '{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        regRequest2.PRM_Auto_Approve__c= True;
        regList.add(regRequest2);
        requestList.add(regRequest2);
        
        
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
        regRequest3.PRM_Salesforce_ID__c = acct[1].Id;
        regRequest3.PRM_Channel_Program__c = cprogram.Id;
        regRequest3.PRM_Partner_Role__c = 'Service Provider';//Distributor
        regRequest3.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest3.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest3.PRM_Preferred_Language__c = 'ENG';
        regRequest3.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest3.PRM_Auto_Approve__c= True;
        regRequest3.PRM_EmailVerifiedDateTime__c = System.Now();
        requestList.add(regRequest3);
        //System.debug('regRequest3'+regRequest3);
        listToInsert.add(regRequest3);
        //PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert);

        

 /*      List<PRM_Registration_Request__c> listToInsert3 = new List<PRM_Registration_Request__c>();
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
        regRequest5.PRM_Account_Partner_Type__c = 'Distributor';
        regRequest5.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest5.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest5.PRM_Auto_Approve__c= True;
        insert regRequest5;
        //System.debug('regRequest5'+regRequest5);
        listToInsert3.add(regRequest5);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert3); */
//Test.stopTest();
        List<PRM_Registration_Request__c> listToInsert4 = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest6 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest6.Name = 'Deckow, Torphy and Reilly';
        regRequest6.PRM_Account_Name__c = 'Deckow, Torphy and Reilly';
        regRequest6.PRM_Phy_Country__c = 'India';
        //regRequest6.PRM_Country__c = 'US';
        regRequest6.PRM_Contact_Country__c = 'US';
        regRequest6.Countries__c = 'India';
        regRequest6.PRM_Phy_Address_Line_1__c = 'abc';
        regRequest6.PRM_Phy_Address_Line_2__c = 'abc12';
        regRequest6.PRM_Phy_State_Province__c = 'MH';
        regRequest6.PRM_Phy_City__c = 'Pune';
        regRequest6.PRM_Phy_Zip_Postal_Code__c = '454566';
        regRequest6.PRM_Zip_Postal_Code__c = '32521';
        regRequest6.PRM_Address_Line_2__c = '905 Mercer Street';
        regRequest6.PRM_Channel_Program__c = cprogram.Id;
        regRequest6.PRM_Partner_Role__c = 'Guest';
        regRequest6.PRM_Partner_Type__c = 'FPGA Design Services';
        regRequest6.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest6.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest6.PRM_Auto_Approve__c= True;
        requestList.add(regRequest6);
        //System.debug('regRequest6'+regRequest6);
        listToInsert4.add(regRequest6);
        insert requestList;
        //System.debug('Reached 3');
        Test.startTest();
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(requestList);
        //PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(regList);
        List<Account> accList = new List<Account>();
        accList.add(a);
        List<Contact> contList = new List<Contact>();
        contList.add(c);
        //System.debug('@@@c '+contList);
        PRM_CreateAccountAndRelatedRecords.sendWelcomeEmailNotification(contList,'Welcome_email_on_request_approval_New',regRequest2);
        Test.stopTest();
        
     //   PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(c.Email);
      //  Test.stopTest();
        
        System.assertEquals(regRequest2.Name, 'RR1', 'Value does not match');
        
    }
    
    @isTest static void linkEmailLogToContactTest()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
         Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
         Account__c accNum = new Account__c();
        accNum.Name='AccountNumber';
        accNum.PRM_Max_Account_Number__c ='10000';
        insert accNum;

        Account a1 = PRM_TestUtility.getAccount();
        a1.AccountNumber = '435767';
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
        a1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert a1;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a1.Id;
        c.Core_IPA_PartnerRole__c='Distributor';
        //c.Email='hariharasudhan.meiyappan@intel.com';
        c.Email='testuser@mailli.com';
        c.MailingCountry='USA';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        insert c;
        
        PRM_EmailLog__c eLog = new PRM_EmailLog__c();
        eLog.PRM_ToEmailID__c = c.Email;
        //eLog.Email_Template_Name__c = 'SCRREQTOAPVDNEW';
        eLog.PRM_Contact__c = c.Id;
        insert eLog;
        
        
        
        Test.startTest();
        PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(c.Id);
        Test.stopTest();
        System.assertEquals('435767', a1.AccountNumber, 'Value does not match');
    }
    
    @isTest static void existingcontact(){
          Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
         Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();

         Account__c accNum = new Account__c();
        accNum.Name='AccountNumber';
        accNum.PRM_Max_Account_Number__c ='10000';
        insert accNum;
        
        Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '435765';
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
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        a2.Core_User_Defined_Website__c = 'abc.com';
        insert a2;
       
        
         Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@spamok.com';
        c1.Core_IPA_PartnerRole__c='Distributor';
        c1.MailingCountry='USA';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_PartnerRole__c = 'Service Provider';
        insert c1;
        

        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_ContactRelationships__c employee = new PRM_ContactRelationships__c();   //Contact Relationship
        employee.Name='Employee';
        employee.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        employee.PRM_Channel_Program_Id__c = cprogram.Id;
        employee.PRM_Default_Relationship_Ind__c = true;
        insert employee;
        
        PRM_Contact_Relationship__c emp = new PRM_Contact_Relationship__c();
        emp.Name ='Employee';
        emp.PRM_Relationship_Name__c='Employee';
        emp.PRM_Relationship_Id__c=employee.Id;
        insert emp;
        
        PRM_Account_Contact_Relationship__c acrEmp1 = new PRM_Account_Contact_Relationship__c();
        acrEmp1.PRM_Relationship_Id__c = employee.Id;
        acrEmp1.PRM_Account_Id__c = a2.Id;
        acrEmp1.PRM_Contact_Id__c = c1.Id;
        acrEmp1.PRM_InActive_Ind__c= true;
        acrEmp1.PRM_Status_Nm__c = 'Pending Action';
        acrEmp1.PRM_Status_Reason_Txt__c = 'test';
        insert acrEmp1;
        
           PRM_Account_Contact_Relationship__c acrEmp2 = new PRM_Account_Contact_Relationship__c();
        acrEmp2.PRM_Relationship_Id__c = employee.Id;
        acrEmp2.PRM_Account_Id__c = a2.Id;
        acrEmp2.PRM_Contact_Id__c = c1.Id;
        acrEmp2.PRM_InActive_Ind__c= false;
        acrEmp2.PRM_Status_Nm__c = 'Complete';
        acrEmp2.PRM_Status_Reason_Txt__c = 'test';
        insert acrEmp2;
        
        Test.startTest();
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
        regRequest5.PRM_Account_Partner_Type__c = 'Distributor';
        regRequest5.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest5.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest5.PRM_Auto_Approve__c= True;
        insert regRequest5;
        //System.debug('regRequest5'+regRequest5);
        listToInsert3.add(regRequest5);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert3);
        Test.stopTest();
        
        System.assertEquals('435765', a2.AccountNumber, 'Value does not match');
    }
 /*   @isTest static void newUserExistingAccount(){
        Test.startTest();
        List<PRM_Registration_Request__c> listToInsert = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c rr = [Select Id,Name,PRM_Salesforce_ID__c,PRM_Channel_Program__c,PRM_Partner_Role__c,PRM_Person_Phone_Number__c
                                         from PRM_Registration_Request__c where PRM_Person_Phone_Number__c = '8937'];
        Test.stopTest();
    } */
  @isTest static void existingaccount(){
     Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
         Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();

         Account__c accNum = new Account__c();
        accNum.Name='AccountNumber';
        accNum.PRM_Max_Account_Number__c ='10000';
        insert accNum;
        
  Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '435765';
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account';
        //a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        a2.Core_User_Defined_Website__c = 'abc.com';
        insert a2;
      
      
       Account a3 = new Account();
        a3.AccountNumber = '435765';
        a3.Name='New Account';
        a3.Core_Account_Type__c ='Distributor';
        a3.Industry='Agriculture';
        a3.BillingCity='Goa';
        a3.BillingCountryCode='IND';
        a3.BillingStreet='4th Floor,New Road 123';
        a3.BillingPostalCode='110345';
        a3.BillingStateCode='KA';
        a3.Core_IPA_Partner_Role__c = 'Service Provider';
        a3.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        insert a3;
      
      
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a2.Id;
        c.Core_IPA_PartnerRole__c='Distributor';
        c.MailingCountry='USA';
        c.Email='hariharasudhann.meiyappan@spamok.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
       
        insert c;
        
      ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;
      
              List<PRM_AccountChannelMembership__c> listToInsert3 = new List<PRM_AccountChannelMembership__c>();

       PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = a2.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
        acm2.PRM_Status_Nm__c ='Pending';
        acm2.PRM_Status_Reason_Txt__c = 'test';
      listToInsert3.add(acm2);
        insert acm2;
        PRM_AccountChannelMembership__c  acm3 = PRM_TestUtility.getMembership();
        acm3.PRM_Account_Id__c = a2.Id;
        acm3.PRM_Channel_Program_Id__c = cprogram.Id;
        acm3.PRM_Partner_Role__c='Service Provider';
        acm3.PRM_Status_Nm__c ='Approved';
        acm3.PRM_Status_Reason_Txt__c = 'test';
      listToInsert3.add(acm3);
        insert acm3;
      
       /*PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_ContactRelationships__c contRelation1 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation1.Name=System.Label.PRM_WorksFor;
        contRelation1.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        contRelation1.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation1.PRM_Default_Relationship_Ind__c = true;
        insert contRelation1;*/
      
        PRM_ContactRelationships__c employee = new PRM_ContactRelationships__c();   //Contact Relationship
        employee.Name='Employee';
        employee.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        employee.PRM_Channel_Program_Id__c = cprogram.Id;
        employee.PRM_Default_Relationship_Ind__c = true;
        insert employee;
        
        PRM_Contact_Relationship__c emp = new PRM_Contact_Relationship__c();
        emp.Name ='Employee';
        emp.PRM_Relationship_Name__c='Employee';
        emp.PRM_Relationship_Id__c=employee.Id;
        insert emp;
      List<PRM_Account_Contact_Relationship__c> acrlistt = new List<PRM_Account_Contact_Relationship__c>();
        
        PRM_Account_Contact_Relationship__c acrEmp1 = new PRM_Account_Contact_Relationship__c();
        acrEmp1.PRM_Relationship_Id__c = employee.Id;
        acrEmp1.PRM_Account_Id__c = a2.Id;
        acrEmp1.PRM_Contact_Id__c = c.Id;
        acrEmp1.PRM_InActive_Ind__c= false;
        acrEmp1.PRM_Status_Nm__c = 'Pending Action';
        acrEmp1.PRM_Status_Reason_Txt__c = 'test';
       // insert acrEmp1;
        
      PRM_Account_Contact_Relationship__c acrEmp2 = new PRM_Account_Contact_Relationship__c();
        acrEmp2.PRM_Relationship_Id__c = employee.Id;
        acrEmp2.PRM_Account_Id__c = a2.Id;
        acrEmp2.PRM_Contact_Id__c = c.Id;
        acrEmp2.PRM_InActive_Ind__c= false;
        acrEmp2.PRM_Status_Nm__c = 'Complete';
        acrEmp2.PRM_Status_Reason_Txt__c = 'test';
      // acrEmp2.PRM_Partner_Role__c ='Service Provider';
        //insert acrEmp2;
        
      acrlistt.add(acrEmp1);
      acrlistt.add(acrEmp2);
      insert acrlistt;
        PRM_PartnerAgreement__c p = PRM_TestUtility.getPartnerAgreement();
        p.Name='IPA Terms & Condition';
        p.PRM_Agreement_Cd__c = 'IPA_TANDC';
        insert p;
        
        PRM_AccountLegalAgreemntAssociation__c alaa = PRM_TestUtility.getAccountAgreementAssociation();
        alaa.PRM_Account_Id__c = a2.Id;
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
        csa.PRM_Status_Reason_Txt__c = 'test';
        insert csa;
  
    
   Test.startTest();
  List<PRM_Registration_Request__c> listToInsert2 = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest4 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest4.PRM_Matching_Contact__c = c.Id;
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
        regRequest4.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact+';'+System.Label.PRM_WorksFor; 
        regRequest4.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest4.PRM_Auto_Approve__c= True;
        insert regRequest4;
        //System.debug('regRequest4'+regRequest4);
        listToInsert2.add(regRequest4);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert2);
        /*PRM_IPA_Utility.createEventLog(null,a3.Id,a2.Id,'ABCD');
        PRM_IPA_Utility.createEventLog(true,a3.Id,a2.Id,null);
        PRM_IPA_Utility.createEventLog(false,a3.Id,a2.Id,'ABCD');
        PRM_IPA_Utility.getNotificationLogInstance('Prime Name Update','ABC',a2.Id,a3.Id);*/
        PRM_IPA_Utility.acrActiveCheck(acrlistt,regRequest4);
        PRM_IPA_Utility.acrActiveCheck(null,regRequest4);
      
         PRM_IPA_Utility.acmActiveCheck(listToInsert3,regRequest4);
        Test.stopTest();
        
       System.assertEquals('435765', a2.AccountNumber, 'Value does not match');
  }
    

    @isTest static void testACRCreationForPendingStatus(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();

        Account__c accNum = new Account__c();
        accNum.Name='AccountNumber';
        accNum.PRM_Max_Account_Number__c ='10000';
        insert accNum;

        Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '30000086';
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='Duplicate Account';
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
        a2.Core_User_Defined_Website__c = 'www.test.com';
        insert a2;
      
        Contact c = PRM_TestUtility.getContact();
        c.LastName = 'testinguser'; 
        c.AccountId = a2.Id;
        c.Core_IPA_PartnerRole__c='Distributor';
        c.Email='test@testcontact.com'; 
        c.MailingCountry='USA';             
        c.RecordTypeId = contactRecordType;
        insert c;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.LastName = 'testinguser1'; 
        c1.AccountId = a2.Id;
        c1.MailingCountry='USA';
        c1.Core_IPA_PartnerRole__c='Distributor';
        c1.Email='test1@testcontact.com';              
        c1.RecordTypeId = contactRecordType;
        insert c1;
        
      ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;
       
       ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cprogram.Id;
        insert cpl1;
        
       PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = a2.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
        acm2.PRM_Status_Nm__c ='Pending';
        acm2.PRM_Status_Reason_Txt__c = 'Pending';
        insert acm2;
      
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c >();
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id; 
        crList.add(contRelation);        
        
        PRM_ContactRelationships__c contRelation1 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation1.Name=System.Label.PRM_WorksFor;
        contRelation1.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        contRelation1.PRM_Channel_Program_Id__c = cprogram.Id; 
        crList.add(contRelation1);
        //System.debug('crList:'+crList);
        insert crList;
        
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a2.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Status_Nm__c = 'Pending Action';
        acr.PRM_Status_Reason_Txt__c = 'Pending';
       // insert acr;
        
        Test.startTest();
        List<PRM_Registration_Request__c> listToInsert2 = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest4 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest4.PRM_First_Name__c = 'Casie';
        regRequest4.PRM_Last_Name__c = 'Mccall';
        regRequest4.PRM_Email_ID__c = 'casiemccall@dkjsdhjhk.com';
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
        regRequest4.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact+';'+System.Label.PRM_WorksFor; 
        regRequest4.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest4.PRM_Auto_Approve__c= True;
        insert regRequest4;
        //System.debug('regRequest4'+regRequest4);
        listToInsert2.add(regRequest4);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert2);
        
        
        List<PRM_Registration_Request__c> listToInsert3 = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest.PRM_Phy_Country__c = 'US';
        regRequest.PRM_Contact_Country__c = 'US';
        regRequest.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest.PRM_Phy_State_Province__c = 'NY';
        regRequest.PRM_Phy_City__c = 'Las Vegas';
        regRequest.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest.PRM_Zip_Postal_Code__c = '32521';
        regRequest.PRM_Salesforce_ID__c = a2.Id;
        regRequest.PRM_Channel_Program__c = cprogram.Id;
        regRequest.PRM_Partner_Role__c = 'Service Provider';
        regRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact+';'+System.Label.PRM_WorksFor; 
        regRequest.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest.PRM_Auto_Approve__c= True;
        regRequest.PRM_Matching_Contact__c = c1.id;
        insert regRequest;
        listToInsert3.add(regRequest);
    List<PRM_Account_Contact_Relationship__c> acrlistt = new List<PRM_Account_Contact_Relationship__c>();
        acrlistt.add(acr);
        insert acrlistt;
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert3);
         PRM_IPA_Utility.acrActiveCheck(acrlistt,regRequest);
        
        Test.stoptest();
    } 
    
/*    @isTest static void phoneAndWebsiteMapping()
    {
       Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
       Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        List<PRM_Registration_Request__c> requestList = new List<PRM_Registration_Request__c>();
        
        Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '435765';
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account';
        //a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        insert a2;
      
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a2.Id;
        c.Email='hariharasudhann.meiyappan@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        insert c;
        
      ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.ProgramId = cprogram.Id;
        insert level;
      
        
        test.startTest();
        List<PRM_Registration_Request__c> listToInsert2 = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest4 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest4.PRM_Matching_Contact__c = c.Id;
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
        regRequest4.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact+';'+System.Label.PRM_WorksFor; 
        regRequest4.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest4.PRM_Auto_Approve__c= True;
        insert regRequest4;
        requestList.add(regRequest4);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(requestList);
        test.stopTest();
        
    }
*/

    @isTest static void getSalesforceLimitsTest(){
          Test.startTest();
            PRM_CreateAccountAndRelatedRecords.getSalesforceLimits();
        Test.stopTest();
    }    
    
    @isTest static void approveACMTest(){
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        List<PRM_Registration_Request__c> requestList = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c>();
        Account__c accNum = new Account__c();
        accNum.Name='AccountNumber';
        accNum.PRM_Max_Account_Number__c ='10000';
        insert accNum;
        
        
        List<Account> acct = new List<Account>();
        
        Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '435765';
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
       // insert a2;
       acct.add(a2);
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435766';
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
        acct.add(a);
        
        Account a1 = PRM_TestUtility.getAccount();
        a1.AccountNumber = '435767';
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
        a1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        a1.Core_User_Defined_Website__c ='www.test.com';
        acct.add(a1);
        insert acct;
        

        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a1.Id;
        //c.Email='hariharasudhan.meiyappan@intel.com';
        c.email='harihar@malinator.com';
        c.MailingCountry='USA';
        c.Core_IPA_PartnerRole__c='Distributor';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.Core_IPA_PartnerRole__c='Distributor';
        c.RecordTypeId = contactRecordType;
        insert c;
        
        PRM_EmailLog__c eLog = new PRM_EmailLog__c();
        eLog.Email_Template_Name__c = 'SCRREQTOAPVDNEW';
        eLog.PRM_ToEmailID__c = c.Email;
        insert eLog;            
            
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@intel.com';
        c1.MailingCountry='USA';
        c1.Core_IPA_PartnerRole__c='Distributor';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_PartnerRole__c = 'Service Provider';
        insert c1;
        

        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        
        List<PRM_AccountChannelMembership__c> acmList = New List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = a2.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
        acm2.PRM_Status_Nm__c ='Pending';
        acm2.PRM_Status_Reason_Txt__c = 'Pending';
        insert acm2;
        acmList.add(acm2);
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = a.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c= System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Pending';
        acm.PRM_Status_Reason_Txt__c = 'Pending';
        insert acm;
        acmList.add(acm);
        
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = a1.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c='Distributor';
        acm1.PRM_Status_Nm__c ='Pending';
        acm1.PRM_Status_Reason_Txt__c = 'Pending';
        insert acm1;
        acmList.add(acm1);
        
        
        List<PRM_Registration_Request__c> listToInsert2 = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regRequest4 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequest4.PRM_Matching_Contact__c = c.Id;
        regRequest4.PRM_Phy_Country__c = 'US';
         regRequest4.PRM_Contact_Country__c = 'US';
        regRequest4.PRM_Phy_Address_Line_1__c = '5th Floor,ITPL Main Road';
        regRequest4.PRM_Phy_Address_Line_2__c = 'Karnataka,India';
        regRequest4.PRM_Phy_State_Province__c = 'NY';
        regRequest4.PRM_Phy_City__c = 'Las Vegas';
        regRequest4.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest4.PRM_Zip_Postal_Code__c = '37521';
        regRequest4.PRM_Salesforce_ID__c = a1.Id;
        regRequest4.PRM_Channel_Program__c = cprogram.Id;
        regRequest4.PRM_Partner_Role__c = 'Service Provider';
        regRequest4.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest4.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact+';'+System.Label.PRM_WorksFor; 
        regRequest4.PRM_Subscriptions__c ='CSPx2_Sub2';
        regRequest4.PRM_Auto_Approve__c= True;
        insert regRequest4;
        listToInsert2.add(regRequest4);
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(listToInsert2);
        
        
        
        Test.startTest();
        PRM_CreateAccountAndRelatedRecords.approveACM(acmList);
        Test.stopTest();
    }
        @isTest
      public static void linkBulkEmailLogToContactTest(){
         Test.startTest();
       /* UserRole r = new UserRole(Name = 'Admin');
    insert r;  
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'testlast@intel.com',
             Username = 'testlast@intel.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             UserRoleId = r.Id,
             IsActive = false
        );
            insert u;*/
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
            
        Account a1 = PRM_TestUtility.getAccount();
        a1.AccountNumber = '435767';
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
        a1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        a1.Core_User_Defined_Website__c ='www.test.com';
        insert a1;

        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a1.Id;
            c.Core_IPA_PartnerRole__c='Distributor';
        //c.Email='hariharasudhan.meiyappan@intel.com';
        c.email='harihar@malinator.com';
        c.MailingCountry='USA';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        insert c;
            
        PRM_EmailLog__c eLog = new PRM_EmailLog__c();
        eLog.Email_Template_Name__c = 'SCRREQTOAPVDNEW';
        eLog.PRM_ToEmailID__c = c.Email;
      //  eLog.PRM_User__c = u.Id;
        insert eLog;
         
        List<String> receipientMail = new List<String>();
        List<String> receipientMail1 = new List<String>();
        receipientMail.add('harihar@malinator.com') ;     
        receipientMail1.add(' ') ;    
        PRM_CreateAccountAndRelatedRecords.linkBulkEmailLogToContact(receipientMail); 
        try{
            PRM_CreateAccountAndRelatedRecords.linkBulkEmailLogToContact(receipientMail1);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
  
  
    }

}