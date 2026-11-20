/*********************************************************************************************************************
Class Name  : PRM_RegistrationApprovalMail_Test
    Version       : 1.0
    Created Date  : 12th JUNE,2020
    Function      : Test Class for 'PRM_RegistrationApprovalEmail' and 'PRM_RegistrationApprovalEmailSchedule'
    
Modification Log :
     * Developer                          Date                    Description
 * ----------------------------------------------------------------------------------------------
 * Pratik Sanganeria               12/06/2020              Test Class for RegApprovalEmail class and batch class
 * Srishty Sharma                  02/11/2020              US821810: KIIT Secondary user created from PCR tab for the existing account- Welcome email is received twice.
 *********************************************************************************************************************/

@isTest
private class PRM_RegistrationApprovalMail_Test {
    @testSetup
    private static void createData()
    {
        Id accountRecordTypeOpid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        // Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        Account opid = PRM_TestUtility.getAccount();
        opid.AccountNumber = '435710 -OPID';
        opid.RecordTypeId = accountRecordTypeOpid;
        opid.Name='New Account - OPID';
        opid.Core_Account_Type__c ='Distributor';
        opid.Industry='Agriculture';
        opid.BillingCity='New Delhi';
        opid.BillingCountryCode='IND';
        opid.BillingStreet='4th Floor,New Road';
        opid.BillingPostalCode='110037';
        opid.BillingStateCode='KA';
        opid.Core_IPA_Partner_Role__c = 'Distributor';
        opid.Core_IPA_Badge_Tier__c = 'Partner';
        insert opid;
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        // Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435710';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.Core_IPA_One_Partner_Id__c = opid.Id;
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Distributor';
        a.Core_IPA_Badge_Tier__c = 'Partner';
        insert a;
        
        
        // benefit assignment
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Partner University1';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb1.PRM_Account_Type_Nm__c = 'Both';
        insert pb1;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = opid.Id;
        aba.PRM_Partner_Benefit_Id__c = pb1.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c ='TEst';
        insert aba;
        
        List<Contact> conList = new List<Contact>();
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='user.check@maildrop.cc';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        //   c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = false;
        // c.Core_IPA_Partner_Role__c = 'Distributor';
        c.Core_IPA_PartnerRole__c = 'Distributor';
        c.Core_Login_Id__c = 'abc';
        conList.add(c);
        
        Contact con = new Contact();
        con.FirstName='Mattwelcome';
        con.LastName='Smithemail';
        //con.Email='testrequest@mailinator.com';
        con.Phone='9999779791';
        con.Core_IPA_PartnerRole__c = 'Service Provider'; //'Seller';
        con.AccountId = a.Id;
        con.Email='usercheckwe@example.com';
        con.MailingCountryCode = 'CHN';
        con.Core_Preferred_Language__c = 'ENG';
        con.Core_eRPM_Language_Code__c = 'ENG';
        con.Core_Do_Not_Contact__c = false;
        con.Core_IPA_PartnerRole__c = 'Distributor';
        con.Core_Login_Id__c = 'abc';
        conList.add(con);
        
        insert conList;
        
        Profile P =[select Id from Profile where Name = 'Partner' ];
        User itAdminUser = new User(Alias = 'itAdm21', ContactId=con.Id, Email='usercheckwe@example.com',
        EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
        LanguageLocaleKey='en_US',  LocaleSidKey='en_US',
        ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles',
        UserName='usercheckwe@example.com');
        
        insert itAdminUser;
        List<PRM_ContactRelationships__c> lstConRelation = new List<PRM_ContactRelationships__c>();
        
        PRM_ContactRelationships__c cr3 = new PRM_ContactRelationships__c(Name = 'Employee',PRM_Contact_Relationship_Cd__c = 'WORKSFOR');
        lstConRelation.add(cr3);
        
        insert lstConRelation;
        
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_Relationship_Id__c = cr3.Id;
        acr.PRM_InActive_Ind__c = true;
        acr.PRM_Status_Reason_Txt__c = 'Test Class';
        acrList.add(acr);
        
        PRM_Account_Contact_Relationship__c acrWelcomeemail = new PRM_Account_Contact_Relationship__c();
        acrWelcomeemail.PRM_Account_Id__c = a.Id;
        acrWelcomeemail.PRM_Contact_Id__c = con.Id;
        acrWelcomeemail.PRM_Relationship_Id__c = cr3.Id;
        acrWelcomeemail.PRM_InActive_Ind__c = true;
        acrWelcomeemail.PRM_Status_Reason_Txt__c = 'Test Class';
        acrList.add(acrWelcomeemail);
        
        insert acrList;
        
        // ChannelProgram channelPrg = new ChannelProgram();
        // channelPrg.name='Intel Partner Alliance';
        // channelPrg.PRM_programCode__c='IPA';
        // channelPrg.PRM_inactind__c=true;
        // insert channelPrg;
        
        List<PRM_Registration_Request__c> listregReq = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = a.Id;
        prmRegRequest.PRM_Channel_Program__c =cp.Id;
        prmRegRequest.PRM_Partner_Role__c='Distributor';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@mailinator.com';
        //prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Profession__c='PROFESSOR';
        prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        listregReq.add(prmRegRequest);
        
        
        
        PRM_Registration_Request__c prmRegRequest1 = new PRM_Registration_Request__c();
        prmRegRequest1.Name = 'welcomeEmail';
        prmRegRequest1.PRM_Salesforce_ID__c = a.Id;
        prmRegRequest1.PRM_Channel_Program__c =cp.Id;
        prmRegRequest1.PRM_Partner_Role__c='Distributor';
        prmRegRequest1.PRM_First_Name__c='welcome';
        prmRegRequest1.PRM_Last_Name__c='Emailuser';
        prmRegRequest1.PRM_Email_ID__c='usercheckwelcome@maildrop.cc';
        //prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest1.PRM_Profession__c='PROFESSOR';
        prmRegRequest1.PRM_Contact_Country__c='US';
        prmRegRequest1.PRM_Legal_Agreements__c='IPA_TANDC';
        listregReq.add(prmRegRequest1);
        insert listregReq;
        
        List<Core_Entitlement__c> listent = new List<Core_Entitlement__c>();
        Core_Entitlement__c entitlement2 = new Core_Entitlement__c();
        entitlement2.Name = 'Partner Admin';
        entitlement2.Core_Display_Name__c = 'Partner Admin';
        listent.add(entitlement2);
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c();
        entitlement.Name = 'Partner Admin Delegate';
        entitlement.Core_Display_Name__c = 'Partner Admin Delegate';
        listent.add(entitlement);
        
        Core_Entitlement__c entitlement1 = new Core_Entitlement__c();
        entitlement1.Name = 'Employee';
        entitlement1.Core_Display_Name__c = 'Employee';
        listent.add(entitlement1);
        
        Core_Entitlement__c entitlementwel = new Core_Entitlement__c();
        entitlementwel.Name = 'Partner Marketing Studio';
        entitlementwel.Core_Display_Name__c = 'Partner Marketing Studio';
        listent.add(entitlementwel);
        
        Core_Entitlement__c entitlementwel2 = new Core_Entitlement__c();
        entitlementwel2.Name = 'FPGA Partner Program Member Tier Access';
        entitlementwel2.Core_Display_Name__c = 'FPGA Partner Program Member Tier Access';
        listent.add(entitlementwel2);
        
        insert listent;
        
        
        List<Core_Contact_Entitlement__c> coreContEnt = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c conEntitlement = new Core_Contact_Entitlement__c();
        conEntitlement.Core_Contact_Id__c = c.Id;
        conEntitlement.Core_Entitlement_Id__c = entitlement.Id;
        conEntitlement.Core_Status__c = 'Complete';
        conEntitlement.Core_Selected__c = true;
        coreContEnt.add(conEntitlement);
        
        Core_Contact_Entitlement__c conEntitlementwel1 = new Core_Contact_Entitlement__c();
        conEntitlementwel1.Core_Contact_Id__c = con.Id;
        conEntitlementwel1.Core_Entitlement_Id__c = entitlementwel.Id;
        conEntitlementwel1.Core_Status__c = 'Complete';
        conEntitlementwel1.Core_Selected__c = true;
        coreContEnt.add(conEntitlementwel1);
        
        Core_Contact_Entitlement__c conEntitlementwel2 = new Core_Contact_Entitlement__c();
        conEntitlementwel2.Core_Contact_Id__c = con.Id;
        conEntitlementwel2.Core_Entitlement_Id__c = entitlementwel2.Id;
        conEntitlementwel2.Core_Status__c = 'Complete';
        conEntitlementwel2.Core_Selected__c = true;
        coreContEnt.add(conEntitlementwel2);
        
        
        Core_Contact_Entitlement__c conEntitlement1 = new Core_Contact_Entitlement__c();
        conEntitlement1.Core_Contact_Id__c = con.Id;
        conEntitlement1.Core_Entitlement_Id__c = entitlement1.Id;
        conEntitlement1.Core_Status__c = 'Complete';
        conEntitlement1.Core_Selected__c = true;
        coreContEnt.add(conEntitlement1);
        
        
        Core_Contact_Entitlement__c conEntitlement2 = new Core_Contact_Entitlement__c();
        conEntitlement2.Core_Contact_Id__c = c.Id;
        conEntitlement2.Core_Entitlement_Id__c = entitlement2.Id;
        conEntitlement2.Core_Status__c = 'Complete';
        conEntitlement2.Core_Selected__c = true;
        coreContEnt.add(conEntitlement2);
        
        insert coreContEnt;
        
        PRM_EmailLog__c emailLogs = new PRM_EmailLog__c();
        emailLogs.PRM_Subject__c = 'Submitted: Your Testoffering Offering';
        emailLogs.PRM_Contact__c = con.Id;
        emailLogs.PRM_EmailContent__c = 'Email Content';
        emailLogs.PRM_User__c =UserInfo.getUserId();
        emailLogs.PRM_EmailDeliverabilityStatus__c = true;
        emailLogs.PRM_ToEmailID__c = con.email;
        emailLogs.Email_Template_Name__c = System.Label.PRM_OPID_TitaniumUpgrade_Template;
        //emailLogs.PRM_EmailHTMLContent__c = 'abc';
        
        insert emailLogs;
        
        PRM_EmailLog__c emailLogs1 = new PRM_EmailLog__c();
        emailLogs1.PRM_Subject__c = 'Congratulations on Your New Intel® Cloud Insider Status';
        emailLogs1.PRM_Contact__c = c.Id;
        emailLogs1.PRM_EmailContent__c = 'Email Content';
        emailLogs1.PRM_User__c =UserInfo.getUserId();
        emailLogs1.PRM_EmailDeliverabilityStatus__c = true;
        emailLogs1.PRM_ToEmailID__c = 'we233ffg@mailinator.com';
        
        insert emailLogs1;
        
        List<PRM_EmailQueue__c> listemailQueue = new List<PRM_EmailQueue__c>();
        PRM_EmailQueue__c emailQueue = new PRM_EmailQueue__c();
        emailQueue.PRM_Business_Event__c = System.label.PRM_Email_Admin_Approval_Event;
        emailQueue.PRM_Contact__c = con.Id;
        emailQueue.PRM_Email_Content__c = 'Email Content';
        emailQueue.PRM_IsInactive__c = false;
        emailQueue.PRM_PartnerRole__c = 'Distributor';
        emailQueue.PRM_Priority__c = 1;
        emailQueue.PRM_Registration_Request__c = prmRegRequest.Id;
        emailQueue.PRM_Status__c = 'PENDING';
        emailQueue.PRM_Tier__c = 'PARTNER';
        
        listemailQueue.add(emailQueue);
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=a.Id;
        membership1.PRM_Status_Nm__c = 'Pending';
        membership1.PRM_Status_Reason_Txt__c ='TEst';
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        membership1.PRM_Status_Reason_Txt__c = 'Test Class';
        insert(membership1);
        
        //welcome Email
        
        
        
        
        PRM_EmailQueue__c emailQueuewel = new PRM_EmailQueue__c();
        emailQueuewel.PRM_Business_Event__c = 'Welcome_email_on_request_approval_Existing';
        emailQueuewel.PRM_Contact__c = con.Id;
        emailQueuewel.PRM_Email_Content__c = 'Email Content';
        emailQueuewel.PRM_IsInactive__c = false;
        emailQueuewel.PRM_PartnerRole__c = 'Distributor';
        emailQueuewel.PRM_Priority__c = 1;
        emailQueuewel.PRM_Registration_Request__c = prmRegRequest.Id;
        emailQueuewel.PRM_Status__c = 'ERROR';
        emailQueuewel.PRM_Tier__c = 'PARTNER';
        
        listemailQueue.add(emailQueuewel);
        insert listemailQueue;
        
        List<PRM_EmailQueue__c> emailqueuList = new List<PRM_EmailQueue__c>();
        emailqueuList.add(emailQueuewel);
        PRM_RegistrationApprovalEmail.sendWelcomeEmail(emailqueuList);
    }
    @isTest
    private static void callScheduleClass() {
        
        Test.startTest();
        PRM_RegistrationApprovalEmailSchedule sh1 = new PRM_RegistrationApprovalEmailSchedule();
        String sch = '0 0 23 * * ?';
        String jobId = System.Schedule('Test Territory Check', sch, sh1);
        
        Test.stopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'Expecting one scheduled job');
        
    }
    @isTest
    private static void startMethod() {
        Test.startTest();
        PRM_RegistrationApprovalEmailSchedule sh1 = new PRM_RegistrationApprovalEmailSchedule();
        String sch = '0 01 * * * ?';
        String jobId = System.Schedule('first batch job', sch, sh1);
        PRM_RegistrationApprovalEmail sh2 = new PRM_RegistrationApprovalEmail();
        Database.executeBatch(sh2,1);
        Test.stopTest();
    }
}