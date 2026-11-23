@isTest
public class ER_ProcessAutoApprovedRecordsUtilityTest {
    
    static testMethod void ABTValidationRuleException()
    {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                         /* Core_Account_Type__c='Other',*/RecordTypeId=recordTypeIdAccount, Industry='Others',Core_English_Only_Name__c = 'exception',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',MailingCountry='India',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1; 
        
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cp.Id;
        membership.PRM_Account_Id__c=testAccount.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Partner_Role__c='Distributor';
        membership.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        membership.PRM_Status_Reason_Txt__c='Test';
        insert membership;
        
        Core_AGS_Role__c agsrole = new Core_AGS_Role__c();
        agsrole.Core_Technical_Name__c = 'RDC_Priv_User';
        agsrole.Name = 'Developer Zone Premier';
        insert agsrole;
        
        Core_Entitlement__c ee = new Core_Entitlement__c();
        ee.Core_AGS_Role_Id__c = agsrole.Id;
        ee.Name ='Resource & Design Center for Secure Content';
        ee.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee.Core_Display_Name__c = 'Developer Zone Premier(CNDA required)';
        insert ee;
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'testFirstName123';
        regRequest.PRM_Last_Name__c = 'testLastName';
        regRequest.PRM_Email_ID__c = 'test1234@testing.com.testsetup';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.Entitlement_Details__c = ee.Id;
        regRequest.PRM_Contact_Salesforce_Id__c = testContact.Id;
        regRequest.PRM_Salesforce_ID__c = testAccount.Id;
        regRequest.Current_Status__c = 'Open';
        regRequest.PRM_Status__c = 'New';
        regRequest.RecordTypeId = accCreateRequestId;
        insert regRequest;
        
        List<ProcessAutoApprovedRecords__e> event= new List<ProcessAutoApprovedRecords__e>();
        Test.startTest();
        ProcessAutoApprovedRecords__e evn= new ProcessAutoApprovedRecords__e();
        evn.RequestID__c = regRequest.Id;
        evn.AccountId__c = regRequest.PRM_Salesforce_ID__c;
        evn.ContactId__c = regRequest.PRM_Contact_Salesforce_Id__c;
        evn.EntitlementId__c = regRequest.Entitlement_Details__c;
        event.add(evn);
        
        ER_ProcessAutoApprovedRecordsUtility.AssignABTandCBT(event);
        
        List<PRM_Registration_Request__c> regreq1 = [select Id,Current_Status__c, PRM_Review_Note_txt__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'test1234@testing.com.testsetup'];
        
        System.assertEquals('Open', regreq1[0].Current_Status__c);
        Test.stopTest();
        
    }
    
    static testMethod void PlatformEventTrigger()
    {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          /*Core_Account_Type__c='Other', // BizOrgType code removal*/ Industry='Others',Core_English_Only_Name__c = 'exception',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', RecordTypeId=recordTypeIdAccount,BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',MailingCountry='India',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        Core_AGS_Role__c agsrole = new Core_AGS_Role__c();
        agsrole.Core_Technical_Name__c = 'RDC_Priv_User';
        agsrole.Name = 'Developer Zone Premier';
        insert agsrole;
        
        Core_Entitlement__c ee = new Core_Entitlement__c();
        ee.Core_AGS_Role_Id__c = agsrole.Id;
        ee.Name ='Resource & Design Center for Secure Content';
        ee.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee.Core_Display_Name__c = 'Developer Zone Premier(CNDA required)';
        insert ee;
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        insert business;
        
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        PRM_VXEnttlmntMatrix__c em = new PRM_VXEnttlmntMatrix__c();
        em.Business_Types__c = business.Id;
        em.PRM_IsActive_Ind__c = true;
        em.PRM_Entitlement_Id__c = ee.Id;
        em.RecordTypeId = eBREnttRecTypeId;
        em.PRM_Approval_Type_Nm__c = 'Manual';
        insert em;
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'testFirstName123';
        regRequest.PRM_Last_Name__c = 'testLastName';
        regRequest.PRM_Email_ID__c = 'test1234@testing.com.testsetup';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.Entitlement_Details__c = ee.Id;
        regRequest.PRM_Contact_Salesforce_Id__c = testContact.Id;
        regRequest.PRM_Salesforce_ID__c = testAccount.Id;
        regRequest.Current_Status__c = 'Open';
        regRequest.PRM_Status__c = 'New';
        regRequest.RecordTypeId = accCreateRequestId;
        insert regRequest;
                
        List<ProcessAutoApprovedRecords__e> event= new List<ProcessAutoApprovedRecords__e>();
        Test.startTest();
        ProcessAutoApprovedRecords__e evn= new ProcessAutoApprovedRecords__e();
        evn.RequestID__c = regRequest.Id;
        evn.AccountId__c = regRequest.PRM_Salesforce_ID__c;
        evn.ContactId__c = regRequest.PRM_Contact_Salesforce_Id__c;
        evn.EntitlementId__c = regRequest.Entitlement_Details__c;
        event.add(evn);
        List<Database.SaveResult> results = EventBus.publish(event);
        
        
        List<PRM_Registration_Request__c> regreq1 = [select Id,Current_Status__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'test1234@testing.com.testsetup'];
        System.assertEquals('Open', regreq1[0].Current_Status__c);
        Test.stopTest();
    }
    
    static testMethod void UpdateSuccessRegReq()
    {
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          /*Core_Account_Type__c='Other', // BizOrgType code removal*/ Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'exception',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',MailingCountry='India',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1; 
        
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cp.Id;
        membership.PRM_Account_Id__c=testAccount.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Partner_Role__c='Distributor';
        membership.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        membership.PRM_Status_Reason_Txt__c='Test';
        insert membership;
        
        Core_AGS_Role__c agsrole = new Core_AGS_Role__c();
        agsrole.Core_Technical_Name__c = 'RDC_Priv_User';
        agsrole.Name = 'Developer Zone Premier';
        insert agsrole;
        
        Core_Entitlement__c ee = new Core_Entitlement__c();
        ee.Core_AGS_Role_Id__c = agsrole.Id;
        ee.Name ='Resource & Design Center for Secure Content';
        ee.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee.Core_Display_Name__c = 'Developer Zone Premier(CNDA required)';
        insert ee;
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        insert business;
        
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        PRM_VXEnttlmntMatrix__c em = new PRM_VXEnttlmntMatrix__c();
        em.Business_Types__c = business.Id;
        em.PRM_IsActive_Ind__c = true;
        em.PRM_Entitlement_Id__c = ee.Id;
        em.RecordTypeId = eBREnttRecTypeId;
        em.PRM_Approval_Type_Nm__c = 'Manual';
        insert em;
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'testFirstName123';
        regRequest.PRM_Last_Name__c = 'testLastName';
        regRequest.PRM_Email_ID__c = 'test1234@testing.com.testsetup';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.Entitlement_Details__c = ee.Id;
        regRequest.PRM_Contact_Salesforce_Id__c = testContact.Id;
        regRequest.PRM_Salesforce_ID__c = testAccount.Id;
        regRequest.Current_Status__c = 'Open';
        regRequest.PRM_Status__c = 'New';
        regRequest.RecordTypeId = accCreateRequestId;
        Test.startTest();
        insert regRequest;
        Test.stopTest();
        
        List<PRM_Registration_Request__c> regreq1 = [select Id,Current_Status__c,PRM_Contact_Salesforce_Id__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'test1234@testing.com.testsetup'];
       // System.assertEquals(regreq1[0].Current_Status__c, 'Auto-Approval Pending');
        
        List<Contact_Business_Types__c> cbts = [SELECT Id,Contact__r.Email,Status__c FROM Contact_Business_Types__c WHERE Status__c = 'Approval - Pending' AND Contact__c =: testContact.Id];
        //System.assertEquals(cbts.size(),1);
        
        //cbts[0].Status__c = 'Approved';
        //update cbts[0];
        
        List<Contact_Business_Types__c> cbts1 = [SELECT Id,Contact__r.Email,Status__c FROM Contact_Business_Types__c WHERE Status__c = 'Approved' AND Contact__c =: testContact.Id];
        //System.assertEquals(cbts1.size(),1);
    }
    
    static testMethod void ExceptionMethod()
    {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                         /* Core_Account_Type__c='Other',// BizOrgType code removal*/ Industry='Others',Core_English_Only_Name__c = 'exception',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA',RecordTypeId=recordTypeIdAccount, BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',MailingCountry='India',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1; 
        
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cp.Id;
        membership.PRM_Account_Id__c=testAccount.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Partner_Role__c='Distributor';
        membership.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        membership.PRM_Status_Reason_Txt__c='Test';
        insert membership;
        
        Core_AGS_Role__c agsrole = new Core_AGS_Role__c();
        agsrole.Core_Technical_Name__c = 'RDC_Priv_User';
        agsrole.Name = 'Developer Zone Premier';
        insert agsrole;
        
        Core_Entitlement__c ee = new Core_Entitlement__c();
        ee.Core_AGS_Role_Id__c = agsrole.Id;
        ee.Name ='Resource & Design Center for Secure Content';
        ee.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee.Core_Display_Name__c = 'Developer Zone Premier(CNDA required)';
        insert ee;
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'testFirstName123';
        regRequest.PRM_Last_Name__c = 'testLastName';
        regRequest.PRM_Email_ID__c = 'test1234@testing.com.testsetup';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.Entitlement_Details__c = ee.Id;
        regRequest.PRM_Contact_Salesforce_Id__c = testContact.Id;
        regRequest.PRM_Salesforce_ID__c = testAccount.Id;
        regRequest.Current_Status__c = 'Open';
        regRequest.PRM_Status__c = 'New';
        regRequest.RecordTypeId = accCreateRequestId;
        insert regRequest;
        
        List<ProcessAutoApprovedRecords__e> event= new List<ProcessAutoApprovedRecords__e>();
        Test.startTest();
        ProcessAutoApprovedRecords__e evn= new ProcessAutoApprovedRecords__e();
        evn.RequestID__c = regRequest.Id;
        evn.AccountId__c = regRequest.PRM_Salesforce_ID__c;
        evn.ContactId__c = regRequest.PRM_Contact_Salesforce_Id__c;
        evn.EntitlementId__c = null;
        event.add(evn);
        
        ER_ProcessAutoApprovedRecordsUtility.AssignABTandCBT(event);
        
        List<PRM_Registration_Request__c> regreq1 = [select Id,Current_Status__c, PRM_Review_Note_txt__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'test1234@testing.com.testsetup'];
        
        //System.assertEquals('Auto-Approval Pending', regreq1[0].Current_Status__c);
        Test.stopTest();
        
    }
    
}