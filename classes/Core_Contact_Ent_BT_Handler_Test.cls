/***********************************************************************************************************
Apex Class Name:  Core_Contact_Ent_BT_Handler_Test
Version     : 1.0 
Created Date: 11 NOV 2021
Function    : Test Class for the Core_Contact_Ent_BT_Handler
Modification Log :
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------------------------------                  
* Gaurav Kurwade              11/11/2021             Added updateContactBTtrue_Test, updateContactBTfalse_Test
**************************************************************************************************************/

@isTest
public class Core_Contact_Ent_BT_Handler_Test {
    
    static testMethod void insertContactBTtrue_Test() {
        
        Test.startTest();
        
        List<Contact> lstContacts = new List<Contact>(); 
        List<Core_Contact_Entitlement__c> lstEnt = new  List<Core_Contact_Entitlement__c>();
        List<String> lstBT = new  List<String>();
        List<Id> entMent = new  List<String>();
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'Joy',
                                          Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        lstContacts.add(testContact);
        system.assertNOTEquals(null,testContact.id);
        
        Contact testContact2 = new Contact(FirstName='testFirst',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLast', Email='test@testing.com.testsetup',
                                           AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'Max',
                                           Core_Enterprise_Id__c='145',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact2;
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;
        system.assertNOTEquals(null,cee.id);
        
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        
        insert business;
        System.assertNotEquals(null, business.Id);
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
        insert entitle;
        System.assert(true,entitle.Core_Category__c!= null);
        
        PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                     PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true, RecordTypeId = eBREnttRecTypeId );
        
        insert matrix;
        System.assertNotEquals(null, matrix.Id);
        entMent.add(matrix.PRM_Entitlement_Id__c);
        
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id,  Status__c='Approval - Pending');
        
        insert bType;
        lstBT.add(bType.Business_Types__c);
        
        System.assertNotEquals(null, bType.Id);
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact2.Id,Core_Entitlement_Id__c=entitle.id,Core_Selected__c=true,Core_Status__c = 'Pending', Core_Source__c='Grant Access');
        insert ce1; 
        lstEnt.add(ce1);
        
        System.assertNotEquals(null, ce1.Id);
        
        Test.stopTest();
        
        
    }
    
    static testMethod void updateContactBTfalse_Test() {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            
            
            List<Contact> lstContacts = new List<Contact>(); 
            Map<id, Core_Contact_Entitlement__c> lstEnt = new  Map<id, Core_Contact_Entitlement__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'Jack',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
            
            PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
            rr.PRM_Enterprise_ID__c = '300002199713';
            rr.PRM_Preferred_Language__c = 'ENG';
            rr.PRM_Email_ID__c = testContact.Email;
            rr.PRM_Status__c = 'Approved';
            rr.recordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
            rr.PRM_Profile_Response__c='{QuestionCode : project_budget | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
            insert rr;
            System.assertNotEquals(null, rr.Id);
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;
            system.assertNOTEquals(null,cee.id);
            
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true, RecordTypeId = eBREnttRecTypeId);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            Test.startTest();
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id);
            
            insert bType;
            Test.stopTest();
            lstBT.add(bType);
            
            Core_Contact_Entitlement__c ce1 = [SELECT Id,Core_Selected__c,Core_Status__c,Core_Source__c  FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =: testContact.Id];		
            ce1.Core_Source__c = 'Grant Access';
            ce1.Core_Selected__c = true;
            ce1.Core_Status__c='Complete';
            update ce1;
            
            Contact_Business_Types__c bTy1 = [select Id, Status__c from Contact_Business_Types__c where Contact__c=:testContact.Id];
            
          //  system.assertEquals('Approved', bTy1.Status__c);
            System.assertNotEquals(null, bType.Id);
            
        }
        
    }
    
    static testMethod void updateContactBTReject_Test() {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            
            
            List<Contact> lstContacts = new List<Contact>(); 
            Map<id, Core_Contact_Entitlement__c> lstEnt = new  Map<id, Core_Contact_Entitlement__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'Koyel',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
            
            PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
            rr.PRM_Enterprise_ID__c = '300002199713';
            rr.PRM_Preferred_Language__c = 'ENG';
            rr.PRM_Email_ID__c = testContact.Email;
            rr.PRM_Status__c = 'Approved';
            rr.recordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
            rr.PRM_Profile_Response__c='{QuestionCode : project_budget | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
            insert rr;
            System.assertNotEquals(null, rr.Id);
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;
            system.assertNOTEquals(null,cee.id);
            
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true, RecordTypeId = eBREnttRecTypeId);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            Test.startTest();
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id);
            
            insert bType;
            lstBT.add(bType);
            Test.stopTest();
            
            Core_Contact_Entitlement__c ce1 = [SELECT Id,Core_Selected__c,Core_Status__c, Core_Source__c  FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =: testContact.Id];		
            ce1.Core_Source__c = 'Grant Access';
            ce1.Core_Selected__c = false;
            ce1.Core_Status__c='Pending';
            update ce1;
            
            
            
            //system.assertEquals('Approved', bTy1.Status__c);
            System.assertNotEquals(null, bType.Id);
            
            Core_Contact_Entitlement__c ce2 = [SELECT Id,Core_Selected__c,Core_Status__c,Core_Source__c  FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =: testContact.Id AND Core_Source__c = 'Grant Access'];    
            ce2.Core_Source__c = 'Grant Access';
            ce2.Core_Selected__c = false;
            ce2.Core_Status__c='Complete';
            update ce2;
            
            Contact_Business_Types__c bTy1 = [select Id, Status__c from Contact_Business_Types__c where Contact__c=:testContact.Id];
          //  system.assertEquals('Rejected', bTy1.Status__c);
        }
    }
    
    static testMethod void updateContactBTException_Test() {
        Test.startTest();
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            
            
            List<Contact> lstContacts = new List<Contact>(); 
            Map<id, Core_Contact_Entitlement__c> lstEnt = new  Map<id, Core_Contact_Entitlement__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'Leo',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;
            system.assertNOTEquals(null,cee.id);
            
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true, RecordTypeId = eBREnttRecTypeId);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id);
            
            insert bType;
            lstBT.add(bType);
            
            Core_Contact_Entitlement__c ce1 = [SELECT Id,Core_Selected__c,Core_Status__c,Core_Update_Reason__c  FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =: testContact.Id];		
            ce1.Core_Selected__c = true;
            ce1.Core_Status__c='Complete';
            ce1.Core_Update_Reason__c = 'exception';
            update ce1;
            
            Contact_Business_Types__c bTy1 = [select Id, Status__c from Contact_Business_Types__c where Contact__c=:testContact.Id];
            
            
            System.assertNotEquals(null, bType.Id);
            
            Test.stopTest();   
        }
    }
    
    static testMethod void CBTValidationRuleException()
    {
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'exception',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
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
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
        
        List<Id> reqIdList = new List<Id>();
        reqIdList.add(regRequest.Id);
         System.debug('Adding ABT');
        
        ER_ABT_TriggerHandler_Utility.AssignAccountBusinessTypes(reqIdList); 
        Core_Contact_Ent_BT_Handler.AssignContactBusinessTypes(reqIdList);

        System.debug('After ABT');
    }
    
    static testMethod void CBTValidationRuleSuccess()
    {
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'exception',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
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
            
           
        
        List<Id> reqIdList = new List<Id>();
        reqIdList.add(regRequest.Id);
         System.debug('Adding ABT');
        
        ER_ABT_TriggerHandler_Utility.AssignAccountBusinessTypes(reqIdList);
        Core_Contact_Ent_BT_Handler.AssignContactBusinessTypes(reqIdList);

        System.debug('After ABT');
    }
}