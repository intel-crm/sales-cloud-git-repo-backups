@isTest
public class PRM_IPA_TriggerHandler_Test {
    
    @testSetup
    static void setupTestData() {
        Test.startTest();
        Contact testConObj = createTestContact();
        Test.stopTest();
    } 
    
    @isTest
    static void Insert_Update_ContactEntitlement()
    {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];       
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;        
        
        system.runas(itAdminUser){
            Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
            cm.Name = 'IPS Standard Entitlement';
            cm.Value__c  = 'IPS Standard Entitlement';
            insert cm;
            
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false);
            insert testAccount;
            
            Contact testContact = new Contact(FirstName = 'testFirstName123', LastName = 'testLastName', Email = 'test123@testing.com.test', Core_IPA_PartnerRole__c = 'Service Provider',
                                              AccountId = testAccount.Id, Core_IPS_Active__c = false, Core_IPS_Intel_Support_Owner__c = itAdminUser.Id, MailingCountry ='USA');
            insert testContact;
            Test.startTest();
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;   
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
            insert entitle;
            Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
            insert entitle1;
            Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
            insert entitle2;
            
            
            
            List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
            //Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false,Core_Data_Loaded__c=true);
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true,Core_Data_Loaded__c=true);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true,Core_Data_Loaded__c=true);
            //newlstentitle.add(ce1);
            newlstentitle.add(ce2);
            newlstentitle.add(ce3);
            insert newlstentitle;
            
            List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
            //Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
            
            Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
            Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);
            
            //oldlstentitle.add(conent1);
            oldlstentitle.add(conent2);
            oldlstentitle.add(conent3);
            
            update  oldlstentitle;   
            system.assert(oldlstentitle.size() > 0);
            Test.stopTest();
            
        }       
    }
    
    @isTest
    static void Insert_Update_Contact()
    {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'Contact_Insert_IPA_Integration_Trigger';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            Core_Trigger_Executions__c executeTrigger1 = new Core_Trigger_Executions__c();
            executeTrigger1.Name = 'Contact_Update_IPA_Integration_Trigger';
            executeTrigger1.Core_Object__c = 'Contact';
            executeTrigger1.Core_Active__c = TRUE;
            executeTrigger1.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger1.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger1.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger1;
            System.assertNotEquals(null, executeTrigger1.Id);
            
            
            // Create a new Contact 
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            contact.Core_IPA_PartnerRole__c = 'Service Provider';
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            contact.MailingCountry = 'USA';
            insert contact;
            System.assertNotEquals(null, contact.Id);
            
            // Make sure that the Job Function is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c, Core_ERPM_Integration_Status__c,PRM_IPA_Integration_Status__c
                       FROM Contact WHERE Id = :contact.Id];
            //System.assertEquals('Pending', contact.PRM_IPA_Integration_Status__c);        
            
            contact.PRM_IPA_Integration_Status__c = 'Successful';
            update contact;            
            
            // Update the existing Contact 
            contact.LastName = 'Testatb';            
            //contact.Core_English_Only_First_Name__c = 'ATB'; 
            Core_ContactHandler.hasRunUpdate = false;
            update contact;
            
            contact = [select Id, Core_English_Only_Last_Name__c, Core_ERPM_Integration_Status__c,LastName,PRM_IPA_Integration_Status__c 
                       FROM Contact WHERE Id = :contact.Id];
            System.assertEquals('Successful', contact.PRM_IPA_Integration_Status__c);   
            System.assertEquals('Testatb', contact.LastName);
        }
    }
    
    @isTest
    static void Update_account() {
        test.startTest();
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'Account_Update_IPA_Integration_Trigger';
            executeTrigger.Core_Object__c = 'Account';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Update';
            executeTrigger.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger.Core_Class_Name__c = 'Core_Account';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
        }
        
        Contact testConObj = [SELECT Id,AccountId,PRM_IPA_Integration_Status__c 
                              from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c, Core_IPA_Partner_Role__c 
                       FROM Account WHERE Id =: testConObj.AccountId];
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        act.Core_IPA_Partner_Role__c = 'Distributor';
        //act.PRM_IPA_Integration_Status__c = 'Successful';
        update act;
        Account actUpdate = [SELECT Id,Core_IPA_Partner_Role__c, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: act.Id];
        //System.assertEquals('Pending', actUpdate.PRM_IPA_Integration_Status__c);                             
        test.stopTest();
    }
    
    @isTest
    static void Insert_Update_ACM()
    {
        Contact testConObj = [SELECT Id,AccountId,PRM_IPA_Integration_Status__c 
                              from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        //PMP_Company__c company = 
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem[0]);
        
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(acctConMem, acctConMem.getSObjectType());
        cntsts.execute(null);
        
        Contact cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c
                     FROM Contact where id=: testConObj.Id];
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        
        //Test.stopTest();
        
        //Test.startTest();
        
        acctConMem[0].PRM_Status_Nm__c = 'Inactive';
        acctConMem[0].PRM_Status_Reason_Txt__c ='inactive';
        PRM_ACM_TriggerHandler.firstRun = true;
        PRM_ACM_TriggerHandler.IPAfirstRun = true;
        
        Test.startTest();
        update acctConMem;
        Test.stopTest();
        
        
        ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(acctConMem, acctConMem.getSObjectType());
        cntsts1.execute(null);
        
        cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c FROM Contact where id=: testConObj.Id];
        Account actUpdate = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', actUpdate.PRM_IPA_Integration_Status__c);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
    }
    
    @isTest
    static void Insert_Update_ACR()
    {
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        
        Test.startTest();
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();       
        
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        List<PRM_Account_Contact_Relationship__c> rel = new List<PRM_Account_Contact_Relationship__c>();
        rel.add( CreateAccountContactRelationship(testConObj, acctConMem[0]));
        
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(rel, rel.getSObjectType());
        cntsts.execute(null);
        
        Contact cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c, PRM_IPA_Integration_Status__c 
                     FROM Contact where id=: testConObj.Id];
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        
        rel[0].PRM_InActive_Ind__c = false;
        PRM_AcctContRel_TriggerHandler.firstRun = true;
        PRM_AcctContRel_TriggerHandler.IPAfirstRun = true;
        
        cnt.PRM_IPA_Integration_Status__c = 'Successful';
        
        update cnt;
        update rel;
        
        ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(rel, rel.getSObjectType());
        cntsts1.execute(null);
        
        cnt=[SELECT Id, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Queue_txt__c, PRM_IPA_Integration_Status__c 
             FROM Contact where id=: testConObj.Id];
        System.assertEquals('Successful', cnt.PRM_IPA_Integration_Status__c);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        Test.stopTest();
        cntsts1 = new ContactERPMIntegrationStatusHandler(lstIntOBM, lstIntOBM.getSObjectType());
        cntsts1.execute(null);
    }
    
    @isTest
    static void Insert_Update_ABA()
    {
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem[0]);
        
        List<PRM_AccountBenefitAssociation__c> bnft = CreateAccountBenefitAssociation(testConObj, acctConMem[0]);
        
        
        Test.startTest();
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(bnft, bnft.getSObjectType());
        cntsts.execute(null);
        
        Contact cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c FROM Contact where id=: testConObj.Id];
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        
        bnft[0].PRM_Status_Nm__c = 'Inactive';
        bnft[0].PRM_Status_Reason_Txt__c = 'Other';
        PRM_aba_TriggerHandler.firstRun = true;
        PRM_aba_TriggerHandler.IPAfirstRun = true;
        

        act.PRM_IPA_Integration_Status__c = 'Successful';
        update act;
        update bnft;
        
        ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(bnft, bnft.getSObjectType());
        cntsts1.execute(null);
        
        cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c FROM Contact where id=: testConObj.Id];
        Account actUpdate = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', actUpdate.PRM_IPA_Integration_Status__c);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        Test.stopTest();
        
        
    }
    
    @isTest
    static void Insert_Update_CSA()
    {
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];  
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem[0]);
        
        List<PRM_ContactSubscriptionAssociation__c> cntSubLst = new List<PRM_ContactSubscriptionAssociation__c>();
        
        cntSubLst.add(CreateContactSubscriptionAssoction(testConObj));
        
        Test.startTest();
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(cntSubLst, cntSubLst.getSObjectType());
        cntsts.execute(null);
        
        Contact cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c, PRM_IPA_Integration_Status__c 
                     FROM Contact where id=: testConObj.Id];
        //System.assertEquals('In-Progress', cnt.Core_ERPM_Integration_Status__c);  
        //System.assertEquals('Pending', cnt.PRM_IPA_Integration_Status__c);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
       // System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        
        cntSubLst[0].PRM_Status_Nm__c = 'Inactive';
        cntSubLst[0].PRM_Status_Reason_Txt__c ='Inactive';
        PRM_CSA_TriggerHandler.firstRun = true;
        PRM_CSA_TriggerHandler.IPAfirstRun = true;        
        
        if(cnt.Core_ERPM_Integration_Queue_txt__c == 'Full') {
            cnt.Core_ERPM_Integration_Queue_txt__c = 'Empty';
            cnt.Core_ERPM_Integration_Status__c = 'Pending';
            cnt.PRM_IPA_Integration_Status__c = 'Successful';
        }
        
        update cnt;
        update cntSubLst;
        
        ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(cntSubLst, cntSubLst.getSObjectType());
        cntsts1.execute(null);
        
        cnt=[SELECT Id, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Queue_txt__c, PRM_IPA_Integration_Status__c 
             FROM Contact where id=: testConObj.Id];
       // System.assertEquals('In-Progress', cnt.Core_ERPM_Integration_Status__c); 
        System.assertEquals('Full', cnt.Core_ERPM_Integration_Queue_txt__c);
        System.assertEquals('Successful', cnt.PRM_IPA_Integration_Status__c);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());
        Test.stopTest();        
    }
    
    @isTest
    static void Insert_Update_PrflRes()
    {
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];  
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem[0]);
        List<PRM_Profile_Responses__c> prflReslst = new List<PRM_Profile_Responses__c>();
        prflReslst.add(CreateProfileResponsesForCnctAndAcct(testConObj,'HSK'));
        
        Test.startTest();
        
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(prflReslst, prflReslst.getSObjectType());
        cntsts.execute(null);
        
        Contact cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c,PRM_IPA_Integration_Status__c FROM Contact where id=: testConObj.Id];
        //System.assertEquals('In-Progress', cnt.Core_ERPM_Integration_Status__c); 
        System.assertEquals('Empty', cnt.Core_ERPM_Integration_Queue_txt__c); 
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());

        prflReslst[0].PRM_Response_Txt__c = 'Pending';
        prflReslst[0].PRM_Contact_Id__c = cnt.Id;
        PRM_ProfileResponses_TriggerHandler.firstRun = true;
        
        if(cnt.Core_ERPM_Integration_Queue_txt__c == 'Full') {
                        cnt.Core_ERPM_Integration_Queue_txt__c = 'Empty';
                        cnt.Core_ERPM_Integration_Status__c = 'Pending';
                    }
        
        update cnt;
        update prflReslst;
        
        ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(prflReslst, prflReslst.getSObjectType());
        cntsts1.execute(null);
        
  		cnt=[SELECT Id, Core_ERPM_Integration_Status__c,Core_ERPM_Integration_Queue_txt__c,PRM_IPA_Integration_Status__c FROM Contact where id=: testConObj.Id];
        System.assertEquals('In-Progress', cnt.Core_ERPM_Integration_Status__c); 
        System.assertEquals('Empty', cnt.Core_ERPM_Integration_Queue_txt__c);
        //System.assertEquals('Pending', cnt.PRM_IPA_Integration_Status__c); 
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm, lstIntOBM.size());
        Test.stopTest();
        

    }
    
    @isTest
    static void Insert_Account_LA(){
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem[0]);
        
        PRM_PartnerAgreement__c pam = new PRM_PartnerAgreement__c();
        pam.Name='Intel Partner Alliance Terms & Condition';
        pam.PRM_Channel_Program_Id__c = acctConMem[0].PRM_Channel_Program_Id__c;
        pam.PRM_Agreement_Cd__c = 'IPA_TANDC';
        pam.PRM_Agreement_Dsc__c = 'IPA terms and Condition';
        
        insert pam;
        List<PRM_AccountLegalAgreemntAssociation__c> newLAs = new List<PRM_AccountLegalAgreemntAssociation__c>();
        PRM_AccountLegalAgreemntAssociation__c newLA = new PRM_AccountLegalAgreemntAssociation__c();
        newLA.PRM_Account_Id__c = acctConMem[0].PRM_Account_Id__c;
        newLA.PRM_Partner_Agreement_Id__c = pam.Id;
        newLA.PRM_Agreement_Sign_Dt__c = System.now();
        newLA.PRM_Contact__c = testConObj.Id;
        newLAs.add(newLA);
        insert newLAs;
        
        Test.startTest();
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(newLAs, newLAs.getSObjectType());
        cntsts.execute(null);
        
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);

        Test.stopTest();
    }
    
    @isTest
    static void Insert_Update_Partner_Assist_Consent(){
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem[0]);
        List<PRM_Partner_Assist_Consent__c> pacs = CreatePartnerAssistConsent(testConObj.AccountId,testConObj);
        
        Test.startTest();
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(pacs, pacs.getSObjectType());
        cntsts.execute(null);
        
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);
        
        act.PRM_IPA_Integration_Status__c = 'Successful';
        
        pacs[0].PRM_Consent_Provided_Ind__c = false;
        PRM_PartnerAssistConsent_Handler.IPAfirstRun = true;
        
        update act;
        update pacs;
        
        ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(pacs, pacs.getSObjectType());
        cntsts1.execute(null);
        
        act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);
          
        
        Test.stopTest();
    }
    
    
    @isTest
    static void Insert_Update_Account_Whitelisted_Domain(){
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        PRM_Account_Contact_Relationship__c rel= CreateAccountContactRelationship(testConObj, acctConMem[0]);
        List<Core_Account_Whitelisted_Domains__c> awds = CreateAccountWhitelistedDomains(testConObj.AccountId);
        
        Test.startTest();
        
        ContactERPMIntegrationStatusHandler cntsts = new ContactERPMIntegrationStatusHandler(awds, awds.getSObjectType());
        cntsts.execute(null);
        
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);
        
        act.PRM_IPA_Integration_Status__c = 'Successful';
        
        awds[0].Inactive_Indicator__c = true;
        PRM_Whitelisted_Domain_TriggerHandler.IPAfirstRun = true;
        
        update act;
        update awds;
        
        ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(awds, awds.getSObjectType());
        cntsts1.execute(null);
        
        act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);
          
        
        Test.stopTest();
        
    }
    
    @isTest
    static void Insert_Update_ASA() {
        Test.startTest();
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        
        PRM_Account_Specialty_Association__c asa = CreateAccountSplAssociation(testConObj.AccountId);
        
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals(null, act.PRM_IPA_Integration_Status__c);
        
        asa.PRM_InActive_Ind__c = true;
        PRM_Account_Specialty_Assoc_Handler.IPAfirstRun = true;
        //act.PRM_IPA_Integration_Status__c = 'Successful';
        update asa;
        
        System.assertEquals(null, act.PRM_IPA_Integration_Status__c);   
        
        Test.stopTest();
    }
    
    @isTest
    static void Insert_Update_CAG() {
        Test.startTest();
        Contact testConObj = [SELECT Id,AccountId from Contact where Core_eRPM_Person_Id__c = '111111' LIMIT 1];
        //String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='USA',BillingStreet='abc chowk delhi',BillingState='FL',
                                              ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId());
		
       Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='USA',BillingStreet='cbc chowk delhi',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
		
        List<Account> partnerAccts = new List<Account>();
        partnerAccts.add(partnerAccount1);
        partnerAccts.add(intelAccount1);
        insert partnerAccts;
        
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c = partnerAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c = testConObj.AccountId;
        accGroupMem.Core_Inactive_Ind__c = false;
        accGroupMem.Core_MDA_Ind__c = false;
        Database.insert(accGroupMem);
        
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);
        
        accGroupMem.Core_Inactive_Ind__c = true;
        Core_Acct_Grp_Mbr_TriggerHandler.IPAfirstRun = true;
        act.PRM_IPA_Integration_Status__c = 'Successful';
        update act;
        update accGroupMem;
        
        Account actUp = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', actUp.PRM_IPA_Integration_Status__c);
        
        Test.stopTest();
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
        //conObj.Core_ERPM_Integration_Status__c = 'Pending';
        //conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        insert conObj;
        
        Core_Entitlement_Out_Int_Test.createTestContactEntitlement(conObj,1);
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
        acctObj.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acctObj.Core_IPA_Partner_Role__c = 'Service Provider';
        acctObj.Industry = 'Agriculture';
        acctObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        insert acctObj;
        
        
        return acctObj;
    }
    
    public static List<PRM_AccountChannelMembership__c> CreateAccountChannelMembership(Contact cntct, String statusVal)
    {
        ChannelProgram chnlprgm = CreateChannelProgram();       
        List<PRM_AccountChannelMembership__c> acmlst=new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctMembership = new PRM_AccountChannelMembership__c();
        acctMembership.PRM_Account_Id__c = cntct.AccountId;
        acctMembership.PRM_Channel_Program_Id__c = chnlprgm.Id;
        acctMembership.PRM_Status_Nm__c = statusVal;     
        acctMembership.PRM_Status_Reason_Txt__c ='test';   
        acctMembership.PRM_Channel_Program_Level_Id__c = GetChannelProgramLevel(chnlprgm.Id).Id;     
        acctMembership.PRM_Partner_Role__c = 'Service Provider';
        acmlst.add(acctMembership);
        
        insert acctMembership;
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
        lvl.Name = 'Prestige';
        lvl.PRM_programlevelcode__c = 'Prestige';
        lvl.PRM_inactind__c = false;
        lvl.ProgramId = prgmId;
        
        insert lvl;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=prgmId;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=prgmId;
        insert cpl1;
        
        return lvl;
    }
    
    public static PRM_Account_Contact_Relationship__c CreateAccountContactRelationship(Contact cntct, PRM_AccountChannelMembership__c acm)
    {
        PRM_Account_Contact_Relationship__c acctCon = new PRM_Account_Contact_Relationship__c();
        acctCon.PRM_Account_Id__c = cntct.AccountId;
        acctCon.PRM_Contact_Id__c = cntct.Id;
        acctCon.PRM_Relationship_Id__c = CreateRelationship().Id;
        acctCon.PRM_InActive_Ind__c= false;
        
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
        
        PRM_BatchCustomSetting__c bmc = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bmc.Name='BatchFieldValues';
        bmc.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bmc.PRM_ChannelProgramLevel__c='Partner;Partner;Prestige';
        bmc.PRM_SchedulingHour__c=6;
        bmc.PRM_NoOfRecords__c=300;
        bmc.PRM_NoOfBatchEntRecords__c=10;
        bmc.PRM_PartnerRole__c ='Service Provider';
        bmc.PRM_MP_Benefits__c ='Solution Marketplace Enhanced';
        insert bmc;
        
        List<PRM_AccountBenefitAssociation__c> accountBenefits = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c accntBenft = new PRM_AccountBenefitAssociation__c();        
        accntBenft.PRM_Partner_Benefit_Id__c = pb1.ID;
        accntBenft.PRM_Account_Id__c = cntct.AccountId;
        accntBenft.PRM_Status_Nm__c = 'Active';
        accntBenft.PRM_Status_Reason_Txt__c ='test';
        accountBenefits.add(accntBenft);
              
        insert accountBenefits;
        
        return accountBenefits;
        
    }
    
    public static PRM_ContactSubscriptionAssociation__c CreateContactSubscriptionAssoction(Contact cntct)
    {
        PRM_ContactSubscriptionAssociation__c contSub = new PRM_ContactSubscriptionAssociation__c();
        contSub.PRM_Contact_Id__c = cntct.Id;
        contSub.PRM_Partner_Subscription_Id__c = CreatePartnerSubscription().Id;
        contSub.PRM_Status_Nm__c = 'Active';
        contSub.PRM_Status_Reason_Txt__c ='test';
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
    
    public static PRM_Profile_Responses__c CreateProfileResponsesForCnctAndAcct(Contact cntct,String variable)
    {
        PRM_Profile_Responses__c prflRes = new PRM_Profile_Responses__c();
        prflRes.PRM_Account_Id__c = cntct.AccountId;
        prflRes.PRM_Contact_Id__c = cntct.Id;
        prflRes.PRM_Profile_Answer_Id__c = CreateProfileAnswer(variable).Id;
        prflRes.PRM_Profile_Questions_Id__c =  prflRes.PRM_Profile_Answer_Id__r.PRM_Profile_Questions_Id__c;//[SELECT Id FROM PRM_Profile_Questions__c WHERE PRM_Question_Cd__c='TEST' LIMIT 1].Id;//CreateProfileQuestion().Id;
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
    
    public static PRM_Account_Specialty_Association__c CreateAccountSplAssociation(Id accountId) {
        PRM_Specialty__c specialty = new PRM_Specialty__c();
        specialty.name='Select Benefits';     
        specialty.PRM_Access_Level_Nm__c = 'Public';
        specialty.PRM_Role_Nm__c = 'Service Provider';
        specialty.PRM_Tier_Nm__c = 'Gold';
        specialty.PRM_Description_Txt__c = 'Test';
        specialty.PRM_Funding_BU_Nm__c = 'Automotive Sales Group';
        specialty.PRM_Start_Date_Dt__c = system.Today();
        specialty.PRM_End_Date_Dt__c = system.Today()+60;
        insert specialty;
        
        PRM_Account_Specialty_Association__c acctSpecialty = new PRM_Account_Specialty_Association__c();
        acctSpecialty.PRM_Account_Id__c = accountId;
        acctSpecialty.PRM_Specialty_Id__c = specialty.Id;
        acctSpecialty.PRM_InActive_Ind__c = false;
        //acctSpecialty.PRM_Status_Nm__c = 'TBD';
        insert acctSpecialty;
        
        return acctSpecialty;
    }
    
    public static List<Core_Account_Whitelisted_Domains__c> CreateAccountWhitelistedDomains(Id accountId) {
        List<Core_Account_Whitelisted_Domains__c> acctWhiteDomains = new List<Core_Account_Whitelisted_Domains__c>();
        Core_Account_Whitelisted_Domains__c acctWhiteDomain = new Core_Account_Whitelisted_Domains__c();
        acctWhiteDomain.Name = 'gmail1.com';
        acctWhiteDomain.Inactive_Indicator__c = false;
        acctWhiteDomain.Effective_End_Date_Time__c = DateTime.Now().AddDays(1);
        acctWhiteDomain.Account__c = accountId;
        acctWhiteDomain.Partner_Program__c = [SELECT Id FROM ChannelProgram WHERE PRM_programCode__c ='IPA' LIMIT 1].Id;
        acctWhiteDomains.add(acctWhiteDomain);
        insert acctWhiteDomains;
        
        return acctWhiteDomains;
    }
    
    public static List<PRM_Partner_Assist_Consent__c> CreatePartnerAssistConsent(Id accountId, Contact cntct){
        List<PRM_Partner_Assist_Consent__c> pas = new List<PRM_Partner_Assist_Consent__c>();
        
        PRM_Partner_Consent_Distributor__c dist = new PRM_Partner_Consent_Distributor__c();
        dist.PRM_Account_Id__c = accountId;
        dist.PRM_Distributor_Name_Txt__c = 'Test';
        dist.PRM_Geo_Nm__c = 'EMEA';
        dist.PRM_Sub_Region_Nm__c = 'SA';
        
        insert dist;
        
        
        PRM_Partner_Assist_Consent__c pa = new PRM_Partner_Assist_Consent__c();
        pa.PRM_Account_Id__c = accountId;
        pa.PRM_Consent_Provided_By_Id__c = cntct.Id;
        pa.PRM_Consent_Provided_Ind__c = true;
        pa.PRM_Consent_Provided_Date_Dt__c = DateTime.Now();
        pa.PRM_Start_Date_Dt__c = DateTime.Now();
        pa.PRM_End_Date_Dt__c = DateTime.Now().AddDays(1);
        pa.PRM_Choice_Nm__c = 'Partner Assist Choice 1';
        pa.PRM_Distributor_Id__c = dist.Id;
        pas.add(pa);
        
        insert pas;        
        
        
        return pas;
    }
    @isTest
    static void additionalCoverage(){
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];       
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;        
        
        system.runas(itAdminUser){
            Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
            cm.Name = 'IPS Standard Entitlement';
            cm.Value__c  = 'IPS Standard Entitlement';
            insert cm;
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                                Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                                BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                                BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false);
            insert testAccount;
            Contact testContact = new Contact(FirstName = 'testFirstName123', LastName = 'testLastName', Email = 'test123@testing.com.test', Core_IPA_PartnerRole__c = 'Service Provider',
                                                Core_English_Only_First_Name__c = 'testFirstName123', Core_English_Only_Last_Name__c = 'testLastName',AccountId = testAccount.Id, Core_IPS_Active__c = false, Core_IPS_Intel_Support_Owner__c = itAdminUser.Id, MailingCountry='USA');
            List<Contact> conList = new List<Contact>{testContact};
            insert conList;
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);   
            insert business;
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id);
            insert bType;

            ContactERPMIntegrationStatusHandler cntsts1 = new ContactERPMIntegrationStatusHandler(conList, conList.getSObjectType());
            cntsts1.execute(null);

            cntsts1 = new ContactERPMIntegrationStatusHandler(new List<Contact_Business_Types__c>{bType}, new List<Contact_Business_Types__c>{bType}.getSObjectType());
            cntsts1.execute(null);
        }
    }
    
}