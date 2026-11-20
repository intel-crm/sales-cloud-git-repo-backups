@isTest
public class Core_Entitlement_Out_Int_Test { 
    //public static Integer currentNumber = 1;
    
    @isTest static void ValidateAccountBenefits(){
        Contact testConObj = createTestContact();
        createTestContactEntitlement(testConObj, 1);
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem, false, false);
        
        //List<PRM_AccountBenefitAssociation__c> bnft = CreateAccountBenefitAssociation(testConObj, acctConMem);
        List<PRM_AccountBenefitAssociation__c> bnft = new List<PRM_AccountBenefitAssociation__c>();
        bnft = CreateAccountBenefitAssociation(testConObj, acctConMem);
        
                
        Test.startTest();
        
        //List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //Draco
        List<Core_Integration_Outbound_Message__c> lstIntOBM = new List<Core_Integration_Outbound_Message__c>();
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //Draco
        Integer currentNumErpmObm = lstIntOBM.size();
        
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(bnft, bnft.getSObjectType());
        cntsts.execute(null);
        Test.stopTest();
        
        Contact cnt= new contact();
        cnt = [SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c FROM Contact where id=: testConObj.Id];
        Account act = new Account();
        act = [SELECT Id FROM Account WHERE Id =: testConObj.AccountId];
         //System.assertEquals('In-Progress', cnt.Core_ERPM_Integration_Status__c); 
        //System.assertEquals('Full', cnt.Core_ERPM_Integration_Queue_txt__c); 
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        
    }
    
    /* @isTest static void ValidateAccountBenefits(){

List<Contact> lstTestContacts = new List<Contact>();
Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
Contact testConObj = createTestContact();
createTestContactEntitlement(testConObj, 1);        
lstTestContacts.add(testConObj);
ChannelProgram ChnlPrg = CreateChannelProgram();                       

ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
cpl.PRM_programlevelcode__c='Titanium';
cpl.Name='Titanium';
cpl.ProgramId=ChnlPrg.Id;

insert cpl;

ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
cpl2.Name='Member';
cpl2.ProgramId=ChnlPrg.Id;
insert cpl2;

ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
cpl1.Name='Gold';
cpl1.ProgramId=ChnlPrg.Id;
insert cpl1; 


List<PRM_AccountChannelMembership__c> acctMem = new List<PRM_AccountChannelMembership__c>();
PRM_AccountChannelMembership__c acctMembership = new PRM_AccountChannelMembership__c();        
acctMembership.PRM_Account_Id__c = testConObj.AccountId;
acctMembership.PRM_Channel_Program_Id__c = ChnlPrg.Id;
acctMembership.PRM_Channel_Program_Level_Id__c = cpl.Id;
acctMembership.PRM_Status_Nm__c = 'Pending';        
acctMembership.PRM_Partner_Role__c = 'Service Provider';
acctMem.add(acctMembership);
insert acctMembership;
//System.enqueuejob(new ContactERPMIntegrationStatusHandler(acctMem,acctMembership.getSObjectType()));


List<PRM_Account_Contact_Relationship__c> acctRel = new List<PRM_Account_Contact_Relationship__c>();
PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctMembership, false ,false);
acctRel.add(rel);

acctMembership.PRM_Status_Nm__c= 'Approved';
update acctMembership;

PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
pb.Name='Technology Sandbox';
pb.PRM_Benefit_Cd__c = 'BFTSNDBX';
pb.PRM_Channel_Program_Id__c = ChnlPrg.id;
pb.PRM_Account_Type_Nm__c = 'Mastered_Account';
insert pb;


PRM_PartnerType__c pt = new PRM_PartnerType__c(); //Partner Type
pt.Name = 'Cloud Service Provider (CSP)';
pt.PRM_PartneryTypeCode__c = 'CSP';
pt.PRM_PartnerRoleCode__c = 'SPR';
pt.PRM_channelprogram__c = ChnlPrg.id;
insert pt;

PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
bm.PRM_Partner_Benefit_Id__c = pb.id;
bm.PRM_Channel_Program_Id__c = ChnlPrg.id;
bm.PRM_Channel_Program_Level_Id__c = cpl.id;
bm.PRM_Partner_Type_Id__c = pt.id;
bm.PRM_Covered_Account_Ind__c  = true;
bm.PRM_Approval_Type_Nm__c = 'Automatic';
bm.PRM_Partner_Role_Nm__c='Service Provider';

insert bm;//Benefit Matrix insertion with Member as CPL
//database.insert(bm,false);       

PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
pb1.Name='Marketing Studio';
pb1.PRM_Benefit_Cd__c = 'BFTMKTSTD';
pb1.PRM_Channel_Program_Id__c = ChnlPrg.id;
pb1.PRM_Account_Type_Nm__c = 'Mastered_Account';
insert pb1;

PRM_VXBnftMatrix__c bm1 = new PRM_VXBnftMatrix__c(); //Benefit Matrix
bm1.PRM_Partner_Benefit_Id__c = pb1.id;
bm1.PRM_Channel_Program_Id__c = ChnlPrg.id;
bm1.PRM_Channel_Program_Level_Id__c = cpl.id;
bm1.PRM_Partner_Type_Id__c = pt.id;
bm1.PRM_Covered_Account_Ind__c  = true;
bm1.PRM_Approval_Type_Nm__c = 'Automatic';
bm1.PRM_Partner_Role_Nm__c='Service Provider';

insert bm1;//Benefit Matrix insertion with Titanium as CPL

List<PRM_AccountBenefitAssociation__c> accountBenefits = new List<PRM_AccountBenefitAssociation__c>();
PRM_AccountBenefitAssociation__c accntBenft = new PRM_AccountBenefitAssociation__c();        
accntBenft.PRM_Partner_Benefit_Id__c = pb.ID;
accntBenft.PRM_Account_Id__c = testConObj.AccountId;
accntBenft.PRM_Status_Nm__c = 'Active';
accntBenft.PRM_Source__c = 'Specialty';
accountBenefits.add(accntBenft);

//List<PRM_AccountBenefitAssociation__c> accountBenefits = new List<PRM_AccountBenefitAssociation__c>();
PRM_AccountBenefitAssociation__c accntBenft1 = new PRM_AccountBenefitAssociation__c();        
accntBenft1.PRM_Partner_Benefit_Id__c = pb1.ID;
accntBenft1.PRM_Account_Id__c = testConObj.AccountId;
accntBenft1.PRM_Status_Nm__c = 'Active';
accntBenft1.PRM_Source__c = 'Specialty';
accountBenefits.add(accntBenft1);

      
insert accountBenefits;





//System.enqueuejob(new ContactERPMIntegrationStatusHandler(acctRel,rel.getSObjectType()));



List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
Integer currentNumErpmObm = lstIntOBM.size();


Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
c.Core_ERPM_Integration_Status__c ='Pending';
update c;
Core_Entitlement_Outbound_Integrations.hasRun=false;
Test.startTest();  
Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
Test.stopTest();

lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
System.assertEquals(currentNumErpmObm+1, lstIntOBM.size()); 

}*/
    
    @isTest static void ValidateAccountLegalAgreements(){
        
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        
        Contact testConObj = createTestContact();
        //createTestContactEntitlement(testConObj, 3);
        createTestContactEntitlement(testConObj, 1);
        lstTestContacts.add(testConObj);
        
        ChannelProgram ChnlPrg = CreateChannelProgram();
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.PRM_programlevelcode__c='Titanium';
        cpl2.Name='Titanium';
        cpl2.ProgramId=ChnlPrg.Id;
        insert cpl2;
        ChannelProgramLevel cpl3=new ChannelProgramLevel(); //Channel Program Level
        cpl3.Name='Member';
        cpl3.ProgramId=ChnlPrg.Id;
        insert cpl3;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=ChnlPrg.Id;
        insert cpl1; 
        
        PRM_AccountChannelMembership__c acctMembership = new PRM_AccountChannelMembership__c();        
        acctMembership.PRM_Account_Id__c = testConObj.AccountId;
        acctMembership.PRM_Channel_Program_Id__c = ChnlPrg.Id;
        acctMembership.PRM_Channel_Program_Level_Id__c = cpl2.Id;
        acctMembership.PRM_Status_Nm__c = 'Pending';        
        acctMembership.PRM_Partner_Role__c = 'Service Provider';
        acctMembership.PRM_Status_Reason_Txt__c='Service Reason';
        insert acctMembership;
        CreateAccountContactRelationship(testConObj,acctMembership,false,false);
        
        
        List<PRM_PartnerAgreement__c> partnerAgreements = new List<PRM_PartnerAgreement__c>();
        PRM_PartnerAgreement__c prntAgrmnt = new PRM_PartnerAgreement__c();
        prntAgrmnt.PRM_Agreement_Cd__c ='AGRMNTCD001';
        prntAgrmnt.Name ='Parter Agreement Name 001';
        prntAgrmnt.PRM_InActive_Ind__c= false;
        prntAgrmnt.PRM_Channel_Program_Id__c = ChnlPrg.Id; 
        partnerAgreements.add(prntAgrmnt);
        
        prntAgrmnt = new PRM_PartnerAgreement__c();
        prntAgrmnt.PRM_Agreement_Cd__c ='AGRMNTCD002';
        prntAgrmnt.Name ='Parter Agreement Name 002';
        prntAgrmnt.PRM_InActive_Ind__c= false;
        prntAgrmnt.PRM_Channel_Program_Id__c = ChnlPrg.Id;
        prntAgrmnt.PRM_Language_Codes__c='RUS';
        partnerAgreements.add(prntAgrmnt);
        insert partnerAgreements;
        
        List<PRM_PartnerAgreement__c> partnerAgreementsList = [SELECT ID FROM PRM_PartnerAgreement__c WHERE PRM_Agreement_Cd__c IN ('AGRMNTCD001','AGRMNTCD002') ORDER BY PRM_Agreement_Cd__c ASC];
        
        List<PRM_AccountLegalAgreemntAssociation__c> accountLegalAgreements = new List<PRM_AccountLegalAgreemntAssociation__c>();
        PRM_AccountLegalAgreemntAssociation__c accntAgrment = new PRM_AccountLegalAgreemntAssociation__c();        
        accntAgrment.PRM_Partner_Agreement_Id__c = partnerAgreementsList[0].ID;
        accntAgrment.PRM_Account_Id__c = testConObj.AccountId;
        accntAgrment.PRM_Contact__c = testConObj.Id;
        accntAgrment.PRM_Agreement_Sign_Dt__c = datetime.now();
        accountLegalAgreements.add(accntAgrment);
        
        accntAgrment = new PRM_AccountLegalAgreemntAssociation__c();
        accntAgrment.PRM_Partner_Agreement_Id__c = partnerAgreementsList[1].ID;
        accntAgrment.PRM_Account_Id__c = testConObj.AccountId; 
        accntAgrment.PRM_Contact__c = testConObj.Id;
        accountLegalAgreements.add(accntAgrment);
        accntAgrment.PRM_Agreement_Sign_Dt__c = datetime.now(); 
        insert accountLegalAgreements;
        Test.startTest(); 
        acctMembership.PRM_Status_Nm__c = 'Approved';
        update acctMembership;
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
         Core_Entitlement_Outbound_Integrations.getPersonTitle('Miss');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size()); 
        
        Test.stopTest();
    }
    
    public static testmethod void testGenerateAGSOBM() {
        List<Contact> lstTestContacts = new List<Contact>();
        //Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
        
        Contact testConObj = createTestContact();
        //Contact testOldConObj = testConObj.clone(true, true, true, true);
        
        createTestContactEntitlement(testConObj, 3);
        
        
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        //testOldConObj.Core_ERPM_Integration_Status__c = 'Pending';
        //testOldConObj.Core_AGS_Integration_Status__c = 'Pending';
        //testOldConObj.Core_Enterprise_Id__c = ' ';//draco
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Employee', Core_Display_Name__c='test account setup',Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c ='B2B' );
        lstEnt.add(entitle);
        
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='Employee1', Core_Display_Name__c='test account setup1',Core_IsActive__c=true, Entitlement_B2B_B2C_Indicator__c ='B2B');
        lstEnt.add(entitle1); 
        
        lstTestContacts.add(testConObj);
        //lstOldTestContacts.put(testConObj.Id, testOldConObj);
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        //testOldConObj.Core_ERPM_Integration_Status__c = 'Successful';
        //testOldConObj.Core_AGS_Integration_Status__c = '';
        //testOldConObj.Core_Enterprise_Id__c = ' ';//draco
        
        lstTestContacts.clear();
        //lstOldTestContacts.clear();
        lstTestContacts.add(testConObj);
        //lstOldTestContacts.put(testConObj.Id, testOldConObj);
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
        system.assert(testConObj!=null);
        //Draco
        //Core_Entitlement_Outbound_Integrations.isCallOutboundMsg = false; 
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        //testOldConObj.Core_Enterprise_Id__c = ' ';
        //testOldConObj.Core_ERPM_Integration_Status__c = 'Successful'; 
        //testOldConObj.Core_AGS_Integration_Status__c = 'Successful';
        lstTestContacts.clear();
        lstTestContacts.add(testConObj);
        //lstOldTestContacts.put(testConObj.Id, testOldConObj); 
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        //Draco
        //changes by Mani
        List<Contact> lstTestContacts1 = new List<Contact>();
        //Map<Id,Contact> lstOldTestContacts1 = new Map<Id,Contact>();
        List<Account> acc = [Select id from Account where name = 'Outbound Test Account acc' limit 1];
        Contact conObj = new Contact();
        conObj.AccountId = acc[0].Id;
        conObj.Core_eRPM_Person_Id__c = '1157651';
        conObj.Core_Enterprise_Id__c = '123026';
        conObj.Core_Login_Id__c = '109255';
        conObj.FirstName = 'Integrations Tester';
        conObj.MailingCountry='USA';
        conObj.LastName = 'Per';
        conObj.Email = 'OITest123@tester.com';
        conObj.Core_English_Only_First_Name__c = 'Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Per';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.Core_Preferred_Language__c= 'ENG';
        conObj.MailingStreet = '12 Test St';
        conObj.MailingCity = 'Testcity';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '10145';
        conObj.Phone = '35768996';
        conObj.MobilePhone = '246589';
        conObj.Core_IPA_PartnerRole__c = 'Service Provider';
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        insert conObj;
        //Contact testOldConObj1 = testConObj.clone(true, true, true, true);
        //testConObj1.Core_Login_Id__c = null;
        //lstTestContacts1.add(testConObj1);
        //lstOldTestContacts1.put(testConObj1.Id, testOldConObj1);
        //Core_Entitlement_Outbound_Integrations.isCallOutboundMsg = false;
        // createTestContactEntitlement(testConObj, 1);
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        insert testAGSRole;
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c='B2B';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=lstTestContacts[0].Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        testConObj.Core_Enterprise_Id__c = '1111';
        update testConObj;
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        Assert.isnotNull(lstTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
        
        // Core_Entitlement_Outbound_Integrations.isCallOutboundMsg = true;
        
    }
    @IsTest
    public static void newtestGenerateAGSOBM(){
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account acc';
        acctObj.Core_CNDA_Number__c = '102233445560';
        acctObj.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acctObj.BillingStreet = '1221 Tester Account123456789123456789123456789123456789Account1123456789123456789123456789123456789Account11234567891234567891Account 1123456789123456789';
        acctObj.BillingCity = 'Testing City cty';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '120000';
        acctObj.ShippingStreet = 'Yemen';
        acctObj.ShippingCity = 'Testing City cty';
        acctObj.ShippingStateCode = 'OR';
        acctObj.ShippingCountryCode = 'USA';
        acctObj.ShippingPostalCode = '120000';
        acctObj.Core_User_Defined_Phone_Number__c = '1234567890';
        acctObj.Core_User_Defined_Website__c ='www.xyz.com';
        acctObj.Core_User_Defined_Number_of_Employees__c = '1-9';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acctObj.Core_CIM_ID__c = '123456789';
        acctObj.Industry = 'Agriculture';
        
        insert acctObj;
        
        List<Contact> lstTestContacts = new List<Contact>();
        //Map<Id,Contact> lstOldTestContacts1 = new Map<Id,Contact>();
        List<Account> acc = [Select id from Account where name = 'Outbound Test Account acc' limit 1];
        Contact conObj = new Contact();
        conObj.AccountId = acc[0].Id;
        conObj.Core_eRPM_Person_Id__c = '1157651';
        conObj.Core_Enterprise_Id__c = '123026';
        conObj.Core_Login_Id__c = '109255';
        conObj.FirstName = 'Integrations Tester';
        conObj.LastName = 'Per';
        conObj.MailingCountry='USA';
        conObj.Email = 'OITest123@tester.com';
        conObj.Core_English_Only_First_Name__c = 'Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Per';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.Core_Preferred_Language__c= 'ENG';
        conObj.MailingStreet = '12 Test St';
        conObj.MailingCity = 'Testcity';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '10145';
        conObj.Phone = '35768996';
        conObj.MobilePhone = '246589';
        conObj.Core_IPA_PartnerRole__c = 'Service Provider';
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        insert conObj;
        //Contact testOldConObj1 = testConObj.clone(true, true, true, true);
        //testConObj1.Core_Login_Id__c = null;
        lstTestContacts.add(conObj);
        //lstOldTestContacts1.put(testConObj1.Id, testOldConObj1);
        //Core_Entitlement_Outbound_Integrations.isCallOutboundMsg = false;
        // createTestContactEntitlement(testConObj, 1);
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        insert testAGSRole;
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='AGS';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=lstTestContacts[0].Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
        //testConObj.Core_AGS_Integration_Status__c = 'Pending';
        //testConObj.Core_Enterprise_Id__c = '1111';
        //update testConObj;
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        Assert.isnotNull(lstTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
    }
   @IsTest
    public static void newtestGenerateAGSOBM2(){
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account acc';
        acctObj.Core_CNDA_Number__c = '102233445560';
        acctObj.BillingStreet = '1221 Tester Account123456789123456789123456789123456789Account1123456789123456789123456789123456789Account11234567891234567891Account 1123456789123456789';
        acctObj.BillingCity = 'Testing City cty';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '120000';
        acctObj.ShippingStreet = 'Yemen';
        acctObj.ShippingCity = 'Testing City cty';
        acctObj.ShippingStateCode = 'OR';
        acctObj.ShippingCountryCode = 'USA';
        acctObj.ShippingPostalCode = '120000';
        acctObj.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acctObj.Core_User_Defined_Phone_Number__c = '1234567890';
        acctObj.Core_User_Defined_Website__c ='www.xyz.com';
        acctObj.Core_User_Defined_Number_of_Employees__c = '1-9';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acctObj.Core_CIM_ID__c = '123456789';
        acctObj.Industry = 'Agriculture';
        
        insert acctObj;
        
        List<Contact> lstTestContacts = new List<Contact>();
        //Map<Id,Contact> lstOldTestContacts1 = new Map<Id,Contact>();
        List<Account> acc = [Select id from Account where name = 'Outbound Test Account acc' limit 1];
        Contact conObj = new Contact();
        conObj.AccountId = acc[0].Id;
        conObj.Core_eRPM_Person_Id__c = '1157651';
        conObj.Core_Enterprise_Id__c = '123026';
        conObj.Core_Login_Id__c = '109255';
        conObj.FirstName = 'Integrations Tester';
        conObj.LastName = 'Per';
        conObj.Email = 'OITest123@tester.com';
        conObj.MailingCountry='USA';
        conObj.Core_English_Only_First_Name__c = 'Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Per';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.Core_Preferred_Language__c= 'ENG';
        conObj.MailingStreet = '12 Test St';
        conObj.MailingCity = 'Testcity';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '10145';
        conObj.Phone = '35768996';
        conObj.MobilePhone = '246589';
        conObj.Core_IPA_PartnerRole__c = 'Service Provider';
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        insert conObj;
        //Contact testOldConObj1 = testConObj.clone(true, true, true, true);
        //testConObj1.Core_Login_Id__c = null;
        lstTestContacts.add(conObj);
         List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
         Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
         testAGSRole.Name = 'Test SMP AGS Role ';
         testAGSRole.Core_IsActive__c = true;
         testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
         insert testAGSRole;
        User testUser = new User();
        testUser.LastName = 'User1';
        testUser.Alias = 'tuser1';
        testUser.Email = 'test.user1@intel.com';
        testUser.Username = 'test.user1@intel.com.crm.testclass';
        testUser.ProfileId = lstProfiles[0].id;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.ContactId =conObj.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        //testUser.UserRoleId =usr.id;
        testUser.IsActive=true;
		insert testUser;
        //lstOldTestContacts1.put(testConObj1.Id, testOldConObj1);
        //Core_Entitlement_Outbound_Integrations.isCallOutboundMsg = false;
        // createTestContactEntitlement(testConObj, 1);
       
        
        
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2C';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=lstTestContacts[0].Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
        //testConObj.Core_AGS_Integration_Status__c = 'Pending';
        //testConObj.Core_Enterprise_Id__c = '1111';
        //update testConObj;
       
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        Assert.isnotNull(lstTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
        
    }
   
    //draco
    public static testmethod void testGenerateAGSOBM1() {
        List<Contact> lstTestContacts = new List<Contact>();
        // /Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        //Contact testOldConObj = testConObj.clone(true, true, true, true);
        
        //lstOldTestContacts1.put(testConObj1.Id, testOldConObj1);
        //Core_Entitlement_Outbound_Integrations.isCallOutboundMsg = false;
        // createTestContactEntitlement(testConObj, 1);
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        insert testAGSRole;
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='AGS';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2C';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testConObj.Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
        //testConObj.Core_AGS_Integration_Status__c = 'Pending';
        //testConObj.Core_Enterprise_Id__c = '1111';
        //update testConObj;
        
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
    
         
        //testOldConObj.Core_Enterprise_Id__c = ' ';
        //testOldConObj.Core_ERPM_Integration_Status__c = 'Successful'; 
        //testOldConObj.Core_AGS_Integration_Status__c = 'Successful';
        
        lstTestContacts.add(testConObj);
        //lstOldTestContacts.put(testConObj.Id, testOldConObj); 
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
       Assert.isnotNull(lstTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
        system.assert(testConObj!=null);
        
    }
      public static testmethod void testGenerateAGSOBM3() {
        List<Contact> lstTestContacts = new List<Contact>();
        // /Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        //Contact testOldConObj = testConObj.clone(true, true, true, true);
        
        //lstOldTestContacts1.put(testConObj1.Id, testOldConObj1);
        //Core_Entitlement_Outbound_Integrations.isCallOutboundMsg = false;
        // createTestContactEntitlement(testConObj, 1);
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        insert testAGSRole;
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2C';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
          
            Core_Entitlement__c testEntitlementDetail2 = new Core_Entitlement__c();
        testEntitlementDetail2.Name = 'TestNew SMP Entitilement Detail ';
        testEntitlementDetail2.Core_Display_Name__c = 'SMPNew Entitlement Detail ';
        testEntitlementDetail2.Core_Entitlement_Type__c ='AGS';
        testEntitlementDetail2.Entitlement_B2B_B2C_Indicator__c = 'B2C';
        testEntitlementDetail2.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail2.Core_IsActive__c = true;
        insert testEntitlementDetail2;
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testConObj.Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
           Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testConObj.Id, Core_From_Source__c=true, Core_Selected__c=false,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail2.id,Core_Status__c ='Pending');
        insert ce2;
        //testConObj.Core_AGS_Integration_Status__c = 'Pending';
        //testConObj.Core_Enterprise_Id__c = '1111';
        //update testConObj;
        
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
    
         
        //testOldConObj.Core_Enterprise_Id__c = ' ';
        //testOldConObj.Core_ERPM_Integration_Status__c = 'Successful'; 
        //testOldConObj.Core_AGS_Integration_Status__c = 'Successful';
        
        lstTestContacts.add(testConObj);
        //lstOldTestContacts.put(testConObj.Id, testOldConObj); 
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        Assert.isnotNull(lstTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
          
    
        
    }
    
    public static testmethod void testGenerateAGSOBM4() {
        List<Account> acc1 = [Select id from Account where name = 'Outbound Test Account acc' limit 1];
        List<Contact> lstTestContacts = new List<Contact>();
        Contact testConObj = createTestContact();
         List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
         Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
         testAGSRole.Name = 'Test SMP AGS Role ';
         testAGSRole.Core_IsActive__c = true;
         testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
         insert testAGSRole;
        
        User testUser = new User();
        testUser.LastName = 'User1';
        testUser.Alias = 'tuser1';
        testUser.Email = 'test.user1@intel.com';
        testUser.Username = 'test.user1@intel.com.crm.testclass';
        testUser.ProfileId = lstProfiles[0].id;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.ContactId =testConObj.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive=false;
		insert testUser;
       
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2C';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
          
        Core_Entitlement__c testEntitlementDetail2 = new Core_Entitlement__c();
        testEntitlementDetail2.Name = 'TestNew SMP Entitilement Detail ';
        testEntitlementDetail2.Core_Display_Name__c = 'SMPNew Entitlement Detail ';
        testEntitlementDetail2.Core_Entitlement_Type__c ='AGS';
        testEntitlementDetail2.Entitlement_B2B_B2C_Indicator__c = 'B2C';
        testEntitlementDetail2.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail2.Core_IsActive__c = true;
        insert testEntitlementDetail2;
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testConObj.Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
           Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testConObj.Id, Core_From_Source__c=true, Core_Selected__c=false,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail2.id,Core_Status__c ='Pending');
        insert ce2;
       
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        lstTestContacts.add(testConObj);
       
        Assert.isnotNull(lstTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
          
    }
    
    public static testmethod void testGenerateAGSOBM5() {
        List<Contact> lstTestContacts = new List<Contact>();
        Contact testConObj = createTestContact();
        
         List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
         Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
         testAGSRole.Name = 'Test SMP AGS Role ';
         testAGSRole.Core_IsActive__c = true;
         testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
         insert testAGSRole;
        
        User testUser = new User();
        testUser.LastName = 'User2';
        testUser.Alias = 'tuser2';
        testUser.Email = 'test.user2@intel.com';
        testUser.Username = 'test.user2@intel.com.crm.testclass';
        testUser.ProfileId = lstProfiles[0].id;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.ContactId =testConObj.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive=true;
		insert testUser;
        
        Core_Entitlement__c testEntitlementDetail2 = new Core_Entitlement__c();
        testEntitlementDetail2.Name = 'TestNew SMP Entitilement Detail ';
        testEntitlementDetail2.Core_Display_Name__c = 'SMPNew Entitlement Detail ';
        testEntitlementDetail2.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail2.Entitlement_B2B_B2C_Indicator__c = 'B2C';
        testEntitlementDetail2.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail2.Core_IsActive__c = true;
        insert testEntitlementDetail2;
        
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testConObj.Id, Core_From_Source__c=true, Core_Selected__c=false,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail2.id,Core_Status__c ='Pending');
        insert ce2;
        
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        lstTestContacts.add(testConObj);
        
        Assert.isnotNull(lstTestContacts);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts);
          
    }
    
    public static testmethod void testGenerateERPMOBM() {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,false);
        acctConMem.PRM_Status_Nm__c = 'Approved';
        update acctConMem;
        lstTestContacts.add(testConObj);
        Test.startTest();
        Contact c = new contact();
        c = [Select Id,Core_ERPM_Integration_Queue_txt__c, Core_ERPM_Integration_Status__c from Contact where id=:testConObj.Id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        c.Core_AGS_Republish_Ind__c = false;
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        createTestContactEntitlement(testConObj, 1);
        
        
        c = [Select Id,Core_ERPM_Integration_Queue_txt__c, Core_ERPM_Integration_Status__c from Contact where id=:testConObj.Id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = new List<Core_Integration_Outbound_Message__c>();
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());
        
        createTestSMPContactEntitlement(testConObj, 2);
        Test.stopTest();
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        currentNumErpmObm = lstIntOBM.size();
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts,lstOldTestContacts);
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts); 
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        
        createTestEmailTriggerForEntitlement(testConObj, 3);
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c 
                     from Core_Integration_Outbound_Message__c 
                     where Core_MessageType__c='ERPM Contact Entitlement' limit 100];
        currentNumErpmObm = lstIntOBM.size();
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts,lstOldTestContacts);
       
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
        
        
    }
    
    public static testmethod void testGenerateERPMOBM1() {
        Account acc = createTestAccount();
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        List<Contact> lstCont = new List<Contact>();
        List<Core_Entitlement__c> lstEnt = new List<Core_Entitlement__c>();
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.testsetup',MailingCountry='USA',
                                          AccountId=acc.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_ERPM_Integration_Status__c = 'Pending',Core_eRPM_Person_Id__c = '111111');
        lstCont.add(testContact);
        Contact testContact1 = new Contact(FirstName='testFirstName122', LastName='testLastName', Email='test123@testing.com.testsetup',MailingCountry='USA',
                                           AccountId=acc.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12346',Core_ERPM_Integration_Status__c = 'Pending');
        lstCont.add(testContact1); 
        insert lstCont;
        lstTestContacts.add(testContact);
        lstTestContacts.add(testContact1);     
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Employee', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='test account setup',Core_IsActive__c=true);
        lstEnt.add(entitle);
        
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='Employee1', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_ERPM_Engagement_Id__c=cee.id,Core_Help_Text__c='Help text',Core_Display_Name__c='test account setup1',Core_IsActive__c=true);
        lstEnt.add(entitle1); 
        insert lstEnt;
        Test.startTest();
        List<Core_Contact_Entitlement__c> lstContEnt = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,
                                                                         Core_Entitlement_Id__c=entitle1.id,
                                                                         Core_Selected__c=true,Core_Status__c = 'In Progress');
        lstContEnt.add(ce);
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=entitle.id,
                                                                          Core_Selected__c=true,Core_Status__c = 'In Progress');
        lstContEnt.add(ce1);
        insert lstContEnt;
        Assert.isNotNull(lstTestContacts);
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        Test.stopTest();
    }
    
    public static testmethod void OtbndMsgACMApproved()
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
       
        CreateContactSubscriptionAssoction(testConObj);
       
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST1');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK1');
        
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,false);
        acctConMem.PRM_Status_Nm__c = 'Approved';
        
        Test.startTest();
        update acctConMem;
        createTestContactEntitlement(testConObj, 1);
        lstTestContacts.add(testConObj);
        
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
       Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        
        
        Test.stopTest();
        
    }
    
    public static testmethod void OtbndMsgACMPending()
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        CreateContactSubscriptionAssoction(testConObj);
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST2');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK2');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,false);
        Test.startTest();
        createTestContactEntitlement(testConObj, 1);
        lstTestContacts.add(testConObj);
        
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        
        
        Test.stopTest();
        
    }
    
    public static testmethod void OtbndMsgACRelPending()
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        CreateContactSubscriptionAssoction(testConObj);
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST3');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK3');
         PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,true);
         Test.startTest();
        createTestContactEntitlement(testConObj, 3);
        lstTestContacts.add(testConObj);
        
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;        
        
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];

        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        
        
        Test.stopTest();
        
    }
    
    
    /*  Create another method for Generating ERPM Outbound Message for IPA (BlackBox API)
1. CreateTestContact() method in which we need to also call CreateTestAccount() method.
2. CreateAccountChannelMembership() method
3. CreateChannelProgram() method
*/
    
    public static testmethod void GenerateERPMOutboundMsg() 
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        CreateContactSubscriptionAssoction(testConObj);
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST4');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK4');
         PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,false);
         acctConMem.PRM_Status_Nm__c = 'Approved';
        Test.startTest();
        update acctConMem;
        createTestContactEntitlement(testConObj, 3);
        lstTestContacts.add(testConObj);
        
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
         
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        
        
        Test.stopTest();
        
    }
    
    
    public static testmethod void GenerateERPMOutboundMsg_NewUser_Inactivate_User() 
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        CreateContactSubscriptionAssoction(testConObj);
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST');
        //CreateProfileResponsesForCnctAndAcct(testConObj,'HSK');
        Test.startTest();
        createTestContactEntitlement(testConObj, 1);
        lstTestContacts.add(testConObj);
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
                
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size()); 
            List<PRM_BatchCustomSetting__c> prmbatchsetting= new List<PRM_BatchCustomSetting__c>();
            PRM_BatchCustomSetting__c rec1 = new PRM_BatchCustomSetting__c() ;
            rec1.Name='BatchFieldValues';
            rec1.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
            rec1.PRM_PartnerRole__c='Service Provider';
            rec1.PRM_PartnerType__c='Cloud Service Provider (CSP)';
		    prmbatchsetting.add(rec1);
            insert prmbatchsetting;
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,true,false);
        rel.PRM_Status_Nm__c = 'Complete';
        update rel;
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        currentNumErpmObm = lstIntOBM.size();
        
        c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
         lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size()); 
        
        Test.stopTest();
        
    }
    
    
    public static testmethod void GenerateERPMOtbndMsgWithMemPending()
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = CreateTestContact();
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        Test.startTest();
        createTestContactEntitlement(testConObj, 1);
        lstTestContacts.add(testConObj);
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        Core_Entitlement_Outbound_Integrations.publishERPMMessage(lstTestContacts, lstOldTestContacts);
        
                lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        
        
        Test.stopTest();
        
    }
    
  /*  public static testmethod void testGenerateBoxBAccountOBM() {
        List<Account> lstAccounts = new List<Account>();
        Map<Id,Account> mapOldAccounts = new Map<Id,Account>();
        
        Account acctObj = createB2BTestAccount();
        Account acctOldObj = acctObj.clone(true,true,true,true);
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='BoxB Account'];
        
        acctOldObj.Name = 'Old Name';
        
        lstAccounts.add(acctObj);
        mapOldAccounts.put(acctObj.id, acctOldObj);
        
        Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage(lstAccounts, mapOldAccounts);
        Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage(lstAccounts, null);
        
        lstAccounts = new List<Account>();
        
        acctObj.Core_Deactivated__c = true;
        acctObj.Name = 'Old Name';
        
        lstAccounts.add(acctObj);
        
        Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage(lstAccounts, mapOldAccounts);
        system.assert(acctObj!=null);
    }*/
    public static testmethod void testGenerateERPMOnCIMUpdate() {
        List<Contact> lstTestContacts = new List<Contact>();
        Contact testConObj = createB2BTestContact();
        
        createTestContactEntitlement(testConObj, 3);
        
        lstTestContacts.add(testConObj);
        
        List<Account> lstAccounts = new List<Account>();
        Map<Id,Account> mapOldAccounts = new Map<Id,Account>();
        
        
        Account acctObj = [Select id, Name, Core_CNDA_Number__c, BillingStreet,BillingCity,BillingStateCode,BillingCountryCode,
                           BillingPostalCode,Phone,Core_Account_Legal_Name__c,Core_IsODM__c,Core_B2B_ERPM_Account_Number__c,
                           Core_English_Only_Name__c, Core_Alternate_Language_Name__c, Core_B2B_Entitlement__c,
                           BillingCountry, BillingState, Core_CIM_ID__c,RecordTypeId,Core_Intel_Partner_Alliance_PartnerGroup__c,
                           ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode, ShippingStreet
                           from Account where id=:testConObj.AccountId];
        
        Account acctOldObj = new Account();
        acctOldObj = acctObj.clone(true,true,true,true);
        /*acctOldObj.Name = 'Old Outbound Test Account';
acctOldObj.Core_CNDA_Number__c = '112233445566';
acctOldObj.BillingStreet = '1234 Tester Account';
acctOldObj.BillingCity = 'Testing City';
acctOldObj.BillingStateCode = 'OR';
acctOldObj.BillingCountryCode = 'USA';
acctOldObj.BillingPostalCode = '12345';
acctOldObj.Phone = '1234567890';
acctOldObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
acctOldObj.Core_IsODM__c = false;
acctOldObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
acctOldObj.Core_English_Only_Name__c = 'Outbound Test Account';
acctOldObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';

insert acctOldObj;*/
        acctObj.Name = 'New Outbound Test Account';
        
        lstAccounts.add(acctObj);
        mapOldAccounts.put(acctObj.id, acctOldObj);
        
        
        Core_Entitlement_Outbound_Integrations.runOnce = false;
        Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate(lstAccounts, mapOldAccounts);
        
        acctOldObj.Name = 'New Outbound Test Account';
        acctObj.Core_English_Only_Name__c = 'New English Only Name Outbound Test Account';
        
        lstAccounts = new List<Account>();
        lstAccounts.add(acctObj);
        mapOldAccounts.put(acctObj.id, acctOldObj);
        Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate(lstAccounts, mapOldAccounts);
        system.assert(acctObj!=null);
    }
    
    public static testmethod void testSmartSplitLogic1() {
        // Scenario 1: String less than partition length
        List<String> stringList = new List<String>();
        String testString = '12345 tester street';
        
        Test.startTest();
        stringList = Core_Entitlement_Outbound_Integrations.smartSplit(testString, 125);
        Test.stopTest();
        
        System.assert(stringList.size() == 1);
        
        
        
    }
    
    public static testmethod void testSmartSplitLogic2() {
        // Scenario 2: String greater than partition length
        List<String> stringList = new List<String>();
        String testString = '12345 tester test testing testerino testing street';
        
        Test.startTest();
        stringList = Core_Entitlement_Outbound_Integrations.smartSplit(testString, 20);
        Test.stopTest();
        
        System.assert(stringList.size() == 3);
        System.assertEquals(17,stringList[0].length());
        System.assertEquals(17,stringList[1].length());
        System.assertEquals('12345 tester test',stringList[0]);
        System.assertEquals('testing testerino',stringList[1]);
    }
    
    public static testmethod void testSmartSplitLogic3() {
        // Scenario 3: String is null
        List<String> stringList = new List<String>();
        String testString = null;
        
        Test.startTest();
        stringList = Core_Entitlement_Outbound_Integrations.smartSplit(testString, 20);
        Test.stopTest();
        
        System.assertEquals(null, stringList);
    }
    public static testmethod void testSmartSplitLogic4() {
        // Scenario 3: String is blank
        List<String> stringList = new List<String>();
        String testString = '';
        
        Test.startTest();
        stringList = Core_Entitlement_Outbound_Integrations.smartSplit(testString, 20);
        Test.stopTest();
        
        System.assertEquals(null, stringList);
    }
    
    public static testmethod void testIsoCountryCodeLogic1() {
        // Scenario 1: No country code custom settings values
        String returnStr = '';
        Test.startTest();
        returnStr = Core_Entitlement_Outbound_Integrations.getISO2CountryCode('ALB');
        Test.stopTest();
        System.assertEquals(null, returnStr);
    }
    
    public static testmethod void testIsoCountryCodeLogic2() {
        // Scenario 2: No matching country codes
        Database.insert(new Core_Country_Code_Mapping__c(Name = 'Albania', Country_Code__c = 'AL', ISO_Code__c='ALB'));
        
        String returnStr = '';
        Test.startTest();
        returnStr = Core_Entitlement_Outbound_Integrations.getISO2CountryCode('USA');
        Test.stopTest();
        System.assertEquals(null, returnStr);
    }
    
    public static testmethod void testIsoCountryCodeLogic3() {
        // Scenario 3: Matching country code
        Database.insert(new Core_Country_Code_Mapping__c(Name = 'Albania', Country_Code__c = 'AL', ISO_Code__c='ALB'));
        
        String returnStr = '';
        Test.startTest();
        returnStr = Core_Entitlement_Outbound_Integrations.getISO2CountryCode('ALB');
        Test.stopTest();
        System.assertEquals('AL', returnStr);
    }
    
    private static List<Core_AGS_Role__c> createTestAGSRole(Integer numOfTestAGSRoles) {
        
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        for(Integer i=0; i<numOfTestAGSRoles; i++) {
            Integer currentNumber = 1;
            Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
            testAGSRole.Name = 'Test AGS Role ' + currentNumber;
            testAGSRole.Core_IsActive__c = true;
            testAGSRole.Core_Technical_Name__c = 'Test AGS Role Tech Name ' + currentNumber;
            lstAGSRoles.add(testAGSRole);
        }
        if(lstAGSRoles.size()>0) {
            insert lstAGSRoles;
            return lstAGSRoles;
        } else {
            return null;
        }
    }
    
    private static List<Core_ERPM_Engagement__c> createTestERPMEngagement(Integer numOfTestERPMEngagements) {
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        for(Integer i = 0; i < numOfTestERPMEngagements; i++) {
            Integer currentNumber = 1;
            Core_ERPM_Engagement__c testERPMEngagement = new Core_ERPM_Engagement__c();
            testERPMEngagement.Name = 'Test ERPM Engagement ' + currentNumber;
            testERPMEngagement.Core_Technical_Engagement_Code__c = 'ENG' + currentNumber;
            testERPMEngagement.Core_Technical_DeDup_Number__c = 'B2B';
            testERPMEngagement.Core_Engagement_Type__c = 'SEC';
            testERPMEngagement.Core_IsActive__c = true;
            lstERPMEngagements.add(testERPMEngagement);
        }
        if(lstERPMEngagements.size()>0) {
            insert lstERPMEngagements;
            return lstERPMEngagements;
        } else {
            return null;
        }
    }
    public static List<Core_Entitlement__c> createTestActiveEntitlementDetail(Integer numOfTestEntitlementDetails) {
        Integer currentNumber = 1;
        
        List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        
        lstAGSRoles = createTestAGSRole(numOfTestEntitlementDetails);
        lstERPMEngagements = createTestERPMEngagement(numOfTestEntitlementDetails);
        
        
        for(Integer i = 0; i<numOfTestEntitlementDetails; i++) {
            Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
            testEntitlementDetail.Name = 'Test Entitilement Detail ' + currentNumber;
            testEntitlementDetail.Core_Display_Name__c = 'Entitlement Detail ' + currentNumber;
            testEntitlementDetail.Core_ERPM_Engagement_Id__c = lstERPMEngagements[i].Id;
            testEntitlementDetail.Core_AGS_Role_Id__c = lstAGSRoles[i].Id;
            testEntitlementDetail.Core_IsActive__c = true;
            currentNumber++;
            lstEntitlementDetails.add(testEntitlementDetail);
        }
        if(lstEntitlementDetails.size()>0) {
            insert lstEntitlementDetails;
        }
        return lstEntitlementDetails;
    }
    
    
    public static Contact createTestContact() 
    {
        Contact conObj = new Contact();
        Account acctObj = createTestAccount();
        conObj.AccountId = acctObj.Id;
        conObj.Core_eRPM_Person_Id__c = '111111';
        conObj.Core_Enterprise_Id__c = '123456';
        conObj.Core_Login_Id__c = '12355';
        conObj.FirstName = 'Outbound Integrations Tester';
        conObj.LastName = 'Person';
        conObj.Email = 'OITester123@tester.com';
        conObj.MailingCountry='USA';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Person';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.Core_Preferred_Language__c= 'ENG';
        conObj.MailingStreet = '1234 Tester St';
        conObj.MailingCity = 'Testing City';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '12345';
        conObj.Phone = '1234567890';
        conObj.MobilePhone = '0987654321';
        conObj.Core_IPA_PartnerRole__c = 'Service Provider';
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        insert conObj;
        
        return conObj;
    }
    
    public static Account createTestAccountWithoutPersistance() {
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account1';
        acctObj.Core_CNDA_Number__c = '112233445577';
        acctObj.BillingStreet = '1234 Tester Account1';
        acctObj.BillingCity = 'Testing City1';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '45321';
        acctObj.Core_User_Defined_Phone_Number__c = '1234567891';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account1';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1237';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account1';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account1';
        acctObj.Industry = 'Agriculture';
        //insert acctObj;
        
        return acctObj;
    }
    
    public static Contact createTestContactWithoutPersistance() {
        
        Contact conObj = new Contact();
        Account acctObj = createTestAccountWithoutPersistance();
        database.insert(acctObj);
        conObj.Core_eRPM_Person_Id__c = '111111';
        conObj.Core_Enterprise_Id__c = '123456';
        conObj.Core_Login_Id__c = '12355';
        conObj.FirstName = 'Outbound Integrations Tester';
        conObj.LastName = 'Person';
        conObj.Email = 'OITester124@tester.com';
        conObj.MailingCountry='USA';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Person';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.MailingStreet = '1234 Tester St1';
        conObj.MailingCity = 'Testing City1';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '45321';
        conObj.Phone = '1234567891';
        conObj.MobilePhone = '0987654322';
        conObj.AccountId = acctObj.Id;
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        
        //insert conObj;
        
        return conObj;
    }
    
    
    public static Account createTestAccount() 
    {
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account acc';
        acctObj.Core_CNDA_Number__c = '102233445560';
        acctObj.BillingStreet = '1221 Tester Account123456789123456789123456789123456789Account1123456789123456789123456789123456789Account11234567891234567891Account 1123456789123456789';
        acctObj.BillingCity = 'Testing City cty';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '120000';
        acctObj.ShippingStreet = 'Yemen';
        acctObj.ShippingCity = 'Testing City cty';
        acctObj.ShippingStateCode = 'OR';
        acctObj.ShippingCountryCode = 'USA';
        acctObj.ShippingPostalCode = '120000';
        acctObj.Core_User_Defined_Phone_Number__c = '1234567890';
        acctObj.Core_User_Defined_Website__c ='www.xyz.com';
        acctObj.Core_User_Defined_Number_of_Employees__c = '1-9';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acctObj.Core_CIM_ID__c = '123456789';
        acctObj.Industry = 'Agriculture';
        acctObj.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        insert acctObj;
        
        return acctObj;
    }
    
    public static PRM_ContactSubscriptionAssociation__c CreateContactSubscriptionAssoction(Contact cntct)
    {
        PRM_ContactSubscriptionAssociation__c contSub = new PRM_ContactSubscriptionAssociation__c();
        contSub.PRM_Contact_Id__c = cntct.Id;
        contSub.PRM_Partner_Subscription_Id__c = CreatePartnerSubscription().Id;
        contSub.PRM_Status_Nm__c = 'Active';
        contSub.PRM_Status_Reason_Txt__c='Service Reason';
        //contSub.PRM_Status_Reason_Txt__c = '';
        
        insert contSub;
        
        return contSub;
        
    }
    
    public static PRM_Partner_Subscription__c CreatePartnerSubscription()
    {
        PRM_Partner_Subscription__c partnerSub = new PRM_Partner_Subscription__c();
        partnerSub.Name='Intel® Cloud Insider Newsletters';
        partnerSub.PRM_Subscription_Cd__c = 'CSP_Sub';
        partnerSub.PRM_InActive_Ind__c= false;
        
        insert partnerSub;
        
        return partnerSub;
    }
    
    public static PRM_Account_Contact_Relationship__c CreateAccountContactRelationship(Contact cntct, PRM_AccountChannelMembership__c acm, Boolean inactive,Boolean setToPending)
    {
        PRM_Account_Contact_Relationship__c acctCon = new PRM_Account_Contact_Relationship__c();
        acctCon.PRM_Account_Id__c = cntct.AccountId;
        acctCon.PRM_Contact_Id__c = cntct.Id;
        acctCon.PRM_Status_Reason_Txt__c = 'Service Reason';
        acctCon.PRM_Relationship_Id__c = CreateRelationship().Id;
        acctCon.PRM_InActive_Ind__c= inactive;
        if(setToPending)
            acctCon.PRM_Status_Nm__c = 'Pending Action';
        else
            acctCon.PRM_Status_Nm__c = 'Complete';
        
        insert acctCon;
                return acctCon;
    }
    
    public static PRM_ContactRelationships__c CreateRelationship()
    {
        PRM_ContactRelationships__c contactReltn = new PRM_ContactRelationships__c();
        contactReltn.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contactReltn.Name ='Primary Contact';
        contactReltn.PRM_Mandatory_Relationship_Ind__c = true;
        contactReltn.PRM_InActive_Ind__c= false;
        contactReltn.PRM_Channel_Program_Id__c = [SELECT Id FROM ChannelProgram WHERE PRM_programCode__c='IPA' LIMIT 1].Id;
        
        insert contactReltn;
        return contactReltn;
    }
    
    public static PRM_AccountChannelMembership__c CreateAccountChannelMembership(Contact cntct, String statusVal)
    {
        ChannelProgram chnlprgm = CreateChannelProgram();       
        PRM_AccountChannelMembership__c acctMembership = new PRM_AccountChannelMembership__c();
        acctMembership.PRM_Account_Id__c = cntct.AccountId;
        acctMembership.PRM_Channel_Program_Id__c = chnlprgm.Id;
        acctMembership.PRM_Status_Nm__c = statusVal;
        acctMembership.PRM_Status_Reason_Txt__c='Service Reason';        
        acctMembership.PRM_Channel_Program_Level_Id__c = GetChannelProgramLevel(chnlprgm.Id).Id;     
        acctMembership.PRM_Partner_Role__c = 'Service Provider';
        
        insert acctMembership;
        return acctMembership;
    }
    public static ChannelProgramLevel GetChannelProgramLevel(Id prgmId)
    {
        ChannelProgramLevel lvl = new ChannelProgramLevel();
        lvl.Name = 'Titanium';
        lvl.PRM_programlevelcode__c = 'Titanium';
        lvl.PRM_inactind__c = false;
        lvl.ProgramId = prgmId;
        
        insert lvl;
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=prgmId;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=prgmId;
        insert cpl1; 
        return lvl;
    }
    
    public static ChannelProgram CreateChannelProgram()
    {
        ChannelProgram prgm = new ChannelProgram();
        prgm.Name = 'Intel Partner Alliance';
        prgm.PRM_programCode__c ='IPA';
        prgm.IsActive = true;
        prgm.PRM_inactind__c = false;
        insert prgm;
        
        return prgm;
    }
    
    public static PRM_Profile_Responses__c CreateProfileResponsesForCnctAndAcct(Contact cntct,String variable)
    {
        String var = variable;
        PRM_Profile_Responses__c prflRes = new PRM_Profile_Responses__c();
        prflRes.PRM_Account_Id__c = cntct.AccountId;
        prflRes.PRM_Contact_Id__c = cntct.Id;
        prflRes.PRM_Profile_Answer_Id__c = CreateProfileAnswer(variable).Id;
        prflRes.PRM_Profile_Questions_Id__c =  [SELECT Id FROM PRM_Profile_Questions__c WHERE PRM_Question_Cd__c=: var LIMIT 1].Id;//CreateProfileQuestion().Id;
        prflRes.PRM_Response_Txt__c = 'test';
        
        insert prflRes;
        return prflRes;
        
    }
    
    public static PRM_Profile_Answer__c CreateProfileAnswer(String variable)
    {
        PRM_Profile_Answer__c prflAns = new PRM_Profile_Answer__c();
        prflAns.PRM_Answer_Cd__c = variable;
        prflAns.PRM_Answer_Display_Txt__c = variable;
        prflAns.PRM_Answer_Txt__c = variable;
        prflAns.PRM_InActive_Ind__c = false;
        prflAns.PRM_Profile_Questions_Id__c = CreateProfileQuestion(variable).Id;
        
        insert prflAns;
        return prflAns;
        
    }
    
    public static PRM_Profile_Questions__c CreateProfileQuestion(String variable)
    {
        PRM_Profile_Questions__c prflQstn = new PRM_Profile_Questions__c();
        prflQstn.PRM_Question_Cd__c = variable;
        prflQstn.PRM_Question_Display_Txt__c = variable;
        prflQstn.PRM_InActive_Ind__c = false;
        prflQstn.PRM_Channel_Program_Id__c =  [SELECT Id FROM ChannelProgram WHERE PRM_programCode__c='IPA' LIMIT 1].Id;
        
        insert prflQstn;
        return prflQstn;
    }
    
    public static List<PRM_AccountBenefitAssociation__c> CreateAccountBenefitAssociation(Contact cntct, PRM_AccountChannelMembership__c acm)
    {
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name='Marketing Studio';
        pb1.PRM_Benefit_Cd__c = 'BFTMKTSTD';
        pb1.PRM_Channel_Program_Id__c = acm.PRM_Channel_Program_Id__c;
        pb1.PRM_Benefit_Type_Nm__c = 'MKTG';
        pb1.PRM_Account_Type_Nm__c = 'Mastered_Account';
        insert pb1;
                PRM_PartnerType__c pt = new PRM_PartnerType__c(); //Partner Type
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        pt.PRM_channelprogram__c = acm.PRM_Channel_Program_Id__c;//[SELECT Id FROM ChannelProgram WHERE PRM_programCode__c='IPA' LIMIT 1].Id;
        insert pt;
        
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
        bm.PRM_Partner_Benefit_Id__c = pb1.id;
        bm.PRM_Channel_Program_Id__c = acm.PRM_Channel_Program_Id__c;
        bm.PRM_Channel_Program_Level_Id__c = acm.PRM_Channel_Program_Level_Id__c;
        bm.PRM_IsActive_Ind__c = true;
        bm.PRM_Covered_Account_Ind__c  = true;
        bm.PRM_Approval_Type_Nm__c = 'Automatic';
        bm.PRM_Partner_Role_Nm__c='Service Provider';
        
        insert bm;
         PRM_VXBnftMatrix__c bm1 = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
        bm1.PRM_Partner_Benefit_Id__c = pb1.id;
        bm1.PRM_Channel_Program_Id__c = acm.PRM_Channel_Program_Id__c;
        bm1.PRM_Channel_Program_Level_Id__c = acm.PRM_Channel_Program_Level_Id__c;
        bm1.PRM_Partner_Type_Id__c = pt.id;
        bm1.PRM_Covered_Account_Ind__c  = true;
        bm1.PRM_Approval_Type_Nm__c = 'Manual';
        bm1.PRM_Partner_Role_Nm__c='Service Provider';
        
        insert bm1;
        
        List<PRM_AccountBenefitAssociation__c> accountBenefits = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c accntBenft = new PRM_AccountBenefitAssociation__c();        
        accntBenft.PRM_Partner_Benefit_Id__c = pb1.ID;
        accntBenft.PRM_Account_Id__c = cntct.AccountId;
        accntBenft.PRM_Status_Nm__c = 'Active';
        accntBenft.PRM_Status_Reason_Txt__c='Service Reason';
        accountBenefits.add(accntBenft);
        
         insert accountBenefits;
        
        return accountBenefits;
        
    }
    
    public static Contact createB2BTestContact() {
        
        Contact conObj = new Contact();
        Account acctObj = createB2BTestAccount();
        conObj.Core_eRPM_Person_Id__c = '111111';
        conObj.Core_Enterprise_Id__c = '123456';
        conObj.Core_Login_Id__c = '12355';
        conObj.FirstName = 'Outbound Integrations Tester';
        conObj.LastName = 'Person';
        conObj.Email = 'OITester123@tester.com';
        conObj.MailingCountry='USA';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Person';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.MailingStreet = '1234 Tester St';
        conObj.MailingCity = 'Testing City';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '12345';
        conObj.Phone = '1234567890';
        conObj.MobilePhone = '0987654321';
        conObj.AccountId = acctObj.Id;
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.Core_Contact_B2B_Indicator__c = true;
        
        insert conObj;
        
        return conObj;
    }
    public static Account createB2BTestAccount() 
    {
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '12345';
        acctObj.Phone = '1234567890';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_B2B_Entitlement__c = true;
        acctObj.Core_Deactivated__c = false;
        acctObj.Core_CIM_ID__c = '123456789';
        acctObj.Industry = 'Agriculture';
        acctObj.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        insert acctObj;
        
        return acctObj;
    }
    
    public static void createTestContactEntitlement(Contact conObj, Integer numTestContactEntitlements) 
    {
        List<Core_Entitlement__c> lstEntitlements = createTestActiveEntitlementDetail(numTestContactEntitlements);
         List<Core_Contact_Entitlement__c> lstTestContactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
        Boolean selected = true;
        for(Core_Entitlement__c entObj : lstEntitlements) {
            Core_Contact_Entitlement__c ce =
                new Core_Contact_Entitlement__c(Core_Contact_Id__c=conObj.Id, Core_From_Source__c=true, Core_Selected__c=selected,Core_Data_Loaded__c= true,
                                                Core_Entitlement_Id__c=entObj.id,Core_Status__c ='In Progress');
            lstTestContactEntitlementsToInsert.add(ce);
            selected = !selected;
        }
        
        if(lstTestContactEntitlementsToInsert != null && lstTestContactEntitlementsToInsert.size() > 0) {
            insert lstTestContactEntitlementsToInsert;
        }
    }
    
    private static List<Core_AGS_Role__c> createTestSMPAGSRole(Integer numOfTestAGSRoles) {
        
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        for(Integer i=0; i<numOfTestAGSRoles; i++) {
            Integer currentNumber = 1;
            Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
            testAGSRole.Name = 'Test SMP AGS Role ' + currentNumber;
            testAGSRole.Core_IsActive__c = true;
            testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ' + currentNumber;
            lstAGSRoles.add(testAGSRole);
        }
        if(lstAGSRoles.size()>0) {
            insert lstAGSRoles;
            return lstAGSRoles;
        } else {
            return null;
        }
    }
    
    private static List<Core_ERPM_Engagement__c> createTestSMPERPMEngagement(Integer numOfTestERPMEngagements) {
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        for(Integer i = 0; i < numOfTestERPMEngagements; i++) {
            Integer currentNumber = 1;
            Core_ERPM_Engagement__c testERPMEngagement = new Core_ERPM_Engagement__c();
            testERPMEngagement.Name = 'Test SMP ERPM Engagement ' + currentNumber;
            testERPMEngagement.Core_Technical_Engagement_Code__c = 'SMPENG' + currentNumber;
            testERPMEngagement.Core_Technical_DeDup_Number__c = 'B2B';
            testERPMEngagement.Core_Engagement_Type__c = 'SMP';
            testERPMEngagement.Core_IsActive__c = true;
            lstERPMEngagements.add(testERPMEngagement);
        }
        if(lstERPMEngagements.size()>0) {
            insert lstERPMEngagements;
            return lstERPMEngagements;
        } else {
            return null;
        }
    }
    public static List<Core_Entitlement__c> createTestSMPActiveEntitlementDetail(Integer numOfTestEntitlementDetails) {
        Integer currentNumber = 1;
        
        List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        
        lstAGSRoles = createTestSMPAGSRole(numOfTestEntitlementDetails);
        lstERPMEngagements = createTestSMPERPMEngagement(numOfTestEntitlementDetails);
        
        for(Integer i = 0; i<numOfTestEntitlementDetails; i++) {
            Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
            testEntitlementDetail.Name = 'Test SMP Entitilement Detail ' + currentNumber;
            testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ' + currentNumber;
            testEntitlementDetail.Core_ERPM_Engagement_Id__c = lstERPMEngagements[i].Id;
            testEntitlementDetail.Core_AGS_Role_Id__c = lstAGSRoles[i].Id;
            testEntitlementDetail.Core_IsActive__c = true;
            currentNumber++;
            lstEntitlementDetails.add(testEntitlementDetail);
        }
        if(lstEntitlementDetails.size()>0) {
            insert lstEntitlementDetails;
        }
        return lstEntitlementDetails;
    }
    
    
    public static List<Core_Entitlement__c> createTestActiveEntitlements(Integer numOfTestEntitlementDetails) {
        Integer currentNumber = 1;
        
        List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        
        lstAGSRoles = createTestSMPAGSRole(numOfTestEntitlementDetails);
        lstERPMEngagements = createTestSMPERPMEngagement(numOfTestEntitlementDetails);
        
        for(Integer i = 0; i<numOfTestEntitlementDetails; i++) {
            Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
            testEntitlementDetail.Name = 'Test SMP Entitilement Detail1 ' + currentNumber;
            testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail1 ' + currentNumber;
            testEntitlementDetail.Core_ERPM_Engagement_Id__c = lstERPMEngagements[i].Id;
            testEntitlementDetail.Core_AGS_Role_Id__c = lstAGSRoles[i].Id;
            testEntitlementDetail.Core_IsActive__c = true;
            currentNumber++;
            lstEntitlementDetails.add(testEntitlementDetail);
        }
        if(lstEntitlementDetails.size()>0) {
            insert lstEntitlementDetails;
        }
        return lstEntitlementDetails;
    }
    
    public static void createTestSMPContactEntitlement(Contact conObj, Integer numTestContactEntitlements) {
        List<Core_Entitlement__c> lstEntitlements = createTestActiveEntitlements(numTestContactEntitlements);
        List<Core_Contact_Entitlement__c> lstTestContactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
        Boolean selected = true;
        for(Core_Entitlement__c entObj : lstEntitlements) {
            Core_Contact_Entitlement__c ce =
                new Core_Contact_Entitlement__c(Core_Contact_Id__c=conObj.Id, Core_From_Source__c=true, Core_Selected__c=selected,
                                                Core_Entitlement_Id__c=entObj.id);
            lstTestContactEntitlementsToInsert.add(ce);
            selected = !selected;
        }
        
        if(lstTestContactEntitlementsToInsert != null && lstTestContactEntitlementsToInsert.size() > 0) {
            insert lstTestContactEntitlementsToInsert;
        }
    }
    
    /* Test class for testing e-mail triggering for Partner Portal Engagment */
    public static void createTestEmailTriggerForEntitlement(Contact conObj, Integer numTestContactEntitlements){
        
        List<Core_Entitlement__c> lstEntitlements = createTestSMPActiveEntitlementDetail(numTestContactEntitlements);
        List<Core_Contact_Entitlement__c> lstTestContactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
        Boolean selected = true;
        
        Core_Entitlement__c coreEntilementOne = lstEntitlements[0];
        Core_Entitlement__c coreEntilementTwo = lstEntitlements[1];
        
        ContactNotificationDisablerTest.setMetadata(
            'SELECT Id,Label,Core_Allowed_Entitlement_Ids__c,Core_Engagement_Id__c,Core_Excluded_Entitlement_Ids__c,Core_Is_the_Rule_Active__c FROM Core_Contact_Email_Notification_Disabler__mdt WHERE DeveloperName = \'Default\'',
            (List<Core_Contact_Email_Notification_Disabler__mdt>)JSON.deserialize
            ('[{"Label":"1", "Core_Allowed_Entitlement_Ids__c":"'+coreEntilementOne.Id+'", "Core_Engagement_Id__c" : "'+coreEntilementOne.Core_ERPM_Engagement_Id__c+'",'+
             '"Core_Excluded_Entitlement_Ids__c":"'+coreEntilementTwo.Id+'", "Core_Is_the_Rule_Active__c":"true"}]', List<Core_Contact_Email_Notification_Disabler__mdt>.class )
        ); 
        
        for(Core_Entitlement__c entObj : lstEntitlements) {
            Core_Contact_Entitlement__c ce =
                new Core_Contact_Entitlement__c(Core_Contact_Id__c=conObj.Id, Core_From_Source__c=true, 
                                                Core_Selected__c=true,
                                                Core_Entitlement_Id__c=entObj.id);
            lstTestContactEntitlementsToInsert.add(ce);
            //selected = !selected;
        }
        
        if(lstTestContactEntitlementsToInsert != null && lstTestContactEntitlementsToInsert.size() > 0) {
            insert lstTestContactEntitlementsToInsert;
        }
        
        
    }
    @isTest
    static void contactInsert(){
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
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_AccountChannelMembership__c> listACMs = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Status_Reason_Txt__c='Service Reason';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Solution Integrator';
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
        ben01.PRM_Status_Reason_Txt__c='Service Reason';
        ben01.PRM_Account_Id__c = newAccount.id;
        ben01.PRM_Source__c = System.Label.PRM_Source_BenefitMatrix;
        insert ben01;
        
        ben01.PRM_Status_Nm__c = 'Inactive';
        benList.add(ben01);
        ContactERPMIntegrationStatusHandler.upsertData(benList, 'PRM_AccountBenefitAssociation__c');
        
        
        List<Contact> listContacts = new List<Contact>();
        
        Account newAccount01 = new Account();//Account
        newAccount01.RecordTypeId = recordTypeAccount01;
        newAccount01.Name='vist';
        newAccount01.BillingCity='Ci';
        newAccount01.BillingStreet='Ste';
        newAccount01.BillingCountry='India';
        newAccount01.BillingPostalCode='P299';
        newAccount01.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount01.Core_IPA_Partner_Role__c = 'Solution Integrator';
        newAccount01.Industry = 'Agriculture';
        newAccount01.Core_User_Defined_Website__c = 'www.acc.com';
        insert newAccount01;
        
        //List<Contact> listContacts = new List<Contact>();
        Contact con02 = new Contact();
        con02.AccountId=newAccount01.Id;
        con02.lastName='test';
        con02.FirstName='con02';
        con02.email='testcon02@rediff.com';
        con02.MailingCountry='USA';
        con02.Core_Job_Function__c='Branch Manager';
        con02.Core_eRPM_Language_Code__c='Eng';
        con02.Core_IPA_PartnerRole__c = 'Solution Integrator';
        con02.Core_Login_Status__c='Active';
        listContacts.add(con02);
        insert listContacts;
        ContactERPMIntegrationStatusHandler.callableMethod(listContacts) ;
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);
        
        insert business;
        List<Contact_Business_Types__c> conBusinessTypeList = new List<Contact_Business_Types__c>();
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = con02.Id, Business_Types__c= business.Id);
        conBusinessTypeList.add(bType);
        Assert.isnotNull(conBusinessTypeList);
        ContactERPMIntegrationStatusHandler.callableMethod(conBusinessTypeList);
        //Schema.SObjectType cont = Schema.Contact.getSObjectType();
        //System.enqueueJob(new ContactERPMIntegrationStatusHandler(listContacts, cont));
        
        /*List<Contact> listContactsupdate = new List<Contact>();
        con01.FirstName = 'erpmupdatecon';
        listContactsupdate.add(con01);
        System.enqueueJob(new ContactERPMIntegrationStatusHandler(listContactsupdate, cont));*/


      }
public static testmethod void forceSetERPMOutboundIntegrationStatus() {
    List<Contact> lstTestContacts = new List<Contact>();
    //Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
    
    Contact testConObj = createTestContact();
    testConObj.Core_Republish_OBM_s__c = True;
    update testConObj;
    
    Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
    testAGSRole.Name = 'Test SMP AGS Role ';
    testAGSRole.Core_IsActive__c = true;
    testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
    insert testAGSRole;
    Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
    testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
    testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
    testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
    testEntitlementDetail.Core_IsActive__c = true;
    insert testEntitlementDetail;
    Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
        Core_Contact_Id__c=testConObj.Id, Core_From_Source__c=false,
        Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
    insert ce;
    
    //createTestContactEntitlement(testConObj, 3);
    lstTestContacts.add(testConObj);
    Core_ERPM_Outbound_Integration.forceSetERPMOutboundIntegrationStatus(lstTestContacts);
    //Contact testOldConObj = testConObj.clone(true, true, true, true);
    
    //createTestContactEntitlement(testConObj, 3);
    
}

}