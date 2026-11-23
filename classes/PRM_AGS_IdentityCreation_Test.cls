@isTest
public class PRM_AGS_IdentityCreation_Test {
    public static boolean isTestClassRunning = false;
    @testSetup
    private static void createData(){
        test.startTest();
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        bcs.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        insert bCs;        
        String accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account intelAccount = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',
                                           Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi',
                                           ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,Core_User_Defined_Website__c= 'www.Test123.com', RecordTypeId = accRecTypeId);
        insert intelAccount;
        
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        List<Contact> contacts = new List<Contact>();
        Contact cont = new Contact(FirstName='Test',LastName='Contact1',MailingCountryCode='US',Email='testcontact1@spamok.com',AccountId=intelAccount.Id,Core_Login_Id__c='testcontact1@spamok.com',
                                 /*MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456',Core_Preferred_Language__c='ENG',*/RecordTypeId=IntelContRecTypeId,
                                  Core_IPA_PartnerRole__c='Service Provider');
        Contact cont1 = new Contact(FirstName='Test1',LastName='Contact12',MailingCountryCode='US',Email='testcontact2@spamok.com',AccountId=intelAccount.Id,Core_Login_Id__c='testcontact2@spamok.com',
                                 /*MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456',Core_Preferred_Language__c='ENG',*/RecordTypeId=IntelContRecTypeId,
                                  Core_IPA_PartnerRole__c='Distributor',Core_Enterprise_Id__c='12123',Core_IPA_Email_Verification_Date__c=system.now());
        Contact cont2 = new Contact(FirstName='Test1',LastName='Contact12',MailingCountryCode='US',Email='testcontact3@spamok.com',AccountId=intelAccount.Id,Core_Login_Id__c='testcontact2@spamok.com',
                                 /*MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456',Core_Preferred_Language__c='ENG',*/RecordTypeId=IntelContRecTypeId,
                                  Core_IPA_PartnerRole__c='Distributor');
        
        
        contacts.add(cont);
        contacts.add(cont1);
        contacts.add(cont2);
        insert contacts; 
        try {
            PRM_AGS_IdentityCreation.createIdentityInAGSAsyncBulk(cont.Id);
        }
        catch (Exception e) {
        }
        
        try {
            PRM_AGS_IdentityCreation.createIdentityInAGSAsyncBulk(null);
        }
        catch (Exception e) {
        }
    
        
        isTestClassRunning = true;
        try {
            PRM_AGS_IdentityCreation.createIdentityInAGSAsyncBulk(cont.Id);
        }
        catch (Exception e) {
        }
        isTestClassRunning = false;
        test.stopTest();
    }
    
    @isTest static void exceptions(){
        PRM_AGS_IdentityCreation.createIdentityInAGSAsyncBulk(null); 
        PRM_AGS_IdentityCreation.getToken(null);
        PRM_AGS_IdentityCreation.createIdentityInAGSSync(null);  
       
    }
    
    
    @isTest static void createIdentityInAGS_Test(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        test.startTest();        
        Contact cont = [SELECT id,FirstName,LastName,Email,Core_Login_Id__c,MailingCountryCode,Core_Preferred_Language__c FROM Contact where Core_Login_Id__c = 'testcontact1@spamok.com' LIMIT 1];
        //System.debug('cont : '+cont);
        try {
            PRM_AGS_IdentityCreation.createIdentityInAGSAsync(cont.Id);  
        } catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        
        isTestClassRunning =  true;
        if (isTestClassRunning){
            PRM_AGS_IdentityCreation.createIdentityInAGSAsync(cont.Id);  
        }
        isTestClassRunning = false;
        
        system.assertEquals('testcontact1@spamok.com', cont.Core_Login_Id__c );
        test.stopTest();
              
    }
    
    @isTest static void updateACRStatusOnAgsIdentityCreationFailureTest1(){
       test.startTest();
       Contact cont = [SELECT id,FirstName,LastName,Email,Core_Login_Id__c FROM Contact LIMIT 1];        
       PRM_AGS_IdentityCreation.updateACRStatusOnAgsIdentityCreationFailure(cont.Id,False);
       test.stopTest();
    }
    
    @isTest static void reTriggerEVFuture(){
         test.startTest();
         Contact cont =[SELECT id,AccountId,Account.Name,Account.AccountNumber,Account.BillingCountryCode,MailingCountryCode,Core_IPA_PartnerRole__c,Core_Login_Id__c,Core_Do_Not_Contact__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,Core_IPA_Email_Verification_Date__c,(SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false) FROM Contact where Core_Enterprise_Id__c != null  Limit 1];
         PRM_AGS_IdentityCreation.reTriggerEVFuture(cont.Id);
         PRM_RetriggerEV_Token_API.reTriggerEV(cont.Email);
         test.stopTest();
    }
    @isTest static void reTriggerEVFuture2(){
         test.startTest();
         Contact cont =[SELECT id,AccountId,Account.Name,Account.AccountNumber,Account.BillingCountryCode,MailingCountryCode,Core_IPA_PartnerRole__c,Core_Login_Id__c,Core_Do_Not_Contact__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,Core_IPA_Email_Verification_Date__c,(SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false) FROM Contact where Core_Enterprise_Id__c != null  Limit 1];
         PRM_AGS_IdentityCreation.reTriggerEVFuture(cont.Id);
         PRM_RetriggerEV_Token_API.reTriggerEV(cont.Email);
         test.stopTest();
    }
    
    
    @isTest static void createIdentityInAGS_Negative_Test(){
       test.startTest();
       Contact cont = [SELECT id,FirstName,LastName,Email,Core_Login_Id__c FROM Contact LIMIT 1];        
       PRM_AGS_IdentityCreation.createIdentityInAGSAsync(cont.Id);
       PRM_AGS_IdentityCreation.createIdentityInAGSAsync(null);
       system.assert(cont!=null);
       test.stopTest();          
    }
    
    @isTest static void createIdentityInAGS_Test1(){
       test.startTest();
       Contact cont = [SELECT id FROM Contact LIMIT 1];  
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        try{
            PRM_AGS_IdentityCreation.createIdentityInAGSAsync(cont.Id);     
        }catch(Exception ex){
            system.assertEquals(ex.getMessage(), ex.getMessage());
        }
         try{
         PRM_AGS_IdentityCreation.createIdentityInAGSAsync(null);         
        }catch(Exception ex){
            system.assertEquals(ex.getMessage(), ex.getMessage());
        }
      
       system.assert(cont!=null);
       test.stopTest();
    }
    
    @isTest static void SendEmailVerificationAndCreateIdentityInAGSTest1(){
        test.startTest();
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id, Email FROM Contact WHERE Core_IPA_PartnerRole__c='Service Provider' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm.PRM_Status_Reason_Txt__c='test';
        acms.add(acm);       
              
        insert acms;
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=intelAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=conts[0].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Reason_Txt__c='test';
        //insert acr;
        acrs.add(acr);
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Pending Action'; 
        acr1.PRM_Status_Reason_Txt__c='test';
        //insert acr1;
        acrs.add(acr1);
        insert acrs;
        
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Status_Nm__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr1.Id];
        system.assertEquals('Pending Action', acrRec.PRM_Status_Nm__c);
        PRM_RetriggerEV_Token_API.reTriggerEV(conts[0].Email);
        test.stopTest();
    }
    
    @isTest static void ReInviteBySendingEmailVerificationTest1(){
        test.startTest();        
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id, email FROM Contact WHERE Core_IPA_PartnerRole__c='Service Provider' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='test';
        acms.add(acm);       
              
        insert acms;
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=intelAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=conts[0].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Reason_Txt__c='test';
        //insert acr;
        acrs.add(acr);
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= true;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Complete';
        acr1.PRM_Status_Reason_Txt__c='test';
        //insert acr1;
        acrs.add(acr1);
        insert acrs;
        
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr1.Id];
        /*acrRec.PRM_Status_Nm__c = 'Complete';
        acrRec.PRM_InActive_Ind__c = true;
        update acrRec;*/
        
        //System.debug('acrRec'+acrRec);
        PRM_AcctContRel_TriggerHandler.firstUpdateRun = true;
        acrRec.PRM_Status_Nm__c = 'Pending Action';
        acrRec.PRM_InActive_Ind__c = false;
        update acrRec;

        conts[0].Core_Enterprise_Id__c = null;
        conts[0].Core_IPA_PartnerRole__c = 'Builder';
        update conts;
        //System.debug('starting secon update>>>>'+conts[0].id);
        //System.debug('????? query to be rremoved'+[Select id,Core_IPA_PartnerRole__c,Core_Enterprise_Id__c from Contact where id =: conts[0].id]);
        PRM_AcctContRel_TriggerHandler.firstUpdateRun = true;
        acrRec.PRM_Status_Nm__c = 'Pending Action';
        acrRec.PRM_InActive_Ind__c = false;
        update acrRec;
        
        //System.debug('acrRec'+acrRec);
        //System.debug('Core_IPA_PartnerRole__c :'+acrRec.PRM_Partner_Role__c);
        system.assertEquals('Pending Action', acrRec.PRM_Status_Nm__c);
        PRM_RetriggerEV_Token_API.reTriggerEV(conts[0].Email);
        test.stopTest();
    }
    
    @isTest static void ReInviteBySendingEmailVerificationTest12(){
        test.startTest();      
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE Core_IPA_PartnerRole__c='Service Provider' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='test';
        acms.add(acm);       
              
        insert acms;
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=intelAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=conts[0].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Reason_Txt__c='AGS Identity Creation Failed';  
        acr.PRM_Status_Reason_Txt__c='test';
        //insert acr;
        acrs.add(acr);
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= true;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Complete';
        acr1.PRM_Status_Reason_Txt__c='AGS Identity Creation Failed';
        acr1.PRM_Status_Reason_Txt__c='test';
        //insert acr1;
        acrs.add(acr1);
        insert acrs;
        
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr1.Id];
        /*acrRec.PRM_Status_Nm__c = 'Complete';
        acrRec.PRM_InActive_Ind__c = true;
        update acrRec;*/
        
        //System.debug('acrRec'+acrRec);
        PRM_AcctContRel_TriggerHandler.firstUpdateRun = true;
        acrRec.PRM_Status_Nm__c = 'Pending Action';
        acrRec.PRM_InActive_Ind__c = false;
        update acrRec;

        conts[0].Core_Enterprise_Id__c =null;
        conts[0].Core_IPA_PartnerRole__c = 'Builder';
        update conts;
        //System.debug('starting secon update>>>>'+conts[0].id);
        //System.debug('????? query to be rremoved'+[Select id,Core_IPA_PartnerRole__c,Core_Enterprise_Id__c from Contact where id =: conts[0].id]);
        PRM_AcctContRel_TriggerHandler.firstUpdateRun = true;
        acrRec.PRM_Status_Nm__c = 'Pending Action';
        acrRec.PRM_InActive_Ind__c = false;
        update acrRec;
        
        //System.debug('acrRec'+acrRec);
        //System.debug('Core_IPA_PartnerRole__c :'+acrRec.PRM_Partner_Role__c);
        system.assertEquals('Pending Action', acrRec.PRM_Status_Nm__c);
        test.stopTest();
    }
    
    @isTest static void ReInviteBySendingEmailVerificationTest2()
    {
        test.startTest();        
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id,Core_IPA_PartnerRole__c FROM Contact WHERE Core_IPA_PartnerRole__c='Distributor' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='test';
        acms.add(acm);       
        
        insert acms;
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=intelAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=conts[0].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Reason_Txt__c='test';
        //acr.PRM_Partner_Role__c = 'Service Provider';
        //insert acr;
        acrs.add(acr);
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= true;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Complete';
        acr1.PRM_Status_Reason_Txt__c='test';
        //acr.PRM_Partner_Role__c = 'Service Provider';
        //insert acr1;
        acrs.add(acr1);
        insert acrs;
        
        //System.debug('acrs : '+acrs);
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Nm__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr1.Id];
        PRM_AccountChannelMembership__c acmRec = [SELECT id,PRM_Partner_Role__c,PRM_Status_Nm__c FROM PRM_AccountChannelMembership__c WHERE PRM_Account_Id__c= :intelAccount.id];
        /*acrRec.PRM_Status_Nm__c = 'Complete';
acrRec.PRM_InActive_Ind__c = true;
update acrRec;*/
        
        //System.debug('acrRec'+acrRec);
        //System.debug('acmRec '+acmRec);
        PRM_AcctContRel_TriggerHandler.firstUpdateRun = true;
        acrRec.PRM_Status_Nm__c = 'Complete';
        acrRec.PRM_InActive_Ind__c = false;
        update acrRec;
        
        acrRec = [SELECT id,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Nm__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr1.Id];
        //System.debug('acrRec'+acrRec);
        //System.debug('Core_IPA_PartnerRole__c :'+acrRec.PRM_Partner_Role__c);
        //system.assertEquals('Complete', acrRec.PRM_Status_Nm__c);
        test.stopTest();
    }
    
    @isTest static void SendEmailVerificationAndCreateIdentityInAGSTest2(){
        test.startTest();        
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE Core_IPA_PartnerRole__c='Distributor' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm1.PRM_Partner_Role__c='Distributor';
        acm1.PRM_Status_Reason_Txt__c='test';
        acms.add(acm1);        
        insert acms;
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=intelAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[0].Id;
        acr2.PRM_Contact_Id__c=conts[0].Id;
        acr2.PRM_execute_trigger__c=true;
        acr2.PRM_Status_Reason_Txt__c='test';
        //insert acr;
        acrs.add(acr2);        
        
        PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr3.PRM_InActive_Ind__c= false;
        acr3.PRM_Account_Id__c=intelAccount.Id;
        acr3.PRM_Relationship_Id__c = crList[0].Id;
        acr3.PRM_Contact_Id__c=conts[0].Id;
        acr3.PRM_execute_trigger__c=true;
          acr3.PRM_Status_Reason_Txt__c='test';
        //insert acr1;
        acrs.add(acr3);
        insert acrs;
        
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Status_Nm__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr3.Id];
        system.assertEquals('Pending Action', acrRec.PRM_Status_Nm__c);
        test.stopTest();
    }
    
    @isTest static void SendEmailVerificationAndCreateIdentityInAGSTest3(){
        test.startTest();
                
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE Email='testcontact3@spamok.com' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm1.PRM_Partner_Role__c='Distributor';
         acm1.PRM_Status_Reason_Txt__c='test';
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
        acr3.PRM_Relationship_Id__c = crList[1].Id;
        acr3.PRM_Contact_Id__c=conts[0].Id;
        acr3.PRM_execute_trigger__c=true;
        acr3.PRM_Status_Reason_Txt__c='test';
        //insert acr1;
        acrs.add(acr3);
        insert acrs;
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Status_Nm__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr3.Id];
        system.assertEquals('Pending Action', acrRec.PRM_Status_Nm__c);
        test.stopTest();
    }
    @isTest static void updateAcctContRelation_StatusFieldTest(){
        test.startTest();        
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id,AccountId FROM Contact WHERE Email='testcontact3@spamok.com' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_AccountChannelMembership__c accChannelMember = new PRM_AccountChannelMembership__c();
        accChannelMember.PRM_Status_Nm__c = 'Pending';
        accChannelMember.PRM_Partner_Role__c = 'Distributor';
        accChannelMember.PRM_Account_Id__c = conts[0].AccountId;
         accChannelMember.PRM_Status_Reason_Txt__c='test';
        insert accChannelMember;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm1.PRM_Partner_Role__c='Distributor';
        acm1.PRM_Status_Reason_Txt__c='test';
        acms.add(acm1);        
        insert acms;
        
        conts[0].Core_Enterprise_Id__c = null;
        conts[0].Core_IPA_Email_Verification_Date__c = System.now();
        Update conts[0];
        
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=intelAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[0].Id;
        acr2.PRM_Contact_Id__c=conts[0].Id;
        acr2.PRM_execute_trigger__c=true;
        acr2.PRM_No_Email__c = false;
        acr2.PRM_Status_Reason_Txt__c='test';
        //insert acr;
        acrs.add(acr2);        
        
        PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr3.PRM_InActive_Ind__c= false;
        acr3.PRM_Account_Id__c=intelAccount.Id;
        acr3.PRM_Relationship_Id__c = crList[1].Id;
        acr3.PRM_Contact_Id__c=conts[0].Id;
        acr3.PRM_execute_trigger__c=true;
        acr3.PRM_No_Email__c = false;
        acr3.PRM_Status_Nm__c = 'Pending Action';
        acr3.PRM_Status_Reason_Txt__c='test';
        
        //insert acr1;
        acrs.add(acr3);
        insert acrs;
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Status_Nm__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr3.Id];
        system.assertEquals('Pending Action', acrRec.PRM_Status_Nm__c);
        PRM_AGS_IdentityCreation.updateAcctContRelation_StatusField(acrs);
        test.stopTest();
    }
    
    @isTest static void ReInviteBySendingEmailVerificationTest4(){
        test.startTest();        
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE  Core_Enterprise_Id__c = null and Core_IPA_Email_Verification_Date__c=null LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
         acm.PRM_Status_Reason_Txt__c='test';
        acms.add(acm);       
              
        insert acms;
        //acms[0].PRM_Partner_Role__c = null;
        update acms[0];
        conts[0].Core_Enterprise_Id__c = 'eqweqweweqw';
      //  conts[0].Core_IPA_Email_Verification_Date__c = system.today();
        Update conts[0];
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=intelAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=conts[0].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Reason_Txt__c='test';
        //insert acr;
        acrs.add(acr);
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= true;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Complete';
        acr1.PRM_Status_Reason_Txt__c='test';
        //insert acr1;
        acrs.add(acr1);
        insert acrs;
        
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr1.Id];
        /*acrRec.PRM_Status_Nm__c = 'Complete';
        acrRec.PRM_InActive_Ind__c = true;
        update acrRec;*/
        
        //System.debug('acrRec'+acrRec);
        PRM_AcctContRel_TriggerHandler.firstUpdateRun = true;
        acrRec.PRM_Status_Nm__c = 'Pending Action';
        acrRec.PRM_InActive_Ind__c = false;
        update acrRec;
        
        //System.debug('acrRec'+acrRec);
        //System.debug('Core_IPA_PartnerRole__c :'+acrRec.PRM_Partner_Role__c);
        system.assertEquals('Pending Action', acrRec.PRM_Status_Nm__c);
        test.stopTest();
    }
    
   
    
    @isTest static void ReInviteBySendingEmailVerificationTest5(){
        test.startTest();        
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE  Core_Enterprise_Id__c = null and Core_IPA_Email_Verification_Date__c=null LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
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
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='test';
        acms.add(acm);       
              
        insert acms;
        conts[0].Core_Enterprise_Id__c = null;
        Update conts[0];
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=intelAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=conts[0].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Status_Reason_Txt__c='test';
        //insert acr;
        acrs.add(acr);
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= true;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Complete';
        acr1.PRM_Status_Reason_Txt__c='test';
        //insert acr1;
        acrs.add(acr1);
        insert acrs;
        
        PRM_Account_Contact_Relationship__c acrRec = [SELECT id,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM PRM_Account_Contact_Relationship__c WHERE Id= :acr1.Id];
        /*acrRec.PRM_Status_Nm__c = 'Complete';
        acrRec.PRM_InActive_Ind__c = true;
        update acrRec;*/
        
        //System.debug('acrRec'+acrRec);
        PRM_AcctContRel_TriggerHandler.firstUpdateRun = true;
        acrRec.PRM_Status_Nm__c = 'Pending Action';
        acrRec.PRM_InActive_Ind__c = false;
        update acrRec;
        
        //System.debug('acrRec'+acrRec);
        //System.debug('Core_IPA_PartnerRole__c :'+acrRec.PRM_Partner_Role__c);
        system.assertEquals('Pending Action', acrRec.PRM_Status_Nm__c);
        test.stopTest();
    }
    
    
    
    
  public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
            res.setBody('{"local.PRMIPAPartition.APIGEEaccesstoken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
            res.setStatusCode(200);
            return res;
        }
  }
    
    @isTest static void updateACRStatusOnAgsIdentityCreationFailureTest(){
        test.startTest();        
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id , email FROM Contact WHERE Core_IPA_PartnerRole__c='Distributor' and email != null LIMIT 2];  //Add
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
         PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>(); //Add
        acr1.PRM_InActive_Ind__c= true;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Pending Action';
        acr1.PRM_AGS_Identity_Creation_Fail__c = false;
         acr1.PRM_Status_Reason_Txt__c='test';
        acrList.add(acr1) ;   //Add
        //acr.PRM_Partner_Role__c = 'Service Provider';
        insert acr1;
        
        PRM_AGS_IdentityCreation.updateACRStatusOnAgsIdentityCreationFailure(conts[0].Id,true);
        PRM_AGS_IdentityCreation.updateACRStatusOnAgsIdentityCreationFailure(conts[0].Id,false);
        createUser();
        
        User user  = [SELECT Id, Email FROM User 
                      WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember  WHERE Group.Developername = :'PRM_IPA_Registration_Approvers') limit 1 ];
        //System.debug('user   ----> '+user);
        /*System.runAs(user)
        {
            PRM_AGS_IdentityCreation.sendEmailToAdminOnAgsIdentityCreationFailure(acrList);  //Add           
        }*/
        
    }
    @isTest static void updateACRStatusOnAgsIdentityCreationFailureTest_acr(){
        test.startTest();
        
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id , email FROM Contact WHERE Core_IPA_PartnerRole__c='Distributor' and email != null LIMIT 2];  //Add
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
         PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>(); //Add
        acr1.PRM_InActive_Ind__c= true;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Pending Action';
        acr1.PRM_AGS_Identity_Creation_Fail__c = true;
        acr1.PRM_Status_Reason_Txt__c='test';
        acrList.add(acr1) ;   //Add
        //acr.PRM_Partner_Role__c = 'Service Provider';
        insert acr1;
        
        PRM_AGS_IdentityCreation.updateACRStatusOnAgsIdentityCreationFailure(conts[0].Id,true);
        PRM_AGS_IdentityCreation.updateACRStatusOnAgsIdentityCreationFailure(conts[0].Id,false);
        createUser();
        
        User user  = [SELECT Id, Email, IsPortalEnabled FROM User 
                      WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember  WHERE Group.Developername = :'PRM_IPA_Registration_Approvers') limit 1 ];
        user.IsPortalEnabled = true;
        //System.debug('user   ----> '+user);
        /*System.runAs(user)
        {
            PRM_AGS_IdentityCreation.sendEmailToAdminOnAgsIdentityCreationFailure(acrList);  //Add           
        }*/
        
    }
    public Static void createUser(){
        List<Contact> conts = [SELECT Id , email FROM Contact WHERE Core_IPA_PartnerRole__c='Distributor' and email != null LIMIT 1];  //Add
        
        Profile prof = [select id from profile where name LIKE '%IPS External Customer%'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.ContactId = conts[0].Id;
        user.username = 'testxyz@test.com';
        user.email = 'test@test.com';
        user.Alias = 'test123';
        user.Email = 'test12345@test.com';
        user.EmailEncodingKey = 'UTF-8';
        user.CommunityNickname = 'test12345';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        
        insert user;
       
    }
    
     @isTest static void getACRListTest(){
            test.startTest();
        Account intelAccount = [SELECT id FROM Account LIMIT 1];
        List<Contact> conts = [SELECT Id FROM Contact WHERE Core_IPA_PartnerRole__c='Distributor' LIMIT 1];
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
         PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= true;
        acr1.PRM_Account_Id__c=intelAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=conts[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Nm__c = 'Pending Action';
          acr1.PRM_Status_Reason_Txt__c='test';
        //acr.PRM_Partner_Role__c = 'Service Provider';
        insert acr1;
            
            PRM_AGS_IdentityCreation.getACRList(conts[0].id);
            PRM_AGS_IdentityCreation.createIdentityInAGSSync1(conts[0].id,acr1.id);
            
            
    }
    @isTest static void createIdentityInAGSFailure_Test(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailure()); 
        test.startTest();
        Contact cont = [SELECT id,FirstName,LastName,Email,Core_Login_Id__c,MailingCountryCode,Core_Preferred_Language__c FROM Contact where Core_Login_Id__c = 'testcontact1@spamok.com' LIMIT 1];
        //System.debug('cont : '+cont);
        PRM_AGS_IdentityCreation.createIdentityInAGSAsync(cont.Id);
        system.assertEquals('testcontact1@spamok.com', cont.Core_Login_Id__c );
        test.stopTest();
                
    }

    public class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "null"');
            res.setStatusCode(400);
            return res;
        }
    }
    @isTest static void createIdentityInAGSFailure2_Test(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailure2()); 
        test.startTest();
        Contact cont = [SELECT id,FirstName,LastName,Email,Core_Login_Id__c,MailingCountryCode,Core_Preferred_Language__c FROM Contact where Core_Login_Id__c = 'testcontact1@spamok.com' LIMIT 1];
        //System.debug('cont : '+cont);
        PRM_AGS_IdentityCreation.createIdentityInAGSAsync(cont.Id);
        system.assertEquals('testcontact1@spamok.com', cont.Core_Login_Id__c );
        test.stopTest();
                
    }

    public class MockHttpResponseGeneratorFailure2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
            if(req.getEndpoint().contains('auth/token')){
                res.setStatusCode(200);
            }else{
                res.setStatusCode(400);
            }
            
            return res;
        }
    }

    @isTest static void createIdentityInAGSFailure3_Test(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailure3()); 
        test.startTest();
        Contact cont = [SELECT id,FirstName,LastName,Email,Core_Login_Id__c,MailingCountryCode,Core_Preferred_Language__c FROM Contact where Core_Login_Id__c = 'testcontact1@spamok.com' LIMIT 1];
        //System.debug('cont : '+cont);
        PRM_AGS_IdentityCreation.createIdentityInAGSAsync(cont.Id);
        system.assertEquals('testcontact1@spamok.com', cont.Core_Login_Id__c );
        test.stopTest();
                
    }

    public class MockHttpResponseGeneratorFailure3 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('auth/token')){
                res.setBody('{"access_token": null}');
                res.setStatusCode(200);
            }else{
                
                res.setStatusCode(400);
            }
            
            return res;
        }
    }
       
}