@isTest
public class Core_Entitlement_Out_Int_Test {
    //public static Integer currentNumber = 1;
    //
    @isTest static void ValidateAccountBenefits(){
        
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();        
        lstTestContacts.add(testConObj);
        system.debug(':::::: testConObj :::::: ' + testConObj);
        ChannelProgram ChnlPrg = CreateChannelProgram();                       
        system.debug(':::::: ChnlPrg :::::: ' + ChnlPrg);
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.PRM_programlevelcode__c='Titanium';
        cpl.Name='Titanium';
        cpl.ProgramId=ChnlPrg.Id;
        insert cpl;
        System.debug('::::::::::CPL2 Insertion done :::::::' + cpl);
        
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
        system.debug(':::::::acctMembership::::: ' + acctMembership); 
        
        List<PRM_Account_Contact_Relationship__c> acctRel = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctMembership, false ,false);
        system.debug(':::::::acctMembership:::::' + rel);
        acctRel.add(rel);
        
        acctMembership.PRM_Status_Nm__c= 'Approved';
        update acctMembership;
        
        //System.enqueuejob(new ContactERPMIntegrationStatusHandler(acctRel,rel.getSObjectType()));
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name='Technology Sandbox';
        pb.PRM_Benefit_Cd__c = 'BFTSNDBX';
        pb.PRM_Channel_Program_Id__c = ChnlPrg.id;
        insert pb;
        System.debug('PB Insertion done');
       
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c(); //Partner Type
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        pt.PRM_channelprogram__c = ChnlPrg.id;
        insert pt;
        System.debug('PT Insertion done');
        
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
        bm.PRM_Partner_Benefit_Id__c = pb.id;
        bm.PRM_Channel_Program_Id__c = ChnlPrg.id;
        bm.PRM_Channel_Program_Level_Id__c = cpl.id;
        bm.PRM_Partner_Type_Id__c = pt.id;
        bm.PRM_Covered_Account_Ind__c  = true;
        bm.PRM_Approval_Type_Nm__c = 'Automatic';
        bm.PRM_Partner_Role_Nm__c='Service Provider';
        
        insert bm;//Benefit Matrix insertion with Member as CPL
        System.debug('bm Insertion done'+bm);
        //database.insert(bm,false);       
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name='Marketing Studio';
        pb1.PRM_Benefit_Cd__c = 'BFTMKTSTD';
        pb1.PRM_Channel_Program_Id__c = ChnlPrg.id;
        //pb1.PRM_Benefit_Type_Nm__c = 'MKTG';
        insert pb1;
        System.debug('pb1 Insertion done');
                              
        PRM_VXBnftMatrix__c bm1 = new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bm1.PRM_Partner_Benefit_Id__c = pb1.id;
        bm1.PRM_Channel_Program_Id__c = ChnlPrg.id;
        bm1.PRM_Channel_Program_Level_Id__c = cpl.id;
        bm1.PRM_Partner_Type_Id__c = pt.id;
        bm1.PRM_Covered_Account_Ind__c  = true;
        bm1.PRM_Approval_Type_Nm__c = 'Automatic';
        bm1.PRM_Partner_Role_Nm__c='Service Provider';
        
        insert bm1;//Benefit Matrix insertion with Titanium as CPL
        System.debug('bm1 Insertion done'+bm1); 
          
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
        
        system.debug(':::::::accountBenefits::::: ' + accountBenefits);       
        insert accountBenefits;
		
        
        system.debug(':::::::accountBenefits after ::::: ' + accountBenefits);       
        System.debug(':::::::: testConObj :::::::: ' + testConObj);
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
        
        System.debug('Begin generateErpmOutboundMessage');
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        Test.startTest();
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        Test.stopTest();
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size()); 
        
    }
    
    @isTest static void ValidateAccountLegalAgreements(){
        
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Test.startTest(); 
        Contact testConObj = createTestContact();
        //createTestContactEntitlement(testConObj, 3);
        
        lstTestContacts.add(testConObj);       
        ChannelProgram ChnlPrg = CreateChannelProgram();
        system.debug(':::::: ChnlPrg :::::: ' + ChnlPrg);
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.PRM_programlevelcode__c='Titanium';
        cpl2.Name='Titanium';
        cpl2.ProgramId=ChnlPrg.Id;
        insert cpl2;
        System.debug('::::::::::CPL2 Insertion done :::::::' + cpl2);
        
        PRM_AccountChannelMembership__c acctMembership = new PRM_AccountChannelMembership__c();        
        acctMembership.PRM_Account_Id__c = testConObj.AccountId;
        acctMembership.PRM_Channel_Program_Id__c = ChnlPrg.Id;
        acctMembership.PRM_Channel_Program_Level_Id__c = cpl2.Id;
        acctMembership.PRM_Status_Nm__c = 'Pending';        
        acctMembership.PRM_Partner_Role__c = 'Service Provider';
        insert acctMembership;
        system.debug(':::::::acctMembership::::: ' + acctMembership); 
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
        system.debug(':::::::partnerAgreements::::: ' + partnerAgreements);
        insert partnerAgreements;
        system.debug(':::::::partnerAgreements::::: ' + partnerAgreements);
        
        List<PRM_PartnerAgreement__c> partnerAgreementsList = [SELECT ID FROM PRM_PartnerAgreement__c WHERE PRM_Agreement_Cd__c IN ('AGRMNTCD001','AGRMNTCD002') ORDER BY PRM_Agreement_Cd__c ASC];
        system.debug(':::::::partnerAgreementsList::::: ' + partnerAgreementsList);
        
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
        system.debug(':::::::accountLegalAgreements::::: ' + accountLegalAgreements);
        insert accountLegalAgreements;
        
        acctMembership.PRM_Status_Nm__c = 'Approved';
        update acctMembership;
        
        System.debug(' testConObj - ' + testConObj);
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
       
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size()); 
        
        Test.stopTest();
    }
    
    public static testmethod void testGenerateAGSOBM() {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        
        Contact testConObj = createTestContact();
        Contact testOldConObj = testConObj.clone(true, true, true, true);
        
        createTestContactEntitlement(testConObj, 3);
        
        
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        testOldConObj.Core_ERPM_Integration_Status__c = 'Pending';
        testOldConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        lstTestContacts.add(testConObj);
        lstOldTestContacts.put(testConObj.Id, testOldConObj);
        
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        testOldConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testOldConObj.Core_AGS_Integration_Status__c = '';
        
        lstTestContacts.add(testConObj);
        lstOldTestContacts.put(testConObj.Id, testOldConObj);
        
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        
    }

    public static testmethod void testGenerateERPMOBM() {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,false);
        system.debug(rel);
        acctConMem.PRM_Status_Nm__c = 'Approved';
        update acctConMem;
        lstTestContacts.add(testConObj);
        Contact c = [Select Id,Core_ERPM_Integration_Queue_txt__c, Core_ERPM_Integration_Status__c from Contact where id=:testConObj.Id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        createTestContactEntitlement(testConObj, 1);
        Test.startTest();
        
        c = [Select Id,Core_ERPM_Integration_Queue_txt__c, Core_ERPM_Integration_Status__c from Contact where id=:testConObj.Id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        System.debug('Zay Inside Test Class Before Reg Test - ' + testConObj);
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());
        System.debug(lstIntOBM);
              
        createTestSMPContactEntitlement(testConObj, 2);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        currentNumErpmObm = lstIntOBM.size();
        System.debug('Zay Inside Test Class Before SMP Test - ' + testConObj);
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts,lstOldTestContacts);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        
        
        createTestEmailTriggerForEntitlement(testConObj, 3);
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c 
                                                                 from Core_Integration_Outbound_Message__c 
                                                                 where Core_MessageType__c='ERPM Contact Entitlement'];
        currentNumErpmObm = lstIntOBM.size();
        System.debug('Zay Inside Test Class Before createTestEmailTriggerForEntitlement - ' + testConObj);
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts,lstOldTestContacts);        
        
        Test.stopTest();
        
    }

        public static testmethod void OtbndMsgACMApproved()
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        System.debug('Contact & Account Creation Complete');
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        System.debug('Account Channel Membership Complete');
        CreateContactSubscriptionAssoction(testConObj);
        System.debug('Contact Subscription Assosciation Complete');
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK');
        System.debug('Profile Responses Complete');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,false);
        system.debug(rel);
        acctConMem.PRM_Status_Nm__c = 'Approved';
        update acctConMem;
        
        lstTestContacts.add(testConObj);
        System.debug('testConObj ------------------------------------------------ : ' + [SELECT Core_IPA_Partner_Role__c FROM Contact where Id=:testConObj.Id]);
        System.debug('Begin Test with creation of Contact' + testConObj);
        

        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        Test.startTest();
        System.debug('Begin generateErpmOutboundMessage');
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        

        Test.stopTest();

    }
    
    public static testmethod void OtbndMsgACMPending()
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        System.debug('Contact & Account Creation Complete');
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        System.debug('Account Channel Membership Complete');
        CreateContactSubscriptionAssoction(testConObj);
        System.debug('Contact Subscription Assosciation Complete');
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK');
        System.debug('Profile Responses Complete');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,false);
        system.debug(rel);
        
        lstTestContacts.add(testConObj);
        System.debug('testConObj ------------------------------------------------ : ' + [SELECT Core_IPA_Partner_Role__c FROM Contact where Id=:testConObj.Id]);
        System.debug('Begin Test with creation of Contact' + testConObj);
        

        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        Test.startTest();
        System.debug('Begin generateErpmOutboundMessage');
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        

        Test.stopTest();

    }
    
    public static testmethod void OtbndMsgACRelPending()
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        System.debug('Contact & Account Creation Complete');
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        System.debug('Account Channel Membership Complete');
        CreateContactSubscriptionAssoction(testConObj);
        System.debug('Contact Subscription Assosciation Complete');
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK');
        System.debug('Profile Responses Complete');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,true);
        system.debug(rel);
        
        lstTestContacts.add(testConObj);
        System.debug('testConObj ------------------------------------------------ : ' + [SELECT Core_IPA_Partner_Role__c FROM Contact where Id=:testConObj.Id]);
        System.debug('Begin Test with creation of Contact' + testConObj);
        

        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        Test.startTest();
        System.debug('Begin generateErpmOutboundMessage');
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        

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
        System.debug('Contact & Account Creation Complete');
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        System.debug('Account Channel Membership Complete');
        CreateContactSubscriptionAssoction(testConObj);
        System.debug('Contact Subscription Assosciation Complete');
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK');
        System.debug('Profile Responses Complete');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,false,false);
        system.debug(rel);
        acctConMem.PRM_Status_Nm__c = 'Approved';
        update acctConMem;
        
        lstTestContacts.add(testConObj);
        System.debug('testConObj ------------------------------------------------ : ' + [SELECT Core_IPA_Partner_Role__c FROM Contact where Id=:testConObj.Id]);
        System.debug('Begin Test with creation of Contact' + testConObj);
        

        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        Test.startTest();
        System.debug('Begin generateErpmOutboundMessage');
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        

        Test.stopTest();

    }
    
    
        public static testmethod void GenerateERPMOutboundMsg_NewUser_Inactivate_User() 
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        System.debug('Contact & Account Creation Complete');
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        System.debug('Account Channel Membership Complete');
        CreateContactSubscriptionAssoction(testConObj);
        System.debug('Contact Subscription Assosciation Complete');
        CreateProfileResponsesForCnctAndAcct(testConObj,'TEST');
        CreateProfileResponsesForCnctAndAcct(testConObj,'HSK');
        System.debug('Profile Responses Complete');
        
        lstTestContacts.add(testConObj);
        System.debug('testConObj ------------------------------------------------ : ' + [SELECT Core_IPA_Partner_Role__c FROM Contact where Id=:testConObj.Id]);
        System.debug('Begin Test with creation of Contact' + testConObj);
        Test.startTest();

        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        System.debug('Begin generateErpmOutboundMessage');
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size()); 
        
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem,true,false);
        system.debug(rel);
        rel.PRM_Status_Nm__c = 'Complete';
        update rel;
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        currentNumErpmObm = lstIntOBM.size();
        
        c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        System.debug('Begin generateErpmOutboundMessage');
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size()); 

        Test.stopTest();

    }
    
    
    public static testmethod void GenerateERPMOtbndMsgWithMemPending()
    {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = CreateTestContact();
        System.debug('Contact & Account Creation Complete');
        PRM_AccountChannelMembership__c acctConMem = CreateAccountChannelMembership(testConObj,'Pending');
        System.debug('Account Channel Membership Complete');
        
        lstTestContacts.add(testConObj);
        System.debug('Begin Test with creation of Contact' + testConObj);
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
        
        Contact c = [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id =: testConObj.id];
        System.debug('Core_ERPM_Integration_Queue_txt__c + Core_ERPM_Integration_Status__c'+ c.Core_ERPM_Integration_Queue_txt__c + '   '+c.Core_ERPM_Integration_Status__c);
        c.Core_ERPM_Integration_Queue_txt__c = 'Empty';
        c.Core_ERPM_Integration_Status__c ='Pending';
        update c;
        Core_Entitlement_Outbound_Integrations.hasRun=false;
        
        Test.startTest();
        System.debug('Begin generateErpmOutboundMessage');
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        System.debug('End generateErpmOutboundMessage');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());        

        Test.stopTest();

    }

    public static testmethod void testGenerateBoxBAccountOBM() {
        List<Account> lstAccounts = new List<Account>();
        Map<Id,Account> mapOldAccounts = new Map<Id,Account>();
        
        Account acctObj = createB2BTestAccount();
        Account acctOldObj = acctObj.clone(true,true,true,true);
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='BoxB Account'];
        
        acctOldObj.Name = 'Old Name';
        
        lstAccounts.add(acctObj);
        mapOldAccounts.put(acctObj.id, acctOldObj);
        
        Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage(lstAccounts, mapOldAccounts);
        
        lstAccounts = new List<Account>();
        
        acctObj.Core_Deactivated__c = true;
        acctObj.Name = 'Old Name';
        
        lstAccounts.add(acctObj);
        
        Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage(lstAccounts, mapOldAccounts);
      
    }
    public static testmethod void testGenerateERPMOnCIMUpdate() {
        List<Contact> lstTestContacts = new List<Contact>();
        Contact testConObj = createB2BTestContact();
        
        System.debug('Zay Inside Test Class - ' + testConObj.Core_Contact_B2B_Indicator__c);
        createTestContactEntitlement(testConObj, 3);
        
        lstTestContacts.add(testConObj);
        
        List<Account> lstAccounts = new List<Account>();
        Map<Id,Account> mapOldAccounts = new Map<Id,Account>();
        

        Account acctObj = [Select id, Name, Core_CNDA_Number__c, BillingStreet,BillingCity,BillingStateCode,BillingCountryCode,
                           BillingPostalCode,Phone,Core_Account_Legal_Name__c,Core_IsODM__c,Core_B2B_ERPM_Account_Number__c,
                           Core_English_Only_Name__c, Core_Alternate_Language_Name__c, Core_B2B_Entitlement__c,
                           BillingCountry, BillingState, Core_CIM_ID__c,RecordTypeId,
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
        
        System.debug('Zay Inside Test Class - ' + testConObj.Core_Contact_B2B_Indicator__c);
        
        Core_Entitlement_Outbound_Integrations.runOnce = false;
        Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate(lstAccounts, mapOldAccounts);
        
        acctOldObj.Name = 'New Outbound Test Account';
        acctObj.Core_English_Only_Name__c = 'New English Only Name Outbound Test Account';
        
        lstAccounts = new List<Account>();
        lstAccounts.add(acctObj);
        mapOldAccounts.put(acctObj.id, acctOldObj);
        Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate(lstAccounts, mapOldAccounts);
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
        System.debug('lstERPMEngagements : '+lstERPMEngagements);
        
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
        System.debug('lstEntitlementDetails'+lstEntitlementDetails);
        return lstEntitlementDetails;
    }


    public static Contact createTestContact() 
    {
        Contact conObj = new Contact();
        Account acctObj = createTestAccount();
        System.debug('Account in create testcontact' + acctObj.Id);
        System.debug('Whole object' + acctObj);
        conObj.AccountId = acctObj.Id;
        conObj.Core_eRPM_Person_Id__c = '111111';
        conObj.Core_Enterprise_Id__c = '123456';
        conObj.Core_Login_Id__c = '12355';
        conObj.FirstName = 'Outbound Integrations Tester';
        conObj.LastName = 'Person';
        conObj.Email = 'OITester123@tester.com';
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
        conObj.Core_IPA_Partner_Role__c = 'Service Provider';
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        insert conObj;
        
        System.debug('Contact in create testcontact' + conObj.AccountId);
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
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account123456789123456789123456789123456789Account1123456789123456789123456789123456789Account11234567891234567891Account 1123456789123456789';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '12345';
        acctObj.ShippingStreet = 'Yemen';
        acctObj.ShippingCity = 'Testing City';
        acctObj.ShippingStateCode = 'OR';
        acctObj.ShippingCountryCode = 'USA';
        acctObj.ShippingPostalCode = '12345';
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
        
        insert acctObj;
        
        return acctObj;
    }

    public static PRM_ContactSubscriptionAssociation__c CreateContactSubscriptionAssoction(Contact cntct)
    {
        PRM_ContactSubscriptionAssociation__c contSub = new PRM_ContactSubscriptionAssociation__c();
        contSub.PRM_Contact_Id__c = cntct.Id;
        contSub.PRM_Partner_Subscription_Id__c = CreatePartnerSubscription().Id;
        contSub.PRM_Status_Nm__c = 'Active';
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
        System.debug('Inside Account Contact Relationship method');
        PRM_Account_Contact_Relationship__c acctCon = new PRM_Account_Contact_Relationship__c();
        acctCon.PRM_Account_Id__c = cntct.AccountId;
        acctCon.PRM_Contact_Id__c = cntct.Id;
        acctCon.PRM_Relationship_Id__c = CreateRelationship().Id;
        acctCon.PRM_InActive_Ind__c= inactive;
        System.debug('setToPending : '+setToPending);
        if(setToPending)
            acctCon.PRM_Status_Nm__c = 'Pending Action';
        else
            acctCon.PRM_Status_Nm__c = 'Complete';
        
        insert acctCon;
        System.debug('Select query : '+acctCon);
        System.debug([SELECT PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Status_Nm__c,PRM_Relationship_Id__c,PRM_Partner_Role__c from PRM_Account_Contact_Relationship__c where Id=:acctCon.Id]);
        System.debug('Inside Account Contact Relationship method END' );
        return acctCon;
    }
    
    public static PRM_ContactRelationships__c CreateRelationship()
    {
        System.debug('Inside Create Relationship method');
        PRM_ContactRelationships__c contactReltn = new PRM_ContactRelationships__c();
        contactReltn.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contactReltn.Name ='Primary Contact';
        contactReltn.PRM_Mandatory_Relationship_Ind__c = true;
        contactReltn.PRM_InActive_Ind__c= false;
        contactReltn.PRM_Channel_Program_Id__c = [SELECT Id FROM ChannelProgram WHERE PRM_programCode__c='IPA' LIMIT 1].Id;
        
        insert contactReltn;
        System.debug('Inside Create Relationship method END');
        return contactReltn;
    }

    public static PRM_AccountChannelMembership__c CreateAccountChannelMembership(Contact cntct, String statusVal)
    {
        ChannelProgram chnlprgm = CreateChannelProgram();       
        PRM_AccountChannelMembership__c acctMembership = new PRM_AccountChannelMembership__c();
        System.debug('Contact'+ cntct);
        System.debug('Account ID'+cntct.AccountId);
        acctMembership.PRM_Account_Id__c = cntct.AccountId;
        acctMembership.PRM_Channel_Program_Id__c = chnlprgm.Id;
        acctMembership.PRM_Status_Nm__c = statusVal;        
        acctMembership.PRM_Channel_Program_Level_Id__c = GetChannelProgramLevel(chnlprgm.Id).Id;     
        acctMembership.PRM_Partner_Role__c = 'Service Provider';

        insert acctMembership;
        System.debug('Inside Account Channel Memebership--- Complete' + acctMembership);
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
        System.debug('Inside Profile responses method');
        PRM_Profile_Responses__c prflRes = new PRM_Profile_Responses__c();
        prflRes.PRM_Account_Id__c = cntct.AccountId;
        prflRes.PRM_Contact_Id__c = cntct.Id;
        prflRes.PRM_Profile_Answer_Id__c = CreateProfileAnswer(variable).Id;
        System.debug('Profile Answer Id: '+ prflRes.PRM_Profile_Answer_Id__c);
        prflRes.PRM_Profile_Questions_Id__c =  [SELECT Id FROM PRM_Profile_Questions__c WHERE PRM_Question_Cd__c='TEST' LIMIT 1].Id;//CreateProfileQuestion().Id;
        System.debug('Profile Question Id: '+ prflRes.PRM_Profile_Questions_Id__c);
        prflRes.PRM_Response_Txt__c = 'test';

        insert prflRes;
        System.debug('Profile response creation complete');
        return prflRes;

    }

    public static PRM_Profile_Answer__c CreateProfileAnswer(String variable)
    {
        System.debug('Inside Profile answer method');
        PRM_Profile_Answer__c prflAns = new PRM_Profile_Answer__c();
        prflAns.PRM_Answer_Cd__c = variable;
        prflAns.PRM_Answer_Display_Txt__c = variable;
        prflAns.PRM_Answer_Txt__c = variable;
        prflAns.PRM_InActive_Ind__c = false;
        prflAns.PRM_Profile_Questions_Id__c = CreateProfileQuestion(variable).Id;
        
        insert prflAns;
        System.debug('Profile answer creation complete');
        return prflAns;

    }
    
    public static PRM_Profile_Questions__c CreateProfileQuestion(String variable)
    {
        System.debug('Inside Profile question method');
        PRM_Profile_Questions__c prflQstn = new PRM_Profile_Questions__c();
        prflQstn.PRM_Question_Cd__c = variable;
        prflQstn.PRM_Question_Display_Txt__c = variable;
        prflQstn.PRM_InActive_Ind__c = false;
        prflQstn.PRM_Channel_Program_Id__c =  [SELECT Id FROM ChannelProgram WHERE PRM_programCode__c='IPA' LIMIT 1].Id;
        System.debug([SELECT Id FROM ChannelProgram WHERE PRM_programCode__c='IPA' LIMIT 1]);
        System.debug('Code' + prflQstn.PRM_Channel_Program_Id__c);

        insert prflQstn;
        System.debug('Profile question creation complete');
        return prflQstn;
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
        
        insert acctObj;
        
        return acctObj;
    }
    
    public static void createTestContactEntitlement(Contact conObj, Integer numTestContactEntitlements) 
    {
        List<Core_Entitlement__c> lstEntitlements = createTestActiveEntitlementDetail(numTestContactEntitlements);
        System.debug('lstEntitlements :'+lstEntitlements);
        List<Core_Contact_Entitlement__c> lstTestContactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
        Boolean selected = true;
        for(Core_Entitlement__c entObj : lstEntitlements) {
            Core_Contact_Entitlement__c ce =
                            new Core_Contact_Entitlement__c(Core_Contact_Id__c=conObj.Id, Core_From_Source__c=true, Core_Selected__c=selected,Core_Data_Loaded__c= true,
                                                            Core_Entitlement_Id__c=entObj.id);
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
        
        System.debug('createTestEmailTriggerForEntitlement : lstTestContactEntitlementsToInsert = ' + lstTestContactEntitlementsToInsert);
    
  }
  
}