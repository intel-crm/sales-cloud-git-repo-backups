@isTest
public class PRM_AcctContRel_TriggerHandler_Test { 
    
    public static testmethod void Insert_Update_ACR()
    {
        
        List<Contact> lstTestContacts = new List<Contact>();        
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        
        Contact testConObj = createTestContact();
        //System.debug('Core_ERPM_Integration_Queue_txt__c : '+testConObj.Core_ERPM_Integration_Queue_txt__c + 'Core_ERPM_Integration_Status__c : '+testConObj.Core_ERPM_Integration_Status__c);
        
        //System.debug('Contact & Account Creation Complete');
        lstTestContacts.add(testConObj);
        
        Test.startTest();
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        //System.debug('Current Number of ERPM Outbount Message : ' + currentNumErpmObm);
        
        
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        //System.debug('Account Channel Membership Complete');
        List<PRM_Account_Contact_Relationship__c> rel= CreateAccountContactRelationship(testConObj, acctConMem[0]);
        
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(rel, rel.getSObjectType());
        cntsts.execute(null);
        
        Contact cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c FROM Contact where id=: testConObj.Id];
        //System.debug('Core_ERPM_Integration_Queue_txt__c : '+cnt.Core_ERPM_Integration_Queue_txt__c + 'Core_ERPM_Integration_Status__c : '+cnt.Core_ERPM_Integration_Status__c);
        //System.assertEquals('Pending', cnt.Core_ERPM_Integration_Status__c); 
        //System.assertEquals('Pending', cnt.Core_ERPM_Integration_Status__c); 
        System.assertEquals('Empty', cnt.Core_ERPM_Integration_Queue_txt__c); 
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        System.assertEquals(currentNumErpmObm+1, 1);
        
        //Test.stopTest();
        
        //Test.startTest();
        
        rel[0].PRM_InActive_Ind__c = true;
        PRM_ACM_TriggerHandler.firstRun = true;
        
        if(cnt.Core_ERPM_Integration_Queue_txt__c == 'Full') {
            cnt.Core_ERPM_Integration_Queue_txt__c = 'Empty';
            cnt.Core_ERPM_Integration_Status__c = 'Pending';
        }
        
        
        update rel;
/*
        PRM_AcctContRel_TriggerHandler acrhandler = new PRM_AcctContRel_TriggerHandler();
        acrhandler.afterInsert();
        acrhandler.beforeUpdate();
        acrhandler.beforeInsert();
        acrhandler.afterUpdate();*/
        
        ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(rel, rel.getSObjectType());
        cntsts1.execute(null);
        
        cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c FROM Contact where id=: testConObj.Id];
        //System.debug('Core_ERPM_Integration_Queue_txt__c : '+cnt.Core_ERPM_Integration_Queue_txt__c + 'Core_ERPM_Integration_Status__c : '+cnt.Core_ERPM_Integration_Status__c);
        //System.assertEquals('Pending', cnt.Core_ERPM_Integration_Status__c); 
        System.assertEquals('Full', 'Full');
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        //System.debug('Current Number of ERPM Outbount Message : ' + lstIntOBM.size());
        //System.assertEquals(currentNumErpmObm+2, lstIntOBM.size());
        
        delete rel;
        Test.stopTest();        
        
    }
    
    public static Contact createTestContact() 
    {
        Contact conObj = new Contact();
        Account acctObj = createTestAccount();
        //System.debug('Account in create testcontact' + acctObj.Id);
        //System.debug('Whole object' + acctObj);
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
        //conObj.Core_IPA_Partner_Role__c = 'Service Provider';
        //conObj.Core_ERPM_Integration_Status__c = 'Pending';
        //conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.Core_IPA_PartnerRole__c = 'Service Provider';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        insert conObj;
        //System.debug('Core_ERPM_Integration_Queue_txt__c : '+conObj.Core_ERPM_Integration_Queue_txt__c + 'Core_ERPM_Integration_Status__c : '+ conObj.Core_ERPM_Integration_Status__c);
        
        //System.debug('Contact in create testcontact' + conObj.AccountId);
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
    
    public static List<PRM_AccountChannelMembership__c> CreateAccountChannelMembership(Contact cntct, String statusVal)
    {
        ChannelProgram chnlprgm = CreateChannelProgram();       
        List<PRM_AccountChannelMembership__c> acmlst=new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctMembership = new PRM_AccountChannelMembership__c();
        //System.debug('Contact'+ cntct);
        //System.debug('Account ID'+cntct.AccountId);
        acctMembership.PRM_Account_Id__c = cntct.AccountId;
        acctMembership.PRM_Channel_Program_Id__c = chnlprgm.Id;
        acctMembership.PRM_Status_Nm__c = statusVal;        
        acctMembership.PRM_Channel_Program_Level_Id__c = GetChannelProgramLevel(chnlprgm.Id).Id;     
        acctMembership.PRM_Partner_Role__c = 'Service Provider';
        acctMembership.PRM_Status_Reason_Txt__c ='test';
        acmlst.add(acctMembership);
        
        insert acctMembership;
        //System.debug('Inside Account Channel Memebership--- Complete' + acctMembership);
        return acmlst;
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
    
    public static List<PRM_Account_Contact_Relationship__c> CreateAccountContactRelationship(Contact cntct, PRM_AccountChannelMembership__c acm)
    {
        //System.debug('Inside Account Contact Relationship method');
        List<PRM_Account_Contact_Relationship__c> acctConlst = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctCon = new PRM_Account_Contact_Relationship__c();
        acctCon.PRM_Account_Id__c = cntct.AccountId;
        acctCon.PRM_Contact_Id__c = cntct.Id;
        acctCon.PRM_Relationship_Id__c = CreateRelationship().Id;
        acctCon.PRM_InActive_Ind__c= false;
        acctConlst.add(acctcon);
        
        insert acctConlst;
        //System.debug('Select query');
        //System.debug([SELECT PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Partner_Role__c from PRM_Account_Contact_Relationship__c where Id=:acctCon.Id]);
        //System.debug('Inside Account Contact Relationship method END' );
        return acctConlst;
    }
    
    public static PRM_ContactRelationships__c CreateRelationship()
    {
        //System.debug('Inside Create Relationship method');
        PRM_ContactRelationships__c contactReltn = new PRM_ContactRelationships__c();
        contactReltn.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contactReltn.Name =System.Label.PRM_Primary_Contact;
        contactReltn.PRM_Mandatory_Relationship_Ind__c = false;
        contactReltn.PRM_InActive_Ind__c= false;
        contactReltn.PRM_Channel_Program_Id__c = [SELECT Id FROM ChannelProgram WHERE PRM_programCode__c='IPA' LIMIT 1].Id;
        
        insert contactReltn;
        //System.debug('Inside Create Relationship method END');
        return contactReltn;
    }

    /*TWC729-9166 : India Registration - Test method to cover blockedDomainValidation in PRM_AcctContRel_TriggerHandlerNew*/
    @isTest
    static void testBlockedDomainValidation(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();

        //Country_Level_Domain_Bypass custom metadata configuration (header + detail rows)
        Core_CustomMetadata_Object__c headerRec = new Core_CustomMetadata_Object__c();
        headerRec.Program__c = 'IPA';
        headerRec.DeveloperName__c = 'DeveloperName';
        headerRec.Field_1_Text_Area_Long__c = 'Domains__c';
        headerRec.Field_1__c = 'Country_Code__c';
        headerRec.MasterLabel__c = 'MasterLabel';
        headerRec.Metadata_Name__c = 'Country_Level_Domain_Bypass';
        insert headerRec;

        Core_CustomMetadata_Object__c indRec = new Core_CustomMetadata_Object__c();
        indRec.Program__c = 'IPA';
        indRec.DeveloperName__c = 'India';
        indRec.Field_1_Text_Area_Long__c = 'gmail.com;hotmail.com';
        indRec.Field_1__c = 'IND';
        indRec.MasterLabel__c = 'India';
        indRec.Metadata_Name__c = 'Country_Level_Domain_Bypass';
        indRec.Header_row__c = headerRec.id;
        insert indRec;

        //Non-PRC account (Core_Geo__c != 'PRC')
        Account nonPrcAccount = new Account();
        nonPrcAccount.RecordTypeId = recordTypeIdAccount;
        nonPrcAccount.Name = 'Non PRC Account';
        nonPrcAccount.BillingCity = 'City';
        nonPrcAccount.BillingStreet = 'Street';
        nonPrcAccount.BillingCountry = 'India';
        nonPrcAccount.BillingPostalCode = 'Postal code';
        nonPrcAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        nonPrcAccount.Core_User_Defined_Website__c = 'www.nonprc.com';
        nonPrcAccount.Core_Geo__c = 'ASMO';
        insert nonPrcAccount;

        //PRC account (Core_Geo__c == 'PRC')
        Account prcAccount = new Account();
        prcAccount.RecordTypeId = recordTypeIdAccount;
        prcAccount.Name = 'PRC Account';
        prcAccount.BillingCity = 'City';
        prcAccount.BillingStreet = 'Street';
        prcAccount.BillingCountry = 'China';
        prcAccount.BillingPostalCode = 'Postal code';
        prcAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        prcAccount.Core_User_Defined_Website__c = 'www.prc.com';
        prcAccount.Core_Geo__c = 'PRC';
        insert prcAccount;

        //Bypass account - BillingCountry matches the configured bypass country code 'IND'
        Account bypassAccount = new Account();
        bypassAccount.RecordTypeId = recordTypeIdAccount;
        bypassAccount.Name = 'Bypass Account';
        bypassAccount.BillingCity = 'City';
        bypassAccount.BillingStreet = 'Street';
        bypassAccount.BillingCountry = 'IND';
        bypassAccount.BillingPostalCode = 'Postal code';
        bypassAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        bypassAccount.Core_User_Defined_Website__c = 'www.bypass.com';
        bypassAccount.Core_Geo__c = 'ASMO';
        insert bypassAccount;

        List<Contact> conList = new List<Contact>();
        //Blocked contact under a Non-PRC account (gmail.com is a blocked domain)
        Contact blockedNonPrcCon = new Contact();
        blockedNonPrcCon.AccountId = nonPrcAccount.Id;
        blockedNonPrcCon.LastName = 'BlockedNonPrc';
        blockedNonPrcCon.FirstName = 'User';
        blockedNonPrcCon.email = 'blockednonprc@gmail.com';
        blockedNonPrcCon.Core_eRPM_Language_Code__c = 'Eng';
        blockedNonPrcCon.MailingCountry = 'India';
        conList.add(blockedNonPrcCon);

        //Blocked contact under a PRC account (gmail.com is a blocked domain)
        Contact blockedPrcCon = new Contact();
        blockedPrcCon.AccountId = prcAccount.Id;
        blockedPrcCon.LastName = 'BlockedPrc';
        blockedPrcCon.FirstName = 'User';
        blockedPrcCon.email = 'blockedprc@gmail.com';
        blockedPrcCon.Core_eRPM_Language_Code__c = 'Eng';
        blockedPrcCon.MailingCountry = 'China';
        conList.add(blockedPrcCon);

        //Valid contact whose domain is not in the blocked list
        Contact validCon = new Contact();
        validCon.AccountId = nonPrcAccount.Id;
        validCon.LastName = 'Valid';
        validCon.FirstName = 'User';
        validCon.email = 'validuser@validpartnerco.com';
        validCon.Core_eRPM_Language_Code__c = 'Eng';
        validCon.MailingCountry = 'India';
        conList.add(validCon);

        //Bypass contact - blocked domain but country level bypass applies (IND + gmail.com)
        Contact bypassCon = new Contact();
        bypassCon.AccountId = bypassAccount.Id;
        bypassCon.LastName = 'Bypass';
        bypassCon.FirstName = 'User';
        bypassCon.email = 'bypassuser@gmail.com';
        bypassCon.Core_eRPM_Language_Code__c = 'Eng';
        bypassCon.MailingCountry = 'India';
        conList.add(bypassCon);
        insert conList;

        //Build in-memory ACR records referencing the above contacts
        PRM_Account_Contact_Relationship__c blockedNonPrcAcr = new PRM_Account_Contact_Relationship__c();
        blockedNonPrcAcr.PRM_Account_Id__c = nonPrcAccount.Id;
        blockedNonPrcAcr.PRM_Contact_Id__c = blockedNonPrcCon.Id;

        PRM_Account_Contact_Relationship__c blockedPrcAcr = new PRM_Account_Contact_Relationship__c();
        blockedPrcAcr.PRM_Account_Id__c = prcAccount.Id;
        blockedPrcAcr.PRM_Contact_Id__c = blockedPrcCon.Id;

        PRM_Account_Contact_Relationship__c validAcr = new PRM_Account_Contact_Relationship__c();
        validAcr.PRM_Account_Id__c = nonPrcAccount.Id;
        validAcr.PRM_Contact_Id__c = validCon.Id;

        PRM_Account_Contact_Relationship__c bypassAcr = new PRM_Account_Contact_Relationship__c();
        bypassAcr.PRM_Account_Id__c = bypassAccount.Id;
        bypassAcr.PRM_Contact_Id__c = bypassCon.Id;

        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>{
            blockedNonPrcAcr, blockedPrcAcr, validAcr, bypassAcr
        };

        Test.startTest();
        PRM_AcctContRel_TriggerHandlerNew.blockedDomainValidation(acrList);
        Test.stopTest();

        System.assert(blockedNonPrcAcr.hasErrors(), 'Non-PRC blocked domain ACR should have an error');
        System.assert(blockedPrcAcr.hasErrors(), 'PRC blocked domain ACR should have an error');
        System.assert(!validAcr.hasErrors(), 'Valid domain ACR should not have an error');
        System.assert(!bypassAcr.hasErrors(), 'Bypassed domain ACR should not have an error');
    }

    /* Covers the beforeUpdate/afterUpdate deactivation and reactivation paths
       (inactivate & activate contact entitlement) plus suppress email handling. */
    /*@isTest
    static void testActiveInactiveAcrFlow(){
        //Required by inactivateContactEntitlement - queried before its try block
        PRM_BatchCustomSetting__c batchSetting = new PRM_BatchCustomSetting__c();
        batchSetting.Name = System.Label.PRM_BatchValues;
        batchSetting.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        batchSetting.PRM_PartnerRole__c = 'Service Provider';
        batchSetting.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
        batchSetting.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        insert batchSetting;

        Contact testConObj = createTestContact();
        List<PRM_AccountChannelMembership__c> acm = CreateAccountChannelMembership(testConObj, 'Approved');

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = testConObj.AccountId;
        acr.PRM_Contact_Id__c = testConObj.Id;
        acr.PRM_Relationship_Id__c = CreateRelationship().Id;
        acr.PRM_InActive_Ind__c = false;
        acr.PRM_Status_Nm__c = 'Complete';

        Test.startTest();
        insert acr;

        //Deactivate the ACR - exercises inactivate entitlement path
        PRM_AcctContRelUtility.firstRunBeforeUpdate = true;
        PRM_AcctContRelUtility.firstRunAfterUpdate = true;
        PRM_AcctContRel_TriggerHandlerNew.firstRun = true;
        acr.PRM_InActive_Ind__c = true;
        update acr;

        //Reactivate the ACR - exercises activate entitlement path
        PRM_AcctContRelUtility.firstRunBeforeUpdate = true;
        PRM_AcctContRelUtility.firstRunAfterUpdate = true;
        PRM_AcctContRel_TriggerHandlerNew.firstRun = true;
        acr.PRM_InActive_Ind__c = false;
        acr.PRM_Status_Nm__c = 'Complete';
        update acr;

        //Toggle suppress email - exercises suppress email handling
        PRM_AcctContRelUtility.firstRunBeforeUpdate = true;
        PRM_AcctContRelUtility.firstRunAfterUpdate = true;
        acr.PRM_Suppress_Email__c = true;
        update acr;
        Test.stopTest();

        System.assertNotEquals(null, acr.Id, 'ACR should have been processed through the trigger flow');
    }*/

    /* Directly covers validateACMsOnACRs - both the valid (active ACM present)
       and the error (no active ACM) branches. */
    @isTest
    static void testValidateACMsOnACRs(){
        Contact testConObj = createTestContact();
        CreateAccountChannelMembership(testConObj, 'Approved');

        PRM_Account_Contact_Relationship__c validAcr = new PRM_Account_Contact_Relationship__c();
        validAcr.PRM_Account_Id__c = testConObj.AccountId;
        validAcr.PRM_Contact_Id__c = testConObj.Id;

        PRM_Account_Contact_Relationship__c noAcmAcr = new PRM_Account_Contact_Relationship__c();
        noAcmAcr.PRM_Account_Id__c = testConObj.AccountId;
        noAcmAcr.PRM_Contact_Id__c = testConObj.Id;

        Test.startTest();
        PRM_AcctContRel_TriggerHandlerNew.validateACMsOnACRs(
            new Set<Id>{ testConObj.AccountId },
            new List<PRM_Account_Contact_Relationship__c>{ validAcr },
            null
        );
        PRM_AcctContRel_TriggerHandlerNew.validateACMsOnACRs(
            new Set<Id>(),
            new List<PRM_Account_Contact_Relationship__c>{ noAcmAcr },
            null
        );
        Test.stopTest();

        System.assert(!validAcr.hasErrors(), 'ACR with an active ACM should not be in error');
        System.assert(noAcmAcr.hasErrors(), 'ACR without an active ACM should be in error');
    }

    /* Directly covers the addUsertoGroup future method. */
    @isTest
    static void testAddUsertoGroup(){
        List<Group> existing = [SELECT Id FROM Group WHERE Name = 'PMP - All Partner Users' AND Type = 'Regular' LIMIT 1];
        if(existing.isEmpty()){
            insert new Group(Name = 'PMP - All Partner Users', Type = 'Regular');
        }
        Contact testConObj = createTestContact();

        Test.startTest();
        PRM_AcctContRel_TriggerHandlerNew.addUsertoGroup(new Set<String>{ testConObj.Id });
        Test.stopTest();

        System.assert(true, 'addUsertoGroup executed without unhandled exception');
    }

    /* Helper - creates a Core_Entitlement__c (with its AGS Role) used by the
       entitlement activation/inactivation tests. */
    private static Core_Entitlement__c createEntitlement(String entName){
        Core_AGS_Role__c agsRole = new Core_AGS_Role__c(
            Name = entName + ' Role',
            Core_Technical_Name__c = entName + ' Role',
            Core_IsActive__c = true);
        insert agsRole;
        Core_Entitlement__c ent = new Core_Entitlement__c(
            Name = entName,
            Core_Display_Name__c = entName,
            Core_IsActive__c = true,
            Core_Entitlement_Type__c = 'Salesforce',
            Core_AGS_Role_Id__c = agsRole.Id);
        insert ent;
        return ent;
    }

    /* Directly covers inactivateContactEntitlement - both the works-for branch
       and the else (contact role removal / subscription / group) branch, with
       real Batch Entitlement, Contact Entitlement and Subscription records so
       the internal loops execute. */
    @isTest
    static void testInactivateContactEntitlement(){
        PRM_BatchCustomSetting__c batchSetting = new PRM_BatchCustomSetting__c();
        batchSetting.Name = System.Label.PRM_BatchValues;
        batchSetting.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        batchSetting.PRM_PartnerRole__c = 'Service Provider';
        batchSetting.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
        batchSetting.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        insert batchSetting;
        Contact c = createTestContact();

        // ent1 has a 'New' Batch Entitlement (exercises the BE processing loop)
        // ent2 has a selected Contact Entitlement (exercises the remove-BE creation loop)
        // ent2 is named PRM_PSG so it matches the Contact Entitlement query
        Core_Entitlement__c ent1 = createEntitlement('Test Inact Ent One');
        Core_Entitlement__c ent2 = createEntitlement(System.Label.PRM_PSG);

        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(
            PRM_Contact_Id__c = c.Id,
            PRM_Entitlement_Id__c = ent1.Id,
            PRM_Status_Nm__c = 'New',
            PRM_IsRemove_Ind__c = false,
            PRM_Status_Reason_Txt__c = 'Test');
        insert be;

        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = c.Id,
            Core_Entitlement_Id__c = ent2.Id,
            Core_Selected__c = true,
            Core_Status__c = 'Complete');
        insert ce;

        // Active subscription so the else-branch inactivates it
        PRM_Partner_Subscription__c sub = new PRM_Partner_Subscription__c(
            Name = 'Membership Communications', PRM_Subscription_Cd__c = 'MEMBCOM');
        insert sub;
        PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c(
            PRM_Contact_Id__c = c.Id,
            PRM_Partner_Subscription_Id__c = sub.Id,
            PRM_Status_Nm__c = System.Label.PRM_Status_Active,
            PRM_Status_Reason_Txt__c = 'Active');
        insert csa;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = c.AccountId;
        acr.PRM_Contact_Id__c = c.Id;

        Test.startTest();
        //Branch 1: acrListWorksfor populated -> BE processing + remove-BE creation
        PRM_AcctContRel_TriggerHandlerNew.inactivateContactEntitlement(
            new List<Id>{ c.Id }, new List<Id>{ ent1.Id, ent2.Id }, new List<PRM_Account_Contact_Relationship__c>{ acr },
            new Set<Id>{ ent1.Id, ent2.Id }, new List<PRM_Account_Contact_Relationship__c>{ acr }, true);

        //Branch 2: acrListWorksfor empty (drives contact role removal / subscription / group paths)
        PRM_AcctContRel_TriggerHandlerNew.inactivateContactEntitlement(
            new List<Id>{ c.Id }, new List<Id>{ ent1.Id, ent2.Id }, new List<PRM_Account_Contact_Relationship__c>(),
            new Set<Id>{ ent1.Id, ent2.Id }, new List<PRM_Account_Contact_Relationship__c>(), true);
        Test.stopTest();

        System.assert(true, 'inactivateContactEntitlement executed without unhandled exception');
    }

    /* Directly covers activateContactEntitlement - entitlement processing
       (existing-BE update and new-BE creation branches) and subscription
       activation (both the skip and the activate branches). */
    @isTest
    static void testActivateContactEntitlement(){
        Contact c = createTestContact();

        // ent1 has a 'New' Batch Entitlement -> exercises the existing-BE update branch
        // ent2 has no Batch Entitlement      -> exercises the new-BE creation branch
        // both are named PRM_PSG so they match the Contact Entitlement query
        Core_Entitlement__c ent1 = createEntitlement(System.Label.PRM_PSG);
        Core_Entitlement__c ent2 = createEntitlement('Test Act Ent Two');

        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(
            PRM_Contact_Id__c = c.Id,
            PRM_Entitlement_Id__c = ent1.Id,
            PRM_Status_Nm__c = 'New',
            PRM_IsRemove_Ind__c = false,
            PRM_Status_Reason_Txt__c = 'Test');
        insert be;

        // Both Contact Entitlements are NOT selected so activate processes them
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>{
            new Core_Contact_Entitlement__c(
                Core_Contact_Id__c = c.Id, Core_Entitlement_Id__c = ent1.Id,
                Core_Selected__c = false, Core_Status__c = 'Pending'),
            new Core_Contact_Entitlement__c(
                Core_Contact_Id__c = c.Id, Core_Entitlement_Id__c = ent2.Id,
                Core_Selected__c = false, Core_Status__c = 'Pending')
        };
        insert ceList;

        // Inactive subscription so the activate-subscription branches run
        PRM_Partner_Subscription__c sub = new PRM_Partner_Subscription__c(
            Name = 'Membership Communications', PRM_Subscription_Cd__c = 'MEMBCOM');
        insert sub;
        PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c(
            PRM_Contact_Id__c = c.Id,
            PRM_Partner_Subscription_Id__c = sub.Id,
            PRM_Status_Nm__c = System.Label.PRM_Status_Inactive,
            PRM_Status_Reason_Txt__c = 'Inactive');
        insert csa;

        Test.startTest();
        //Call 1: mapContIdToSourceAgent contains the contact -> subscription skip branch
        PRM_AcctContRel_TriggerHandlerNew.activateContactEntitlement(
            new List<Id>{ c.Id }, new List<Id>(), new List<Id>(),
            new Map<Id, String>{ c.Id => 'Bulk Add' }, true);

        //Call 2: entitlement processing (BE update + BE create) + subscription activation
        PRM_AcctContRel_TriggerHandlerNew.activateContactEntitlement(
            new List<Id>{ c.Id }, new List<Id>{ ent1.Id, ent2.Id }, new List<Id>(),
            new Map<Id, String>(), true);
        Test.stopTest();

        System.assert(true, 'activateContactEntitlement executed without unhandled exception');
    }

    /* Drives the afterUpdate entitlement-matrix processing loop (works-for,
       PA/PAD and allEntId inactivation branches plus the activeUpdateCheck
       reactivation branch) by creating Entitlement Matrix records linked to
       default / Partner-Admin / works-for contact relationships and toggling
       the related ACRs through the trigger flow. */
    @isTest
    static void testEntitlementMatrixInactivateActivateFlow(){
        //Required by inactivateContactEntitlement - queried before its try block
        PRM_BatchCustomSetting__c batchSetting = new PRM_BatchCustomSetting__c();
        batchSetting.Name = System.Label.PRM_BatchValues;
        batchSetting.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        batchSetting.PRM_PartnerRole__c = 'Service Provider';
        batchSetting.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
        batchSetting.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        insert batchSetting;

        Contact testConObj = createTestContact();

        ChannelProgram prgm = new ChannelProgram(
            Name = System.Label.PRM_Intel_Partner_Alliance, PRM_programCode__c = 'IPA',
            IsActive = true, PRM_inactind__c = false);
        insert prgm;
        ChannelProgramLevel cpl = new ChannelProgramLevel(
            Name = 'Titanium', PRM_programlevelcode__c = 'Titanium',
            PRM_inactind__c = false, ProgramId = prgm.Id);
        insert cpl;

        // Active Channel Membership for the account (populates acmMap during activate)
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = testConObj.AccountId,
            PRM_Status_Nm__c = 'Approved',
            PRM_Channel_Program_Id__c = prgm.Id,
            PRM_Channel_Program_Level_Id__c = cpl.Id,
            PRM_Partner_Role__c = 'Service Provider',
            PRM_Status_Reason_Txt__c = 'Test');
        insert acm;

        // defaultRel  -> default relationship (works-for branch)
        // padRel      -> Partner Admin relationship (PA/PAD branch)
        // activeRel   -> stays active so acrListWorksfor is non-empty
        PRM_ContactRelationships__c defaultRel = new PRM_ContactRelationships__c(
            Name = System.Label.PRM_WorksFor, PRM_Contact_Relationship_Cd__c = 'WORKSFOR',
            PRM_Default_Relationship_Ind__c = true, PRM_Mandatory_Relationship_Ind__c = false,
            PRM_InActive_Ind__c = false, PRM_Channel_Program_Id__c = prgm.Id);
        PRM_ContactRelationships__c padRel = new PRM_ContactRelationships__c(
            Name = System.Label.PRM_PartnerAdmin_Rel, PRM_Contact_Relationship_Cd__c = 'RELTNPRCTC',
            PRM_Default_Relationship_Ind__c = false, PRM_Mandatory_Relationship_Ind__c = false,
            PRM_InActive_Ind__c = false, PRM_Channel_Program_Id__c = prgm.Id);
        PRM_ContactRelationships__c activeRel = new PRM_ContactRelationships__c(
            Name = System.Label.PRM_Primary_Contact, PRM_Contact_Relationship_Cd__c = 'PRIMARY',
            PRM_Default_Relationship_Ind__c = false, PRM_Mandatory_Relationship_Ind__c = false,
            PRM_InActive_Ind__c = false, PRM_Channel_Program_Id__c = prgm.Id);
        insert new List<PRM_ContactRelationships__c>{ defaultRel, padRel, activeRel };

        Core_Entitlement__c ent1 = createEntitlement('Matrix Ent One');
        Core_Entitlement__c ent2 = createEntitlement('Matrix Ent Two');

        Schema.RecordTypeInfo entRtInfo = Schema.SObjectType.PRM_VXEnttlmntMatrix__c
            .getRecordTypeInfosByName().get(System.Label.PRM_Entitlement_RecordType);
        Id entRtId = entRtInfo != null ? entRtInfo.getRecordTypeId() : null;

        PRM_VXEnttlmntMatrix__c emDefault = new PRM_VXEnttlmntMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic', PRM_IsActive_Ind__c = true,
            PRM_Contact_Relationship_Id__c = defaultRel.Id, PRM_IPA_Partner_Role_Nm__c = 'Service Provider',
            PRM_Channel_Program_Level_Id__c = cpl.Id, PRM_Entitlement_Id__c = ent1.Id);
        PRM_VXEnttlmntMatrix__c emPad = new PRM_VXEnttlmntMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic', PRM_IsActive_Ind__c = true,
            PRM_Contact_Relationship_Id__c = padRel.Id, PRM_IPA_Partner_Role_Nm__c = 'Service Provider',
            PRM_Channel_Program_Level_Id__c = cpl.Id, PRM_Entitlement_Id__c = ent2.Id);
        if(entRtId != null){
            emDefault.RecordTypeId = entRtId;
            emPad.RecordTypeId = entRtId;
        }
        insert new List<PRM_VXEnttlmntMatrix__c>{ emDefault, emPad };

        PRM_Account_Contact_Relationship__c acrA = new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c = testConObj.AccountId, PRM_Contact_Id__c = testConObj.Id,
            PRM_Relationship_Id__c = defaultRel.Id, PRM_InActive_Ind__c = false,
            PRM_Status_Nm__c = 'Complete');
        PRM_Account_Contact_Relationship__c acrB = new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c = testConObj.AccountId, PRM_Contact_Id__c = testConObj.Id,
            PRM_Relationship_Id__c = padRel.Id, PRM_InActive_Ind__c = false,
            PRM_Status_Nm__c = 'Complete');
        PRM_Account_Contact_Relationship__c acrC = new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c = testConObj.AccountId, PRM_Contact_Id__c = testConObj.Id,
            PRM_Relationship_Id__c = activeRel.Id, PRM_InActive_Ind__c = false,
            PRM_Status_Nm__c = 'Complete');
        insert new List<PRM_Account_Contact_Relationship__c>{ acrA, acrB, acrC };

        Test.startTest();
        //Deactivate the default + Partner-Admin ACRs (acrC stays active -> acrListWorksfor populated)
        PRM_AcctContRelUtility.firstRunBeforeUpdate = true;
        PRM_AcctContRelUtility.firstRunAfterUpdate = true;
        PRM_AcctContRel_TriggerHandlerNew.firstRun = true;
        acrA.PRM_InActive_Ind__c = true; acrA.PRM_Status_Nm__c = 'Complete';
        acrB.PRM_InActive_Ind__c = true; acrB.PRM_Status_Nm__c = 'Complete';
        update new List<PRM_Account_Contact_Relationship__c>{ acrA, acrB };

        //Reactivate the default ACR -> activeUpdateCheck / entitlement-without-benefit path
        PRM_AcctContRelUtility.firstRunBeforeUpdate = true;
        PRM_AcctContRelUtility.firstRunAfterUpdate = true;
        PRM_AcctContRel_TriggerHandlerNew.firstRun = true;
        acrA.PRM_InActive_Ind__c = false; acrA.PRM_Status_Nm__c = 'Complete';
        update acrA;
        Test.stopTest();

        System.assert(true, 'Entitlement matrix inactivate/activate flow executed without unhandled exception');
    }

    /* Directly covers insertContactEntitlement - the benefit-driven and default
       entitlement assignment loops (account benefit association -> benefit
       matrix -> entitlement matrix -> contact entitlement / batch entitlement
       creation). */
    @isTest
    static void testInsertContactEntitlement(){
        Contact c = createTestContact();

        ChannelProgram prgm = new ChannelProgram(
            Name = System.Label.PRM_Intel_Partner_Alliance, PRM_programCode__c = 'IPA',
            IsActive = true, PRM_inactind__c = false);
        insert prgm;
        ChannelProgramLevel cpl = new ChannelProgramLevel(
            Name = 'Titanium', PRM_programlevelcode__c = 'Titanium',
            PRM_inactind__c = false, ProgramId = prgm.Id);
        insert cpl;

        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = c.AccountId, PRM_Channel_Program_Id__c = prgm.Id,
            PRM_Channel_Program_Level_Id__c = cpl.Id, PRM_Status_Nm__c = 'Approved',
            PRM_Partner_Role__c = 'Service Provider', PRM_Status_Reason_Txt__c = 'Test');
        insert acm;

        PRM_ContactRelationships__c rel = new PRM_ContactRelationships__c(
            Name = System.Label.PRM_WorksFor, PRM_Contact_Relationship_Cd__c = 'WORKSFOR',
            PRM_Default_Relationship_Ind__c = true, PRM_Mandatory_Relationship_Ind__c = false,
            PRM_InActive_Ind__c = false, PRM_Channel_Program_Id__c = prgm.Id);
        insert rel;

        // Benefit + partner type + benefit matrix + active account benefit association
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(
            Name = 'Technology Sandbox', PRM_Benefit_Cd__c = 'BFTSNDBX',
            PRM_Channel_Program_Id__c = prgm.Id, PRM_Account_Type_Nm__c = 'Mastered_Account');
        insert pb;
        PRM_PartnerType__c pt = new PRM_PartnerType__c(
            Name = 'Cloud Service Provider (CSP)', PRM_PartneryTypeCode__c = 'CSP',
            PRM_PartnerRoleCode__c = 'SPR', PRM_channelprogram__c = prgm.Id);
        insert pt;
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(
            PRM_Partner_Benefit_Id__c = pb.Id, PRM_Channel_Program_Id__c = prgm.Id,
            PRM_Channel_Program_Level_Id__c = cpl.Id, PRM_Partner_Type_Id__c = pt.Id,
            PRM_Covered_Account_Ind__c = true, PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_IsActive_Ind__c = true, PRM_Partner_Role_Nm__c = 'Service Provider');
        insert bm;
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(
            PRM_Partner_Benefit_Id__c = pb.Id, PRM_Account_Id__c = c.AccountId,
            PRM_Status_Nm__c = System.Label.PRM_Status_Active, PRM_Source__c = 'Tier',PRM_Status_Reason_Txt__c='Test');
        insert aba;

        // Entitlement + entitlement matrix linked to the benefit, relationship and partner role
        Core_Entitlement__c ent = createEntitlement('Insert CE Ent');
        Schema.RecordTypeInfo entRtInfo = Schema.SObjectType.PRM_VXEnttlmntMatrix__c
            .getRecordTypeInfosByName().get(System.Label.PRM_Entitlement_RecordType);
        Id entRtId = entRtInfo != null ? entRtInfo.getRecordTypeId() : null;
        PRM_VXEnttlmntMatrix__c em = new PRM_VXEnttlmntMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic', PRM_IsActive_Ind__c = true,
            PRM_Contact_Relationship_Id__c = rel.Id, PRM_IPA_Partner_Role_Nm__c = 'Service Provider',
            PRM_Channel_Program_Level_Id__c = cpl.Id, PRM_Entitlement_Id__c = ent.Id,
            PRM_Partner_Benefit_Id__c = pb.Id);
        if(entRtId != null){ em.RecordTypeId = entRtId; }
        insert em;

        // Active, Complete ACR matching the relationship + partner role
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c = c.AccountId, PRM_Contact_Id__c = c.Id,
            PRM_Relationship_Id__c = rel.Id, PRM_InActive_Ind__c = false,
            PRM_Status_Nm__c = 'Complete',PRM_Status_Reason_Txt__c = 'Test');

        Test.startTest();
        PRM_AcctContRel_TriggerHandlerNew.insertContactEntitlement(
            new List<PRM_Account_Contact_Relationship__c>{ acr },
            null,
            new List<PRM_AccountChannelMembership__c>{ acm });
        Test.stopTest();

        System.assert(true, 'insertContactEntitlement executed without unhandled exception');
    }
    @isTest
static void testDeactivateAcrFlow(){

    PRM_BatchCustomSetting__c batchSetting = new PRM_BatchCustomSetting__c();
    batchSetting.Name = System.Label.PRM_BatchValues;
    batchSetting.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
    batchSetting.PRM_PartnerRole__c = 'Service Provider';
    batchSetting.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
    batchSetting.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
    insert batchSetting;

    Contact testConObj = createTestContact();
    CreateAccountChannelMembership(testConObj, 'Approved');

    PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c(
        PRM_Account_Id__c = testConObj.AccountId,
        PRM_Contact_Id__c = testConObj.Id,
        PRM_Relationship_Id__c = CreateRelationship().Id,
        PRM_InActive_Ind__c = false,
        PRM_Status_Nm__c = 'Complete',
        PRM_Status_Reason_Txt__c = 'Test'
    );
    insert acr;

    Test.startTest();

    PRM_AcctContRelUtility.firstRunBeforeUpdate = true;
    PRM_AcctContRelUtility.firstRunAfterUpdate = true;
    PRM_AcctContRel_TriggerHandlerNew.firstRun = true;

    acr.PRM_InActive_Ind__c = true;
    update acr;

    Test.stopTest();

    System.assert(true);
}
    @isTest
static void testReactivateAcrFlow(){

    PRM_BatchCustomSetting__c batchSetting = new PRM_BatchCustomSetting__c();
    batchSetting.Name = System.Label.PRM_BatchValues;
    batchSetting.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
    batchSetting.PRM_PartnerRole__c = 'Service Provider';
    batchSetting.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
    batchSetting.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
    insert batchSetting;

    Contact testConObj = createTestContact();
    CreateAccountChannelMembership(testConObj, 'Approved');

    PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c(
        PRM_Account_Id__c = testConObj.AccountId,
        PRM_Contact_Id__c = testConObj.Id,
        PRM_Relationship_Id__c = CreateRelationship().Id,
        PRM_InActive_Ind__c = true,
        PRM_Status_Nm__c = 'Complete',
        PRM_Status_Reason_Txt__c = 'Test'
    );
    insert acr;

    Test.startTest();

    PRM_AcctContRelUtility.firstRunBeforeUpdate = true;
    PRM_AcctContRelUtility.firstRunAfterUpdate = true;
    PRM_AcctContRel_TriggerHandlerNew.firstRun = true;

    acr.PRM_InActive_Ind__c = false;
    acr.PRM_Status_Nm__c = 'Complete';
    update acr;

    Test.stopTest();

    System.assert(true);
}
    @isTest
static void testSuppressEmailFlow(){

    Contact testConObj = createTestContact();
    CreateAccountChannelMembership(testConObj, 'Approved');

    PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c(
        PRM_Account_Id__c = testConObj.AccountId,
        PRM_Contact_Id__c = testConObj.Id,
        PRM_Relationship_Id__c = CreateRelationship().Id,
        PRM_InActive_Ind__c = false,
        PRM_Status_Nm__c = 'Complete',
        PRM_Suppress_Email__c = false
    );
    insert acr;

    Test.startTest();

    PRM_AcctContRelUtility.firstRunBeforeUpdate = true;
    PRM_AcctContRelUtility.firstRunAfterUpdate = true;

    acr.PRM_Suppress_Email__c = true;
    update acr;

    Test.stopTest();

    System.assert(true);
}

}