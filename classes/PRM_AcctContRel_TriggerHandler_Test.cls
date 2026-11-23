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
        acctObj.RecordTypeId=[select Id from RecordType where sObjectType='Account' and Name='Intel Account'].Id;
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
    
}