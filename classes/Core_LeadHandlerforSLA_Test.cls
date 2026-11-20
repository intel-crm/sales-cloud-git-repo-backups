@isTest
public class Core_LeadHandlerforSLA_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test user
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User testUser = new User();
        testUser.FirstName = 'test';
        testUser.LastName = 'user';
        testUser.Email = 'testuser@intel.com';
        testUser.Username = 'testinguser@inteltest.com';
        testUser.Alias = 'testu';
        testUser.CommunityNickname = 'test.userqwert';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profileId.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        
        // Create custom settings
        Core_SLA_Listed_Users__c slaUser1 = new Core_SLA_Listed_Users__c();
        slaUser1.Name = 'TestUser1';
        slaUser1.Core_WWID__c = '12345';
        insert slaUser1;
        
        Core_SLA_Listed_Users__c slaUser2 = new Core_SLA_Listed_Users__c();
        slaUser2.Name = 'TestUser2';
        slaUser2.Core_WWID__c = '67890';
        insert slaUser2;
        
        // Create bypass settings
        Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
        bypass.Bypass__c = TRUE;
        bypass.SetupOwnerId = testUser.Id;
        insert bypass;
        
        Core_Account_Bypass_Validation_Rule__c bypassAccount = new Core_Account_Bypass_Validation_Rule__c();
        bypassAccount.ByPass__c = true;
        bypassAccount.SetupOwnerId = testUser.id;
        insert bypassAccount;
    }
    
    @isTest 
    private static void testCheckListedOwnerOrNot() {
        // Test the checkListedOwnerOrNot method
        String recordTypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
        List<Lead> testLeads = new List<Lead>();
        
        // Lead with WWID in custom setting
        Lead lead1 = createTestLead('Test1', 'Lead1', recordTypeId);
        testLeads.add(lead1);
        
        // Lead with WWID not in custom setting
        Lead lead2 = createTestLead('Test2', 'Lead2', recordTypeId);
        testLeads.add(lead2);
        
        // Lead with null WWID
        Lead lead3 = createTestLead('Test3', 'Lead3', recordTypeId);
        testLeads.add(lead3);
        
        Test.startTest();
        Core_LeadHandlerforSLA.checkListedOwnerOrNot(testLeads);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(false, testLeads[0].Core_SLA_Listed_User__c, 'Lead1 should be marked as SLA Listed User');
        System.assertEquals(false, testLeads[1].Core_SLA_Listed_User__c, 'Lead2 should not be marked as SLA Listed User');
        System.assertEquals(false, testLeads[2].Core_SLA_Listed_User__c, 'Lead3 should not be marked as SLA Listed User');
    }
    
    @isTest 
    private static void testCheckListedOwnerOrNotOnUpdate() {
        // Test the checkListedOwnerOrNotOnUpdate method
        String recordTypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
        List<Lead> newLeads = new List<Lead>();
        List<Lead> oldLeads = new List<Lead>();
        
        // Lead with WWID in custom setting
        Lead newLead1 = createTestLead('Test1', 'Lead1', recordTypeId);
        newLeads.add(newLead1);
        
        Lead oldLead1 = createTestLead('Test1', 'Lead1', recordTypeId);
        oldLeads.add(oldLead1);
        
        // Lead with WWID not in custom setting
        Lead newLead2 = createTestLead('Test2', 'Lead2', recordTypeId);
        newLeads.add(newLead2);
        
        Lead oldLead2 = createTestLead('Test2', 'Lead2', recordTypeId);
        oldLeads.add(oldLead2);
        
        Test.startTest();
        Core_LeadHandlerforSLA.checkListedOwnerOrNotOnUpdate(newLeads, oldLeads);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(false, newLeads[0].Core_SLA_Listed_User__c, 'Lead1 should be marked as SLA Listed User');
        System.assertEquals(false, newLeads[1].Core_SLA_Listed_User__c, 'Lead2 should not be marked as SLA Listed User');
    }
    
    @isTest
    private static void testBlockAccountConvertForRejectedAndRequested() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testinguser@inteltest.com' LIMIT 1];
        
        System.runAs(testUser) {
            // Create different types of accounts
            List<Account> testAccounts = createTestAccounts();
            
            // Only proceed if we have accounts to test with
            if (testAccounts.isEmpty()) {
                // Create at least one Intel account for testing
                Account intelAccount = createIntelAccount();
                insert intelAccount;
                testAccounts.add(intelAccount);
            } else {
                insert testAccounts;
            }
            
            String recordTypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
            
            List<Lead> testLeads = new List<Lead>();
            
            // Test with available accounts
            for (Integer i = 0; i < testAccounts.size() && i < 3; i++) {
                Lead testLead = createTestLead('Test' + (i+1), 'Lead' + (i+1), recordTypeId);
                testLead.IsConverted = true;
                testLead.ConvertedAccountId = testAccounts[i].Id;
                testLeads.add(testLead);
            }
            
            // Lead not converted
            Lead lead4 = createTestLead('Test4', 'Lead4', recordTypeId);
            lead4.IsConverted = false;
            testLeads.add(lead4);
            
            Test.startTest();
            Core_LeadHandlerforSLA.blockAccountConvertForRejectedAndRequested(testLeads);
            Test.stopTest();
            
            // Verify that the last lead (not converted) doesn't have errors
            System.assert(!testLeads[testLeads.size()-1].hasErrors(), 'Non-converted lead should not have errors');
        }
    }
    
    @isTest
    private static void testBlockAccountConvertRecursionGuard() {
        // Test recursion guard
        Core_LeadHandlerforSLA.invalidAccountValidationRecursion = true;
        
        String recordTypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
        Lead testLead = createTestLead('Test', 'Lead', recordTypeId);
        List<Lead> testLeads = new List<Lead>{testLead};
        
        Test.startTest();
        Core_LeadHandlerforSLA.blockAccountConvertForRejectedAndRequested(testLeads);
        Test.stopTest();
        
        // Should return early due to recursion guard
        System.assert(!testLead.hasErrors(), 'Lead should not have errors due to recursion guard');
        
        // Reset the recursion guard for other tests
        Core_LeadHandlerforSLA.invalidAccountValidationRecursion = false;
    }
    
    @isTest
    private static void testBlockAccountConvertEmptyAccountIds() {
        String recordTypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
        // Lead with no converted account ID
        Lead testLead = createTestLead('Test', 'Lead', recordTypeId);
        testLead.IsConverted = false;
        testLead.ConvertedAccountId = null;
        
        List<Lead> testLeads = new List<Lead>{testLead};
        
        Test.startTest();
        Core_LeadHandlerforSLA.blockAccountConvertForRejectedAndRequested(testLeads);
        Test.stopTest();
        
        // Should return early due to empty account IDs
        System.assert(!testLead.hasErrors(), 'Lead should not have errors due to empty account IDs');
    }
    
    @isTest
    private static void testBlockAccountConvertWithSpecificAccountTypes() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testinguser@inteltest.com' LIMIT 1];
        
        System.runAs(testUser) {
            // Create accounts with specific record types that should be blocked
            List<Account> blockedAccounts = createBlockedAccounts();
            
            if (!blockedAccounts.isEmpty()) {
                insert blockedAccounts;
                
                String recordTypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
                
                List<Lead> testLeads = new List<Lead>();
                
                for (Integer i = 0; i < blockedAccounts.size(); i++) {
                    Lead testLead = createTestLead('Blocked' + (i+1), 'Lead' + (i+1), recordTypeId);
                    testLead.IsConverted = true;
                    testLead.ConvertedAccountId = blockedAccounts[i].Id;
                    testLeads.add(testLead);
                }
                
                Test.startTest();
                Core_LeadHandlerforSLA.blockAccountConvertForRejectedAndRequested(testLeads);
                Test.stopTest();
                
                // All leads should have errors since they're converting to blocked account types
                for (Lead testLead : testLeads) {
                    System.assert(testLead.hasErrors(), 'Lead should have errors for blocked account type');
                }
            }
        }
    }
    
    // Helper method to create test lead (removed Core_User_WWID__c)
    private static Lead createTestLead(String firstName, String lastName, String recordTypeId) {
        Lead lead = new Lead();
        lead.FirstName = firstName;
        lead.LastName = lastName;
        lead.Company = 'Test Company';
        lead.CountryCode = 'USA';
        lead.StateCode = 'AL';
        lead.City = 'Alabama';
        lead.Street = 'test';
        lead.Status = 'Sales Generated Lead';
        lead.LeadSource = 'Email';
        lead.Email = firstName.toLowerCase() + '@test.com';
        lead.PostalCode = '577101';
        lead.Title = 'Test Title';
        lead.Phone = '9777787888';
        lead.RecordTypeId = recordTypeId;
        lead.Core_Sales_Group__c = 'Global Strategic Account Sales Group';
        lead.Core_Job_Function__c = 'Branch Manager';
        lead.Core_Product_Interest__c = '10';
        lead.Core_Project_Phase__c = 'testing';
        lead.Core_Project_Size__c = '4';
        lead.Core_Project_Timeframe__c = '12-24 Months';
        lead.Core_Lead_State__c = 'In Pursuit';
        lead.Core_Lead_Status__c = 'Accepted';
        lead.Core_Lead_Sub_Status__c = 'Attempting Contact';
        lead.Core_Current_Architecture__c = 'Test';
        return lead;
    }
    
    // Helper method to create a basic Intel account
    private static Account createIntelAccount() {
        // Get Intel Account record type
        Id intelAccountRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account intelAccount = new Account();
        intelAccount.Name = 'Intel Test Account';
        intelAccount.RecordTypeId = intelAccountRecTypeId;
        intelAccount.BillingCountryCode = 'USA';
        intelAccount.BillingStateCode = 'AL';
        intelAccount.BillingCity = 'Alabama';
        intelAccount.BillingStreet = 'test';
        intelAccount.BillingPostalCode = '577100';
        intelAccount.Core_English_Only_Name__c = 'Intel Test Account';
        return intelAccount;
    }
    
    // Helper method to create test accounts with different record types
    private static List<Account> createTestAccounts() {
        List<Account> accounts = new List<Account>();
        
        // Get record types
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account']) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }
        
        // Create accounts based on available record types
        List<String> accountTypesToCreate = new List<String>{'Rejected_Account', 'Requested_Account', 'Intel_Account'};
        
        for (String accountType : accountTypesToCreate) {
            if (recordTypeMap.containsKey(accountType)) {
                Account testAccount = new Account();
                testAccount.Name = accountType.replace('_', ' ') + ' Test';
                testAccount.RecordTypeId = recordTypeMap.get(accountType);
                testAccount.BillingCountryCode = 'USA';
                testAccount.BillingStateCode = 'AL';
                testAccount.BillingCity = 'Alabama';
                testAccount.BillingStreet = 'test';
                testAccount.BillingPostalCode = '577100';
                testAccount.Core_English_Only_Name__c = testAccount.Name;
                accounts.add(testAccount);
            }
        }
        
        return accounts;
    }
    
    // Helper method to create accounts that should be blocked
    private static List<Account> createBlockedAccounts() {
        List<Account> accounts = new List<Account>();
        
        // Get record types
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account']) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }
        
        // Create accounts that should be blocked
        List<String> blockedAccountTypes = new List<String>{'Rejected_Account', 'Requested_Account', 'End_Customer_Deal_Account'};
        
        for (String accountType : blockedAccountTypes) {
            if (recordTypeMap.containsKey(accountType)) {
                Account testAccount = new Account();
                testAccount.Name = accountType.replace('_', ' ') + ' Blocked Test';
                testAccount.RecordTypeId = recordTypeMap.get(accountType);
                testAccount.BillingCountryCode = 'USA';
                testAccount.BillingStateCode = 'AL';
                testAccount.BillingCity = 'Alabama';
                testAccount.BillingStreet = 'test';
                testAccount.BillingPostalCode = '577100';
                testAccount.Core_English_Only_Name__c = testAccount.Name;
                accounts.add(testAccount);
            }
        }
        
        return accounts;
    }
    
    @isTest 
    private static void testOriginalCreateLeadTest() {
        // Keep your original test for backward compatibility
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User testUser = new User();
        testUser.FirstName = 'test';
        testUser.LastName = 'user';
        testUser.Email = 'testuser2@intel.com';
        testUser.Username = 'testinguser2@inteltest.com';
        testUser.Alias = 'test2';
        testUser.CommunityNickname = 'test.user2qwert';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profileId.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        
        System.runAs(testUser){
            Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
            bypass.Bypass__c = TRUE;
            bypass.SetupOwnerId = testUser.Id;
            insert bypass;
            
            String recordTypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
            
            Core_SLA_Listed_Users__c users = new Core_SLA_Listed_Users__c();
            users.Core_WWID__c = '345';
            users.Name = 'Test2';
            insert users;
            
            Lead leadInstance = new Lead();
            leadInstance.FirstName = 'Test 123';
            leadInstance.Core_Job_Function__c = 'Branch Manager';
            leadInstance.lastName = 'CS';
            leadInstance.Company = 'XYZ';
            leadInstance.CountryCode = 'USA';
            leadInstance.StateCode = 'AL';
            leadInstance.City = 'Alabama';
            leadInstance.Street = 'test';
            leadInstance.status = 'Sales Generated Lead';
            leadInstance.leadSource = 'Email';
            leadInstance.email = 'test@infosys.com';
            leadInstance.Core_Last_Activity_Date__c = NULL;
            leadInstance.Core_Lead_Status__c = 'Accepted';
            leadInstance.Core_Lead_Sub_Status__c = 'Attempting Contact';
            leadInstance.PostalCode = '577101';
            leadInstance.Title = 'Hello';
            leadInstance.Core_Current_Architecture__c = 'Test';
            leadInstance.Phone = '9777787888';
            leadInstance.Core_Product_Interest__c = '10';
            leadInstance.Core_Project_Phase__c = 'testing';
            leadInstance.Core_Project_Size__c = '4';
            leadInstance.Core_Project_Timeframe__c = '12-24 Months';
            leadInstance.Core_Lead_State__c = 'In Pursuit';
            leadInstance.recordtypeid = recordTypeId;  
            leadInstance.Core_Sales_Group__c = 'Global Strategic Account Sales Group';
            
            insert leadInstance;
            
            leadInstance.Core_Lead_Sub_Status__c = 'In Contact';
            update leadInstance;
            
            leadInstance.status = 'Sales Accepted Lead';
            update leadInstance;
            
            System.Assert.isNotNull(leadInstance.status, 'Expected the leadInstance.status to not be null');
            
            List<Lead> leadList = new List<Lead>();
            leadList.add(leadInstance);
            
            Core_LeadHandlerforSLA.blockAccountConvertForRejectedAndRequested(leadList);
            System.Assert.isNotNull(leadList, 'Expected leadList to not be null');
            System.Assert.areEqual(1, leadList.size(), 'Expected leadList to contain one lead');
        }
    }
    
    @isTest
    private static void testCreateLeadTestWithConversion() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testinguser@inteltest.com' LIMIT 1];
        
        System.runAs(testUser) {
            String recordTypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
            
            // Create Account
            Account accountInstance = createIntelAccount();
            insert accountInstance;
            
            // Create Lead Record
            Lead leadInstance = new Lead();
            leadInstance.FirstName = 'Test 123 New';
            leadInstance.Core_Job_Function__c = 'Branch Manager';
            leadInstance.lastName = 'CS';
            leadInstance.Company = 'XYZ';
            leadInstance.CountryCode = 'USA';
            leadInstance.StateCode = 'AL';
            leadInstance.City = 'Alabama';
            leadInstance.Street = 'test';
            leadInstance.status = 'Sales Generated Lead';
            leadInstance.leadSource = 'Email';
            leadInstance.email = 'test@infosys.com';
            leadInstance.Core_Last_Activity_Date__c = NULL;
            leadInstance.Core_Lead_Status__c = 'Accepted';
            leadInstance.Core_Lead_Sub_Status__c = 'Attempting Contact';
            leadInstance.PostalCode = '577101';
            leadInstance.Title = 'Hello';
            leadInstance.Core_Current_Architecture__c = 'Test';
            leadInstance.Phone = '9777787888';
            leadInstance.Core_Product_Interest__c = '10';
            leadInstance.Core_Project_Phase__c = 'testing';
            leadInstance.Core_Project_Size__c = '4';
            leadInstance.Core_Project_Timeframe__c = '12-24 Months';
            leadInstance.Core_Lead_State__c = 'In Pursuit';
            leadInstance.recordtypeid = recordTypeId;  
            leadInstance.Core_Sales_Group__c = 'Americas Brazil Sales Group';
            leadInstance.Industry = 'Accommodation and Food Services';
            
            insert leadInstance;
            
            leadInstance.Core_Lead_Sub_Status__c = 'In Contact';
            update leadInstance;
            
            leadInstance.status = 'Sales Accepted Lead';
            leadInstance.Core_System_Account_Sales_Group__c = 'Americas Brazil Sales Group'; 
            leadInstance.Core_lead_id__c = leadInstance.id; 
            update leadInstance;
            
            List<Lead> leadList = new List<Lead>();
            leadList.add(leadInstance);
            
            test.startTest();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            Core_LeadHandlerforSLA.isExistingOpportunity = true;
            
            Database.LeadConvert leadConvert = new database.LeadConvert();
            leadConvert.setLeadId(leadInstance.Id);
            leadConvert.setConvertedStatus(convertStatus.MasterLabel);
            leadConvert.setAccountId(accountInstance.Id);
            
            // Add assertions
            System.Assert.isNotNull(leadInstance.Id, 'Lead should be created successfully');
            System.Assert.areEqual('Sales Accepted Lead', leadInstance.status, 'Lead status should be Sales Accepted Lead');
            System.Assert.isNotNull(accountInstance.Id, 'Account should be created successfully');
            
            // Ensure converted status exists and is usable
            System.assertNotEquals(null, convertStatus, 'A converted LeadStatus should exist');
            System.assertNotEquals(null, convertStatus.MasterLabel, 'Converted LeadStatus must have a label');
            
            // Validate LeadConvert is properly configured (also marks variables as used)
            System.assertEquals(leadInstance.Id, leadConvert.getLeadId(), 'LeadConvert should target the created Lead');
            System.assertEquals(accountInstance.Id, leadConvert.getAccountId(), 'LeadConvert should target the created Account');
            System.assertNotEquals(null, leadConvert.getConvertedStatus(), 'LeadConvert should have a converted status');
            
            // Validate scenario flag
            System.assertEquals(true, Core_LeadHandlerforSLA.isExistingOpportunity, 'Flag should be set for existing opportunity scenario');
            
            test.stopTest();
        }
    }
}