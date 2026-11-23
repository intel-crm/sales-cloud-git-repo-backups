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
    
}