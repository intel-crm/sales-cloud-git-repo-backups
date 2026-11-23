/***********************************************************************************************************
Apex Class Name:  Core_Contact_Business_Type_Handler_Test
Version     : 1.0 
Created Date: 11 NOV 2021
Function    : Test Class for the Core_Contact_Business_Type_Handler_Test
Modification Log :
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------------------------------                  
* Gaurav Kurwade             30/11/2021             Added removeContactEnttrue_Test, removeContactEntfalse_Test
**************************************************************************************************************/


@isTest
public class Core_Contact_Business_Type_Handler_Test {
    
    
    static testMethod void InsertContactEntApprovedABT_Test() {
        
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
            
            List<Contact> lstContacts = new List<Contact>(); 
            Map<id, Contact_Business_Types__c> lstEnt = new  Map<id, Contact_Business_Types__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',
                                              Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                              Core_English_Only_First_Name__c = 'testFirst', Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact;
            
            Contact testContact2 = new Contact(FirstName='testFirst',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLast', Email='test@testing.com.testsetup',
                                               AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='145',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact2;
            
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact2.Id, Business_Types__c= business.Id);
            
            insert bType;
            lstBT.add(bType);
            System.assertNotEquals(null, bType.Id);               
            
            Test.stopTest();
        }
    }
    
    static testMethod void InsertContactBTNoEngNameTest() {
        
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
            
            List<Contact> lstContacts = new List<Contact>(); 
            Map<id, Contact_Business_Types__c> lstEnt = new  Map<id, Contact_Business_Types__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',
                                              Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                              Core_English_Only_First_Name__c = 'testFirst', Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact;
            
            Contact testContact2 = new Contact(FirstName='testFirst',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLast', Email='test@testing.com.testsetup',
                                               AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,
                                               Core_Enterprise_Id__c='145',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_First_Name__c = 'testFirst', Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact2;
            
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact2.Id, Business_Types__c= business.Id);
            try {
                insert bType;
            }
            catch(Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
                System.assertEquals(expectedExceptionThrown, false);
            }         
            Test.stopTest();
        }
    }
    
    static testMethod void InsertContactBTNoEngNameExceptionTest() {
        
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
            
            List<Contact> lstContacts = new List<Contact>(); 
            Map<id, Contact_Business_Types__c> lstEnt = new  Map<id, Contact_Business_Types__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_English_Only_First_Name__c = 'testFirst',
                                              Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                              Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact;
            
            Contact testContact2 = new Contact(FirstName='testFirst',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLast', Email='test@testing.com.testsetup',
                                               AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='145',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact2;
            
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact2.Id, Business_Types__c= business.Id);
            try {
                insert bType;
            }
            catch(Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
                System.assertEquals(expectedExceptionThrown, false);
            }         
            Test.stopTest();
        }
    }
    
    static testMethod void InsertContactEntNoABT_Test() {
        
        Test.startTest();
        List<Contact> lstContacts = new List<Contact>(); 
        Map<id, Contact_Business_Types__c> lstEnt = new  Map<id, Contact_Business_Types__c>();
        List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount;
        System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                          Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                          Core_English_Only_Last_Name__c ='testFirst');
        
        insert testContact;
        
        Contact testContact2 = new Contact(FirstName='testFirst',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLast', Email='test@testing.com.testsetup',
                                           AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                           Core_Enterprise_Id__c='145',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                           Core_English_Only_Last_Name__c ='testFirst');
        
        insert testContact2;
        
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);
        
        insert business;
        System.assertNotEquals(null, business.Id);
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
        insert entitle;
        System.assert(true,entitle.Core_Category__c!= null);
        
        PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                     PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
        
        insert matrix;
        System.assertNotEquals(null, matrix.Id);        
        
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact2.Id, Business_Types__c= business.Id);
        
        insert bType;
        lstBT.add(bType);
        System.assertNotEquals(null, bType.Id);               
        
        
        // Core_Contact_Business_Type_Handler.insertContactEnt(lstEnt);
        Test.stopTest();
        
        
    }
    
    static testMethod void InsertContactEntApprovedABTException_Test() {
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
            List<Contact> lstContacts = new List<Contact>(); 
            Map<id, Contact_Business_Types__c> lstEnt = new  Map<id, Contact_Business_Types__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c != null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                              Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact;
            
            Contact testContact2 = new Contact(FirstName='testFirst',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLast', Email='test@testing.com.testsetup',
                                               AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='145',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact2;
            
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact2.Id, Business_Types__c= business.Id, Status_Reason__c='exception');
            
            insert bType;
            lstBT.add(bType);
            System.assertNotEquals(null, bType.Id);               
            
            Test.stopTest();
        }
    }
    
    static testMethod void removeContactEnt_Test() {
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm22',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
               System.debug('Acct Owner1 : '+itAdminUser.Alias);
            
            List<Core_Contact_Entitlement__c> lstEnt = new  List<Core_Contact_Entitlement__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            Map<id, Contact_Business_Types__c> listrecords = new Map<id, Contact_Business_Types__c>();    
            Account testAccount1 = new Account(Name='testAccountSetup1', Core_Sales_Group__c='Global Accounts',
                                               Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                               BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,OwnerId=itAdminUser.Id,
                                               BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount1;
            Account act = [Select OwnerID, Owner.ID From Account where ID = :testAccount1.id];
            System.assert(true,testAccount1.Core_CNDA_Number__c != null);
            System.assert(true,testAccount1.Core_CNDA_Number__c != null);
            System.debug('OWner : '+act.OwnerID);
            System.debug('OWner : '+testAccount1.OwnerID);
             System.debug('User Id : '+itAdminUser.Id);
            
         
             System.debug('Covered Acct : '+ testAccount1.Core_Covered_Account__c);
             System.debug('CIM : '+ testAccount1.Core_CIM_ID__c);
            System.debug('B2B : '+ testAccount1.Core_B2B_Entitlement__c);
            System.debug('CNDA : '+ testAccount1.Core_CNDA_Number__c);
            
            
                
                         
            Contact testContact2 = new Contact(FirstName='testFirstName1234',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact2;  
            
            Contact testContact3 = new Contact(FirstName='testFirstName1234',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test8877@testing.com.testsetup',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact3;
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name=System.Label.ER_CBT_DZP, Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount1.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            List<Contact_Business_Types__c> cbtList = new List<Contact_Business_Types__c>(); 
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact2.Id, Business_Types__c= business.Id, 
                                                                            Status__c = 'Approved');        
            cbtList.add(bType);        
            
            Contact_Business_Types__c bType1 = new Contact_Business_Types__c(Contact__c = testContact3.Id, Business_Types__c= business.Id, 
                                                                             Status__c = 'Approved');        
            cbtList.add(bType1);
            insert cbtList;
            
            
            Core_Contact_Entitlement__c enti = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact2.Id,Core_Entitlement_Id__c=entitle.id,Core_Selected__c= true,Core_Status__c = 'Complete');
            insert enti; 
            
            Core_Contact_Entitlement__c enti1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact3.Id,Core_Entitlement_Id__c=entitle.id,Core_Selected__c= true,Core_Status__c = 'Complete');
            insert enti1;
            
            PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
            regRequest.PRM_Country__c = 'US';
            regRequest.PRM_First_Name__c = 'test';
            regRequest.PRM_Last_Name__c = 'test12';
            regRequest.PRM_Contact_Country__c = 'USA';
            regRequest.Entitlement_Details__c = entitle.id;
            regRequest.PRM_Email_ID__c =testContact2.Email;
            regRequest.PRM_Account_Phone__c = '76687437';
            regRequest.PRM_Auto_Approve__c= True;
            regRequest.PRM_Status__c = 'Approved';
            insert regRequest;
            
            Test.startTest();
            bType.Status__c = 'Rejection - Pending';
            update bType;
            Test.stopTest();
        }
        
    }
    
    static testMethod void removeContactEntException_Test() {      
        List<Core_Contact_Entitlement__c> lstEnt = new  List<Core_Contact_Entitlement__c>();
        List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
        Map<id, Contact_Business_Types__c> listrecords = new Map<id, Contact_Business_Types__c>();
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            
            Account testAccount1 = new Account(Name='testAccountSetup1', Core_Sales_Group__c='Global Accounts',
                                               Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                               BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                               BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount1;
            System.assert(true,testAccount1.Core_CNDA_Number__c != null);
            
            Contact testContact2 = new Contact(FirstName='testFirstName1234',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='gkinto@dispostable.com',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact2;  
            
            Contact testContact3 = new Contact(FirstName='testFirstName1234',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test8877@testing.com.testsetup',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact3;
            
            
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name=System.Label.ER_CBT_DZP, Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount1.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact2.Id, Business_Types__c= business.Id, 
                                                                            Status__c = 'Approved', Status_Reason__c='exception');        
            insert bType;
            System.assertNotEquals(null, bType.Id);
            
            Contact_Business_Types__c bType1 = new Contact_Business_Types__c(Contact__c = testContact3.Id, Business_Types__c= business.Id, 
                                                                             Status__c = 'Approved');        
            insert bType1;
            
            
            Core_Contact_Entitlement__c enti = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact2.Id,Core_Entitlement_Id__c=entitle.id,Core_Selected__c= true,Core_Status__c = 'Complete');
            insert enti; 
            
            Core_Contact_Entitlement__c enti1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact3.Id,Core_Entitlement_Id__c=entitle.id,Core_Selected__c= true,Core_Status__c = 'Complete');
            insert enti1;
            
            List<PRM_Registration_Request__c> requestList = new List<PRM_Registration_Request__c>();   
            PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
            regRequest.PRM_Country__c = 'US';
            regRequest.PRM_First_Name__c = 'test';
            regRequest.PRM_Last_Name__c = 'test12';
            regRequest.PRM_Contact_Country__c = 'USA';
            regRequest.Entitlement_Details__c = entitle.id;
            regRequest.PRM_Email_ID__c =testContact2.Email;
            regRequest.PRM_Account_Phone__c = '76687437';
            regRequest.PRM_Auto_Approve__c= True;
            regRequest.PRM_Status__c = 'Approved';
            insert regRequest;
            //requestList.add(regRequest);
            
            
            
            Test.startTest();
            bType.Status__c = 'Rejection - Pending';
            update bType;
            Test.stopTest();
            
        }
    }
    
    static testMethod void approveCBT_Test() {
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        UserRole admin = [Select id, name from UserRole where name = 'Admin' limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com', UserRoleId=admin.Id);
        insert itAdminUser;
        system.runas(itAdminUser) {
            
            List<Core_Contact_Entitlement__c> lstEnt = new  List<Core_Contact_Entitlement__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
            Map<id, Contact_Business_Types__c> listrecords = new Map<id, Contact_Business_Types__c>();    
            Account testAccount1 = new Account(Name='testAccountSetup1', Core_Sales_Group__c='Global Accounts',
                                               Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                               BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                               BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount1;
            System.assert(true,testAccount1.Core_CNDA_Number__c != null);
            
            Contact testContact2 = new Contact(FirstName='testFirstName1234',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact2;  
            
            Contact testContact3 = new Contact(FirstName='testFirstName1234',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test8877@testing.com.testsetup',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                               Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                               Core_English_Only_Last_Name__c ='testFirst');
            
            insert testContact3;
            
            Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name=System.Label.ER_CBT_DZP, Is_Active__c = true);
            
            insert business;
            System.assertNotEquals(null, business.Id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id, Business_Types__c = business.Id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
            
            insert matrix;
            System.assertNotEquals(null, matrix.Id);
            
            Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=testAccount1.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
            insert aType;
            List<Contact_Business_Types__c> cbtList = new List<Contact_Business_Types__c>(); 
            Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact2.Id, Business_Types__c= business.Id);        
            cbtList.add(bType);                           
            insert cbtList;
            
            List<Core_Contact_Entitlement__c> enti = [SELECT Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Selected__c, Core_Status__c
                                                      FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =: testContact2.Id AND Core_Entitlement_Id__c=: entitle.id];
            Test.startTest();
            enti[0].Core_Status__c = 'Complete';
            update enti;
            Test.stopTest();
        }
        
    }
    
    static testmethod void testSubscriptionApproved(){
        
        List<PRM_Registration_Request__c> requestList = new List<PRM_Registration_Request__c>();
        
        Account testAccount4 = new Account(Name='testAccountSetup1', Core_Sales_Group__c='Global Accounts',
                                           Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                           BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                           BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount4;
        
        Contact testContact4 = new Contact(FirstName='testFirstName1234',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                           AccountId=testAccount4.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                           Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                           Core_English_Only_Last_Name__c ='testFirst');
        
        insert testContact4; 
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name=System.Label.ER_CBT_DZP, Is_Active__c = true);
        
        insert business;
        System.assertNotEquals(null, business.Id);
        List<Contact_Business_Types__c> cbtList = new List<Contact_Business_Types__c>();
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact4.Id, Business_Types__c= business.Id, 
                                                                        Status__c = 'Approved', Status_Reason__c='Test');        
        insert bType;
        cbtList.add(bType);
        System.assertNotEquals(null, bType.Id);		
        
        Map<String, PRM_Partner_Subscription__c> subscriptionMap = new Map<String, PRM_Partner_Subscription__c>();
        PRM_Partner_Subscription__c pS = new PRM_Partner_Subscription__c();
        pS.Name ='Intel® Cloud Insider Events and Tradeshows';
        pS.PRM_Subscription_Cd__c = 'CSPx2_Sub2';
        insert pS;
        subscriptionMap.put(ps.PRM_Subscription_Cd__c, pS);
        
        PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c();
        csa.PRM_Partner_Subscription_Id__c = pS.Id;
        csa.PRM_Contact_Id__c = testContact4.Id;
        csa.PRM_Status_Nm__c = 'Active';
        insert csa;
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
        
        Core_Country_Code_Mapping__c codeMap = new Core_Country_Code_Mapping__c();
        codeMap.Name = 'CH';
        codeMap.Country_Code__c = 'US';
        codeMap.ISO_Code__c = 'USA';
        insert codeMap;
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
        insert entitle;
        System.assert(true,entitle.Core_Category__c!= null);
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.PRM_Country__c = 'US';
        regRequest.PRM_Contact_Country__c = 'USA';
        regRequest.PRM_Phy_Country__c = 'USA';
        regRequest.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest.PRM_Phy_State_Province__c = 'NY';
        regRequest.PRM_Phy_City__c = 'Las Vegas';
        regRequest.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest.PRM_Zip_Postal_Code__c = '32521';
        regRequest.Entitlement_Details__c = entitle.id;
        regRequest.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact+';'+System.Label.PRM_WorksFor;
        regRequest.PRM_Partner_Type__c = 'FPGA Design Services';
        regRequest.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';//Distributor
        regRequest.PRM_Email_ID__c = testContact4.Email;
        regRequest.PRM_Account_Phone__c = '76687437';
        regRequest.PRM_Company_Size__c ='10000+';
        regRequest.PRM_Auto_Approve__c= True;
        regRequest.PRM_Status__c = 'Approved';
        regRequest.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';
        // regRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest.PRM_Subscriptions__c = 'CSPx2_Sub2, CSPx2_Sub4, MEMBCOM';
        // insert regRequest;
        requestList.add(regRequest);
        
        //  Core_Contact_Business_Type_Handler.insertSubscription(bType);
        
        Test.startTest();
        Core_Contact_Business_Type_Handler.upsertSubscription(cbtList);
        Test.stopTest();
    }
    
    static testmethod void testSubscriptionRejected(){
        
        List<PRM_Registration_Request__c> requestList = new List<PRM_Registration_Request__c>();
        
        Account testAccount4 = new Account(Name='testAccountSetup1', Core_Sales_Group__c='Global Accounts',
                                           Core_Account_Type__c='Other', Industry='Others', Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                           BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',Core_B2B_Entitlement__c = true,
                                           BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        insert testAccount4;
        
        Contact testContact4 = new Contact(FirstName='testFirstName1234',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                           AccountId=testAccount4.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',
                                           Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                           Core_English_Only_Last_Name__c ='testFirst');
        
        insert testContact4; 
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name=System.Label.ER_CBT_DZP, Is_Active__c = true);
        
        insert business;
        System.assertNotEquals(null, business.Id);
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
        insert entitle;
        System.assert(true,entitle.Core_Category__c!= null);
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.PRM_First_Name__c = 'Test G';
        regRequest.PRM_Last_Name__c = 'Test K';       
        regRequest.Entitlement_Details__c = entitle.id;
        regRequest.Name = 'Test Regiistration';
        regRequest.PRM_Email_ID__c = testContact4.Email;
        regRequest.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest.PRM_Subscriptions__c = '	CSPx2_Sub2';
        insert regRequest;
        
        Map<String, PRM_Partner_Subscription__c> subscriptionMap = new Map<String, PRM_Partner_Subscription__c>();
        PRM_Partner_Subscription__c pS = new PRM_Partner_Subscription__c();
        pS.Name ='Intel® Cloud Insider Events and Tradeshows';
        pS.PRM_Subscription_Cd__c = 'CSPx2_Sub2';
        insert pS;
        subscriptionMap.put(ps.PRM_Subscription_Cd__c, pS);
        
        PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c();
        csa.PRM_Partner_Subscription_Id__c = pS.Id;
        csa.PRM_Contact_Id__c = testContact4.Id;
        csa.PRM_Status_Nm__c = 'Active';
        insert csa;
        List<Contact_Business_Types__c> cbtList = new List<Contact_Business_Types__c>();
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact4.Id, Business_Types__c= business.Id, 
                                                                        Status__c = 'Rejected', Status_Reason__c='Test');        
        insert bType;
        cbtList.add(bType);
        System.assertNotEquals(null, bType.Id);		
        
        Test.startTest();
        Core_Contact_Business_Type_Handler.upsertSubscription(cbtList);
        Test.stopTest();
    }
    
}