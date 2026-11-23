@isTest
public class PRM_Contact_AGS_CallbackHandler_Test {
    
    @testSetup
    private static void AGSCallbackHandler_TestSetup(){
        test.startTest();
        Id IntelAcctRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'Americas US Sales Group', RecordTypeId = IntelAcctRecTypeId,
                                  Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',
                                  ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',
                                  Core_User_Defined_Website__c ='www.testPartnerAccount1.com',
                                  Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        insert acc;
        
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        List<Contact> contacts = new List<Contact>();
        Contact cnt1 = new Contact(Core_Enterprise_Id__c = '12345', Core_Login_Id__c = '123456',Core_Preferred_Language__c='ENG',FirstName='Test',LastName='Contact1',Email='test12345@mailinator.com', AccountId=acc.Id, MailingCity='San Jose',MailingPostalCode='123456',RecordTypeId=IntelContRecTypeId,Core_IPA_PartnerRole__c='Service Provider', Core_AGS_Integration_Status__c ='abc',  MailingCountryCode = 'USA',Core_AGS_Integration_Message__c ='abc');
        contacts.add(cnt1);
        
        Contact cnt2 = new Contact(Core_Enterprise_Id__c = '12345678', Core_Login_Id__c = '12345678',Core_Preferred_Language__c='SPA',FirstName='Test1',LastName='Contact12',Email='test12345678@mailinator.com',AccountId=acc.Id, MailingCity='delhi1',MailingCountry='India',MailingPostalCode='12345633',RecordTypeId=IntelContRecTypeId,Core_IPA_PartnerRole__c='Distributor', Core_AGS_Integration_Status__c ='xyz', Core_AGS_Integration_Message__c ='xyz' );
        contacts.add(cnt2);
        
        Contact cnt3 = new Contact(Core_Enterprise_Id__c = '1234567899', Core_Login_Id__c = '1234567899',Core_Preferred_Language__c='SPA',FirstName='Test12',LastName='Contact123',Email='test1234567899@mailinator.com',AccountId=acc.Id, MailingCity='delhi1',MailingCountry='India',MailingPostalCode='12345633',RecordTypeId=IntelContRecTypeId,Core_IPA_PartnerRole__c='Distributor');
        contacts.add(cnt3);
        
        Contact cnt4 = new Contact(Core_Enterprise_Id__c = '1234567890', Core_Login_Id__c = '1234567890',Core_Preferred_Language__c='SPA',FirstName='Test123',LastName='Contact1234',Email='test1234567890@mailinator.com',AccountId=acc.Id, MailingCity='delhi1',MailingCountry='India',MailingPostalCode='12345633',RecordTypeId=IntelContRecTypeId);
        contacts.add(cnt4);
        
        
        
        Contact cnt5 = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=acc.Id, Email='test1234567890@mailinator.com', Core_Enterprise_Id__c = '1234655567890', MailingCountryCode = 'USA',Core_IPA_PartnerRole__c='Distributor' );
        contacts.add(cnt5);
        
        Contact cnt6 = new Contact(Core_Enterprise_Id__c = '1234567', Core_Login_Id__c = '654321',Core_Preferred_Language__c='ENG',FirstName='Test',LastName='Contact6',Email='test654@mailinator.com', Core_IPA_Email_Verification_Date__c= System.now(), AccountId=acc.Id, MailingCity='San Jose',MailingPostalCode='123456',MailingCountryCode = 'USA',RecordTypeId=IntelContRecTypeId,Core_IPA_PartnerRole__c='Service Provider', Core_AGS_Integration_Status__c ='abc',  Core_AGS_Integration_Message__c ='abc');
        contacts.add(cnt6);
        
        Contact cnt7 = new Contact(Core_Enterprise_Id__c = '739929', Core_Login_Id__c = 'test6547@mailinator.com',Core_Preferred_Language__c='ENG',FirstName='Test',LastName='Contact7',Email='test6547@mailinator.com', Core_IPA_Email_Verification_Date__c= System.now(), AccountId=acc.Id, MailingCity='San Jose',MailingPostalCode='123456',MailingCountryCode = 'USA',RecordTypeId=IntelContRecTypeId,Core_IPA_PartnerRole__c='Service Provider', Core_AGS_Integration_Status__c ='abc',  Core_AGS_Integration_Message__c ='abc');
        contacts.add(cnt7);
        
        insert contacts;
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Partner',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        List<PRM_AccountChannelMembership__c> acms = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=acc.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Pending',PRM_Status_Reason_Txt__c='test');
        acms.add(acm1);  
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=acc.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Distributor',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved',PRM_Status_Reason_Txt__c='test');
        acms.add(acm2);
        
        insert acms;
        
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Primary Contact';
        contRel.PRM_Contact_Relationship_Cd__c = 'CONTRELPRIMARY';
        insert contRel;
        
        List<PRM_Account_Contact_Relationship__c> AccContRelList = new List<PRM_Account_Contact_Relationship__c>();
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = acc.Id;
        acr.PRM_Contact_Id__c = cnt1.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_Source_Agent__c = 'Bulk Add';
        acr.PRM_Status_Reason_Txt__c = 'Testclass run';
        
        AccContRelList.add(acr);
        
        
        PRM_Account_Contact_Relationship__c acr1  = new PRM_Account_Contact_Relationship__c();
        acr1.PRM_Account_Id__c = acc.Id;
        acr1.PRM_Contact_Id__c = cnt5.Id;
        acr1.PRM_isActive__c = True;
        acr1.PRM_Relationship_Id__c = contRel.Id;
        acr1.PRM_Source_Agent__c = 'Bulk Invite';
        acr1.PRM_Status_Nm__c = 'Complete';
        acr1.PRM_Status_Reason_Txt__c = 'Testclass run';
        AccContRelList.add(acr1);
       
        
        PRM_Account_Contact_Relationship__c acr2  = new PRM_Account_Contact_Relationship__c();
        acr2.PRM_Account_Id__c = acc.Id;
        acr2.PRM_Contact_Id__c = cnt2.Id;
        acr2.PRM_isActive__c = True;
        acr2.PRM_Relationship_Id__c = contRel.Id;
        acr2.PRM_Status_Nm__c = 'Complete';
        acr2.PRM_Status_Reason_Txt__c = 'Testclass run';
        AccContRelList.add(acr2);
        
        PRM_Account_Contact_Relationship__c acr6  = new PRM_Account_Contact_Relationship__c();
        acr6.PRM_Account_Id__c = acc.Id;
        acr6.PRM_Contact_Id__c = cnt6.Id;
        acr6.PRM_isActive__c = True;
        acr6.PRM_Relationship_Id__c = contRel.Id;
        acr6.PRM_Status_Nm__c = 'Complete';
        acr6.PRM_Status_Reason_Txt__c = 'Testclass run';
       
        AccContRelList.add(acr6);
        
        PRM_Account_Contact_Relationship__c acr7  = new PRM_Account_Contact_Relationship__c();
        acr7.PRM_Account_Id__c = acc.Id;
        acr7.PRM_Contact_Id__c = cnt7.Id;
        acr7.PRM_isActive__c = True;
        acr7.PRM_Relationship_Id__c = contRel.Id;
        acr7.PRM_Status_Nm__c = 'Complete';
        acr7.PRM_Source_Agent__c = 'Bulk Add';
        acr7.PRM_Status_Reason_Txt__c = 'Testclass run';
        
        AccContRelList.add(acr7);
        
        Insert AccContRelList;
        
        PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cnt1,'evtoken','tags');        
        PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cnt2,'','tags');
        test.stopTest();
        
    }
    
    @isTest
    private static void AGSCallbackHandler_updateContact_1(){
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Email
        String reqBody = '{"EnterpriseID" : "12345","cidaas":"true", "LoginID" : "123456", "EmailID" : "test12345@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;        
        PRM_Contact_AGS_CallbackHandler.OutputMessage strJSON = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        //system.assert(strJSON.msg.indexOf('Contact updated successfully') > -1 );
        test.stopTest();
    }     
    
    @isTest
    private static void AGSCallbackHandler_error(){
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Email
        String reqBody = '{"EnterpriseID" : "","cidaas":"true", "LoginID" : "", "EmailID" : "test12345@mailinator.com", "retryCount" : "1", "EmailVerificationDateTime" : "", "status" :"Failed" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;        
        PRM_Contact_AGS_CallbackHandler.OutputMessage strJSON = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        //system.assert(strJSON.msg.indexOf('Contact updated successfully') > -1 );
        test.stopTest();
    }     
    
     @isTest
    private static void AGSCallbackHandler_updateContact_EVCheck(){        
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Email
        String reqBody = '{"EnterpriseID" : "123456", "LoginID" : "654321", "EmailID" : "test654@mailinator.com", "EVPasswordToken" : "", "EmailVerificationDateTime" : "2019-06-27 14:26:44", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage strJSON = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        //system.assert(strJSON.msg.indexOf('Contact updated successfully') > -1 );
        test.stopTest();
    }
    @isTest
    private static void AGSCallbackHandler_updateContact_2(){
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Email
        String reqBody  = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage strJSON = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(strJSON.msg.indexOf('Contact updated successfully') >= -1 );
        test.stopTest();
        List <Contact> cont = [select id from Contact where email = 'test1234567890@mailinator.com' limit 1];
        PRM_Contact_AGS_CallbackHandler.createLogEntryNoInsert('errorMsg', 'msg detail', cont[0], null, 'error', 'PRM_Account_Contact_Relationship__c');
        
    }   
    @isTest
    private static void AGSCallbackHandler_updateContact_3(){
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Email
        String reqBody  = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage strJSON = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(strJSON.msg.indexOf('Contact updated successfully') >= -1);
        test.stopTest();
    }
    
    @isTest
    private static void AGSCallbackHandler_updateContact_4(){
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Email
        String reqBody  = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.msg.indexOf('Contact updated successfully') >= -1 );
        test.stopTest();
    }
    @isTest
    private static void AGSCallbackHandler_updateContact_5(){
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Enterprise id
        String reqBody = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        //system.assert(OutputMessage.msg.indexOf('Contact updated successfully') >= -1 );
        test.stopTest();
        
    }
    @isTest
    private static void AGSCallbackHandler_updateContact_6(){        
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        String reqBody = '{"EnterpriseID" : "12345", "LoginID" : "", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        
        system.assert(OutputMessage.msg.indexOf('Contact updated successfully') >= -1 );
        test.stopTest();
    }
    @isTest
    private static void AGSCallbackHandler_updateContact_cdt(){        
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        String reqBody = '{"EnterpriseID" : "12345", "LoginID" : "", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        
        system.assert(OutputMessage.msg.indexOf('Contact updated successfully') >= -1 );
        test.stopTest();
    }
    
    @isTest
    private static void AGSCallbackHandler_updateContact_cdt_new(){        
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
       
        String reqBody = '{"EnterpriseID" : "739929", "LoginID" : "test12345678@mailinator.com", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);    
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        
        system.assert(OutputMessage.msg.indexOf('Contact updated successfully') >= -1 );
        test.stopTest();
    }
    
    @isTest
    private static void AGSCallbackHandler_updateContact_cdt_new1(){        
        PRM_Contact_AGS_CallbackHandler.IS_DelayInviteEmail = false;
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
       
        String reqBody = '{"EnterpriseID" : "739929", "LoginID" : "test12345678@mailinator.com", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);    
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        
        system.assert(OutputMessage.msg.indexOf('Contact updated successfully') >= -1 );
        test.stopTest();
    }
    
    @isTest
    private static void AGSCallbackHandler_DoNotUpdateContact_Test(){
        test.startTest();           
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST'; 
        
        String reqBody = '{"EnterpriseID" : "", "LoginID" : "", "EmailID" : "test1234567899@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );        
        
        //Condition of No Enterprise id
        reqBody = '{"EnterpriseID" : "", "LoginID" : "123456", "EmailID" : "", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );
        
        //No COntact Found
        reqBody = '{"EnterpriseID" : "12121221", "LoginID" : "121212wwewe", "EmailID" : "", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );   
        
        //Passing non JSON String
        reqBody = '{"EnterpriseID" : "12121221, "LoginID" : "121212wwewe", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "2019-06-27 14:26:44", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );
        
        reqBody = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "test1234567890@mailinator.com", "EVPasswordToken" : "wwerersdasdweer34454dfgdsdfsd", "EmailVerificationDateTime" : "2019-06-27 14:26:44", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
       // system.assert(OutputMessage.success == false );
        
        //Passing non JSON String
        reqBody = '{"EnterpriseID" : "12121221, "LoginID" : "121212wwewe", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "2019-06-27 14:26:44", "status" :"success" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );
        test.stopTest();
        
    }
    
    @isTest
    private static void AGSCallbackHandler_updateContact_7(){
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Enterprise id
        String reqBody = '{ "EmailID" : "test1234567890@mailinator.com", "status" : "Failure" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        test.stopTest();
    }
    
    @isTest
    private static void AGSCallbackHandler_updateContact_8(){
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Enterprise id
        String reqBody = '{ "EmailID" : "test1234567890@mailinator.com", "status" : "somerandomvaluetocausefailure" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        test.stopTest();
    }
    
@isTest
    static void upsertdata(){
    Id recordTypeAccount01 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeAccount01;
        newAccount.Name='vistagun';
        newAccount.BillingCity='City4';
        newAccount.BillingStreet='Stre';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='P15299';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        newAccount.Industry = 'Agriculture';
        insert newAccount;

        ChannelProgram cp = [SELECT Id, Name,PRM_programCode__c from ChannelProgram where Name = 'Intel Partner Alliance' LIMIT 1];
       
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;

        List<PRM_AccountChannelMembership__c> listACMs = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Solution Integrator';
        acm1.PRM_Status_Reason_Txt__c='test';
        insert acm1;

        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Accruals View';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        pb.PRM_Account_Type_Nm__c = 'Mastered_Account';
        insert pb;

        List<PRM_AccountBenefitAssociation__c> benList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c ben01 = new PRM_AccountBenefitAssociation__c();
        ben01.PRM_Partner_Benefit_Id__c = pb.id;
        ben01.PRM_Status_Nm__c = 'Active';
        ben01.PRM_Account_Id__c = newAccount.id;
        ben01.PRM_Source__c = System.Label.PRM_Source_BenefitMatrix;
        ben01.PRM_Status_Reason_Txt__c = 'Testclass run';
        insert ben01;

        ben01.PRM_Status_Nm__c = 'Inactive';
        benList.add(ben01);
        PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
    }
}