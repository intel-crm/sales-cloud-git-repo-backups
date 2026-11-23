@isTest
public class PRM_AGS_IdentityCreation_Test {
    @testSetup
    private static void createData(){
        test.startTest();
         Account intelAccount = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',
                                           Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi',
                                           ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        insert intelAccount;
        
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        List<Contact> contacts = new List<Contact>();
        Contact cont = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@mailinator.com',AccountId=intelAccount.Id,Core_Login_Id__c='testcontact1@mailinator.com',
                                 /*MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456',Core_Preferred_Language__c='ENG',*/RecordTypeId=IntelContRecTypeId,
                                  Core_IPA_Partner_Role__c='Service Provider');
        Contact cont1 = new Contact(FirstName='Test1',LastName='Contact12',Email='testcontact2@mailinator.com',AccountId=intelAccount.Id,Core_Login_Id__c='testcontact2@mailinator.com',
                                 /*MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456',Core_Preferred_Language__c='ENG',*/RecordTypeId=IntelContRecTypeId,
                                  Core_IPA_Partner_Role__c='FPGA Designer',Core_Enterprise_Id__c='12123',Core_IPA_Email_Verification_Date__c=system.now());
        Contact cont2 = new Contact(FirstName='Test1',LastName='Contact12',Email='testcontact3@mailinator.com',AccountId=intelAccount.Id,Core_Login_Id__c='testcontact2@mailinator.com',
                                 /*MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456',Core_Preferred_Language__c='ENG',*/RecordTypeId=IntelContRecTypeId,
                                  Core_IPA_Partner_Role__c='FPGA Designer');
        
        
        contacts.add(cont);
        contacts.add(cont1);
        contacts.add(cont2);
        insert contacts;        
        
        test.stopTest();
    }
    
    @isTest static void createIdentityInAGS_Test(){
        test.startTest();
        Contact cont = [SELECT id,FirstName,LastName,Email,Core_Login_Id__c,MailingCountryCode,Core_Preferred_Language__c FROM Contact where Core_Login_Id__c = 'testcontact1@mailinator.com' LIMIT 1];
        System.debug('cont : '+cont);
        PRM_AGS_IdentityCreation.createIdentityInAGS(cont.Id);
        test.stopTest();
        //Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());       
    }
    
    @isTest static void createIdentityInAGS_Negative_Test(){
       test.startTest();
       Contact cont = [SELECT id,FirstName,LastName,Email,Core_Login_Id__c FROM Contact LIMIT 1];        
       PRM_AGS_IdentityCreation.createIdentityInAGS(cont.Id);
       PRM_AGS_IdentityCreation.createIdentityInAGS(null);
       test.stopTest();          
    }
    
    @isTest static void createIdentityInAGS_Test1(){
       test.startTest();
       Contact cont = [SELECT id FROM Contact LIMIT 1];  
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       PRM_AGS_IdentityCreation.createIdentityInAGS(cont.Id);
       test.stopTest();
    }
    
    @isTest static void SendEmailVerificationAndCreateIdentityInAGSTest1(){
        test.startTest();
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE Core_IPA_Partner_Role__c='Service Provider' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Primary Contact';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Works for';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        List<PRM_AccountChannelMembership__c> acms = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=intelAccount.id;
        acm.PRM_Status_Nm__c='Pending';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acms.add(acm);       
              
        insert acms;
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=intelAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=conts[0].Id;
        acr.PRM_execute_trigger__c=true;
        //insert acr;
        acrs.add(acr);
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        //insert acr1;
        acrs.add(acr1);
        insert acrs;
        test.stopTest();
    }
    
    @isTest static void SendEmailVerificationAndCreateIdentityInAGSTest2(){
        test.startTest();
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE Core_IPA_Partner_Role__c='FPGA Designer' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Primary Contact';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Works for';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        List<PRM_AccountChannelMembership__c> acms = new List<PRM_AccountChannelMembership__c>();
              
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c=intelAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='FPGA Designer';
        acms.add(acm1);        
        insert acms;
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=intelAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[0].Id;
        acr2.PRM_Contact_Id__c=conts[0].Id;
        acr2.PRM_execute_trigger__c=true;
        //insert acr;
        acrs.add(acr2);        
        
        PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr3.PRM_InActive_Ind__c= false;
        acr3.PRM_Account_Id__c=intelAccount.Id;
        acr3.PRM_Relationship_Id__c = crList[0].Id;
        acr3.PRM_Contact_Id__c=conts[0].Id;
        acr3.PRM_execute_trigger__c=true;
        //insert acr1;
        acrs.add(acr3);
        insert acrs;
        test.stopTest();
    }
    
    @isTest static void SendEmailVerificationAndCreateIdentityInAGSTest3(){
        test.startTest();
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE Email='testcontact3@mailinator.com' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Primary Contact';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Works for';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        List<PRM_AccountChannelMembership__c> acms = new List<PRM_AccountChannelMembership__c>();
              
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c=intelAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='FPGA Designer';
        acms.add(acm1);        
        insert acms;
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=intelAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[0].Id;
        acr2.PRM_Contact_Id__c=conts[0].Id;
        acr2.PRM_execute_trigger__c=true;
        //insert acr;
        acrs.add(acr2);        
        
        PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr3.PRM_InActive_Ind__c= false;
        acr3.PRM_Account_Id__c=intelAccount.Id;
        acr3.PRM_Relationship_Id__c = crList[0].Id;
        acr3.PRM_Contact_Id__c=conts[0].Id;
        acr3.PRM_execute_trigger__c=true;
        //insert acr1;
        acrs.add(acr3);
        insert acrs;
        test.stopTest();
    }
    
    
    
	public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(201);
            return res;
        }
	}
}