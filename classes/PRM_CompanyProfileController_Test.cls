@isTest
public class PRM_CompanyProfileController_Test {
    // public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh);
    private Static String  primaryConsent= 'Partner Assist Choice 1';
    Private Static  String  secondaryConsent= 'Partner Assist Choice 2'; 
    @testSetup
    public static void testDataCreation(){
        //Mastered_Account        
        Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        List<Account> lstAccts = new List<Account>();
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='CHN',BillingStreet='abc chowk delhi',
                                              ShippingCity='delhi',ShippingCountry='CHN',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True, Core_Geo__c='APJ',Core_User_Defined_Website__c='www.intel12.com');
        lstAccts.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',
                                            Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,Core_User_Defined_Website__c='www.intel34.com');
        lstAccts.add(intelAccount1);
        insert lstAccts;
        
        List<Account> updatedAcct= new List<Account>();
        for(Account acc:[SELECT ID,NAME,Core_Account_Type__c,Core_IPA_Partner_Role__c,Core_User_Defined_Website__c FROM ACCOUNT]){
            //System.debug('acc ='+acc);
            acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_CIM_ID__c='12345';
            acc.Core_User_Defined_Website__c = 'www.intel6.com';
            updatedAcct.add(acc);
        }
        
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c =partnerAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c =intelAccount1.Id;
        insert accGroupMem;        
        
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cntPartner = new Contact(FirstName='Test',LastName='ContactP',Email='testcontact2@spamok.com',AccountId=partnerAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                         MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456', Core_IPA_PartnerRole__c='Service Provider',Core_Preferred_Language__c='ENG');
        insert cntPartner;
        
        Contact cnt = new Contact(FirstName='robin',LastName='hood',Email='testcontact1@spamok.com',AccountId=intelAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                  MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456', Core_IPA_PartnerRole__c='Service Provider',Core_Preferred_Language__c='ENG', Core_English_Only_First_Name__c='robin',
                                  Core_English_Only_Last_Name__c='hood');
        insert cnt;
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        User partnerUser = new User(FirstName='Test',LastName='Contact1',alias='tcont1',Email='testcontact1@spamok.com',UserName='testcontactPRMProfile20@spamok.com', ContactId=cnt.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');
        insert partnerUser;
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Partner',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=partnerAccount1.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved',PRM_Status_Reason_Txt__c='Test');
        insert acm;
        
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c(Name='IPA Program',PRM_Agreement_Category_Nm__c='Intel Insider Cloud All Agreements',
                                                                 PRM_Agreement_Cd__c='IPA_TANDC',PRM_Channel_Program_Id__c=cp.Id);
        insert pa;        
        
        
        PRM_AccountLegalAgreemntAssociation__c legalAgrmnt = new PRM_AccountLegalAgreemntAssociation__c();       
        legalAgrmnt.PRM_Account_Id__c = intelAccount1.Id;
        legalAgrmnt.PRM_Agreement_Sign_Dt__c = system.now();
        legalAgrmnt.PRM_Partner_Agreement_Id__c = pa.Id;
        legalAgrmnt.PRM_Contact__c = cnt.Id;
        legalAgrmnt.PRM_InActive_Ind__c = false;
        insert legalAgrmnt;        
        
        List<PRM_Specialty__c> specialties = new List<PRM_Specialty__c>(); 
        PRM_Specialty__c specialty = new PRM_Specialty__c();
        specialty.Name = 'Cloud Data Center Specialty';        
        specialty.PRM_Access_Level_Nm__c = 'Public';
        specialty.PRM_Role_Nm__c = 'Service Provider';
        specialty.PRM_Tier_Nm__c = 'Gold'; //'Gold';
        specialty.PRM_Description_Txt__c = 'Test';
        specialty.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        specialty.PRM_Start_Date_Dt__c = system.Today();
        specialty.PRM_End_Date_Dt__c = system.Today()+60;
        specialties.add(specialty);
        
        PRM_Specialty__c specialty1 = new PRM_Specialty__c();
        specialty1.Name = 'Enthusiast PC Specialty';        
        specialty1.PRM_Access_Level_Nm__c = 'Public';
        specialty1.PRM_Role_Nm__c = 'Service Provider';
        specialty1.PRM_Tier_Nm__c = 'Gold';
        specialty1.PRM_Description_Txt__c = 'Test1';
        specialty1.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        specialty1.PRM_Start_Date_Dt__c = system.Today();
        specialty1.PRM_End_Date_Dt__c = system.Today()+60;
        specialties.add(specialty1);
        insert specialties;
        
        List<PRM_Account_Specialty_Association__c> asas = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c acctSpecialty = new PRM_Account_Specialty_Association__c();
        acctSpecialty.PRM_Account_Id__c = partnerAccount1.id;
        acctSpecialty.PRM_Specialty_Id__c = specialties[0].Id;
        asas.add(acctSpecialty);
        
        PRM_Account_Specialty_Association__c acctSpecialty1 = new PRM_Account_Specialty_Association__c();
        acctSpecialty1.PRM_Account_Id__c = partnerAccount1.id;
        acctSpecialty1.PRM_Specialty_Id__c = specialties[1].Id;
        asas.add(acctSpecialty1);
        insert asas;
        
        //Account Contact Relationship
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Partner Admin';
        contRel.PRM_Contact_Relationship_Cd__c = 'PRIMARY';
        insert contRel;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = intelAccount1.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_InActive_Ind__c = False;
        insert acr;        
        
        //  Partner Assist - Start 
        List<PRM_Partner_Consent_Distributor__c> lstConsentDistributor = new  List<PRM_Partner_Consent_Distributor__c>();
        PRM_Partner_Consent_Distributor__c partConsentDistributor1 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistributor1.PRM_Country_Name__c = 'INDIA';
        partConsentDistributor1.PRM_Geo_Nm__c = 'APJ';
        partConsentDistributor1.PRM_Sub_Region_Nm__c = 'ANZ';
        partConsentDistributor1.PRM_Distributor_Name_Txt__c =  'TestDistributor1';
        insert partConsentDistributor1;
        
        PRM_Partner_Consent_Distributor__c partConsentDistributor2 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistributor2.PRM_Country_Name__c = 'INDIA';
        partConsentDistributor2.PRM_Geo_Nm__c = 'APJ';
        partConsentDistributor2.PRM_Sub_Region_Nm__c = 'ANZ';
        partConsentDistributor2.PRM_Distributor_Name_Txt__c =  'TestDistributor2';
        lstConsentDistributor.add(partConsentDistributor2);
        
        PRM_Partner_Consent_Distributor__c partConsentDistributor3 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistributor3.PRM_Country_Name__c = 'INDIA';
        partConsentDistributor3.PRM_Geo_Nm__c = 'APJ';
        partConsentDistributor3.PRM_Sub_Region_Nm__c = 'ANZ';
        partConsentDistributor3.PRM_Distributor_Name_Txt__c =  'TestDistributor3';
        lstConsentDistributor.add(partConsentDistributor3);
        insert lstConsentDistributor;
        
        PRM_Partner_Assist_Consent__c partAssistConsent = new PRM_Partner_Assist_Consent__c();
        partAssistConsent.PRM_Consent_Provided_Ind__c =True;
        partAssistConsent.PRM_Consent_Provided_By_Id__c = cnt.Id;
        partAssistConsent.PRM_Consent_Provided_Date_Dt__c = System.now();
        partAssistConsent.PRM_End_Date_Dt__c = Null;
        partAssistConsent.PRM_Choice_Nm__c = primaryConsent;
        partAssistConsent.PRM_Account_Id__c = partnerAccount1.id;
        partAssistConsent.PRM_Distributor_Id__c = partConsentDistributor1.Id;
        insert partAssistConsent;
        // Partner Assist End 
    }    
    /* private static testMethod void saveWhitelistedDomains_NewList_Test(){ 
test.startTest();
system.debug('start ==> saveWhitelistedDomains_NewList_Test');
Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
Account intelAccount1 = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
ChannelProgram cp = [SELECT id FROM ChannelProgram LIMIT 1];

String answerCode = system.label.IPA_Acceptable_Domains;        
PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
pq.PRM_Channel_Program_Id__c = cp.Id;
pq.PRM_Question_Display_Txt__c = 'Whitelisted Domains';
pq.PRM_Question_Cd__c = answerCode;
insert pq;

PRM_Profile_Answer__c profAns = new PRM_Profile_Answer__c(PRM_Answer_Cd__c=answerCode,PRM_Answer_Display_Txt__c='Whitelisted Domains Answer', PRM_Profile_Questions_Id__c=pq.Id);
insert profAns;
system.runAs([SELECT id FROM User WHERE Email='testcontact1@spamok.com'][0]){
PRM_CompanyProfileController.saveWhitelistedDomains(intelAccount1.Id,'test.com,test1.com');  
system.assertEquals('test.com,test1.com', PRM_CompanyProfileController.getWhitelistedDomains(intelAccount1.Id));
}
system.debug('End ==> saveWhitelistedDomains_NewList_Test');
test.stopTest();        
} */
    public static testMethod void getCompanyAndRoleInfo_Test(){
        test.startTest();
        Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        List<Account> lstAccts = new List<Account>();
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='CHN',BillingStreet='abc chowk delhi',
                                              ShippingCity='delhi',ShippingCountry='CHN',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True, Core_Geo__c='APJ',Core_User_Defined_Website__c='www.intel12.com');
        lstAccts.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount12',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',
                                            Industry='Agriculture',RecordTypeId=intelAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbce chowk delhi',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbct chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,Core_User_Defined_Website__c='www.intel34.com');
        lstAccts.add(intelAccount1);
        insert lstAccts;
        
        List<Account> updatedAcct= new List<Account>();
        for(Account acc:[SELECT ID,NAME,Core_Account_Type__c,Core_IPA_Partner_Role__c,Core_User_Defined_Website__c FROM ACCOUNT]){
            //System.debug('acc ='+acc);
            acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_CIM_ID__c='12345';
            acc.Core_User_Defined_Website__c = 'www.intel6.com';
            updatedAcct.add(acc);
        }
        
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c =partnerAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c =intelAccount1.Id;
        insert accGroupMem;        
        
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cntPartner = new Contact(FirstName='Test',LastName='ContactP',Email='testcontact24@spamok.com',AccountId=partnerAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                         MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456', Core_IPA_PartnerRole__c='Service Provider',Core_Preferred_Language__c='ENG');
        insert cntPartner;
        
        Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact14@spamok.com',AccountId=intelAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                  MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456', Core_IPA_PartnerRole__c='Service Provider',Core_Preferred_Language__c='ENG');
        insert cnt;
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        User partnerUser = new User(FirstName='Test',LastName='Contact1',alias='tcont1',Email='testcontact14@spamok.com',UserName='testcontactPRMProfilete30@spamok.com', ContactId=cnt.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');
        insert partnerUser;
        
        /*  List<ChannelProgram> channelPrograms1 = new List<ChannelProgram>();
ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
channelPrograms1.add(cp);
insert channelPrograms1;*/
        ChannelProgram cp = [Select id from ChannelProgram];
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Partner',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=partnerAccount1.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved',PRM_Status_Reason_Txt__c='Test');
        insert acm;
        
        /*PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c(Name='IPA Program',PRM_Agreement_Category_Nm__c='Intel Insider Cloud All Agreements',
PRM_Agreement_Cd__c='IPAPRGM',PRM_Channel_Program_Id__c=cp.Id);
insert pa; */
        
        PRM_PartnerAgreement__c pa = [Select id from PRM_PartnerAgreement__c];
        
        
        PRM_AccountLegalAgreemntAssociation__c legalAgrmnt = new PRM_AccountLegalAgreemntAssociation__c();       
        legalAgrmnt.PRM_Account_Id__c = intelAccount1.Id;
        legalAgrmnt.PRM_Agreement_Sign_Dt__c = system.now();
        legalAgrmnt.PRM_Partner_Agreement_Id__c = pa.Id;
        legalAgrmnt.PRM_Contact__c = cnt.Id;
        insert legalAgrmnt;        
        
        /* List<PRM_Specialty__c> specialties = new List<PRM_Specialty__c>(); 
PRM_Specialty__c specialty = new PRM_Specialty__c();
specialty.Name = 'Cloud Data Center Specialty';        
specialty.PRM_Access_Level_Nm__c = 'Public';
specialty.PRM_Role_Nm__c = 'Service Provider';
specialty.PRM_Tier_Nm__c = 'Gold';
specialty.PRM_Description_Txt__c = 'Test';
specialty.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
specialty.PRM_Start_Date_Dt__c = system.Today();
specialty.PRM_End_Date_Dt__c = system.Today()+60;
specialties.add(specialty);

PRM_Specialty__c specialty1 = new PRM_Specialty__c();
specialty1.Name = 'Enthusiast PC Specialty';        
specialty1.PRM_Access_Level_Nm__c = 'Public';
specialty1.PRM_Role_Nm__c = 'Service Provider';
specialty1.PRM_Tier_Nm__c = 'Gold';
specialty1.PRM_Description_Txt__c = 'Test1';
specialty1.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
specialty1.PRM_Start_Date_Dt__c = system.Today();
specialty1.PRM_End_Date_Dt__c = system.Today()+60;
specialties.add(specialty1);
insert specialties; */
        List<PRM_Specialty__c> specialties = [SELECT Id FROM PRM_Specialty__c WHERE CreatedDate = Today];
        
        List<PRM_Account_Specialty_Association__c> asas = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c acctSpecialty = new PRM_Account_Specialty_Association__c();
        acctSpecialty.PRM_Account_Id__c = partnerAccount1.id;
        acctSpecialty.PRM_Specialty_Id__c = specialties[0].Id;
        //acctSpecialty.PRM_Specialty_Type__c = 'Specialty';
        //acctSpecialty.PRM_Status_Nm__c = 'TBD';
        asas.add(acctSpecialty);
        
        PRM_Account_Specialty_Association__c acctSpecialty1 = new PRM_Account_Specialty_Association__c();
        acctSpecialty1.PRM_Account_Id__c = partnerAccount1.id;
        acctSpecialty1.PRM_Specialty_Id__c = specialties[1].Id;
        //acctSpecialty.PRM_Status_Nm__c = 'TBD';
        //acctSpecialty1.PRM_Specialty_Type__c = 'Select Benefits';
        asas.add(acctSpecialty1);
        insert asas;
        
        //PRM_Specialty_Type__c
        
        //Account Contact Relationship
        PRM_ContactRelationships__c contRel = [SELECT Id FROM PRM_ContactRelationships__c WHERE CreatedDate = Today limit 1];
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = intelAccount1.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;        
        
        //  Partner Assist - Start 
        List<PRM_Partner_Consent_Distributor__c> lstConsentDistributor = new  List<PRM_Partner_Consent_Distributor__c>();
        PRM_Partner_Consent_Distributor__c partConsentDistributor1 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistributor1.PRM_Country_Name__c = 'INDIA';
        partConsentDistributor1.PRM_Geo_Nm__c = 'APJ';
        partConsentDistributor1.PRM_Sub_Region_Nm__c = 'ANZ';
        partConsentDistributor1.PRM_Distributor_Name_Txt__c =  'TestDistributor1';
        insert partConsentDistributor1;
        
        PRM_Partner_Consent_Distributor__c partConsentDistributor2 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistributor2.PRM_Country_Name__c = 'INDIA';
        partConsentDistributor2.PRM_Geo_Nm__c = 'APJ';
        partConsentDistributor2.PRM_Sub_Region_Nm__c = 'ANZ';
        partConsentDistributor2.PRM_Distributor_Name_Txt__c =  'TestDistributor2';
        lstConsentDistributor.add(partConsentDistributor2);
        
        PRM_Partner_Consent_Distributor__c partConsentDistributor3 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistributor3.PRM_Country_Name__c = 'INDIA';
        partConsentDistributor3.PRM_Geo_Nm__c = 'APJ';
        partConsentDistributor3.PRM_Sub_Region_Nm__c = 'ANZ';
        partConsentDistributor3.PRM_Distributor_Name_Txt__c =  'TestDistributor3';
        lstConsentDistributor.add(partConsentDistributor3);
        insert lstConsentDistributor;
        
        PRM_Partner_Assist_Consent__c partAssistConsent = new PRM_Partner_Assist_Consent__c();
        partAssistConsent.PRM_Consent_Provided_Ind__c =True;
        partAssistConsent.PRM_Consent_Provided_By_Id__c = cnt.Id;
        partAssistConsent.PRM_Consent_Provided_Date_Dt__c = System.now();
        partAssistConsent.PRM_End_Date_Dt__c = Null;
        partAssistConsent.PRM_Choice_Nm__c = primaryConsent;
        partAssistConsent.PRM_Account_Id__c = partnerAccount1.id;
        partAssistConsent.PRM_Distributor_Id__c = partConsentDistributor1.Id;
        insert partAssistConsent;
        
        PRM_CompanyProfileController.getCompanyAndRoleInfo();
        String contId = String.valueOf(cnt.Id);
        String acctId = String.valueOf(intelAccount1.Id);
        PRM_CompanyProfileController.savePartnerAssist(acctId,'TestDistributor1','TestDistributor2',true,contId);
        test.stopTest();
    }
    private static testMethod void saveWhitelistedDomains_ExistingList_Test(){ 
        test.startTest();        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        Account intelAccount1 = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
        Contact cont = [Select id, Core_IPA_PartnerRole__c from Contact where RecordTypeId=:contactRecordType LIMIT 1];  
        ChannelProgram cp = [SELECT id FROM ChannelProgram LIMIT 1];
        
        String answerCode = system.label.IPA_Acceptable_Domains;        
        Core_Account_Whitelisted_Domains__c pq = new Core_Account_Whitelisted_Domains__c();
        pq.Name = 'google.com';
        pq.Inactive_Indicator__c = false ;
        pq.Account__c = intelAccount1.id;
        pq.Partner_Program__c  = cp.id;
        insert pq;
        Core_Account_Whitelisted_Domains__c pc = new Core_Account_Whitelisted_Domains__c();
        pc.Name = 'yahoo.com';
        pc.Inactive_Indicator__c = false ;
        pc.Account__c = intelAccount1.id;
        pc.Partner_Program__c  = cp.id;
        insert pc;
        
        
        List<List<String>> WhiteListDomain = new List<List<String>>();
        List<String> list1 = new List<String>{pq.id,pq.Name};
            List<String> list2 = new List<String>{'a7P8A000000Cj371UAC','Newdomain.com'};
                WhiteListDomain.add(list1);
        WhiteListDomain.add(list2);
        String erorRecid = '332fjf09f3393';
        system.runAs([SELECT id FROM User WHERE Email='testcontact1@spamok.com'][0]){ 
            PRM_CompanyProfileController.getWhitelistedDomains(intelAccount1.Id);
            system.assertEquals(true, PRM_CompanyProfileController.saveWhitelistedDomains(intelAccount1.Id,WhiteListDomain)); 
            system.assertEquals(False, PRM_CompanyProfileController.saveWhitelistedDomains(erorRecid,WhiteListDomain));
        }
        test.stopTest();        
    }
    private static testMethod void getCompanyInfo_Test(){  
        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        //Account testAccount = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
        
        ChannelProgram cp = [select id, name, PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance'];
        
        Account__c customSetting = new Account__c();
        customSetting.PRM_Max_Account_Number__c = '63628892297';
        customSetting.Name ='AccountNumber';
        insert customSetting;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = intelAccRecTypeId;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.intel.com'; 
        //testAccount.Core_Account_CCG_Tier__c='CCG-Tier 1';
        insert testAccount;
        
        
        String answerCode = system.label.IPA_Acceptable_Domains;        
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cp.Id;
        pq.PRM_Question_Display_Txt__c = 'Whitelisted Domains';
        pq.PRM_Question_Cd__c = answerCode;
        insert pq;
        
        PRM_Profile_Answer__c profAns = new PRM_Profile_Answer__c(PRM_Answer_Cd__c=answerCode,PRM_Answer_Display_Txt__c='Whitelisted Domains Answer', PRM_Profile_Questions_Id__c=pq.Id);
        insert profAns;        
        
        // IPARefresh=!IPARefresh;
        
        PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Account_Id__c = testAccount.Id;
        pr.PRM_Profile_Questions_Id__c = pq.Id;
        pr.PRM_Profile_Answer_Id__c = profAns.Id;
        pr.PRM_InActive_Ind__c = false;
        pr.PRM_Response_Txt__c = 'spamok.com';   
        insert pr;
        test.startTest();
        system.runAs([SELECT id, Email FROM User WHERE Email='testcontact1@spamok.com'][0]){
            String json= PRM_CompanyProfileController.getCompanyAndRoleInfo();
            system.assert(!String.isEmpty(json));
        }
        test.stopTest();
    } 
    
    private static testMethod void getCompanyInfo_Test2(){  
        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        //Account testAccount = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
        
        ChannelProgram cp = [select id, name, PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance'];
        
        Account__c customSetting = new Account__c();
        customSetting.PRM_Max_Account_Number__c = '63628892297';
        customSetting.Name ='AccountNumber';
        insert customSetting;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = intelAccRecTypeId;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='China   ';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.intel.com'; 
        //testAccount.Core_Account_CCG_Tier__c='CCG-Tier 1';    
        insert testAccount;
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact(FirstName='robin',LastName='hood',Email='testcontact123@spamok.com',AccountId=testAccount.Id,RecordTypeId=IntelContRecTypeId,
                                  MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456', Core_IPA_PartnerRole__c='Service Provider',Core_Preferred_Language__c='ENG', Core_English_Only_First_Name__c='test',
                                  Core_English_Only_Last_Name__c='new');
        insert cnt;
        
         Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        User partnerUser = new User(FirstName='Test',LastName='Contact1',alias='tcont1',Email='testcontact123@spamok.com',UserName='testcontactconid63@spamok.com', ContactId=cnt.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');
        insert partnerUser;
                              
        String answerCode = system.label.IPA_Acceptable_Domains;        
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cp.Id;
        pq.PRM_Question_Display_Txt__c = 'Whitelisted Domains';
        pq.PRM_Question_Cd__c = answerCode;
        insert pq;
        
        PRM_Profile_Answer__c profAns = new PRM_Profile_Answer__c(PRM_Answer_Cd__c=answerCode,PRM_Answer_Display_Txt__c='Whitelisted Domains Answer', PRM_Profile_Questions_Id__c=pq.Id);
        insert profAns;        
        
        
        PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Account_Id__c = testAccount.Id;
        pr.PRM_Profile_Questions_Id__c = pq.Id;
        pr.PRM_Profile_Answer_Id__c = profAns.Id;
        pr.PRM_InActive_Ind__c = false;
        pr.PRM_Response_Txt__c = 'spamok.com';   
        insert pr;
        test.startTest();
        system.runAs([SELECT id, Email FROM User WHERE Email='testcontact123@spamok.com'][0]){            
            try{
                String json= PRM_CompanyProfileController.getCompanyAndRoleInfo();
                system.assert(!String.isEmpty(json));
            }catch(Exception e){
                
            }
            
        }
        test.stopTest();
    } 
    
    private static testMethod void getMyCompanyLegalAgreemnent_Test(){ 
        test.startTest();
        system.runAs([SELECT id FROM User WHERE Email='testcontact1@spamok.com'][0]){
            PRM_CompanyProfileController.getMyCompanyLegalAgreemnent();
        }
        test.stopTest();
    } 
    
    private static testMethod void updateFlag_Approve_Test(){ 
        test.startTest();        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = intelAccRecTypeId;
        testAccount.Name='John Wick1';
        testAccount.BillingCity='City1';
        testAccount.BillingStreet='Street1';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.intel.com'; 
        insert testAccount;
        
        Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        
        PRM_Registration_Request__c acctReq = new PRM_Registration_Request__c();
        acctReq.Name = 'Test Account Request';
        acctReq.PRM_First_Name__c = 'Test'; 
        acctReq.PRM_Last_Name__c = 'Account Request';
        acctReq.PRM_Email_ID__c = 'testemail123@spamok.com';
        acctReq.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        acctReq.PRM_Account_Name__c = 'Test Account Request';
        acctReq.PRM_Partner_Role__c = 'Service Provider';
        acctReq.PRM_Salesforce_ID__c = testAccount.Id;
        acctReq.RecordTypeId = AccountCreateRT;
        insert acctReq; 
        system.runAs([SELECT id FROM User WHERE Email='testcontact1@spamok.com'][0]){
            PRM_CompanyProfileController.updateFlag(acctReq.Id,'Approve');
            PRM_CompanyProfileController.updateFlag(acctReq.Id,null);
            
            PRM_CompanyProfileController.approveRejectRequestsByPC(new List<Id>{acctReq.Id});
            PRM_CompanyProfileController.approveRejectRequestsByPC(null);
        }
        //PRM_PC_Approve_Reject_Flag__c
        PRM_Registration_Request__c regReq = [SELECT id,PRM_PC_Approve_Reject_Flag__c FROM PRM_Registration_Request__c WHERE Id= :acctReq.Id];
        system.assertEquals('Approved', regReq.PRM_PC_Approve_Reject_Flag__c);
        test.stopTest();
    }    
    private static testMethod void updateFlag_Reject_Test(){ 
        test.startTest();        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAccount1 = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
        Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        
        PRM_Registration_Request__c acctReq = new PRM_Registration_Request__c();
        acctReq.Name = 'Test Account Request';
        acctReq.PRM_First_Name__c = 'Test'; 
        acctReq.PRM_Last_Name__c = 'Account Request';
        acctReq.PRM_Email_ID__c = 'testemail123@spamok.com';
        acctReq.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        acctReq.PRM_Account_Name__c = 'Test Account Request';
        acctReq.PRM_Partner_Role__c = 'Service Provider';
        acctReq.PRM_Salesforce_ID__c = intelAccount1.Id;
        acctReq.RecordTypeId = AccountCreateRT;
        insert acctReq; 
        system.runAs([SELECT id FROM User WHERE Email='testcontact1@spamok.com'][0]){
            PRM_CompanyProfileController.updateFlag(acctReq.Id,'Reject');
            PRM_CompanyProfileController.approveRejectRequestsByPC(new List<Id>{acctReq.Id});    
            
        }
        PRM_Registration_Request__c regReq = [SELECT id,PRM_PC_Approve_Reject_Flag__c FROM PRM_Registration_Request__c WHERE Id= :acctReq.Id];
        system.assertEquals('Rejected', regReq.PRM_PC_Approve_Reject_Flag__c);
        test.stopTest();
    }
    
    private static testMethod void updateAccountInfo_Test(){ 
        test.startTest();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAccount1 = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
        PRM_CompanyProfileController.updateAccountInfo(intelAccount1.Id,'mytest@mytest.com','1231231230'); 
        Account acct = [SELECT Id, Core_User_Defined_Website__c, Core_User_Defined_Phone_Number__c FROM Account WHERE Id = :intelAccount1.Id];
        system.assertEquals('mytest@mytest.com', acct.Core_User_Defined_Website__c);
        system.assertEquals('1231231230', acct.Core_User_Defined_Phone_Number__c);
        test.stopTest();        
    }
    
    private static testMethod void getMyCompanySecondaryContacts_Test(){  
        test.startTest();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAccount1 = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
        Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        
        PRM_Registration_Request__c acctReq = new PRM_Registration_Request__c();
        acctReq.Name = 'Test Account Request';
        acctReq.PRM_First_Name__c = 'Test'; 
        acctReq.PRM_Last_Name__c = 'Account Request';
        acctReq.PRM_Email_ID__c = 'testemail123@spamok.com';
        acctReq.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        acctReq.PRM_Account_Name__c = 'Test Account Request';
        acctReq.PRM_Partner_Role__c = 'Service Provider';
        acctReq.PRM_Salesforce_ID__c = intelAccount1.Id;
        acctReq.RecordTypeId = AccountCreateRT;
        insert acctReq;
        system.runAs([SELECT id FROM User WHERE Email='testcontact1@spamok.com'][0]){
            String res = PRM_CompanyProfileController.getMyCompanySecondaryContacts();
            system.assert(!String.isEmpty(res));
        }
        test.stopTest();
    } 
    
    private static testMethod void getMyCompanyContacts_Test(){  
        test.startTest();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = intelAccRecTypeId;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.abc.com'; 
        insert testAccount;
        
        ChannelProgram cp = [SELECT id FROM ChannelProgram LIMIT 1];
        
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        
        Contact cnt = new Contact(FirstName = 'T12est',
                                  LastName ='C12ontact1',
                                  Email = 't12estc12ontact1@spamok.com',
                                  AccountId = testAccount.Id,
                                  RecordTypeId = IntelContRecTypeId,
                                  Phone='9999887971',
                                  MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456', Core_IPA_PartnerRole__c='Service Provider',Core_Preferred_Language__c='ENG', Core_Enterprise_Id__c ='123456789012',Core_Login_Status__c='Active');
        insert cnt;
        
        
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Employee';
        contRel.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
        insert contRel;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = testAccount.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        
        Core_ERPM_Engagement__c erpmEngagement = new Core_ERPM_Engagement__c();
        erpmEngagement.Name = 'Intel Partner Alliance';
        erpmEngagement.Core_IsActive__c = True;
        erpmEngagement.Core_Engagement_Type__c = 'SEC';
        erpmEngagement.Core_Technical_DeDup_Number__c = 'DEDUPGPIPA';
        insert erpmEngagement;
        
        Core_Entitlement__c coreEntitlement = new Core_Entitlement__c();
        coreEntitlement.Core_ERPM_Engagement_Id__c = erpmEngagement.Id;
        coreEntitlement.Core_IsActive__c = True;
        coreEntitlement.Core_Display_Name__c = 'EMPLOYEE';
        insert coreEntitlement;
        
        Core_Contact_Entitlement__c contEntitlement = new Core_Contact_Entitlement__c();
        contEntitlement.Core_Contact_Id__c = cnt.Id;
        contEntitlement.Core_Entitlement_Id__c = coreEntitlement.Id;
        contEntitlement.Core_Unique_Id__c = 'EMPLOYEE';
        contEntitlement.Core_Selected__c = true;
        contEntitlement.Core_Status__c = 'Complete';
        
        
        Profile p12 = [SELECT Id FROM Profile WHERE Name='Partner'];
        
        User us = new User(Alias = 'bblackk', Email='t12estc12ontact1@spamok.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p12.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samueltest.robert2@intel.com', contactid = cnt.Id);
        Insert us;
        
        system.runAs(us){
            PRM_CompanyProfileController.getMyCompanyContacts();
        }
        test.stopTest();
    } 
    
    /*private static testMethod void partnerAssist_Test(){ 
        test.startTest();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account partnerAccount = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
        Contact partnerContact = [SELECT id FROM Contact WHERE AccountId=:partnerAccount.id LIMIT 1];
        System.assertEquals(true,PRM_CompanyProfileController.savePartnerAssist(partnerAccount.id,'TestDistributor2','TestDistributor3' ,true,partnerContact.id));
        PRM_Partner_Consent_Distributor__c distributorSecondary = [Select id from PRM_Partner_Consent_Distributor__c where PRM_Distributor_Name_Txt__c  = 'TestDistributor2' Limit 1];
        
        PRM_Partner_Assist_Consent__c partAssistConsent = new PRM_Partner_Assist_Consent__c();
        partAssistConsent.PRM_Consent_Provided_Ind__c =True;
        partAssistConsent.PRM_Consent_Provided_By_Id__c = partnerContact.Id;
        partAssistConsent.PRM_Consent_Provided_Date_Dt__c = System.now();
        partAssistConsent.PRM_End_Date_Dt__c = Null;
        partAssistConsent.PRM_Choice_Nm__c = secondaryConsent;
        partAssistConsent.PRM_Account_Id__c = partnerAccount.id;
        partAssistConsent.PRM_Distributor_Id__c = distributorSecondary.Id;
        insert partAssistConsent;
        System.assertEquals(true,PRM_CompanyProfileController.savePartnerAssist(partnerAccount.id,'','' ,true,partnerContact.id));
        System.assertEquals(true,PRM_CompanyProfileController.savePartnerAssist(partnerAccount.id,'TestDistributor1','Select any Distributor 2' ,true,partnerContact.id));
        System.assertEquals(true,PRM_CompanyProfileController.savePartnerAssist(partnerAccount.id,'TestDistributor1','TestDistributor3' ,true,partnerContact.id));
        //System.assertEquals(true,PRM_CompanyProfileController.savePartnerAssist(partnerAccount.id,'TestDistributor1','TestDistributor3' ,false,partnerContact.id));
        //System.assertEquals(false,PRM_CompanyProfileController.savePartnerAssist(partnerContact.id,'TestDistributor1','TestDistributor3' ,true,partnerAccount.id));
        //    }
        test.stopTest();
    }*/
    
    private static testMethod void getpartnerAssist_Test(){ 
        test.startTest();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account partnerAccount = [SELECT id FROM Account WHERE RecordTypeId=:intelAccRecTypeId LIMIT 1];
        Contact partnerContact = [SELECT id FROM Contact WHERE AccountId=:partnerAccount.id LIMIT 1];
        PRM_Partner_Consent_Distributor__c distributorSecondary = [Select id from PRM_Partner_Consent_Distributor__c where PRM_Distributor_Name_Txt__c  = 'TestDistributor2' Limit 1];
        
        PRM_CompanyProfileController.getPartnerAssist(partnerAccount.id);
        PRM_Partner_Assist_Consent__c partAssistConsent = new PRM_Partner_Assist_Consent__c();
        partAssistConsent.PRM_Consent_Provided_Ind__c =True;
        partAssistConsent.PRM_Consent_Provided_By_Id__c = partnerContact.Id;
        partAssistConsent.PRM_Consent_Provided_Date_Dt__c = System.now();
        partAssistConsent.PRM_End_Date_Dt__c = Null;
        partAssistConsent.PRM_Choice_Nm__c = secondaryConsent;
        partAssistConsent.PRM_Account_Id__c = partnerAccount.id;
        partAssistConsent.PRM_Distributor_Id__c = distributorSecondary.Id;
        insert partAssistConsent;
        List<PRM_CompanyProfileController.PartnerAssist> pAssist = PRM_CompanyProfileController.getPartnerAssistList(partnerAccount.id);
        system.assert(pAssist.size() > 0);
        PRM_Partner_Assist_Consent__c updatePartnerAssistInd = [Select id,PRM_Consent_Provided_Ind__c from PRM_Partner_Assist_Consent__c where id =:partAssistConsent.id Limit 1];
        updatePartnerAssistInd.PRM_Consent_Provided_Ind__c = false;
        update updatePartnerAssistInd;
        PRM_CompanyProfileController.getPartnerAssistList(partnerAccount.id);
        PRM_Partner_Assist_Consent__c updatePartnerAssistPrimary = [Select id,PRM_Consent_Provided_Ind__c from PRM_Partner_Assist_Consent__c where PRM_Choice_Nm__c = :primaryConsent Limit 1];
        updatePartnerAssistPrimary.PRM_Consent_Provided_Ind__c = false ;
        update updatePartnerAssistPrimary;
        PRM_CompanyProfileController.getPartnerAssistList(partnerAccount.id);
        test.stopTest();
    }        
    
    public static testMethod void testGetTermsandConditions(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner'];
        
        List<String> blacklistDomains = new List<String>();
        blacklistDomains.add('abc.com');
        blacklistDomains.add('hcl.com');
        
        
        
        
        //   test.startTest(); 
        ChannelProgram cp = [SELECT id FROM ChannelProgram LIMIT 1];
        
        Account parent1 = new Account();
        parent1.RecordTypeId = recordTypeIdPagAccount;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent1.Industry='Construction';  
        insert parent1; 
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingState='OR';
        testAccount.BillingPostalCode = '65436';
        testAccount.ShippingCity = 'USA';
        testAccount.ShippingCountryCode = 'USA';
        testAccount.ShippingCountry = 'USA';
        testAccount.ShippingLatitude = 23.21;
        testAccount.ShippingLongitude = 32.21;
        testAccount.ShippingPostalCode = '12334';
        testAccount.ShippingState = 'OR';
        testAccount.ShippingStateCode = 'OR';
        testAccount.ShippingStreet = '1538 Dogwood Lane';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.intel.com'; 
        testAccount.Core_IPA_One_Partner_Id__c = parent1.Id;
        testAccount.Core_IPA_Partner_Role__c = 'Service Provider';
        insert testAccount;
        
        Contact con2 = new Contact();
        con2.FirstName='Ivory';
        con2.LastName='Smithy';
        con2.Email='testivorysmithy@intel.com';
        con2.Phone='9999779791';
        con2.AccountId = testAccount.Id;
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';        
        con2.Core_Login_Id__c = 'tuv';
        con2.MailingCountry='USA';
        insert con2;
        
        List<PRM_Documents__c> doclist = new List<PRM_Documents__c>();
        PRM_Documents__c doc = new PRM_Documents__c();
        doc.Title__c = 'image';
        doc.Document_Id__c = '12asvghn987';
        doc.Document_Type__c = 'Terms and Conditions';
        doc.Account__c = testAccount.id;
        doclist.add(doc);
        
        insert doclist;
        
        User u = new User(Alias = 'bblac', Email='testivorysmithy@intel.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samuel.robert78@intel.com', contactid = con2.Id);
        Insert u;
        
        
        PRM_CompanyProfileController.LegalAgreementWrapper lr = new PRM_CompanyProfileController.LegalAgreementWrapper();
        lr.RecordId = testAccount.id;
        lr.LegalAgreementName = 'LegalAgreementNametest';
        lr.LegalAgreementSignedBy = 'LegalAgreementSignedBytest';
        lr.LegalAgreementSignedDate = system.now();
        
        
        List<PRM_CompanyProfileController.ProfileResponse> prslist = new List<PRM_CompanyProfileController.ProfileResponse>();
        PRM_CompanyProfileController.ProfileResponse pr = new PRM_CompanyProfileController.ProfileResponse();
        pr.RecordId = testAccount.id;
        pr.QuestionText = 'QuestionTexttest';
        pr.QuestionCode = 'QuestionCodetest';
        pr.ResponseText = 'ResponseText';
        prslist.add(pr);
        
        PRM_CompanyProfileController.ProfileResponse pr11 = new PRM_CompanyProfileController.ProfileResponse();
        pr11.RecordId = testAccount.id;
        pr11.QuestionText = 'Questiontestst';
        pr11.QuestionCode = 'QuestionCodetest1';
        pr11.ResponseText = 'ResponseText1';
        prslist.add(pr11);
        
        List<PRM_CompanyProfileController.documentWrapper> dwList = new List<PRM_CompanyProfileController.documentWrapper>();
        PRM_CompanyProfileController.documentWrapper dw = new PRM_CompanyProfileController.documentWrapper();
        dw.title = 'xyzdoc';
        dw.documentId = '765hgb12hs';
        dwList.add(dw);
        
        List<PRM_CompanyProfileController.CompanyInfoWrapper> compList = new List<PRM_CompanyProfileController.CompanyInfoWrapper>();
        PRM_CompanyProfileController.CompanyInfoWrapper compdesc = new PRM_CompanyProfileController.CompanyInfoWrapper();
        compdesc.OptInPoints = 'Eligible'; 
        compdesc.ProfileResponses = prslist;
        compList.add(compdesc);
        
        
        PRM_CompanyProfileController.CompanyInfoAndRoleDescWrapper comwrap = new PRM_CompanyProfileController.CompanyInfoAndRoleDescWrapper();
        
        List<PRM_CompanyProfileController.SecondaryContactWrapper> secConWrapList = new List<PRM_CompanyProfileController.SecondaryContactWrapper>();
        PRM_CompanyProfileController.SecondaryContactWrapper secConWrap = new PRM_CompanyProfileController.SecondaryContactWrapper();
        secConWrap.Responsibilities = 'Employee'; 
        secConWrap.Status = 'Eligible'; 
        secConWrap.EVVerificationDateTime = datetime.newInstance(2021, 9, 15, 12, 30, 0); 
        secConWrap.isLoggedinUser = true; 
        secConWrap.isPrimary = true; 
        secConWrapList.add(secConWrap);
        
        String answerCode = system.label.IPA_Acceptable_Domains;        
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cp.Id;
        pq.PRM_Question_Display_Txt__c = 'Whitelisted Domains';
        pq.PRM_Question_Cd__c = answerCode;
        insert pq;
        
        PRM_Profile_Answer__c profAns = new PRM_Profile_Answer__c(PRM_Answer_Cd__c=answerCode,PRM_Answer_Display_Txt__c='Whitelisted Domains Answer', PRM_Profile_Questions_Id__c=pq.Id);
        insert profAns;        
        
        
        PRM_Profile_Responses__c pr1 = new PRM_Profile_Responses__c();
        pr1.PRM_Account_Id__c = testAccount.Id;
        pr1.PRM_Profile_Questions_Id__c = pq.Id;
        pr1.PRM_Profile_Answer_Id__c = profAns.Id;
        pr1.PRM_InActive_Ind__c = false;
        pr1.PRM_Response_Txt__c = 'spamok.com';   
        insert pr1;
        
        test.startTest(); 
        System.runAs(u){
            PRM_CompanyProfileController.getTermsandConditions();
            PRM_CompanyProfileController.getCompanyAndRoleInfo();
            
        }

        PRM_CompanyProfileController.showUploadedDoc(); 
        //PRM_CompanyProfileController.isLoggedInUserPrimaryContact();
        PRM_CompanyProfileController.getUploadedTermsnCondition(dwList,testAccount.id);
        PRM_CompanyProfileController.getPartnerRoleLabel(testAccount.Core_IPA_Partner_Role__c);
        //PRM_CompanyProfileController.getCompanyInfo(testAccount, true, testAccount.Core_IPA_Partner_Role__c, blacklistDomains);
       // PRM_CompanyProfileController.getProfileResponses(pr1.id);
        test.stopTest();
        
    }  
    
    
    
}