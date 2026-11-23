@isTest
public class PRM_Contact_AGS_CallbackHandler_Test {
	
    @isTest
    private static void AGSCallbackHandler_Test(){
        
        Account acc = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                              Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        insert acc;
        
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        List<Contact> contacts = new List<Contact>();
        Contact cnt1 = new Contact(Core_Enterprise_Id__c = '12345', Core_Login_Id__c = '123456',Core_Preferred_Language__c='ENG',MailingCountry='United States',FirstName='Test',LastName='Contact1',Email='test12345@mailinator.com',AccountId=acc.Id, MailingCity='San Jose',MailingPostalCode='123456',RecordTypeId=IntelContRecTypeId,Core_IPA_Partner_Role__c='Service Provider');
        contacts.add(cnt1);
        
        Contact cnt2 = new Contact(Core_Enterprise_Id__c = '12345678', Core_Login_Id__c = '12345678',Core_Preferred_Language__c='SPA',FirstName='Test1',LastName='Contact12',Email='test12345678@mailinator.com',AccountId=acc.Id, MailingCity='delhi1',MailingCountry='India',MailingPostalCode='12345633',RecordTypeId=IntelContRecTypeId,Core_IPA_Partner_Role__c='FPGA Designer');
        contacts.add(cnt2);
        
        Contact cnt3 = new Contact(Core_Enterprise_Id__c = '1234567899', Core_Login_Id__c = '1234567899',Core_Preferred_Language__c='SPA',FirstName='Test12',LastName='Contact123',Email='test1234567899@mailinator.com',AccountId=acc.Id, MailingCity='delhi1',MailingCountry='India',MailingPostalCode='12345633',RecordTypeId=IntelContRecTypeId,Core_IPA_Partner_Role__c='Distributor');
        contacts.add(cnt3);
        
        Contact cnt4 = new Contact(Core_Enterprise_Id__c = '1234567890', Core_Login_Id__c = '1234567890',Core_Preferred_Language__c='SPA',FirstName='Test123',LastName='Contact1234',Email='test1234567890@mailinator.com',AccountId=acc.Id, MailingCity='delhi1',MailingCountry='India',MailingPostalCode='12345633',RecordTypeId=IntelContRecTypeId);
        contacts.add(cnt4);
        insert contacts;
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Member',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        List<PRM_AccountChannelMembership__c> acms = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=acc.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Pending');
		acms.add(acm1);  
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=acc.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='FPGA Designer',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved');
		acms.add(acm2);
        
        insert acms;
        
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Primary Contact';
        contRel.PRM_Contact_Relationship_Cd__c = 'CONTRELPRIMARY';
        insert contRel;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = acc.Id;
        acr.PRM_Contact_Id__c = cnt1.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Contact/AGSCallBackHandler/';
        request.httpMethod = 'POST';
        
        //Condition of Email
        String reqBody = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "test12345@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage strJSON = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.debug('strJSON ==>'+strJSON);
        system.assert(strJSON.msg.indexOf('Contact updated successfully') > -1 );
        
        //Condition of Email
        reqBody = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Contact_AGS_CallbackHandler.OutputMessage OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(strJSON.msg.indexOf('Contact updated successfully') > -1 );
        
        //Condition of Email
        reqBody = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "", "EmailVerificationDateTime" : "" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.msg.indexOf('Contact updated successfully') > -1 );
        
        //Condition of Enterprise id
        reqBody = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.msg.indexOf('Contact updated successfully') > -1 );
                
        reqBody = '{"EnterpriseID" : "12345", "LoginID" : "", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.msg.indexOf('Contact updated successfully') > -1 );
        
        reqBody = '{"EnterpriseID" : "12345", "LoginID" : "", "EmailID" : "test1234567899@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );        
         
        //Condition of No Enterprise id
        reqBody = '{"EnterpriseID" : "", "LoginID" : "123456", "EmailID" : "", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );
        
        //No COntact Found
        reqBody = '{"EnterpriseID" : "12121221", "LoginID" : "121212wwewe", "EmailID" : "", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );   
        
        //Passing non JSON String
        reqBody = '{"EnterpriseID" : "12121221, "LoginID" : "121212wwewe", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "2019-06-27 14:26:44" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );
        
        reqBody = '{"EnterpriseID" : "12345", "LoginID" : "123456", "EmailID" : "test1234567890@mailinator.com", "EVPasswordToken" : "wwerersdasdweer34454dfgdsdfsd", "EmailVerificationDateTime" : "2019-06-27 14:26:44" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );
        
        //Passing non JSON String
        reqBody = '{"EnterpriseID" : "12121221, "LoginID" : "121212wwewe", "EmailID" : "test12345678@mailinator.com", "EVPasswordToken" : "12345qwerty", "EmailVerificationDateTime" : "2019-06-27 14:26:44" }';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        OutputMessage = PRM_Contact_AGS_CallbackHandler.AGSCallbackHandler();
        system.assert(OutputMessage.success == false );
        
    }
}