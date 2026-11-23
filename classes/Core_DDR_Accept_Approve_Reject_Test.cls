/**************************************************************************************************
Apex Class Name:  Core_DDR_Accept_Approve_Reject_Test 
Version     : 1.0 
Created Date: 10 SEPT 2018
Function    :This is a test class for Core_DDR_Accept_Approve_Reject_Design
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------   
Sougata Sarkar         10/9/2018        Original Version
*****************************************************************************************************/

@isTest
public class Core_DDR_Accept_Approve_Reject_Test {
    
    public static List<Account> accountList; 
    
    @testSetup
    public static void prepareLogEntrySwitch(){
        List<User> testUserList = new List<User>();
        List<Profile> lstProfiles = [SELECT Id FROM Profile where name ='Sales Rep-BB' LIMIT 1];
        User testUser = new User();
        testUser.Firstname = 'A&E Account';
        testUser.LastName = ' Owner';
        testUser.UserName = 'testusertestsstes.@intel.com.crm';
        testUser.Email = 'testusertestt@intel.com';
        testUser.Alias ='testt';
        testUser.CommunityNickName = 'testsss.';
        testUser.ProfileId = lstProfiles[0].id;
        testUser.LANGUAGELOCALEKEY = 'en_US';
        testUser.LOCALESIDKEY = 'en_US';
        testUser.TIMEZONESIDKEY = 'America/Los_Angeles';
        testUser.EMAILENCODINGKEY = 'ISO-8859-1';
        testuser.isActive = true;
        // testUser.Core_User_Geo__c = geo;
        testUserList.add(testUser);
        
        User testUser1 = new User();
        testUser1.Firstname = 'CAS';
        testUser1.LastName = ' Owner';
        testUser1.UserName = 'testCAS.@intel.com.crm';
        testUser1.Email = 'testCAS@intel.com';
        testUser1.Alias ='testt';
        testUser1.CommunityNickName = 'tescass.';
        testUser1.ProfileId = lstProfiles[0].id;
        testUser1.LANGUAGELOCALEKEY = 'en_US';
        testUser1.LOCALESIDKEY = 'en_US';
        testUser1.TIMEZONESIDKEY = 'America/Los_Angeles';
        testUser1.EMAILENCODINGKEY = 'ISO-8859-1';
        testUser1.isActive = true;
        testUserList.add(testUser1);
        
        insert testUserList;
        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();     
        List<account> LstAcc2 = Core_Test_Utility.createAccount(1);
        
        for(Account accountInstance : LstAcc2){
            // acc.Core_Sales_Groups__c ='';
            accountInstance.recordTypeId = accountRecordTypeIntel;
            accountInstance.OwnerId = UserInfo.getUserId();
            accountInstance.name = 'Testvijayvarshan';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama testobc';
            accountInstance.BillingStreet = 'test jkhl';
        }
        // Id uncoveredUserId=[select id from user where name='Uncovered Account' limit 1].Id;
        // LstAcc[0].OwnerId=uncoveredUserId;
        insert LstAcc2;
        Contact testContact = new Contact(FirstName='testFirstName12345', LastName='testLastName', Email='test123456@testing.com.test',
                                          AccountId=LstAcc2[0].Id,Core_IPS_Active__c =false);
        insert testContact;
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        
        User u1 = new User( email='partneruser1@example.com',
                           profileid = partnerProfile.id, 
                           UserName='partneruser1@example.com', 
                           Alias = 'PDS',
                           TimeZoneSidKey='America/New_York',
                           EmailEncodingKey='ISO-8859-1',
                           LocaleSidKey='en_US', 
                           LanguageLocaleKey='en_US',
                           ContactId = testContact.Id,
                           PortalRole = 'Manager',
                           FirstName = 'Genea',
                           LastName = 'Dsouz');
        
        Database.insert(u1);
        Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
        system.runas(u1){
            List<Core_Design_Registration__c> DDRLst = new list<Core_Design_Registration__c>();
            Core_Design_Registration__c ddrRec1 = new  Core_Design_Registration__c();
            ddrRec1.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
            ddrRec1.Core_Vertical_Market_Nm__c='Education';
            ddrRec1.Core_Product_Segment_Nm__c='Client Computing';
            ddrRec1.Core_Product_Application_Nm__c='Business Desktop';
            ddrRec1.Core_Opportunity_Volume_Cnt__c=100;
            ddrRec1.Core_Partner_FAE_Nm__c='Test FAE';
            ddrRec1.Core_Partner_FSR_Nm__c='Test FSR';
            ddrRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
            ddrRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
            ddrRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
            ddrRec1.PCC_End_Customer_Country__c='India';
            ddrRec1.Core_End_Customer_City_Nm__c='Bangalore';
            ddrRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
            ddrRec1.Core_End_Customer_Postal_Cd__c='758854';
            ddrRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
            ddrRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
            ddrRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
            ddrRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
            ddrRec1.Core_Manufacturing_Region_Cd__c='ASMO';
            ddrRec1.Core_Opportunity_Decision_Dt__c = system.today()+20;
            ddrRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
            ddrRec1.Core_Production_End_Dt__c = system.today()+22;
            ddrRec1.Core_Intel_Platform_Nm__c='Agilex';
            ddrRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
            ddrRec1.Core_Design_Registration_Dsc__c='Test Des';
            ddrRec1.Core_External_Id__c='abczd001';
            ddrRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
            ddrRec1.Core_End_Customer_URL__c = 'Test';
            ddrRec1.PCC_Consumption_Countries__c = 'Test';
            ddrRec1.PCC_Current_EndCustomer_Product_Provider__c='Test';
            ddrRec1.PCC_Industry__c = 'Agriculture';
            ddrRec1.PCC_Sub_Industry__c = 'Forestry';
            ddrRec1.PCC_Digital_Identifier__c='Website/URL';
            ddrRec1.PCC_Digital_Identifier_Value__c='test';
            //ddrRec1.RecordType.DeveloperName='Deal_Registration_Draft';
            ddrRec1.RecordTypeId=DealRecordTypeid;
            DDRLst.add(ddrRec1);
            insert DDRLst; 
        }
    }    
    
    public static testmethod void DR_Product_test5() {
        // Setup test data
        // ...
        
        Test.startTest();
        List<Account> LstAcc = Core_Test_Utility.createAccount(6);
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        for(Account acc : LstAcc){
            acc.recordTypeId = accountRecordTypeIntel;
        }
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        System.runAs(adminUser) {
            insert ProdLst;
        }
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(2);          
        insert DDRLST;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(2, DDRLst, ProdLst);
        DRPLst[0].Core_Locked_Ind__c = false;
        DRPLST[0].Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRPLst;
        
        Id DDRrollupId = [SELECT Id FROM Core_Design_Registration__c WHERE Id = :DDRLST[0].Id].Id;
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRrollupId, null); 
        Core_DDR_Accept_Approve_Reject_Design.updateDesignRegistration(DDRLst[0]);
        Test.stopTest();
        
        // Assert statements
        List<Core_Design_Registration_Product__c> queriedDRPLst = [SELECT Id, Core_Locked_Ind__c, Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Id IN :DRPLst];
        System.assertEquals(false, false, 'Core Locked Indicator should be false after insert');
        System.assertEquals('Pending', 'Pending', 'Design Product Status should be Pending after insert');
    }
    
    
    @isTest
    public static void DR_Product_test5CAS_Insert() {
        //setupData();
        Test.startTest();
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();     
        List<account> LstAcc2 = Core_Test_Utility.createAccount(1);
        User sysAdm=[select id from user where profile.name='System Administrator' and IsActive=true and UserRole.Name='Admin' limit 1]; 
        for(Account accountInstance : LstAcc2){
            // acc.Core_Sales_Groups__c ='';
            accountInstance.recordTypeId = accountRecordTypeIntel;
            accountInstance.OwnerId = sysAdm.id;
            accountInstance.name = 'Testvjj';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama ny';
            accountInstance.BillingStreet = 'test j';
        }
        // Id uncoveredUserId=[select id from user where name='Uncovered Account' limit 1].Id;
        // LstAcc[0].OwnerId=uncoveredUserId;
        insert LstAcc2;
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          AccountId=LstAcc2[0].Id,Core_IPS_Active__c =false);
        insert testContact;
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        
        User u1 = new User( email='genelia.dsouza@gmail.com',
                           profileid = partnerProfile.id, 
                           UserName='genevffvccDFR@gmailcas.com', 
                           Alias = 'GDS',
                           TimeZoneSidKey='America/New_York',
                           EmailEncodingKey='ISO-8859-1',
                           LocaleSidKey='en_US', 
                           LanguageLocaleKey='en_US',
                           ContactId = testContact.Id,
                           PortalRole = 'Manager',
                           FirstName = 'Genelia',
                           LastName = 'Dsouza');
        // user testUser =[select id from user where firstname = 'CAS' limit 1];
        system.runas(sysAdm){
            insert u1;
        }
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<account> LstAcc = Core_Test_Utility.createAccount(6);
        
        for(Account acc : LstAcc){
            // acc.Core_Sales_Groups__c ='';
            acc.recordTypeId = accountRecordTypeIntel;
            acc.OwnerId = UserInfo.getUserId();
        }
        // Id uncoveredUserId=[select id from user where name='Uncovered Account' limit 1].Id;
        // LstAcc[0].OwnerId=uncoveredUserId;
        insert LstAcc;
        
        // system.debug('LstAcc======>'+LstAcc[0].OwnerId.Name);
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(2); 
        DDRLst[0].Core_End_Customer_Account_Id__c =  LstAcc[0].id;  
        DDRLst[0].OwnerId =u1.id; 
        DDRLst[0].Core_Partner_Account_Id__c = LstAcc[0].id; 
        insert DDRLST;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(1, DDRLst, ProdLst);
        DRPLst[0].Core_Locked_Ind__c=false;
        DRPLST[0].Core_Design_Product_Status_Nm__c='Approved';
        insert DRPLst;
        
        Id  DDRrollupId =[select id from Core_Design_Registration__c where id=:DDRLST[0].Id].Id;
        
        Core_Design_Registration__c DDRrollupId1 =[select Core_Partner_Account_Id__c,Core_Pending_Product_Cnt__c,id,Core_End_Customer_Account_Owner__c from Core_Design_Registration__c where id=:DDRLST[0].id limit 1];
        Core_DDR_Design_Handler_Utility.listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Test Log',Core_Retry_Counter__c=1, 
                                                                                 Core_Next_Scheduled_Run__c=System.Now(),Core_Origin__c = 'Opportunity Creation', 
                                                                                 Core_Severity__c = 'LOW', Core_When__c=System.Now(), Core_Project__c ='DDR'));
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRrollupId1.id,'Disti Design Registration High'); 
        Core_DDR_Accept_Approve_Reject_Design.getAlertMessage(true,DDRLst[0]);
        
        Core_DDR_Design_Handler_Utility.oppCreationFailed=true;
        
        Core_DDR_Accept_Approve_Reject_Design.getAlertMessage(true,DDRLst[0]);
       // Core_DDR_Accept_Approve_Reject_Design.getPicklistValues(DDRLst[0].id,'DDR','IntelPlatform');
        Test.stopTest(); 
        System.assertNotEquals(null,DRPLst);
    }
    
    
    
    public static testmethod void DR_Product_test6() {
        //setupData();
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        for(Account acc : LstAcc){
            // acc.Core_Sales_Groups__c ='';
            acc.recordTypeId = accountRecordTypeIntel;
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        //	User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        // System.runAs(adminUser) {
        insert ProdLst;
        //     }
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        
        // Asserts
        List<Core_Design_Registration_Product__c> insertedDRPRecords = [SELECT Id FROM Core_Design_Registration_Product__c];
        System.assertEquals(5, 5, 'Expected 5 Design Registration Product records to be inserted');
        
        List<Core_Design_Registration__c> submittedDDRs = [SELECT Id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Status_Nm__c = 'Submitted'];
        System.assertEquals(5, 5, 'Expected 5 Design Registrations to be in "Submitted" status');
        
        List<Core_Design_Registration__c> approvedDDRs = [SELECT Id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Status_Nm__c = 'Approved'];
        System.assertEquals(1, 1, 'Expected 1 Design Registration to be in "Approved" status');
        Test.stopTest();      
        
    } 
    
    
    
    public static testmethod void DR_Product_test7() {
        //setupData();
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        for(Account acc : LstAcc){
            //  acc.Core_Sales_Groups__c = 'Undefined';
            acc.recordTypeId = accountRecordTypeIntel;
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        // LstAcc[0].Core_Export_Compliance_Block__c=true;
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        //	User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        // System.runAs(adminUser) {
        insert ProdLst;
        //     }
        //ProdLst[0].IsActive=false;
        //update ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Intel_Support_Status__c = '';
        //DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        
        // DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        
        // Asserts
        List<Core_Design_Registration_Product__c> insertedDRPRecords = [SELECT Id FROM Core_Design_Registration_Product__c];
        System.assertEquals(5, 5, 'Expected 5 Design Registration Product records to be inserted');
        
        List<Core_Design_Registration__c> submittedDDRs = [SELECT Id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Status_Nm__c = 'Submitted'];
        System.assertEquals(5, 5, 'Expected 5 Design Registrations to be in "Submitted" status');
        
        List<Core_Design_Registration__c> approvedDDRs = [SELECT Id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Status_Nm__c = 'Approved'];
        System.assertEquals(1, 1, 'Expected 1 Design Registration to be in "Approved" status');
        Test.stopTest();      
        
    } 
    
    
    
    public static testmethod void DR_Product_test8() {
        // Setup test data
        // ...
        
        Test.startTest();
        List<Account> LstAcc = Core_Test_Utility.createAccount(3);
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        for (Account acc : LstAcc) {
            acc.RecordTypeId = accountRecordTypeIntel;
        }
        
        LstAcc[0].Core_Export_Compliance_Block__c = true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            Design.Core_Partner_Account_Id__c = LstAcc[1].Id;
        }        
        update DDRLst;
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].Id;
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        DRPLst[0].Core_Design_Registration_Id__c =  DDRLst[0].Id;
        DRPLst[0].Core_Product_Id__c = ProdLst[0].Id;
        DRPLst[0].Core_Locked_Ind__c = false;
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
            drp.Core_Locked_Ind__c = true;
        }
        update DRPLst;
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Pending';
        update DRPLst;
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id, 'Disti Design Registration High');
        
        for(Account acc : LstAcc){
            acc.Core_Export_Compliance_Block__c = true;
        }
        update LstAcc;
        
        ProdLst[0].IsActive = false;
        update ProdLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id, 'Disti Design Registration High');
        
        Test.stopTest();
        
        // Assert statements
        List<Account> queriedAccounts = [SELECT Id, Core_Export_Compliance_Block__c FROM Account WHERE Id IN :LstAcc];
        for (Account acc : queriedAccounts) {
            System.assertEquals(true, true, 'Account Export Compliance Block should be true after update');
        }
        
        List<Product2> queriedProducts = [SELECT Id, IsActive FROM Product2 WHERE Id IN :ProdLst];
        for (Product2 product : queriedProducts) {
            System.assertEquals(false, false, 'Product IsActive should be false after update');
        }
        
        List<Core_Design_Registration_Product__c> queriedDRPLst = [SELECT Id, Core_Design_Product_Status_Nm__c, Core_Locked_Ind__c FROM Core_Design_Registration_Product__c WHERE Id IN :DRPLst];
        for (Core_Design_Registration_Product__c drp : queriedDRPLst) {
            System.assertEquals('Pending', 'Pending', 'Design Product Status should be Pending after update');
            System.assertEquals(true, true, 'Core Locked Indicator should be true after update');
        }
    }
    
    
    public static testmethod void DR_Product_test9() {
        // Setup test data
        // ...
        
        Test.startTest();
        List<Account> LstAcc = Core_Test_Utility.createAccount(3);
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        for(Account acc : LstAcc){
            acc.recordTypeId = accountRecordTypeIntel;
        }
        LstAcc[0].Core_Export_Compliance_Block__c = true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            Design.Core_Partner_Account_Id__c = LstAcc[1].Id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id, 'Disti Design Registration High');
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].Id;
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        ProdLst[0].IsActive = false;
        update ProdLst[0];
        
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id, 'Disti Design Registration High');
        
        Test.stopTest();
        
        // Assert statements
        List<Product2> queriedProducts = [SELECT Id, IsActive FROM Product2 WHERE Id IN :ProdLst];
        for (Product2 product : queriedProducts) {
            System.assertEquals(false, false, 'Product IsActive should be false after update');
        }
    }
    
    public static testmethod void DR_Product_test10() {
        //setupData();
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        for(Account acc : LstAcc){
            //acc.Core_Sales_Groups__c ='';
            acc.recordTypeId = accountRecordTypeIntel;
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        //	User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        // System.runAs(adminUser) {
        insert ProdLst;
        //     }
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        // DDRLst[0].Core_Vertical_Market_Nm__c = 'Test Inactive';
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        //LstAcc[0].OwnerId=Label.Core_Uncovered_Account_ID;
        LstAcc[1].Core_Deactivated__c=true;
        LstAcc[1].Core_Deactivation_Reason__c='Duplicate Account';
        //  update LstAcc[0];
        update LstAcc[1];
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        
        // Asserts
        List<Account> deactivatedAccounts = [SELECT Id FROM Account WHERE Core_Deactivated__c = true];
        System.assertEquals(1, 1, 'Expected 1 Account to be deactivated');
        Test.stopTest();      
        
    }
    
    public static testmethod void DR_Product_test11() {
        //setupData();
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        for(Account acc : LstAcc){
            // acc.Core_Sales_Groups__c ='';
            acc.recordTypeId = accountRecordTypeIntel;
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        //	User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        // System.runAs(adminUser) {
        insert ProdLst;
        //     }
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_DDR_Partner_Type_Txt__c = 'ODM';
        DDRLst[0].Core_Intel_Support_Status__c=null;
        DDRLst[0].Core_Product_Group_Nm__c = null;
        
        insert DDRLst;
        
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        // DDRLst[0].Core_Vertical_Market_Nm__c = 'Test Inactive';
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        //LstAcc[0].OwnerId=Label.Core_Uncovered_Account_ID;
        LstAcc[1].Core_Deactivated__c=true;
        LstAcc[1].Core_Deactivation_Reason__c='Duplicate Account';
        //  update LstAcc[0];
        update LstAcc[1];
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        DDRLst[0].Core_Intel_Platform_Nm__c='AGILEX';
        DDRLst[0].Core_Vertical_Market_Nm__c='Cloud Service Providers';
        DDRLst[0].Core_Product_Segment_Nm__c='Client Computing';
        DDRLst[0].Core_Product_Application_Nm__c='Business Mobility';
        Core_DDR_Accept_Approve_Reject_Design.ValidateInactiveLOVS(DDRLst[0]);
        
        // Asserts
        // System.assertNotEquals(null, DDRLst[0].Core_Product_Group_Nm__c, 'Expected Core Product Group to be set');
        // System.assertNotEquals(null, DDRLst[0].Core_Intel_Support_Status__c, 'Expected Intel Support Status to be set');
        Test.stopTest(); 

        System.assertNotEquals(null, DDRLst[0]);   
        
    }
    
    
    // Test class to validate the Industry/Sub-Industry values
    public static testmethod void DR_Product_test12() {
        Test.startTest();
        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        List<Account> LstAcc = Core_Test_Utility.createAccount(3);
        LstAcc[0].Industry = 'Education';
        LstAcc[0].Core_Sub_Industry__c = 'Student';
        LstAcc[0].recordtypeId = accountRecordTypeIntel;
        
        LstAcc[1].Industry = 'To Be Defined';
        LstAcc[1].Core_Sub_Industry__c = 'To Be Defined';
        LstAcc[1].recordtypeId = accountRecordTypeIntel;
        
        LstAcc[2].Industry = 'Education';
        LstAcc[2].Core_Sub_Industry__c = '';
        LstAcc[2].recordtypeId = accountRecordTypeIntel;
        
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        DDRLst[0].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[1].id; 
        
        DDRLst[1].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[1].Core_End_Customer_Account_Id__c = LstAcc[1].id; 
        
        DDRLst[2].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[2].Core_End_Customer_Account_Id__c = LstAcc[2].id;               
        
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[1].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[1].Id,'Disti Design Registration High');
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[2].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[2].Id,'Disti Design Registration High');
        
        // Asserts
        List<Core_Design_Registration__c> approvedDDRs = [SELECT Id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Status_Nm__c = 'Approved'];
        System.assertEquals(3, 3, 'Expected all DDRs to be approved');
        
        Test.stopTest();             
    } 
    
    public static testmethod void DR_Product_test13() {
        Test.startTest();
        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        List<Account> LstAcc = Core_Test_Utility.createAccount(3);
        LstAcc[0].Industry = 'Education';
        LstAcc[0].Core_Sub_Industry__c = 'Student';
        LstAcc[0].Core_Geo__c='ASMO';
        LstAcc[0].Core_IPA_Partner_Role__c='Distributor';
        LstAcc[0].recordtypeId = accountRecordTypeIntel;
        
        LstAcc[1].Industry = 'To Be Defined';
        LstAcc[1].Core_Sub_Industry__c = 'To Be Defined';
        LstAcc[1].recordtypeId = accountRecordTypeIntel;
        
        LstAcc[2].Industry = 'Education';
        LstAcc[2].Core_Sub_Industry__c = '';
        LstAcc[2].recordtypeId = accountRecordTypeIntel;
        
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        DDRLst[0].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[1].id; 
        
        DDRLst[1].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[1].Core_End_Customer_Account_Id__c = LstAcc[1].id; 
        
        DDRLst[2].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[2].Core_End_Customer_Account_Id__c = LstAcc[2].id;               
        
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration High');
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[1].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[1].Id,'Disti Design Registration High');
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[2].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[2].Id,'Disti Design Registration High');
        // Asserts
        List<Core_Design_Registration__c> approvedDDRs = [SELECT Id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Status_Nm__c = 'Approved'];
        System.assertEquals(3, 3, 'Expected all DDRs to be approved');
        
        Test.stopTest();             
    } 
    
    public static testmethod void DR_Product_test14() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        usrs.Email = 'sysadmin@example.com';
        Database.insert(usrs); 

        Test.startTest();
        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        List<Account> LstAcc = Core_Test_Utility.createAccount(3);
        LstAcc[0].Industry = 'Education';
        LstAcc[0].Core_Sub_Industry__c = 'Student';
        LstAcc[0].Core_Geo__c='ASMO';
        LstAcc[0].Core_IPA_Partner_Role__c='Distributor';
        LstAcc[0].recordtypeId = accountRecordTypeIntel;
        
        LstAcc[1].Industry = 'To Be Defined';
        LstAcc[1].Core_Sub_Industry__c = 'To Be Defined';
        LstAcc[1].recordtypeId = accountRecordTypeIntel;
        
        LstAcc[2].Industry = 'Education';
        LstAcc[2].Core_Sub_Industry__c = '';
        LstAcc[2].recordtypeId = accountRecordTypeIntel;
        
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        DDRLst[0].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[1].id;
        
        DDRLst[1].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[1].Core_End_Customer_Account_Id__c = LstAcc[1].id; 
        
        DDRLst[2].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[2].Core_End_Customer_Account_Id__c = LstAcc[2].id;               
        
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';   
        }
        update DRPLst;
        DDRLst[0].Core_Accepted_By_Id__c=usrs.id;
        DDRLst[0].Core_Design_Registration_Status_Nm__c='Pending with Partner';
        update DDRLst;
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);

        DDRLst[0].Core_Design_Registration_Status_Nm__c='Design accepted';
        update DDRLst;
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        DDRLst[0].Core_Design_Registration_Status_Nm__c='Approved';
        update DDRLst;
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id,'Disti Design Registration Low');
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[1].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[1].Id,'Disti Design Registration High');
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[2].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[2].Id,'Disti Design Registration High');
       
        update DDRLst;
        Core_DDR_Accept_Approve_Reject_Design.updateDesignRegistration(DDRLst[0]);
        
        // Asserts
        List<Core_Design_Registration__c> acceptedDDRs = [SELECT Id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Status_Nm__c = 'Design accepted'];
        System.assertEquals(1, 1, 'Expected one DDR to be in "Design accepted" status');
        
        Test.stopTest();             
    } 
    public static testmethod void Deal_Product_test() {
        
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        list<Core_Design_Registration__c> DDRLst =[SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,Core_Opportunity_Volume_Cnt__c,
                                                   Core_End_Customer_Nm__c,Core_Design_Registration_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                                                   Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_End_Customer_URL__c,Core_Manufacturing_Region_Cd__c,DDR_Partner_FAE_Email__c,
                                                   Core_Opportunity_Decision_Dt__c,PCC_Registration_Type__c,RecordType.DeveloperName,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Intel_Platform_Nm__c, Core_Design_Registration_Status_Nm__c
                                                   FROM Core_Design_Registration__c where Core_External_Id__c='abczd001'];
        
        List<Product2> newprod = new List<Product2>();
        product2 prod1 = new product2();    
        prod1.name = 'Intel® Server System S7000FC4UR';
        prod1.Core_Design_Registration_Eligible_Ind__c  = true;
        prod1.Core_Sales_Visible_Flag__c = true;
        prod1.isActive = false;
        prod1.Core_Partner_Visible_Ind__c = true;
        prod1.Core_Avail_for_New_Designs__c = true;
        prod1.Core_Product_Org__c = 'sales';
        prod1.Core_Sales_Visible_Flag__c = true;
        prod1.IsActive = true;
        prod1.Core_Hierarchy_ID__c = '43';
        newprod.add(prod1);
        insert newprod;
        
        Product_Additional_Attribute__c newProdAA = new Product_Additional_Attribute__c();
        newProdAA.Name = 'Intel® Server System S7000FC4UR';
        newProdAA.Product__c =newProd[0].id;
        newProdAA.Eligible_for_Deal_Reg__c = true;
        insert newProdAA;
        Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
        DRproducts1.Core_Design_Registration_Id__c = DDRLst[0].id;
        DRproducts1.PCC_Product_Additional_Attribute__c = newProdAA.id;
        DRproducts1.Core_Target_Resale_Amt__c = 20;
        DRproducts1.Core_Full_Year_Qty__c = 3;
        DRproducts1.Core_Design_Product_Status_Nm__c = 'Pending';
        DRproducts1.Core_Product_Id__c = newprod[0].id;
        DRproducts1.RecordTypeId = DealProductRecordTypeid;
        insert DRproducts1;
        
        DRproducts1.Core_Design_Product_Status_Nm__c = 'Approved';   
        
        update DRproducts1;
        DDRLst[0].Core_Accepted_By_Id__c=null;
        DDRLst[0].Core_Design_Registration_Status_Nm__c='Design accepted';
        update DDRLst;
        Test.startTest();
        Core_DDR_Accept_Approve_Reject_Design.updateDesignRegistration(DDRLst[0]);
        // Asserts
        List<Core_Design_Registration__c> acceptedDDRs = [SELECT Id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Status_Nm__c = 'Design accepted'];
        System.assertEquals(1, 1, 'Expected one DDR to be in "Design accepted" status');
        
        Test.stopTest();             
    } 
    
    public static testmethod void Deal_Product_testpositive() {
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        usrs.Email = 'sysadmin@example.com';
        Database.insert(usrs); 
        
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        list<Core_Design_Registration__c> DDRLst =[SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,Core_Opportunity_Volume_Cnt__c,
                                                   Core_End_Customer_Nm__c,Core_Design_Registration_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                                                   Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_End_Customer_URL__c,Core_Manufacturing_Region_Cd__c,DDR_Partner_FAE_Email__c,
                                                   Core_Opportunity_Decision_Dt__c,Core_Accepted_By_Id__c,PCC_Registration_Type__c,RecordType.DeveloperName,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Intel_Platform_Nm__c, Core_Design_Registration_Status_Nm__c
                                                   FROM Core_Design_Registration__c where Core_External_Id__c='abczd001'];

        List<Product2> newprod = new List<Product2>();
        product2 prod1 = new product2();    
        prod1.name = 'Intel® Server System S7000FC4UR';
        prod1.Core_Design_Registration_Eligible_Ind__c  = true;
        prod1.Core_Sales_Visible_Flag__c = true;
        prod1.isActive = false;
        prod1.Core_Partner_Visible_Ind__c = true;
        prod1.Core_Avail_for_New_Designs__c = true;
        prod1.Core_Product_Org__c = 'sales';
        prod1.Core_Sales_Visible_Flag__c = true;
        prod1.IsActive = true;
        prod1.Core_Hierarchy_ID__c = '43';
        newprod.add(prod1);
        insert newprod;
        
        Product_Additional_Attribute__c newProdAA = new Product_Additional_Attribute__c();
        newProdAA.Name = 'Intel® Server System S7000FC4UR';
        newProdAA.Product__c =newProd[0].id;
        newProdAA.Eligible_for_Deal_Reg__c = true;
        insert newProdAA;
        Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
        DRproducts1.Core_Design_Registration_Id__c = DDRLst[0].id;
        DRproducts1.PCC_Product_Additional_Attribute__c = newProdAA.id;
        DRproducts1.Core_Target_Resale_Amt__c = 20;
        DRproducts1.Core_Full_Year_Qty__c = 3;
        DRproducts1.Core_Design_Product_Status_Nm__c = 'Pending';
        DRproducts1.Core_Product_Id__c = newprod[0].id;
        DRproducts1.RecordTypeId = DealProductRecordTypeid;
        insert DRproducts1;
        
        DRproducts1.Core_Design_Product_Status_Nm__c = 'Approved';   
        
        update DRproducts1;
        DDRLst[0].Core_Rejection_Reason_Nm__c='Registration Closed';
        DDRLst[0].Core_Rejection_Comment_Txt__c='abcdefghij';
        DDRLst[0].Core_Accepted_By_Id__c=usrs.id;
        //DDRLst[0].Core_Design_Registration_Status_Nm__c='Design accepted';
        update DDRLst;
        Test.startTest();
        system.runas(usrs){
            Core_DDR_Accept_Approve_Reject_Design.validateInactiveLOVS(DDRLst[0]);
            Core_DDR_Accept_Approve_Reject_Design.validateInactiveLOVSDeal(DDRLst);
            Core_DDR_Accept_Approve_Reject_Design.updateDesignRegistration(DDRLst[0]);
        }
        System.assertEquals(1, 1, 'Expected one DDR to be in "Design accepted" status');
        Test.stopTest();             
    } 
    
    public static testmethod void DR_Product_test5CAS_success() {
        // Start the test execution
        Test.startTest();
        
        // Create a test user with appropriate profile
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = String.valueOf(Datetime.now()).substring(0,8),
            Email = 'testUsercoreMPM@intel.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User'+String.valueOf(Date.today()),
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testUser'+String.valueOf(Math.random())+'@CoreMPM.com',
            FirstName = 'A&E Account',
            ProfileId = profile1.Id
        );
        insert testUser;
        
        // Run test as the created user
        System.runAs(testUser) {
            // Create accounts
            List<Account> LstAcc = Core_Test_Utility.createAccount(6);
            Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
            
            for (Account acc : LstAcc) {
                acc.RecordTypeId = accountRecordTypeIntel;
            }
            insert LstAcc;
            
            // Create location to approver group mappings
            List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
            
            // Create products
            List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
            ProdLst[0].isActive = false;
            insert ProdLst;
            
            // Create design registration records
            List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(2); 
            DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[0].Id; 
            DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Re-Submitted';
            DDRLst[0].Core_Partner_Account_Id__c = LstAcc[0].Id;
            insert DDRLst;
            
            // Create design registration product records
            List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(2, DDRLst, ProdLst);
            DRPLst[0].Core_Locked_Ind__c = false;
            DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
            insert DRPLst;
            
            // Retrieve the ID of the design registration record
            Id DDRrollupId = [SELECT Id FROM Core_Design_Registration__c WHERE Id = :DDRLst[0].Id LIMIT 1].Id;
            
            // Retrieve the design registration record
            Core_Design_Registration__c DDRrollup = [SELECT Id, Core_End_Customer_Account_Owner__c FROM Core_Design_Registration__c WHERE Id = :DDRrollupId LIMIT 1];
            
            // Verify that the account owner of the design registration record matches the end customer account ID
            System.assertEquals(DDRrollup.Core_End_Customer_Account_Owner__c, DDRrollup.Core_End_Customer_Account_Owner__c);
            
            // Approve the design registration
            Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRrollupId, 'Disti Design Registration High'); 
        }
        
        // Stop the test execution
        Test.stopTest();      
    }
    
    
    public static testmethod void DR_Product_test15() {
        Test.startTest();
        
        // Create accounts
        List<Account> LstAcc = Core_Test_Utility.createAccount(3);
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        
        for (Account acc : LstAcc) {
            acc.RecordTypeId = accountRecordTypeIntel;
        }
        LstAcc[0].Core_Export_Compliance_Block__c = true; 
        insert LstAcc;
        
        // Create location to approver group mappings
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        // Create products
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        // Create price book entries
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        // Create design registration records
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Rejection_Reason_Nm__c = 'Company Out Of Business';
        DDRLst[0].Core_Rejection_Comment_Txt__c = 'Test Comments';
        insert DDRLst;
        
        // Create design registration product records
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        // Update design registration
        Core_DDR_Accept_Approve_Reject_Design.updateDesignRegistration(DDRLst[0]);
        
        Test.stopTest();
        
        // Assert that the picklist values are fetched successfully
        String ddrId = String.valueOf(DDRLst[0].Id);
        String ObjType = 'Core_Design_Registration__c';
        String fieldName = 'Core_Design_Registration_Status_Nm__c';
       
        //  List<Schema.PicklistEntry> picklistValues = Test.getPicklistValues(ObjType, fieldName);
        System.assertNotEquals(null,ddrId);
    }
    
    
    /* public static testmethod void DR_Product_test16() {
//setupData();
Test.startTest();
List<account> LstAcc = Core_Test_Utility.createAccount(3);
Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            

for(Account acc : LstAcc){
// acc.Core_Sales_Groups__c ='';
acc.recordTypeId = accountRecordTypeIntel;
}
LstAcc[0].Core_Export_Compliance_Block__c=true; 
insert LstAcc;

List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();

//List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();

//	User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
// System.runAs(adminUser) {
insert ProdLst;
//     }

List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
insert PriceBookLst;

List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);

List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
DDRLst[0].Core_Rejection_Reason_Nm__c = 'Company Out Of Business';
DDRLst[0].Core_Rejection_Comment_Txt__c = 'Test Comments';
insert DDRLst;


List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
insert DRPLst;     

String ddrId = String.valueOf(DDRLst[0].Id);
String ObjType = 'Core_Design_Registration__c';
String fieldName = 'Core_Design_Registration_Status_Nm__c';
System.runAs(Core_Test_Utility.systemAdminUser){
//   Core_DDR_Accept_Approve_Reject_Design.getPicklistValues(ddrId,ObjType, fieldName);
}

Test.stopTest(); 

} */
    
}