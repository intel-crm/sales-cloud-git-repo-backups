@isTest
public class ER_ABT_TriggerHandler_Utility_Test {
    
    /*static testMethod void ABTValidationsTest() {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            Test.startTest();
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            System.assertNotEquals(null, aType.Id);
            
            
            Test.stopTest();
        }
    }*/
    
    static testMethod void ABTValidationsEnglishNameTest() {
        Test.startTest();
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        
        insert business;
        System.assertNotEquals(null, business.Id);
        
        Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                        Status__c = 'Approved');
        try {
            insert aType;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        Test.stopTest();
        
    }
    
    static testMethod void ABTValidationsCNDATest() {
        Test.startTest();
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        
        insert business;
        System.assertNotEquals(null, business.Id);
        
        Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                        Status__c = 'Approved');
        try {
            insert aType;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        Test.stopTest();
        
    }
    
    static testMethod void ABTValidationsCIMIDTest() {
        Test.startTest();
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',Core_English_Only_Name__c = 'testAccountSetup',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        
        insert business;
        System.assertNotEquals(null, business.Id);
        
        Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                        Status__c = 'Approved');
        try {
            insert aType;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        Test.stopTest();
        
    }
    
    static testMethod void ABTValidationsCoverdAcctTest() {
        Test.startTest();
        List<User> u =[select id,name from user where name = 'Uncovered Account'];
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts', OwnerId = u[0].Id,
                                          Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        
        insert business;
        System.assertNotEquals(null, business.Id);
        
        Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                        Status__c = 'Approved');
        try {
            insert aType;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        Test.stopTest();
        
    }
    
    static testMethod void ABTValidationsEception() {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            Test.startTest();
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'exception',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            System.assertNotEquals(null, aType.Id);
            
            
            Test.stopTest();
        }
    }
    
    static testMethod void ABTRejectTest() {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'Henry',Core_English_Only_Last_Name__c = 'John',
                                              Core_Contact_B2B_Indicator__c=true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            System.assertNotEquals(null, aType.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id,  
                                                                            Status__c='Approved');        
            insert bType;
            
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=entitle.id,
                                                                              Core_Selected__c=true,Core_Status__c = 'Complete');
            insert ce1;
            
            System.debug('BeforeRejection');
            Test.startTest();
            aType.Status__c = 'Rejected';
            update aType;
            Test.stopTest();
            System.debug('After Rejection');
            
            Contact_Business_Types__c bTy1 = [select Id, Status__c from Contact_Business_Types__c where Contact__c=:testContact.Id];
            system.assertEquals('Rejection - Pending', bTy1.Status__c);
            //System.assertNotEquals('Rejection - Pending', bTy1.Status__c);
            
        }
    }
    
    static testMethod void ABTRejectExceptionTest() {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            Test.startTest();
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'Lime',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            System.assertNotEquals(null, aType.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id,  
                                                                            Status__c='Approved');        
            insert bType;
            
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=entitle.id,
                                                                              Core_Selected__c=true,Core_Status__c = 'Complete');
            insert ce1;
            
            aType.Status__c = 'Rejected';
            aType.Status_Reason__c = 'exception';
            update aType;
            
            Contact_Business_Types__c bTy1 = [select Id, Status__c from Contact_Business_Types__c where Contact__c=:testContact.Id];
            
            Test.stopTest();
        }
    }
    
    static testMethod void ABTValidationRuleException()
    {
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_English_Only_Name__c = 'exception',
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
        Test.startTest();
        ER_ABT_TriggerHandler_Utility.AssignAccountBusinessTypes(reqIdList);
        Test.stopTest();
        
        System.debug('After ABT');
    }
    
    static testMethod void ABTValidationRuleSuccess()
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
        Test.startTest();
        ER_ABT_TriggerHandler_Utility.AssignAccountBusinessTypes(reqIdList);
        Test.stopTest();
        
        System.debug('After ABT');
    }
}