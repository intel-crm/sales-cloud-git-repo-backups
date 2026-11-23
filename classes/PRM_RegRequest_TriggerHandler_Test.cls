/*********************************************************************************************************************
Class Name  : PRM_RegRequest_TriggerHandler_Test
Version       : 1.0
Created Date  : OCT 2018
Function      : Test Class for 'PRM_RegRequest_TriggerHandler'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Kushal Soni               10/05/2018              PRM_RegRequest_TriggerHandler

*********************************************************************************************************************/
@isTest
private class PRM_RegRequest_TriggerHandler_Test{
    
    @testSetup
    //test data creation
    static void setupDataCreation()
    {
        Map<Id, list<string>>  mapOfAccIdPartnerRole=new map<Id,list<string>>();
        PRM_Language_Culture_Mapping__mdt languageCulturalmetadata = new  PRM_Language_Culture_Mapping__mdt();
        languageCulturalmetadata.PRM_Country__c ='US';
        languageCulturalmetadata.PRM_Culture__c='';
        languageCulturalmetadata.PRM_Country_Cd__c='us';
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.RecordTypeId = recordTypeIdAccount;
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_User_Defined_Website__c = 'WWW.test123.com';
        acc.Name='attempet';
        insert(acc);    
        
         
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_OnePartnerID__c = testAccount.Id;
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='testuser@gmail.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_IPA_PartnerRole__c='Service Provider';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.mailingcountry='India';
        insert cont;
        
    set<string> emailValueSet=new set<string>();
        List<Contact> contactList = new List<Contact>();
        Contact con = PRM_TestUtility.getContact();
        con.Email='testrequest@mailinator.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.Core_Login_Id__c = 'abc';
        con.mailingcountry='India';
        contactList.add(con);
    emailValueSet.add(con.id);
        
        Contact con1 = PRM_TestUtility.getContact();
        con1.Email='testrequest@maildrop.cc';
        con1.AccountId = acc.Id;
        con1.Core_Job_Function__c='Branch Manager';
        con1.Core_eRPM_Language_Code__c='Eng';
        con1.Core_IPA_PartnerRole__c = 'Service Provider';
        con1.Core_Login_Id__c = 'abc';
        con1.mailingcountry='India';
        contactList.add(con1);
    emailValueSet.add(con1.id);
        insert contactList;
        
    PRM_RegistrationTrackerUtility.checkInviteEmail(emailValueSet);
        Core_Account_Whitelisted_Domains__c accWhitelist = new Core_Account_Whitelisted_Domains__c();
        accWhitelist.Name = 'mailinator.com';
        accWhitelist.Account__c = acc.Id;
        accWhitelist.Inactive_Indicator__c = false;
        insert accWhiteList;
        
        List<ChannelProgram> cpList = new List<ChannelProgram>();     
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='New Partner Program';
        cprogram.PRM_programCode__c='NPP';
        cpList.add(cprogram);
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        cpList.add(cp);
        
        ChannelProgram psgProg = new ChannelProgram();
        psgProg.Name='PSG';
        psgProg.PRM_programCode__c='PSG';
        cpList.add(psgProg);
        
        ChannelProgram iqrProgram = new ChannelProgram();
        iqrProgram.Name='Intel Quote Request';
        iqrProgram.PRM_programCode__c='IQR';
        cpList.add(iqrProgram);
        
        ChannelProgram rdcProgram = new ChannelProgram();
        rdcProgram.Name='RDC Privilege';
        rdcProgram.PRM_programCode__c='RDC_Priv';
        cpList.add(rdcProgram);
        insert cpList;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1; 
        
        List<PRM_PartnerAgreement__c> listPartnerAgreement = new List<PRM_PartnerAgreement__c>();
        PRM_PartnerAgreement__c pa = PRM_TestUtility.getPartnerAgreement();
        pa.PRM_Channel_Program_Id__c = cp.Id;
        listPartnerAgreement.add(pa);
        
        PRM_PartnerAgreement__c pa1 = PRM_TestUtility.getPartnerAgreement();
        pa1.PRM_Channel_Program_Id__c = cp.Id;
        pa1.Name='IPA Terms & Condition';
        pa1.PRM_Language_Codes__c='';
        pa1.PRM_Agreement_Cd__c='IPA_TANDC';
        listPartnerAgreement.add(pa1);
        
        PRM_PartnerAgreement__c pa2 = PRM_TestUtility.getPartnerAgreement();
        pa2.PRM_Channel_Program_Id__c = cp.Id;
        pa2.Name='PA2';
        pa2.PRM_Language_Codes__c='';
        pa2.PRM_Agreement_Cd__c='PA2';
        listPartnerAgreement.add(pa2);
        
        insert listPartnerAgreement;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cprogram.Id;
        membership.PRM_Account_Id__c=acc.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Status_Reason_Txt__c ='approved';
        membership.PRM_Partner_Role__c='Solution Integrator';
        acmList.add(membership);
        if(mapOfAccIdPartnerRole.containsKey(membership.PRM_Account_Id__c)){
            mapOfAccIdPartnerRole.get(membership.PRM_Account_Id__c).add(membership.PRM_Partner_Role__c);
        }else{
            mapOfAccIdPartnerRole.put(membership.PRM_Account_Id__c, new List<String>{membership.PRM_Partner_Role__c});
        }
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=acc.Id;
        membership1.PRM_Status_Nm__c = 'Pending';
        membership1.PRM_Status_Reason_Txt__c ='Pending';
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        acmList.add(membership1);
        if(mapOfAccIdPartnerRole.containsKey(membership.PRM_Account_Id__c)){
            mapOfAccIdPartnerRole.get(membership.PRM_Account_Id__c).add(membership.PRM_Partner_Role__c);
        }else{
            mapOfAccIdPartnerRole.put(membership.PRM_Account_Id__c, new List<String>{membership.PRM_Partner_Role__c});
        }
        
        PRM_AccountChannelMembership__c membership2 = new PRM_AccountChannelMembership__c();
        membership2.PRM_Account_Id__c=acc.Id;
        membership2.PRM_Status_Nm__c = 'Pending';
        membership2.PRM_Status_Reason_Txt__c ='Pending';
        membership2.PRM_Channel_Program_Id__c=cp.Id;
        membership2.PRM_Partner_Role__c='Distributor';
        acmList.add(membership2);
        Triggerhandler.bypass('PRM_ACM_TriggerHandler');
        if(mapOfAccIdPartnerRole.containsKey(membership.PRM_Account_Id__c)){
            mapOfAccIdPartnerRole.get(membership.PRM_Account_Id__c).add(membership.PRM_Partner_Role__c);
        }else{
            mapOfAccIdPartnerRole.put(membership.PRM_Account_Id__c, new List<String>{membership.PRM_Partner_Role__c});
        }
        insert acmList;
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
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
        cr1.Name=System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='EMPLOYEE';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=acc.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=con.Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Nm__c ='Pending Action';
        acr.PRM_Status_Reason_Txt__c ='Pending';
        
        acrList.add(acr);
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=acc.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=con.Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c ='Complete';
        acr1.PRM_Status_Reason_Txt__c ='Pending';
       acrList.add(acr1);
       Triggerhandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert acrList;
      Triggerhandler.clearbypass('PRM_AcctContRel_TriggerHandlerNew');
       
        PRM_Profile_Questions__c pQues = new PRM_Profile_Questions__c();
        pQues.PRM_Question_Cd__c = 'Ques1';
        insert pQues;
        
        PRM_Profile_Answer__c pAnswer = new PRM_Profile_Answer__c();
        pAnswer.PRM_Answer_Cd__c = 'PRM_AcceptableDomainAns';
        pAnswer.PRM_Profile_Questions_Id__c = pQues.Id;
        insert pAnswer;
        
        PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Account_Id__c = acc.Id;
        pr.PRM_Response_Txt__c = 'mailinator.com,live.com';
        pr.PRM_Profile_Answer_Id__c = pAnswer.Id;
        insert pr; 
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Points Redeem';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed);
        insert entList;
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='ACCS_ENTTL', Name='Access and Entitlement', Is_Active__c = true);
        insert business;
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        //entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = entList[0].id;
        entmatrix.Business_Types__c = business.id;
        insert entMatrix;
        PRM_Registration_Request__c newfulldupRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newfulldupRequest.PRM_CIM_ID__c='';
        newfulldupRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newfulldupRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newfulldupRequest.PRM_Email_ID__c = 'testuser11@gmail.com';
        newfulldupRequest.PRM_Channel_Program__c = cp.Id;
        newfulldupRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newfulldupRequest.PRM_Partner_Relationship__c = '';
        newfulldupRequest.PRM_Preferred_Language__c = '';
        newfulldupRequest.PRM_Matching_Contact__c = con.Id;
        newfulldupRequest.PRM_Contact_Country__c='IN';
        newfulldupRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newfulldupRequest.PRM_Salesforce_ID__c = acc.Id;
        newfulldupRequest.PRM_Status__c ='New';
        newfulldupRequest.PRM_Dup_Status__c =null;
        newfulldupRequest.PRM_ProcessInstanceWorkItem_Id__c = '';
        newfulldupRequest.PRM_Profile_Response__c = 'test pr';
        newfulldupRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert newfulldupRequest;
        
        PRM_Registration_Request__c newfulldupRequest41 = PRM_TestUtility.getPRMRegistrationRequest();
        newfulldupRequest41.PRM_CIM_ID__c='';
        
        newfulldupRequest41.PRM_EmailVerifiedDateTime__c=System.Today();
        newfulldupRequest41.PRM_EV_Token__c = 'gwiur#@98321327';
        newfulldupRequest41.PRM_Email_ID__c = 'testuser12345678@gmail.com';
        newfulldupRequest41.PRM_Channel_Program__c = cp.Id;
        newfulldupRequest41.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newfulldupRequest41.PRM_Partner_Relationship__c = '';
        newfulldupRequest41.PRM_Preferred_Language__c = '';
        newfulldupRequest41.PRM_Matching_Contact__c = con.Id;
        newfulldupRequest41.PRM_Contact_Country__c='IN';
        newfulldupRequest41.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newfulldupRequest41.PRM_Salesforce_ID__c = acc.Id;
        newfulldupRequest41.PRM_Status__c ='New';
        newfulldupRequest41.PRM_Dup_Status__c =null;
        newfulldupRequest41.PRM_ProcessInstanceWorkItem_Id__c = '';
        newfulldupRequest41.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newfulldupRequest41.PRM_Profile_Response__c = 'test pr';
        
        newfulldupRequest41.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert newfulldupRequest41;
        
        newfulldupRequest.PRM_Dup_Status__c = 'FULLDUP';
        update newfulldupRequest;
        Test.startTest();
        List<PRM_Registration_Request__c> lst = new List<PRM_Registration_Request__c>();
        
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testuser1@gmail.com';
        newRequest.PRM_Channel_Program__c = cp.Id;
        newRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Preferred_Language__c = '';
        newRequest.PRM_Matching_Contact__c = con.Id;
        newRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRequest.PRM_Salesforce_ID__c = acc.Id;
        newRequest.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest.PRM_Profile_Response__c = 'test pr';
        newRequest.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        lst.add(newRequest);
        
        PRM_Registration_Request__c newRequest1 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest1.PRM_CIM_ID__c='';
        newRequest1.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest1.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest1.PRM_Email_ID__c = 'testrequest12@mailinator.com';
        newRequest1.PRM_Channel_Program__c = cp.Id;
        newRequest1.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest1.PRM_Partner_Relationship__c = '';
        newRequest1.PRM_Preferred_Language__c = '';
        newRequest1.PRM_Matching_Contact__c = con.Id;
        newRequest1.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRequest1.PRM_Salesforce_ID__c = acc.Id;
        newRequest1.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest1.PRM_Subscriptions__c = 'PRDSOLCOM;TRAWEBCOM;POINTCOM;EVENTCOM;PARRESCOM;MEMBCOM';
        newRequest1.PRM_Profile_Response__c = 'test pr';
        newRequest1.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest1.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
        lst.add(newRequest1);
        
       /* PRM_Registration_Request__c newRequest21 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest21.PRM_Status__c ='Approved';
        newRequest21.PRM_CIM_ID__c='';
        newRequest21.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest21.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest21.PRM_Email_ID__c = 'testuser2@gmail.com';
        newRequest21.PRM_Channel_Program__c = cp.Id;
        newRequest21.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest21.PRM_Partner_Relationship__c = '';
        newRequest21.PRM_Preferred_Language__c = '';
        newRequest21.PRM_Matching_Contact__c = con.Id;
        newRequest21.PRM_Partner_Type__c =null;
        newRequest21.PRM_Salesforce_ID__c = acc.Id;
        newRequest21.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest21.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest21.PRM_Profile_Response__c = 'test pr';
        newRequest21.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest21.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
        lst.add(newRequest21);
        PRM_Registration_Request__c newRequest71 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest71.PRM_Status__c ='Approved';
        newRequest71.PRM_CIM_ID__c='';
        newRequest71.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest71.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest71.PRM_Email_ID__c = 'testuser3@gmail.com';
        newRequest71.PRM_Channel_Program__c = cp.Id;
        newRequest71.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest71.PRM_Partner_Relationship__c = '';
        newRequest71.PRM_Preferred_Language__c = '';
        newRequest71.PRM_Matching_Contact__c = con.Id;
        newRequest71.PRM_Partner_Type__c =null;
        newRequest71.PRM_Salesforce_ID__c = acc.Id;
        newRequest71.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest71.RecordTypeId =PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT;
        newRequest71.PRM_Matching_Contact__c = null;
        newRequest71.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest71.PRM_Profile_Response__c = 'test pr';
        newRequest71.PRM_EmailVerifiedDateTime__c=system.now();
        lst.add(newRequest71);
        
        PRM_Registration_Request__c newRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        newfulldupRequest.PRM_Status__c ='New';
        newRequest11.PRM_CIM_ID__c='';
        newRequest11.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest11.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest11.PRM_Email_ID__c = 'testuser4@gmail.com';
        newRequest11.PRM_Channel_Program__c = cp.Id;
        newRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest11.PRM_Partner_Relationship__c = '';
        newRequest11.PRM_Preferred_Language__c = '';
        newRequest11.PRM_Matching_Contact__c = con.Id;
        newRequest11.PRM_Partner_Type__c =null;
        newRequest11.PRM_Salesforce_ID__c = acc.Id;
        newRequest11.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest11.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest11.PRM_Profile_Response__c = 'test pr';
        newRequest11.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        lst.add(newRequest11);*/
        
        PRM_Registration_Request__c newRequest12 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest12.PRM_Status__c ='New';
        newRequest12.PRM_CIM_ID__c='';
        newRequest12.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest12.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest12.PRM_Email_ID__c = 'testuser5@gmail.com';
        newRequest12.PRM_Channel_Program__c = cp.Id;
        newRequest12.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest12.PRM_Partner_Relationship__c = '';
        newRequest12.PRM_Preferred_Language__c = '';
        newRequest12.PRM_Matching_Contact__c = con.Id;
        newRequest12.PRM_Partner_Type__c =null;
        newRequest12.recordTypeId = PRM_IPA_Constants.EV_RECORD_TYPE_ID;
        newRequest12.PRM_Salesforce_ID__c = acc.Id;
        newRequest12.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest12.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest12.PRM_Profile_Response__c = 'test pr';
        newRequest12.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest12.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        lst.add(newRequest12);
        PRM_Registration_Request__c newRequest13 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest13.PRM_Status__c ='New';
        newRequest13.PRM_CIM_ID__c='';
        newRequest13.PRM_EmailVerifiedDateTime__c=null;
        newRequest13.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest13.PRM_Email_ID__c = 'testuser6@gmail.com';
        newRequest13.PRM_Channel_Program__c = psgProg.Id;
        newRequest13.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest13.PRM_Partner_Relationship__c = '';
        newRequest13.PRM_Preferred_Language__c = '';
        newRequest13.PRM_Matching_Contact__c = con.Id;
        newRequest13.PRM_Partner_Type__c =null;
        newRequest13.recordTypeId = PRM_IPA_Constants.EV_RECORD_TYPE_ID;
        newRequest13.PRM_Salesforce_ID__c = acc.Id;
        newRequest13.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest13.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest13.PRM_Profile_Response__c = 'test pr';
        newRequest13.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest13.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
       // lst.add(newRequest13);
        PRM_Registration_Request__c newRequest14 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest14.PRM_Status__c ='New';
        newRequest14.PRM_CIM_ID__c='';
        newRequest14.PRM_EmailVerifiedDateTime__c=null;
        newRequest14.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest14.PRM_Email_ID__c = 'testuser7@gmail.com';
        newRequest14.PRM_Channel_Program__c = iqrProgram.Id;
        newRequest14.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest14.PRM_Partner_Relationship__c = '';
        newRequest14.PRM_Preferred_Language__c = '';
        newRequest14.PRM_Matching_Contact__c = con.Id;
        newRequest14.PRM_Partner_Type__c =null;
        newRequest14.recordTypeId = PRM_IPA_Constants.EV_RECORD_TYPE_ID;
        newRequest14.PRM_Salesforce_ID__c = acc.Id;
        newRequest14.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest14.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest14.PRM_Profile_Response__c = 'test pr';
        newRequest14.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest14.PRM_Wechat_Union_Id__c = '001000000000001';
        newRequest14.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        lst.add(newRequest14);
        
        List<PRM_Registration_Request__c> reglst = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c newRequest15 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest15.PRM_Status__c ='Approved';
        newRequest15.PRM_CIM_ID__c='';
        newRequest15.PRM_EmailVerifiedDateTime__c=null;
        newRequest15.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest15.PRM_Email_ID__c = 'testuseasdr8@gmail.com';
        newRequest15.PRM_Channel_Program__c = iqrProgram.Id;
        newRequest15.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest15.PRM_Partner_Relationship__c = '';
        newRequest15.PRM_Preferred_Language__c = '';
        newRequest15.PRM_Matching_Contact__c = con.Id;
        newRequest15.PRM_Partner_Type__c =null;
        newRequest15.recordTypeId = PRM_IPA_Constants.EV_RECORD_TYPE_ID;
        newRequest15.PRM_Salesforce_ID__c = null;
        newRequest15.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest15.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest15.PRM_Profile_Response__c = 'test pr';
        newRequest15.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest15.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
        lst.add(newRequest15);
        
        PRM_Registration_Request__c newRequest55 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest55.PRM_Status__c ='New';
        newRequest55.PRM_CIM_ID__c='';
        newRequest55.PRM_EmailVerifiedDateTime__c=null;
        newRequest55.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest55.PRM_Email_ID__c = 'testuser9@gmail.com';
        newRequest55.PRM_Channel_Program__c = iqrProgram.Id;
        newRequest55.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest55.PRM_Partner_Relationship__c = '';
        newRequest55.PRM_Preferred_Language__c = '';
        newRequest55.PRM_Matching_Contact__c = con.Id;
        newRequest55.PRM_Partner_Type__c =null;
        newRequest55.recordTypeId = PRM_IPA_Constants.EV_RECORD_TYPE_ID;
        newRequest55.PRM_Salesforce_ID__c = null;
        newRequest55.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest55.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest55.PRM_Profile_Response__c = 'test pr';
        newRequest55.recordTypeId = PRM_IPA_Constants.EV_RECORD_TYPE_ID;
        newRequest55.PRM_Channel_Program__c = psgProg.Id;
        //reglst.add(newRequest55);
        //insert reglst;
        
        //lst.add(newRequest55);
        upsert lst;
        
        /*PRM_RegistrationTrackerUtility.createRegistrationTracker(lst,null,false,false);*/
        Map<Id, Account> accMap = new Map<Id, Account>(); 
        accMap.put(acc.id,acc);
        Map<Id, Contact> contMap = new Map<Id, Contact>();
        contMap.put(con.id,con);
        Map<Id, List<PRM_Account_Contact_Relationship__c>> acrs = new Map<Id, List<PRM_Account_Contact_Relationship__c>>();
        acrs.put('001000000000001',null); 
        Map<Id,PRM_Registration_Request__c> regMap = new  Map<Id,PRM_Registration_Request__c>();
        regMap.put(lst[0].id, lst[0]);
        
        /*Map<String,PRM_Registration_Request__c> regNewMap = new  Map<String,PRM_Registration_Request__c>();
        regNewMap.put(lst[0].PRM_Contact_Login_ID__c, lst[0]);
         Map<Id, PRM_Account_Contact_Relationship__c> mapOfACR = new Map<Id, PRM_Account_Contact_Relationship__c>{
            acrList[0].Id => acrList[0],
            acrList[1].Id => acrList[1]
        };*/
        Set<Id> setOpidWithPA = new Set<Id>();
        Map<Id, Id> mapAccIdToOpid = new Map<Id, Id>{acc.Id => acc.Id};
        PRM_RegistrationRequestUtility.partnerrelationship(lst,acrs,contMap,regMap,mapOfAccIdPartnerRole,setOpidWithPA,mapAccIdToOpid);
       // PRM_RegistrationRequestUtility.getACRToUpdate(mapOfACR,regNewMap);
        //PRM_RegistrationRequestUtility.emailNotificationOnReceivingRegistration(reglst);
        Test.stopTest();
        
    }
    
    @isTest static void checkTracker(){
       List<PRM_Registration_Request__c> reglst = new List<PRM_Registration_Request__c>();
        Test.startTest();
        ChannelProgram cpTest = [SELECT Id, Name,PRM_programCode__c from ChannelProgram where Name = 'Intel Partner Alliance' LIMIT 1];

        reglst = [Select Id,Name,PRM_Partner_Role__c,PRM_Matching_Contact__c,PRM_Email_ID__c,PRM_isSubmitted__c,PRM_Auto_Approve__c, RecordType.name, PRM_Channel_Program_Level_txt__c from PRM_Registration_Request__c where RecordType.name = 'Account Create Request' limit 2];
        
        
        PRM_RegistrationTrackerUtility.createRegistrationTracker(reglst,null,false,false);
        PRM_RegistrationRequestUtility.emailNotificationOnReceivingRegistration(reglst);
        Test.stopTest();
        
    }
    
    //checking if both salesforce ID - CIM ID are empty & covering EVcheck method
    @isTest static void applyRTandEVCheck(){
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> regRequest = new List<PRM_Registration_Request__c>();
        Account testAccount=[select id from Account where Name='John Wick'];
         Test.startTest();
        Contact cont=[select id, email from Contact where FirstName='Adam' and lastName ='Grill' ];
        ChannelProgram cpTest = [SELECT Id, Name,PRM_programCode__c from ChannelProgram where Name = 'Intel Partner Alliance' LIMIT 1];
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin Delegate';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        List<PRM_Account_Contact_Relationship__c> acrList = [select id, name , PRM_Contact_Id__c, PRM_Account_Id__c, PRM_InActive_Ind__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,PRM_AGS_Response_Status__c from PRM_Account_Contact_Relationship__c limit 1];
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_Status_Nm__c='Complete';
        acctContRel.PRM_Status_Reason_Txt__c ='Complete';
        acctContRel.PRM_isActive__c=true;
        acctContRel.PRM_AGS_Response_Status__c='Success';
        acrList.add(acctContRel);
        
        PRM_Registration_Request__c rr = [Select RecordTypeId,Entitlement_Details__c,PRM_Channel_Program_Level_txt__c,PRM_Contact_Country__c,PRM_Channel_Program__c,PRM_Salesforce_ID__c,PRM_Dup_Status__c,PRM_Auto_Approve__c,PRM_Status__c,PRM_Status_Reason__c,PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c, PRM_Profile_Response__c,PRM_Contact_Login_ID__c from PRM_Registration_Request__c where PRM_CIM_ID__c = '' LIMIT 1];
        ChannelProgram cp1 = [Select Id from ChannelProgram where Name = 'PSG' LIMIT 1];
        rr.PRM_EmailVerifiedDateTime__c=null;
        List<PRM_Registration_Request__c> regRequestList =new List<PRM_Registration_Request__c>();
        regRequestList.add(rr);
        PRM_RegistrationRequestUtility.emailNotificationOnReceivingRegistration(regRequestList);
        rr.RecordTypeId = accCreateRequestId;
        rr.PRM_Email_Verification_Criteria__c = 'success';
        rr.PRM_Partner_Role__c = 'Distributor';
        rr.PRM_Matching_Contact__c = null;
        rr.PRM_Partner_Type__c = 'Distributor';
        rr.PRM_Email_ID__c = cont.Email;
        rr.PRM_Status__c = 'Approved';
        rr.PRM_Contact_Login_ID__c = cont.Email;
        rr.PRM_City__c = 'qwerty';
        regRequest.add(rr);
        
        PRM_Registration_Req_Approve_Reject.isApprovedUsingButton = true;
        update regRequest;
        
        PRM_Registration_Request__c newRequest15 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest15.PRM_Status__c ='New';
        newRequest15.PRM_CIM_ID__c='';
        newRequest15.PRM_EmailVerifiedDateTime__c=null;
        newRequest15.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest15.PRM_Email_ID__c = 'testuseasdr10@gmail.com';
        newRequest15.PRM_Channel_Program__c = cp1.id;
        newRequest15.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest15.PRM_Partner_Relationship__c = '';
        newRequest15.PRM_Preferred_Language__c = '';
        newRequest15.PRM_Partner_Type__c =null;
        newRequest15.recordTypeId = PRM_IPA_Constants.EV_RECORD_TYPE_ID;
        newRequest15.PRM_Salesforce_ID__c = null;
        newRequest15.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest15.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest15.PRM_Profile_Response__c = 'test pr';
        newRequest15.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest15.PRM_Email_Verification_Criteria__c = System.Label.PRM_Pending;
        newRequest15.PRM_City__c = 'qwerty';
        newRequest15.PRM_Contact_Country__c = 'us';
        newRequest15.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
       // insert newRequest15;
       
        PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
        trac.Stage__c='1';
        trac.PRM_Email__c='testrequest@maildrop.cc';
        trac.PRM_Registration__c=newRequest15.Id;
        trac.PRM_Step_Number__c=1;
        trac.PRM_Current_Step__c=1;  
        trac.PRM_Account__c = testAccount.Id;
        trac.PRM_contact__c = cont.Id;
        insert trac;
        
        PRM_RegistrationTrackerUtility.RegistrationWrapper wrr=new PRM_RegistrationTrackerUtility.RegistrationWrapper();
        wrr.previousStepNo='';
        wrr.GetProfile=false;
        wrr.SBC_Callout_Made=false;
        wrr.EV_Completed=false;
        wrr.Login_Mail_Sent=false;
        wrr.Login_Mail_UnSent=false;
        wrr.Approved_with_Error=false;
        wrr.sameAPICall=false;
        wrr.Benefit_Assigned=false;
        wrr.Entitlement_Assigned=false;
        wrr.Welcome_Email_Unsent=false;
        wrr.User_Logged_into_Partner_Portal=false;
        wrr.User_Yet_to_login=false;
        wrr.ACR_Yet_to_Assign=false;
        wrr.regInitiated=false;
        wrr.dupcheck=false;
        wrr.Invite_UnSent=false;
        wrr.Invite_Sent=false;
        wrr.Invite_Pending=false;
        wrr.Invite_Completed=false;
        wrr.Ack_Mail_Sent=false;
        wrr.admin=false;
        wrr.ackmail=false;
        wrr.Subscription_Yet_to_Assign=true;
        wrr.classname='cc';
        //wrr.AGS_ID_Creation_Successful=true;
        //wrr.AGS_ID_creation_Retry_Success=true;
        wrr.Welcome_Email_Sent=true;
        wrr.manulApproval=false;
        wrr.agsid=false;
        //PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(regRequest[0].PRM_Email_ID__c);
        PRM_RegistrationRequestUtility.emailNotificationOnReceivingRegistration(regRequest);
        //PRM_RegistrationRequestUtility.autoApproveEndUserRegistration();
        Test.stopTest();
        
        System.assertEquals(rr.PRM_First_Name__c ,'Test Request','Value does not match');
    }
    @isTest static void rejectDuplicateMethod(){
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> regRequest = new List<PRM_Registration_Request__c>();
        Test.startTest();
        PRM_Registration_Request__c rr = [Select RecordTypeId,PRM_Contact_Country__c,PRM_Channel_Program__c, PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'testuser1@gmail.com' LIMIT 1];
        Account acct = [Select id, name from Account limit 1];
        rr.RecordTypeId = accCreateRequestId;
        rr.PRM_Partner_Role__c = 'Distributor';
        rr.PRM_Account_Name__c = 'RR1';
        rr.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        rr.PRM_Profile_Response__c= 'test pr';
        rr.PRM_Salesforce_ID__c = acct.Id;
        rr.PRM_Subscriptions__c = 'CSP_Sub';
        rr.PRM_Matching_Contact__c = null;
        rr.PRM_Partner_Type__c = 'Distributor';
        rr.PRM_Status__c = 'New';
        rr.PRM_Partner_Relationship__c = '';
        rr.PRM_Email_Verification_Criteria__c = 'PENDING';
        rr.PRM_City__c = 'Pune';
        rr.PRM_Status__c = 'Approved';
        rr.PRM_Address_Line_1__c = 'yuujkkjjk';
        rr.PRM_Zip_Postal_Code__c = '678375';
        rr.PRM_Dup_Status__c = 'ERROR';
        regRequest.add(rr);

        
        PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun=true;
        PRM_Registration_Req_Approve_Reject.isApprovedUsingButton = true;
        update regRequest;
        regRequest[0].PRM_Status__c = 'Approved';
        regRequest[0].PRM_Email_Verification_Criteria__c = 'success';
        PRM_Registration_Req_Approve_Reject.isApprovedUsingButton = true;
        update regRequest;
        PRM_RegistrationRequestUtility.emailNotificationOnReceivingRegistration(regRequest);
        
        PRM_CimDupErrorUtility.dupCheck(new List<PRM_Registration_Request__c>{rr},null);
        Test.stopTest();
        System.assertEquals(rr.PRM_First_Name__c ,'Test Request','Value does not match');
    }
    @isTest static void rejectDuplicateMethod2(){
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> regRequest = new List<PRM_Registration_Request__c>();
        Test.startTest();
        PRM_Registration_Request__c rr = [Select RecordTypeId,PRM_Contact_Country__c,PRM_Channel_Program__c, PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'testuser1@gmail.com' LIMIT 1];
        Account acct = [Select id, name from Account limit 1];
        rr.RecordTypeId = accCreateRequestId;
        rr.PRM_Email_Verification_Criteria__c = 'Success';
        rr.PRM_Partner_Role__c = 'Distributor';
        rr.PRM_Account_Name__c = 'RR1';
        rr.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        rr.PRM_Profile_Response__c= 'test pr';
        rr.PRM_Salesforce_ID__c = acct.Id;
        rr.PRM_Subscriptions__c = 'CSP_Sub';
        rr.PRM_Matching_Contact__c = null;
        rr.PRM_Partner_Type__c = 'Distributor';
        rr.PRM_Status__c = 'New';
        rr.PRM_Partner_Relationship__c = '';
        rr.PRM_Email_Verification_Criteria__c = 'PENDING';
        regRequest.add(rr);
        
        PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun=true;
        update regRequest;
        regRequest[0].PRM_Status__c = 'Approved';
        regRequest[0].PRM_Email_Verification_Criteria__c = 'success';
        PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun=true;
        PRM_Registration_Req_Approve_Reject.isApprovedUsingButton = true;
        update regRequest;
        PRM_RegistrationRequestUtility.emailNotificationOnReceivingRegistration(regRequest);
        Test.stopTest();
        
        System.assertEquals(rr.PRM_First_Name__c ,'Test Request','Value does not match');
    }
    @isTest static void sendAcknowledgementEmailMethodTest(){
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
       Assert.isNotNull(accCreateRequestId);
        List<PRM_Registration_Request__c> regRequest = new List<PRM_Registration_Request__c>();
        Test.startTest();
        PRM_Registration_Request__c rr = [Select RecordTypeId,PRM_Contact_Country__c,PRM_Contact_Login_ID__c,PRM_Channel_Program__c,PRM_Account_Name__c, PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_Partner_Role__c,PRM_Salesforce_ID__c,PRM_Status__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'testrequest12@mailinator.com' LIMIT 1];
       Assert.isNotNull(rr);
        rr.PRM_EmailVerifiedDateTime__c=null;
        List<PRM_Registration_Request__c> regRequestList =new List<PRM_Registration_Request__c>();
        regRequestList.add(rr);
        rr.PRM_EmailVerifiedDateTime__c=null;
        rr.RecordTypeId = accCreateRequestId;
        rr.PRM_Email_Verification_Criteria__c = Label.PRM_Success;
        rr.PRM_Partner_Role__c = 'Distributor';
        rr.PRM_Dup_Status__c = 'FULLDUP';
        rr.PRM_Auto_Approve__c = false;
        rr.PRM_Profile_Response__c = 'test rr';
        rr.PRM_Status__c = 'Approved';
        rr.PRM_Email_ID__c = 'testrequester@mailinator.com';
        regRequest.add(rr);
        PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun=true;
        PRM_Registration_Req_Approve_Reject.isApprovedUsingButton = true;
        update regRequest;
       
        PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(regRequest[0].PRM_Email_ID__c);
        Test.stopTest();
        
    }  
    @isTest static void sendRejectionEmailMethodTest(){
        List<PRM_Registration_Request__c> regRequest = new List<PRM_Registration_Request__c>();
        Test.startTest();
        PRM_Registration_Request__c rr = [Select RecordTypeId,PRM_Contact_Country__c,PRM_Contact_Login_ID__c,PRM_Channel_Program__c,PRM_Account_Name__c, PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_Partner_Role__c,PRM_Salesforce_ID__c,PRM_Status__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'testrequest12@mailinator.com' LIMIT 1];
        Assert.isNotNull(rr);
        Map<id, PRM_Registration_Request__c> oldregRequestMap = new  Map<id, PRM_Registration_Request__c>();
        oldregRequestMap.put(rr.id,rr);
        rr.PRM_Status__c = 'Rejected';
        regRequest.add(rr);
        update regRequest;
        System.assertEquals( rr.PRM_Status__c ,'Rejected','Value does not match');
        PRM_RegistrationRequestUtility.sendRejectionEmail(regRequest,oldregRequestMap);
        Test.stopTest();
    }      
    @isTest static void autoapprovalonpartnerrole(){
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> listOfRequest1 = new List<PRM_Registration_Request__c>();
        Test.startTest();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'WWW.test123.com';
        insert newAccount;
        
        List<Contact> con = new List<Contact>();
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='thomas';
        cont1.FirstName='Edward';
        cont1.email='edwardthomas@malinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'xyz';
        cont1.mailingcountry='India';
        con.add(cont1);
        insert con;
      
        PRM_ContactRelationships__c cr1 = [Select Id,name from PRM_ContactRelationships__c  where Name='Partner Admin'];
      
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=newAccount.Id;
        acr.PRM_Relationship_Id__c = cr1.Id;
        acr.PRM_Contact_Id__c=con[0].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        acr.PRM_Status_Reason_Txt__c = 'Test';
       Triggerhandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert acr;
      Triggerhandler.clearbypass('PRM_AcctContRel_TriggerHandlerNew');
       
        PRM_Registration_Request__c newRegistrationRequest7 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest7.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest7.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest7.PRM_Contact_Login_ID__c = 'newContact10@mailinator.com';
        newRegistrationRequest7.PRM_Status__c = 'New';
        newRegistrationRequest7.Name = 'Auto Approve Request On Partner Role1';
        newRegistrationRequest7.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest7.PRM_Profile_Response__c = 'test pr';
        insert newRegistrationRequest7;
        
        PRM_Registration_Request__c newRegistrationRequest8 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest8.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Add_Membership_Request).getRecordTypeId();
        newRegistrationRequest8.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest8.PRM_Contact_Login_ID__c = 'newContact101@mailinator.com';
        newRegistrationRequest8.PRM_Status__c = 'New';
        newRegistrationRequest8.Name = 'Auto Approve Request On Partner Role1';
        newRegistrationRequest8.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest8.PRM_Profile_Response__c = 'test pr';
        newRegistrationRequest8.PRM_isSubmitted__c = false;
        newRegistrationRequest8.PRM_Auto_Approve__c = false;
        newRegistrationRequest8.Entitlement_Details__c = null;
        PRM_Registration_Request__c regreq1 = [Select Id,Name,PRM_Salesforce_ID__c,PRM_Status__c,PRM_Partner_Role__c,RecordTypeid,PRM_Profile_Response__c, PRM_Contact_Login_ID__c from PRM_Registration_Request__c where Name='Auto Approve Request On Partner Role1'];
        
        regreq1.RecordTypeId = accCreateRequestId;
        
        regreq1.PRM_Dup_Status__c = 'NODUP';
        
        regReq1.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regreq1.PRM_EmailVerifiedDateTime__c = System.now();
        listOfRequest1.add(regreq1);
        update listOfRequest1;
        Test.stopTest();
        
        System.assertEquals(regreq1.Name ,'Auto Approve Request On Partner Role1','Value does not match');
    }
    
    //sendApprovalEmail on auto approve 
    @isTest static void sendApprovalEmailTest(){
        test.startTest();
        Account acct = [select id from Account Limit 1];
        ChannelProgram cp = [SELECT Id, Name,PRM_programCode__c from ChannelProgram where Name = 'Intel Partner Alliance' LIMIT 1];
        PRM_Registration_Request__c regreq = PRM_TestUtility.getPRMRegistrationRequest();
        regreq.PRM_CIM_ID__c='';
        regreq.PRM_EmailVerifiedDateTime__c=System.Today();
        regreq.PRM_EV_Token__c = 'gwiur#@98321327';
        regreq.PRM_Email_ID__c = 'testuser@gmail.com';
        regreq.PRM_Channel_Program__c = cp.Id;
        regreq.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regreq.PRM_Partner_Relationship__c = '';
        regreq.PRM_Preferred_Language__c = '';
        regreq.PRM_Contact_Country__c='IN';
        regreq.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regreq.PRM_Salesforce_ID__c = acct.Id;
        regreq.PRM_Status__c ='New';
        regreq.PRM_Dup_Status__c =null;
        regreq.PRM_ProcessInstanceWorkItem_Id__c = '';
        regreq.PRM_Profile_Response__c = 'test pr';
        regreq.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        insert regreq;
        
        //PRM_Registration_Request__c regreq = [Select Id,Name,PRM_Partner_Role__c,PRM_Matching_Contact__c,PRM_Email_ID__c,PRM_isSubmitted__c,PRM_Auto_Approve__c, RecordType.name, PRM_Channel_Program_Level_txt__c from PRM_Registration_Request__c where RecordType.name = 'Account Create Request' limit 1];
        Assert.isNotNull(regreq.id);
        regreq.PRM_Matching_Contact__c = null;
        regreq.PRM_City__c = 'Los Angeles';
        regreq.PRM_Dup_Status__c = '';
        regreq.PRM_Salesforce_ID__c = acct.Id;
        regreq.PRM_Address_Line_1__c = 'test addr';
        regreq.PRM_Zip_Postal_Code__c = '655165';
        regreq.PRM_isSubmitted__c = False;
        regreq.PRM_Auto_Approve__c = False;
        regreq.Entitlement_Details__c = null;
        regreq.PRM_Dup_Status__c = 'ERROR';
        List<Contact> conList = [Select Id,Core_Do_Not_Contact__c from Contact limit 1];
        String businessEvent = System.label.PRM_Welcome_Email_New_Event;
        system.assertEquals(businessEvent,'Welcome_email_on_request_approval_New');
         
        PRM_RegistrationRequestUtility.sendApprovalEmail(conList,businessEvent,regreq.Id,regreq.PRM_Partner_Role__c);
        Test.stopTest();
    }
    
    @isTest static void sendApprovalEmailTest2(){
        test.startTest();
        Account acct = [select id from Account Limit 1];
        ChannelProgram cp = [SELECT Id, Name,PRM_programCode__c from ChannelProgram where Name = 'Intel Partner Alliance' LIMIT 1];
        PRM_Registration_Request__c regreq = PRM_TestUtility.getPRMRegistrationRequest();
        regreq.PRM_CIM_ID__c='';
        regreq.PRM_EmailVerifiedDateTime__c=System.Today();
        regreq.PRM_EV_Token__c = 'gwiur#@98321327';
        regreq.PRM_Email_ID__c = 'testuser@gmail.com';
        regreq.PRM_Channel_Program__c = cp.Id;
        regreq.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regreq.PRM_Partner_Relationship__c = '';
        regreq.PRM_Preferred_Language__c = '';
        regreq.PRM_Contact_Country__c='IN';
        regreq.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regreq.PRM_Salesforce_ID__c = acct.Id;
        regreq.PRM_Status__c ='New';
        regreq.PRM_Dup_Status__c =null;
        regreq.PRM_ProcessInstanceWorkItem_Id__c = '';
        regreq.PRM_Profile_Response__c = 'test pr';
        regreq.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert regreq;
        
        //PRM_Registration_Request__c regreq = [Select Id,Name,PRM_Partner_Role__c,PRM_Matching_Contact__c,PRM_Email_ID__c,PRM_isSubmitted__c,PRM_Auto_Approve__c, RecordType.name, PRM_Channel_Program_Level_txt__c from PRM_Registration_Request__c where RecordType.name = 'Account Create Request' limit 1];
        regreq.PRM_Matching_Contact__c = null;
        regreq.PRM_City__c = 'Los Angeles';
        regreq.PRM_Dup_Status__c = '';
        regreq.PRM_Salesforce_ID__c = acct.Id;
        regreq.PRM_Address_Line_1__c = 'test addr';
        regreq.PRM_Zip_Postal_Code__c = '655165';
        regreq.PRM_isSubmitted__c = False;
        regreq.PRM_Auto_Approve__c = False;
        regreq.Entitlement_Details__c = null;
        regreq.PRM_Dup_Status__c = 'ERROR';
        List<Contact> conList = [Select Id,Core_Do_Not_Contact__c from Contact limit 1];
        String businessEvent = System.label.PRM_Welcome_Email_New_Event;   
         system.assertEquals(businessEvent,'Welcome_email_on_request_approval_New');
        PRM_RegistrationRequestUtility.sendApprovalEmail(conList,businessEvent,regreq.Id,regreq.PRM_Partner_Role__c);
        
        Test.stopTest();
    }
    
    @isTest static void sendRejectionEmailTest(){
        Test.startTest();
        PRM_Language_Culture_Mapping__mdt langMdt = new PRM_Language_Culture_Mapping__mdt();
        langMdt.PRM_Country_Cd__c = 'us';
        langMdt.MasterLabel = 'ENG';
        
        list<PRM_Registration_Request__c> regList=new list<PRM_Registration_Request__c>();
        
        PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest11.PRM_Contact_Login_ID__c = 'newContact101@mailinator.com';
        newRegistrationRequest11.PRM_Status__c = 'New';
        newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest11.PRM_Email_ID__c = 'newContact101@mailinator.com';
        newRegistrationRequest11.PRM_Country__c = 'US';
        newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
        regList.add(newRegistrationRequest11);
        //insert newRegistrationRequest11;
        insert regList;
        regList[0].PRM_Status__c = 'Rejected';
        //newRegistrationRequest11.PRM_Status__c = 'Rejected';
        //list<PRM_Registration_Request__c> regList=new list<PRM_Registration_Request__c>();
        //regList.add(newRegistrationRequest11);
        update regList;
        //Test.stopTest();
       Assert.isNotNull(newRegistrationRequest11.PRM_Email_ID__c);
       Assert.isNotNull(newRegistrationRequest11.RecordTypeId);
        PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(newRegistrationRequest11.PRM_Email_ID__c);
        Test.stopTest();
        
    }
    @isTest static void getprofileTest(){
        set<string> conemail=new set<string>();
        conemail.add('testrequest@maildrop.cc');
        list<PRM_Registration_Request__c> reglistt=new list<PRM_Registration_Request__c>();
        list<PRM_Registration_Tracker__c> tracklsi=new list<PRM_Registration_Tracker__c>();
        Test.startTest();
        PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        ChannelProgram  cp=[select id from ChannelProgram where PRM_programCode__c='IPA' limit 1]; 
        newRegistrationRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest11.PRM_Contact_Login_ID__c = 'testrequest@intel.com';
        newRegistrationRequest11.PRM_Status__c = 'New';
        newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest11.PRM_Email_ID__c = 'testrequest@intel.com';
        newRegistrationRequest11.PRM_Country__c = 'US';
        newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest11.PRM_Channel_Program__c = cp.Id;
        newRegistrationRequest11.PRM_Auto_Approve__c = true;
       // insert newRegistrationRequest11;
        reglistt.add(newRegistrationRequest11);
        insert reglistt;
        
        PRM_RegistrationTrackerUtility.RegistrationWrapper wrr=new PRM_RegistrationTrackerUtility.RegistrationWrapper();
        wrr.previousStepNo='';
        wrr.GetProfile=false;
        wrr.SBC_Callout_Made=false;
        wrr.EV_Completed=false;
        wrr.Login_Mail_Sent=false;
        wrr.Login_Mail_UnSent=false;
        wrr.Approved_with_Error=false;
        wrr.sameAPICall=false;
        wrr.Benefit_Assigned=false;
        wrr.Entitlement_Assigned=false;
        wrr.Welcome_Email_Unsent=false;
        wrr.User_Logged_into_Partner_Portal=false;
        wrr.User_Yet_to_login=false;
        wrr.ACR_Yet_to_Assign=false;
        wrr.regInitiated=false;
        wrr.dupcheck=false;
        wrr.Invite_UnSent=false;
        wrr.Invite_Sent=false;
        wrr.Invite_Pending=false;
        wrr.Invite_Completed=false;
        wrr.Ack_Mail_Sent=false;
        wrr.admin=false;
        wrr.ackmail=false;
        wrr.Subscription_Yet_to_Assign=true;
        wrr.classname='cc';
        wrr.Welcome_Email_Sent=true;
        wrr.manulApproval=false;
        wrr.agsid=false;
        wrr.LogEntries = 'EL-01';
        wrr.IntegrationLog = 'Integration Done';
        
        PRM_Integration_Log__c intLog = new PRM_Integration_Log__c();
        intLog.PRM_Callout_Type__c = 'PRM_Callout_Type__c';
        intLog.PRM_System_Name__c = 'AEM';
        intLog.PRM_Record_ID__c = 'testrequest@intel.com';
        insert intLog;
        
        PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
        trac.Stage__c='1';
        trac.PRM_Email__c='testrequest@maildrop.cc';
        trac.PRM_Registration__c=newRegistrationRequest11.Id;
        trac.PRM_Step_Number__c=1;
        trac.PRM_Current_Step__c=1; 
        trac.PRM_Account__c = null;
        trac.PRM_Integration_Log__c = intLog.Id;
        tracklsi.add(trac);
        PRM_Registration_Tracker__c trac2=new PRM_Registration_Tracker__c();
        trac2.Stage__c='2';
        trac2.PRM_Registration__c=newRegistrationRequest11.Id;
        trac2.PRM_Step_Number__c=2;
        trac2.PRM_Email__c='testrequest@maildrop.cc';
        trac2.PRM_Current_Step__c=2; 
        trac2.PRM_Account__c = null;
        trac2.PRM_Integration_Log__c = intLog.Id;
        tracklsi.add(trac2);       
        
        PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='3';
        trac3.PRM_Registration__c=newRegistrationRequest11.Id;
        trac3.PRM_Step_Number__c=3;
        trac3.PRM_Email__c='testrequest@maildrop.cc';
        trac3.PRM_Current_Step__c=3;
        trac3.PRM_Account__c = null;
        trac3.PRM_Integration_Log__c = intLog.Id;
        tracklsi.add(trac3);
        
        PRM_Registration_Tracker__c trac4=new PRM_Registration_Tracker__c();
        trac4.Stage__c='4';       
        trac4.PRM_Step_Number__c=4;
        trac4.PRM_Email__c='testrequest@intel.com';
        trac4.PRM_Account__c = null;
        trac4.PRM_Integration_Log__c = intLog.Id;
        tracklsi.add(trac4);
        
        insert tracklsi;
        //Test.startTest();
        Profile P =[select Id from Profile where Name = 'Sales Rep-BB' ];
        User itAdminUser = new User(Alias = 'itAdm21',   Email='testrequest@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
       // insert itAdminUser;
        
        set<string> regid=new set<string>();
        set<string> emailid=new set<string>();
        regid.add(newRegistrationRequest11.id);
        emailid.add('testrequest@intel.com');
        //Test.startTest();
        //Test.stopTest(); 
        PRM_RegistrationTrackerUtility.medata=PRM_RegistrationTrackerUtility.getmetadatafortestclass('PRM_Account_Contact_Profiles');
         Assert.isNotNull(PRM_RegistrationTrackerUtility.medata);
        PRM_RegistrationTrackerUtility.getregWithTrackersforGetProfileAPI(conemail,null,'PRM_Account_Contact_Profiles');
        PRM_RegistrationTrackerUtility.CheckUserLoginHistory(reglistt);
        PRM_RegistrationTrackerUtility.RegistrationWrapper wrap= PRM_RegistrationTrackerUtility.getTrackers(reglistt[0].Id);
         Assert.isNotNull(wrap);
        Test.stopTest(); 
        
    }
    
    @isTest static void getprofileTest33(){
        set<string> conemail=new set<string>();
        conemail.add('testrequest@maildrop.cc');
        list<PRM_Registration_Request__c> reglistt=new list<PRM_Registration_Request__c>();
        list<PRM_Registration_Tracker__c> tracklsi=new list<PRM_Registration_Tracker__c>();
        PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        ChannelProgram  cp=[select id from ChannelProgram where PRM_programCode__c='IPA' limit 1]; 
        newRegistrationRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest11.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Status__c = 'New';
        newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest11.PRM_Email_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Country__c = 'US';
        newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest11.PRM_Channel_Program__c = cp.Id;
       // insert newRegistrationRequest11;
        
        reglistt.add(newRegistrationRequest11);
        PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
        trac.Stage__c='1';
        trac.PRM_Email__c='testrequest@maildrop.cc';
        trac.PRM_Registration__c=newRegistrationRequest11.Id;
        trac.PRM_Step_Number__c=1;
        trac.PRM_Current_Step__c=1;       
        tracklsi.add(trac);
        PRM_Registration_Tracker__c trac2=new PRM_Registration_Tracker__c();
        trac2.Stage__c='2';
        trac2.PRM_Registration__c=newRegistrationRequest11.Id;
        trac2.PRM_Step_Number__c=2;
        trac2.PRM_Email__c='testrequest@maildrop.cc';
        trac2.PRM_Current_Step__c=2;       
        tracklsi.add(trac2);
        
        PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='34';
        trac3.PRM_Registration__c=newRegistrationRequest11.Id;
        trac3.PRM_Step_Number__c=5;
        trac3.PRM_Email__c='testrequest@maildrop.cc';
        trac3.PRM_Current_Step__c=34;       
        tracklsi.add(trac3);
        insert tracklsi;
        set<string> regid=new set<string>();
        set<string> emailid=new set<string>();
        regid.add(newRegistrationRequest11.id);
        emailid.add('testrequest@maildrop.cc');
        Test.startTest();
        PRM_RegistrationTrackerUtility.medata=PRM_RegistrationTrackerUtility.getmetadatafortestclass('PRM_Account_Contact_Profiles');
        Assert.isNotNull(conemail);
        PRM_RegistrationTrackerUtility.getregWithTrackersforGetProfileAPI(conemail,null,'PRM_Account_Contact_Profiles');
        
        Test.stopTest(); 
    }
    
    @isTest static void regTrackerTest(){
        set<string> conemail=new set<string>();
        conemail.add('testrequest@maildrop.cc');
        list<PRM_Registration_Request__c> reglistt=new list<PRM_Registration_Request__c>();
        list<PRM_Registration_Tracker__c> tracklsi=new list<PRM_Registration_Tracker__c>();
        PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest11.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Status__c = 'New';
        newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest11.PRM_Email_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Country__c = 'US';
        newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest11.PRM_EmailVerifiedDateTime__c=system.now();
        newRegistrationRequest11.PRM_Auto_Approve__c = true;
       // insert newRegistrationRequest11;
        contact con=[select id, email from contact where email='testrequest@mailinator.com' limit 1];
        Test.startTest();
        Account acc=[select id from Account where Name='attempet' limit 1];
        
        Contact con2 = PRM_TestUtility.getContact();
        con2.Email='testrequasaest@maildrop.cc';
        con2.AccountId = acc.Id;
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';
        con2.Core_IPA_PartnerRole__c = 'Service Provider';
        con2.Core_Login_Id__c = 'addbc';
        con2.mailingcountry='India';
        insert con2;
        PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
        trac.Stage__c='1';
        trac.PRM_contact__c=con2.Id;
        trac.PRM_Step_Number__c=1;
        trac.PRM_Current_Step__c=1; 
        trac.PRM_Email__c='testrequasaest@maildrop.cc';   
        tracklsi.add(trac);
        PRM_Registration_Tracker__c trac2=new PRM_Registration_Tracker__c();
        trac2.Stage__c='2';
        trac2.PRM_contact__c=con2.Id;
        trac2.PRM_Step_Number__c=2;
        trac2.PRM_Current_Step__c=2;
        trac2.PRM_Email__c='testrequasaest@maildrop.cc';       
        tracklsi.add(trac2);
        
        PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='3';
        trac3.PRM_contact__c=con2.Id;
        trac3.PRM_Step_Number__c=3;
        trac3.PRM_Current_Step__c=3; 
        trac3.PRM_Email__c='testrequasaest@maildrop.cc';             
        tracklsi.add(trac3);
        insert tracklsi;
        set<string> conids=new set<string>();
        set<string> regid=new set<string>();
        conids.add(con.Id);
        PRM_Registration_Request__c reg=[select id,Sync_Profile_Response__c,recordtype.developername,PRM_Auto_Approve__c,PRM_Status__c,PRM_Salesforce_ID__c,PRM_Matching_Contact__c,PRM_Email_Verification_Criteria__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Log__c,PRM_Email_ID__c,PRM_Email_Log__r.Email_Template_Name__c from PRM_Registration_Request__c  where PRM_Email_ID__c='testuser1@gmail.com' limit 1];
       Assert.isNotNull(reg);
        reglistt.add(reg);
        regid.add(reg.Id);
        
        conemail.add('testrequest@maildrop.cc');
        ChannelProgram  cp=[select id from ChannelProgram where PRM_programCode__c='IPA' limit 1]; 
        
        PRM_Registration_Request__c newRequest1 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest1.PRM_CIM_ID__c='';
        newRequest1.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest1.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest1.PRM_Email_ID__c = 'testrequest@mailinator.com';
        newRequest1.PRM_Channel_Program__c = cp.Id;
        newRequest1.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest1.PRM_Partner_Relationship__c = '';
        newRequest1.PRM_Preferred_Language__c = '';
        newRequest1.PRM_Matching_Contact__c = con2.Id;
        newRequest1.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRequest1.PRM_Salesforce_ID__c = acc.Id;
        newRequest1.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest1.PRM_Subscriptions__c = 'PRDSOLCOM;TRAWEBCOM;POINTCOM;EVENTCOM;PARRESCOM;MEMBCOM';
        newRequest1.PRM_Profile_Response__c = 'test pr';
        newRequest1.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest1.PRM_Status__c='New';
        newRequest1.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
        insert(newRequest1); 
        
        reglistt.add(newRegistrationRequest11);   
        reglistt.add(newRequest1);          
        
        //Test.startTest();
        map<string, list<PRM_Registration_Tracker__c>> emailTrackerMap= PRM_RegistrationTrackerUtility.getRegistrationTracker(conids);
        assert.isNotNull(emailTrackerMap);
        System.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (reglistt,null,false,false));
        
        System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(null,conids,'1212','PRM_EntitlementUtility','Self'));
        PRM_RegistrationTrackerUtility.RegistrationWrapper wrr=new PRM_RegistrationTrackerUtility.RegistrationWrapper();
        wrr.previousStepNo='';
        wrr.GetProfile=false;
        wrr.SBC_Callout_Made=false;
        wrr.EV_Completed=false;
        wrr.Login_Mail_Sent=false;
        wrr.Login_Mail_UnSent=false;
        wrr.Approved_with_Error=false;
        wrr.sameAPICall=false;
        wrr.Benefit_Assigned=false;
        wrr.Entitlement_Assigned=false;
        wrr.Welcome_Email_Unsent=false;
        wrr.User_Logged_into_Partner_Portal=false;
        wrr.User_Yet_to_login=false;
        wrr.ACR_Yet_to_Assign=false;
        wrr.regInitiated=false;
        wrr.dupcheck=false;
        wrr.Invite_UnSent=false;
        wrr.Invite_Sent=false;
        wrr.Invite_Pending=false;
        wrr.Invite_Completed=false;
        wrr.Ack_Mail_Sent=false;
        wrr.admin=false;
        wrr.ackmail=false;
        wrr.Subscription_Yet_to_Assign=true;
        wrr.classname='cc';
        wrr.Welcome_Email_Sent=true;
        wrr.manulApproval=false;
        wrr.agsid=false;
        Test.stopTest(); 
    }
    
    @isTest static void regTrackerTest22(){
        set<string> conemail=new set<string>();
        conemail.add('testrequest@maildrop.cc');
        list<PRM_Registration_Tracker__c> tracklsi=new list<PRM_Registration_Tracker__c>();
        
        contact con=[select id, email from contact where email='testrequest@mailinator.com' limit 1];
        PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
        trac.Stage__c='1';
        trac.PRM_contact__c=con.Id;
        trac.PRM_Step_Number__c=1;
        trac.PRM_Current_Step__c=1; 
        trac.PRM_Email__c='testrequest@mailinator.com';             
        tracklsi.add(trac);
        PRM_Registration_Tracker__c trac2=new PRM_Registration_Tracker__c();
        trac2.Stage__c='2';
        trac2.PRM_contact__c=con.Id;
        trac2.PRM_Step_Number__c=2;
        trac2.PRM_Current_Step__c=2;
        trac2.PRM_Email__c='testrequest@mailinator.com';       
        tracklsi.add(trac2);
        
        PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='3';
        trac3.PRM_contact__c=con.Id;
        trac3.PRM_Step_Number__c=3;
        trac3.PRM_Current_Step__c=3; 
        trac3.PRM_Email__c='testrequest@mailinator.com';             
        tracklsi.add(trac3);
        insert tracklsi;
        set<string> conids=new set<string>();
        conids.add(con.Id);
        conemail.add('testrequest@mailinator.com');
        Test.startTest();
        Assert.isNotNull(conemail);
        PRM_RegistrationTrackerUtility.medata=PRM_RegistrationTrackerUtility.getmetadatafortestclass('PRM_Account_Contact_Profiles');
        PRM_RegistrationTrackerUtility.getregWithTrackersforGetProfileAPI(conemail,null,'PRM_Account_Contact_Profiles');
        
        Test.stopTest(); 
    }
    @isTest static void getprofileTest22(){
        set<string> conemail=new set<string>();
        conemail.add('testrequest@maildrop.cc');
        list<PRM_Registration_Tracker__c> tracklsi=new list<PRM_Registration_Tracker__c>();
        contact con=[select id, email from contact where email='testrequest@mailinator.com' limit 1];
        PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
        trac.Stage__c='1';
        trac.PRM_contact__c=con.Id;
        trac.PRM_Step_Number__c=1;
        trac.PRM_Current_Step__c=1; 
        trac.PRM_Email__c='testrequest@mailinator.com';             
        tracklsi.add(trac);
        PRM_Registration_Tracker__c trac2=new PRM_Registration_Tracker__c();
        trac2.Stage__c='2';
        trac2.PRM_contact__c=con.Id;
        trac2.PRM_Step_Number__c=2;
        trac2.PRM_Current_Step__c=2;
        trac2.PRM_Email__c='testrequest@mailinator.com';       
        tracklsi.add(trac2);
        
        PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='34';
        trac3.PRM_contact__c=con.Id;
        trac3.PRM_Step_Number__c=5;
        trac3.PRM_Current_Step__c=34; 
        trac3.PRM_Email__c='testrequest@mailinator.com';             
        tracklsi.add(trac3);
        insert tracklsi;
        set<string> conids=new set<string>();
        conids.add(con.Id);
        conemail.add('testrequest@mailinator.com');
        Test.startTest();
        Assert.isNotNull(conemail);
        Assert.isNotNull(conids);
        PRM_RegistrationTrackerUtility.medata=PRM_RegistrationTrackerUtility.getmetadatafortestclass('PRM_Account_Contact_Profiles');
        PRM_RegistrationTrackerUtility.getregWithTrackersforGetProfileAPI(conemail,null,'PRM_Account_Contact_Profiles');
        Test.stopTest(); 
        
    }
    
    @isTest static void testRegHandler(){
        Map<String, String> defaultPartnerRoleBizType = new Map<String, String>();

        Map<String,PRM_PartnerRoleTypeMappings__mdt> mdRecrds = PRM_PartnerRoleTypeMappings__mdt.getAll();
       for(PRM_PartnerRoleTypeMappings__mdt Temp : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c from PRM_PartnerRoleTypeMappings__mdt where Grouping_Method__c != null]){
                defaultPartnerRoleBizType.put(Temp.PRM_Partner_Role__c,Temp.PRM_Biz_Org_Type__c);
        }
        
        Test.startTest();
        ChannelProgram ipaProgram = [SELECT Id, Name,PRM_programCode__c from ChannelProgram where Name = 'Intel Partner Alliance' LIMIT 1];
        
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John TesData';
        testAccount.BillingCity='Pune';
        testAccount.BillingStreet='TStreet';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='65565';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=testAccount.Id;
        membership1.PRM_Status_Nm__c = 'Pending';
        membership1.PRM_Status_Reason_Txt__c ='Pending';
        membership1.PRM_Channel_Program_Id__c = ipaProgram.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        insert membership1;
        acmList.add(membership1);
        
        List<PRM_Registration_Request__c> regRequestList = new List<PRM_Registration_Request__c>();
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest11.RecordTypeId = accCreateRequestId;
        newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest11.PRM_Contact_Login_ID__c = 'testrequest55@maildrop.cc';
        newRegistrationRequest11.PRM_Status__c = 'New';
        newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest11.PRM_Email_ID__c = 'testrequest55@maildrop.cc';
        newRegistrationRequest11.PRM_Country__c = 'US';
        newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest11.PRM_EmailVerifiedDateTime__c=system.now();
        newRegistrationRequest11.PRM_Salesforce_ID__c = testAccount.Id;
        newRegistrationRequest11.PRM_Auto_Approve__c = true;
        insert newRegistrationRequest11;
        
        Map<Id, PRM_Registration_Request__c> oldRegRequestMap = new Map<Id, PRM_Registration_Request__c>();
        oldRegRequestMap.put(newRegistrationRequest11.Id, newRegistrationRequest11);
        
        newRegistrationRequest11.PRM_City__c = 'test';        
        update newRegistrationRequest11; 
        regRequestList.add(newRegistrationRequest11); 
        
        
        PRM_RegistrationRequestUtility.updateBizAndPartnerRole(regRequestList, oldRegRequestMap, acmList, defaultPartnerRoleBizType);
    Test.stopTest();         
    }
    @isTest
    public static void coverOtherClass(){
        List<Contact> conList = [SELECT id FROM CONTACT];
        Test.startTest();
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Intel Premier Support', Name='Intel Premier Support', Is_Active__c = true);
        insert business;
        List<Contact_Business_Types__c> cbtList = new List<Contact_Business_Types__c>();
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = conList[0].Id, Business_Types__c= business.Id,Status__c = 'Approval - Pending');
        cbtList.add(bType);
        insert cbtList;
        cbtList[0].Status__c = 'Approved';
        update cbtList;
        /*Contact_Business_Types__c bType1 = new Contact_Business_Types__c(Contact__c = conList[0].Id, Business_Types__c= business.Id,Status__c ='Approval - Pending');
        cbtList.add(bType1);
       */
        Test.stopTest();
        Map<Id,Contact_Business_Types__c> cbtMap = new Map<Id,Contact_Business_Types__c>();
        cbtMap.put(cbtList[0].id,cbtList[0]);
        /*Test.startTest();
        ER_RegistrationUtility.autoApproveRegReq(new List<Contact_Business_Types__c>{cbtList[0]},cbtMap);
        ER_RegistrationUtility.getBusinessTypesByEntitlementNames(new Set<String>{'Points Redeem'});
        Test.stopTest();*/ 
    }
    
     @isTest
    static void testShouldBypassBlockedDomainCheck() {

        Core_CustomMetadata_Object__c headerRec = new Core_CustomMetadata_Object__c();
        headerRec.Program__c = 'IPA';
        headerRec.DeveloperName__c = 'DeveloperName';
        headerRec.Field_1_Text_Area_Long__c ='Domains__c';
        headerRec.Field_1__c = 'Country_Code__c';
        headerRec.MasterLabel__c = 'MasterLabel';
        headerRec.Metadata_Name__c = 'Country_Level_Domain_Bypass';
        insert headerRec;
        Core_CustomMetadata_Object__c indRec = new Core_CustomMetadata_Object__c();
        indRec.Program__c = 'IPA';
        indRec.DeveloperName__c = 'India';
        indRec.Field_1_Text_Area_Long__c ='gmail.com;hotmail.com';
        indRec.Field_1__c = 'IND';
        indRec.MasterLabel__c = 'India';
        indRec.Metadata_Name__c = 'Country_Level_Domain_Bypass';
        indRec.Header_row__c = headerRec.id;
        insert indRec;
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('Country_Level_Domain_Bypass');
    Map<String, Map<String, Object>> bypassRecords = customMetadata.getAll();
    Test.startTest();
    PRM_RegistrationRequestUtility.shouldBypassBlockedDomainCheck('IND','gmail.com',bypassRecords);
    Test.stopTest();
        
    }
    
     @isTest
    static void testValidateStatusChange() {
        
        //RecordType accountCreateRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'ACCOUNT_CREATE_REQUEST_RT' LIMIT 1];
       PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest11.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Status__c = 'New';
        newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest11.PRM_Email_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Country__c = 'US';
        newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest11.PRM_EmailVerifiedDateTime__c=system.now();
        newRegistrationRequest11.PRM_Auto_Approve__c = true;
       
        
        PRM_Registration_Request__c newRegistrationRequest111 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest111.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest111.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest111.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest111.PRM_Status__c = 'Approved';
        newRegistrationRequest111.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest111.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest111.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest111.PRM_Email_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest111.PRM_Country__c = 'US';
        newRegistrationRequest111.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest111.PRM_EmailVerifiedDateTime__c=system.now();
        newRegistrationRequest111.PRM_Auto_Approve__c = true;

        insert new List<PRM_Registration_Request__c>{newRegistrationRequest11, newRegistrationRequest111};

        Map<Id, PRM_Registration_Request__c> oldRegRequestMap = new Map<Id, PRM_Registration_Request__c>{
            newRegistrationRequest111.Id => newRegistrationRequest111
        };

        newRegistrationRequest11.PRM_Status__c = 'Approved';  

        List<PRM_Registration_Request__c> regRequestList = new List<PRM_Registration_Request__c>{newRegistrationRequest11};
        Test.startTest();
        try {
            PRM_RegistrationRequestUtility.validateStatusChange(regRequestList, oldRegRequestMap);
        } catch (DmlException e) {
            System.debug('Error caught: ' + e.getMessage());
        }
       // Test.stopTest();

        newRegistrationRequest11.PRM_Status__c = 'New'; 
        regRequestList = new List<PRM_Registration_Request__c>{newRegistrationRequest11};

        
        try {
            PRM_RegistrationRequestUtility.validateStatusChange(regRequestList, oldRegRequestMap);
        } catch (DmlException e) {
            System.debug('Error caught: ' + e.getMessage());
        }
        Test.stopTest();

    }

    @isTest
    static void testUtilityDirectBranchCoverage() {
        ChannelProgram ipaProgram = [SELECT Id FROM ChannelProgram WHERE Name = 'Intel Partner Alliance' LIMIT 1];
        Account acct = [SELECT Id FROM Account WHERE Name = 'attempet' LIMIT 1];
        Contact cont = [SELECT Id, Email FROM Contact WHERE Email = 'testrequest@mailinator.com' LIMIT 1];

        PRM_Registration_Request__c evRequest = PRM_TestUtility.getPRMRegistrationRequest();
        evRequest.RecordTypeId = PRM_IPA_Constants.EV_RECORD_TYPE_ID;
        evRequest.PRM_Status__c = 'New';
        evRequest.PRM_Channel_Program__c = ipaProgram.Id;
        evRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        evRequest.PRM_Salesforce_ID__c = acct.Id;
        evRequest.PRM_Contact_Login_ID__c = evRequest.PRM_Email_ID__c;
        evRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        evRequest.PRM_Profile_Response__c = 'test pr';
        evRequest.PRM_Zip_Postal_Code__c = '560037';
        evRequest.PRM_Email_Verification_Criteria__c = null;

        Test.startTest();
        PRM_RegistrationRequestUtility.evCheck(new List<PRM_Registration_Request__c>{ evRequest }, null);
        Test.stopTest();

        System.assertEquals(System.Label.PRM_Success, evRequest.PRM_Email_Verification_Criteria__c, 'EV criteria should be marked successful');
        System.assertNotEquals(null, evRequest.PRM_EV_Token_Renewed_Date__c, 'EV token renewed date should be stamped');

        PRM_Registration_Request__c validAgreementRequest = PRM_TestUtility.getPRMRegistrationRequest();
        validAgreementRequest.RecordTypeId = PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT;
        validAgreementRequest.PRM_Status__c = 'New';
        validAgreementRequest.PRM_Email_ID__c = 'valid-agreement@mailinator.com';
        validAgreementRequest.PRM_Contact_Login_ID__c = validAgreementRequest.PRM_Email_ID__c;
        validAgreementRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        validAgreementRequest.PRM_Salesforce_ID__c = acct.Id;
        validAgreementRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        validAgreementRequest.PRM_Legal_Agreement_Criteria__c = Label.PRM_Pending;
        validAgreementRequest.PRM_Channel_Program__c = ipaProgram.Id;
        validAgreementRequest.PRM_Profile_Response__c = 'test pr';
        validAgreementRequest.PRM_Zip_Postal_Code__c = '560037';

        PRM_Registration_Request__c invalidAgreementRequest = PRM_TestUtility.getPRMRegistrationRequest();
        invalidAgreementRequest.RecordTypeId = PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT;
        invalidAgreementRequest.PRM_Status__c = 'New';
        invalidAgreementRequest.PRM_Email_ID__c = 'invalid-agreement@mailinator.com';
        invalidAgreementRequest.PRM_Contact_Login_ID__c = invalidAgreementRequest.PRM_Email_ID__c;
        invalidAgreementRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        invalidAgreementRequest.PRM_Salesforce_ID__c = acct.Id;
        invalidAgreementRequest.PRM_Legal_Agreements__c = 'DOES_NOT_EXIST';
        invalidAgreementRequest.PRM_Legal_Agreement_Criteria__c = Label.PRM_Pending;
        invalidAgreementRequest.PRM_Channel_Program__c = ipaProgram.Id;
        invalidAgreementRequest.PRM_Profile_Response__c = 'test pr';
        invalidAgreementRequest.PRM_Zip_Postal_Code__c = '560037';

        PRM_RegistrationRequestUtility.updateLA(new List<PRM_Registration_Request__c>{ validAgreementRequest, invalidAgreementRequest });
        System.assertEquals('SUCCESS', validAgreementRequest.PRM_Legal_Agreement_Criteria__c, 'Known legal agreement should pass');
        System.assertEquals('FAIL', invalidAgreementRequest.PRM_Legal_Agreement_Criteria__c, 'Unknown legal agreement should fail');

        PRM_Registration_Request__c acrRequest = PRM_TestUtility.getPRMRegistrationRequest();
        acrRequest.RecordTypeId = PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT;
        acrRequest.PRM_Status__c = 'New';
        acrRequest.PRM_Channel_Program__c = ipaProgram.Id;
        acrRequest.PRM_Email_ID__c = cont.Email;
        acrRequest.PRM_Contact_Login_ID__c = cont.Email;
        acrRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        acrRequest.PRM_Partner_Role__c = 'Service Provider';
        acrRequest.PRM_Salesforce_ID__c = acct.Id;
        acrRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        acrRequest.PRM_Profile_Response__c = 'test pr';
        acrRequest.PRM_Zip_Postal_Code__c = '560037';

        PRM_Account_Contact_Relationship__c acr = [
            SELECT Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Email, PRM_Partner_Role__c
            FROM PRM_Account_Contact_Relationship__c
            WHERE PRM_Contact_Id__c = :cont.Id
            LIMIT 1
        ];
        //acr.PRM_Account_Id__c = acct.Id;
        //acr.PRM_Partner_Role__c = 'Service Provider';

        Map<Id, sObject> acrsToUpdate = PRM_RegistrationRequestUtility.getACRToUpdate(
            new Map<Id, PRM_Account_Contact_Relationship__c>{ acr.Id => acr },
            new Map<String, PRM_Registration_Request__c>{ cont.Email => acrRequest }
        );
        System.assertEquals(1, acrsToUpdate.size(), 'Matching ACR should be returned for update');
        PRM_Account_Contact_Relationship__c updatedAcr = (PRM_Account_Contact_Relationship__c) acrsToUpdate.get(acr.Id);
        System.assertEquals('Complete', updatedAcr.PRM_Status_Nm__c, 'Matching ACR should be completed');
        System.assertEquals(true, updatedAcr.PRM_No_Email__c, 'Matching ACR should suppress duplicate email');
    }

    @isTest
    static void testBypassBlockedDomainNegativeCases() {
        Map<String, Map<String, Object>> bypassRecords = new Map<String, Map<String, Object>>{
            'India' => new Map<String, Object>{
                'Country_Code__c' => 'IND;USA',
                'Domains__c' => 'gmail.com;hotmail.com'
            }
        };

        System.assertEquals(true, PRM_RegistrationRequestUtility.shouldBypassBlockedDomainCheck('IND', 'gmail.com', bypassRecords), 'Configured country and domain should bypass');
        System.assertEquals(false, PRM_RegistrationRequestUtility.shouldBypassBlockedDomainCheck('IND', 'intel.com', bypassRecords), 'Unconfigured domain should not bypass');
        System.assertEquals(false, PRM_RegistrationRequestUtility.shouldBypassBlockedDomainCheck(null, 'gmail.com', bypassRecords), 'Null country should not bypass');
        System.assertEquals(false, PRM_RegistrationRequestUtility.shouldBypassBlockedDomainCheck('IND', null, bypassRecords), 'Null domain should not bypass');
        System.assertEquals(false, PRM_RegistrationRequestUtility.shouldBypassBlockedDomainCheck('IND', 'gmail.com', null), 'Null bypass map should not bypass');
    }
    
    @isTest
	static void testAdminDomainFeatureFlagCoverage() {

    Account acct = [SELECT Id,
                           Core_Intel_Partner_Alliance_PartnerGroup__c,
                           Core_Deactivated__c
                    FROM Account
                    LIMIT 1];

    Contact con = [SELECT Id, Email, AccountId
                   FROM Contact
                   LIMIT 1];

    PRM_Registration_Request__c req = new PRM_Registration_Request__c();

    req.RecordTypeId = PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT;
    req.PRM_Status__c = 'New';
    req.PRM_Email_Verification_Criteria__c = 'SUCCESS';
    req.PRM_Email_ID__c = 'someone@testdomain.com'; // NOT mailinator.com
    req.PRM_Salesforce_ID__c = acct.Id;
    req.PRM_Subscriptions__c =LabelConfiguration__mdt.getInstance('PRM_Subscription_Mapping').Value__c.replace(',', ';');

    List<PRM_Registration_Request__c> reqs =new List<PRM_Registration_Request__c>{req};

    Map<String,Boolean> isSysAccMap = new Map<String,Boolean>();

    Map<Id,List<Contact>> mapAccContacts =
        new Map<Id,List<Contact>>{
            acct.Id => new List<Contact>{con}
        };

    Map<Id,Account> mapAccount =
        new Map<Id,Account>{
            acct.Id => acct
        };

    List<PRM_AccountChannelMembership__c> acms =[SELECT Id,
                PRM_Account_Id__c,
                PRM_Partner_Role__c,
                PRM_Status_Nm__c,
                PRM_Account_Id__r.Core_Deactivated__c
         FROM PRM_AccountChannelMembership__c
         WHERE PRM_Account_Id__c = :acct.Id
         LIMIT 1];

    Test.startTest();

    PRM_RegistrationRequestUtility.autoApproveEndUserRegistration(
        reqs,
        null,
        isSysAccMap,
        mapAccContacts,
        mapAccount,
        acms
    );

    Test.stopTest();
	}
    
	}