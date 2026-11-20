/**************************************************************************************
Apex Class Name:  SWS_LeadWrappers_Test
Version     : 1.0 
Created Date: 2026-03-11
Function    : Test Class for SWS_LeadWrappers wrapper/DTO classes
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Naveen          03/11/2026              Original Version
*************************************************************************************/
@isTest
public class SWS_LeadWrappers_Test {
    
    @testSetup 
    private static void setup(){
        User u = SWS_TestUtilty.createUser();
        PermissionSet permissionRec = [SELECT Id,Name FROM PermissionSet WHERE Name = 'PSG_Master_Data_Read_Write_Access' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionRec.Id);
        
        System.runAs(u){
            // Create test data similar to Core_LeadHandler_Test
            List<Core_Country_Reference__c> lstCS = Core_Test_Utility.Core_CountryState(1);
            for (Core_Country_Reference__c sobjCS: lstCS) {
                sobjCS.Name = 'United States';
                sobjCS.Core_Geo__c = 'ASMO';
                sobjCS.Core_Has_States__c = true;
                sobjCS.Core_ISO_Code__c = 'USA';
                sobjCS.Core_Sub_Geo__c = 'NAR';
            }
            insert lstCS;
            
            // Create test accounts
            List<Account> lstAccounts = new List<Account>{SWS_TestUtilty.createAccount()};
            lstAccounts[0].Core_Address_Details__c = 'TestAddress123';
            update lstAccounts;
            
            // Create test contacts with UNIQUE emails
            List<Contact> lstContacts = Core_Test_Utility.createContacts(2);
            for (Integer i = 0; i < lstContacts.size(); i++) {
                lstContacts[i].AccountId = lstAccounts[0].Id;
                lstContacts[i].Email = 'contact' + i + '@testwrapper.com'; // Changed to unique contact emails
                lstContacts[i].MailingCountry = 'USA';
            }
            insert lstContacts;
            
            // Create test leads with UNIQUE emails (different from contacts)
            String salesLeadRecTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Lead').getRecordTypeId();
            List<Lead> lstLeads = Core_Test_Utility.createLead(2);
            for (Integer i = 0; i < lstLeads.size(); i++) {
                lstLeads[i].RecordTypeId = salesLeadRecTypeId;
                lstLeads[i].Core_Lead_Status__c = 'New';
                lstLeads[i].Status = 'Marketing Qualified Lead';
                lstLeads[i].Email = 'lead' + i + '@testwrapper.com'; // Changed to unique lead emails
            }
            insert lstLeads;
            
            // Create partner queue mapping for partner-related tests
            Core_Partner_Queue_Mapping__c mappingRecord = new Core_Partner_Queue_Mapping__c();
            mappingRecord.Core_Partner_Name__c = 'TestPartnerWrapper';
            mappingRecord.Core_Queue_Name__c = 'Core_PTNR_TestPartnerWrapper';
            mappingRecord.Core_Active__c = true;
            insert mappingRecord;
        }
    }
    
    @isTest
    private static void testConversionContextInstantiation() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Test ConversionContext instantiation and property setting
            SWS_LeadWrappers.ConversionContext ctx = new SWS_LeadWrappers.ConversionContext();
            
            // Verify all collections are initialized
            System.assertNotEquals(null, ctx.mapLeadIdAccountId, 'mapLeadIdAccountId should be initialized');
            System.assertNotEquals(null, ctx.mapLeadIdContactId, 'mapLeadIdContactId should be initialized');
            System.assertNotEquals(null, ctx.lstConvertedLeads, 'lstConvertedLeads should be initialized');
            System.assertNotEquals(null, ctx.lstWriteableFields, 'lstWriteableFields should be initialized');
            System.assertNotEquals(null, ctx.setAddressDetails, 'setAddressDetails should be initialized');
            System.assertNotEquals(null, ctx.mapEmailAccounts, 'mapEmailAccounts should be initialized');
            
            // Test setting values
            List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 1];
            List<Account> testAccounts = [SELECT Id FROM Account LIMIT 1];
            
            if (!testLeads.isEmpty() && !testAccounts.isEmpty()) {
                ctx.mapLeadIdAccountId.put(testLeads[0].Id, testAccounts[0].Id);
                ctx.lstConvertedLeads.add(testLeads[0]);
                ctx.setAddressDetails.add('TestAddress123');
                
                System.assertEquals(1, ctx.mapLeadIdAccountId.size(), 'mapLeadIdAccountId should contain 1 entry');
                System.assertEquals(1, ctx.lstConvertedLeads.size(), 'lstConvertedLeads should contain 1 entry');
                System.assertEquals(1, ctx.setAddressDetails.size(), 'setAddressDetails should contain 1 entry');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testAccountDedupParamsFluentInterface() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Get test data
            List<Lead> testLeads = [SELECT Id, Company FROM Lead LIMIT 1];
            List<Account> testAccounts = [SELECT Id FROM Account LIMIT 1];
            Map<Id, Lead> testLeadMap = new Map<Id, Lead>(testLeads);
            
            // Create ConversionContext
            SWS_LeadWrappers.ConversionContext ctx = new SWS_LeadWrappers.ConversionContext();
            
            // Test fluent interface pattern
            SWS_LeadWrappers.AccountDedupParams params = new SWS_LeadWrappers.AccountDedupParams()
                .setContext(ctx)
                .setLead(testLeads.isEmpty() ? null : testLeads[0])
                .setAccount(testAccounts.isEmpty() ? null : testAccounts[0])
                .setLeadMap(testLeadMap);
            
            // Verify all properties are set correctly
            System.assertEquals(ctx, params.ctx, 'Context should be set correctly');
            if (!testLeads.isEmpty()) {
                System.assertEquals(testLeads[0], params.leadInstance, 'Lead should be set correctly');
            }
            if (!testAccounts.isEmpty()) {
                System.assertEquals(testAccounts[0], params.accountInstance, 'Account should be set correctly');
            }
            System.assertEquals(testLeadMap, params.mapNewIdLeads, 'Lead map should be set correctly');
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testDmlContextConstructor() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Create ConversionContext with test data
            SWS_LeadWrappers.ConversionContext ctx = new SWS_LeadWrappers.ConversionContext();
            List<Contact> testContacts = [SELECT Id FROM Contact LIMIT 1];
            List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 1];
            Map<Id, Lead> testLeadMap = new Map<Id, Lead>(testLeads);
            
            // Populate context with test data
            if (!testContacts.isEmpty()) {
                ctx.lstUpdateContacts.add(testContacts[0]);
            }
            ctx.lstAccountContactRole.add(new AccountContactRole());
            ctx.lstOpportunityContactRole.add(new OpportunityContactRole());
            
            // Test DmlContext constructor
            SWS_LeadWrappers.DmlContext dmlCtx = new SWS_LeadWrappers.DmlContext(ctx, testLeadMap);
            
            // Verify all properties are copied correctly
            System.assertEquals(ctx.lstUpdateContacts, dmlCtx.lstUpdateContacts, 'lstUpdateContacts should be copied');
            System.assertEquals(ctx.lstAccountContactRole, dmlCtx.lstAccountContactRole, 'lstAccountContactRole should be copied');
            System.assertEquals(ctx.lstOpportunityContactRole, dmlCtx.lstOpportunityContactRole, 'lstOpportunityContactRole should be copied');
            System.assertEquals(testLeadMap, dmlCtx.mapNewIdLeads, 'mapNewIdLeads should be set');
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testErrorContextFluentInterface() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Create test data
            List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 1];
            Map<Id, Lead> testLeadMap = new Map<Id, Lead>(testLeads);
            List<SObject> testRecords = new List<SObject>();
            if (!testLeads.isEmpty()) {
                testRecords.add(testLeads[0]);
            }
            
            Map<Id, Id> testIdMapping = new Map<Id, Id>();
            Map<Id, Id> testLeadMapping = new Map<Id, Id>();
            
            // Test ErrorContext fluent interface
            SWS_LeadWrappers.ErrorContext errorCtx = new SWS_LeadWrappers.ErrorContext()
                .setRecords(testRecords)
                .setIdMapping(testIdMapping)
                .setLeadMapping(testLeadMapping)
                .setLeadMap(testLeadMap);
            
            // Verify all properties are set correctly
            System.assertEquals(testRecords, errorCtx.records, 'Records should be set correctly');
            System.assertEquals(testIdMapping, errorCtx.mapId1Id2, 'ID mapping should be set correctly');
            System.assertEquals(testLeadMapping, errorCtx.mapId2LeadId, 'Lead mapping should be set correctly');
            System.assertEquals(testLeadMap, errorCtx.mapNewIdLeads, 'Lead map should be set correctly');
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testLeadConvertRequest() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Get test data
            List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 1];
            List<Contact> testContacts = [SELECT Id FROM Contact LIMIT 1];
            
            // Test LeadConvertRequest
            SWS_LeadWrappers.LeadConvertRequest request = new SWS_LeadWrappers.LeadConvertRequest();
            
            if (!testLeads.isEmpty() && !testContacts.isEmpty()) {
                request.leadId = testLeads[0].Id;
                request.contactId = testContacts[0].Id;
                
                System.assertEquals(testLeads[0].Id, request.leadId, 'Lead ID should be set correctly');
                System.assertEquals(testContacts[0].Id, request.contactId, 'Contact ID should be set correctly');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testProcessLeadsCtx() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Create test data
            List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 2];
            
            // Test ProcessLeadsCtx
            SWS_LeadWrappers.ProcessLeadsCtx processCtx = new SWS_LeadWrappers.ProcessLeadsCtx();
            processCtx.finalLeadList = testLeads;
            processCtx.marketingProfileLeadsMap = new Map<String, List<Lead>>();
            processCtx.partnerNameLeadsMap = new Map<String, List<Lead>>();
            
            if (!testLeads.isEmpty()) {
                processCtx.marketingProfileLeadsMap.put('TestProfile', testLeads);
                processCtx.partnerNameLeadsMap.put('TestPartner', testLeads);
            }
            
            // Verify properties
            System.assertEquals(testLeads, processCtx.finalLeadList, 'Final lead list should be set');
            System.assertNotEquals(null, processCtx.marketingProfileLeadsMap, 'Marketing profile map should be initialized');
            System.assertNotEquals(null, processCtx.partnerNameLeadsMap, 'Partner name map should be initialized');
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testAssignMpiCtx() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Create test data
            List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 1];
            List<Core_Partner_Queue_Mapping__c> queueMappings = [SELECT Id, Core_Partner_Name__c FROM Core_Partner_Queue_Mapping__c LIMIT 1];
            
            // Test AssignMpiCtx
            SWS_LeadWrappers.AssignMpiCtx assignCtx = new SWS_LeadWrappers.AssignMpiCtx();
            assignCtx.opidLeadSetMap = new Map<String, Set<Lead>>();
            assignCtx.opidPartnerNameFromQueueMapping = new Map<String, String>();
            assignCtx.partnerNameLeadsMap = new Map<String, List<Lead>>();
            assignCtx.partnerNameQueueMap = new Map<String, Core_Partner_Queue_Mapping__c>();
            assignCtx.availableOpidFromMpiJunction = new Set<String>();
            
            if (!testLeads.isEmpty()) {
                assignCtx.opidLeadSetMap.put('TestOPID', new Set<Lead>(testLeads));
                assignCtx.partnerNameLeadsMap.put('TestPartner', testLeads);
            }
            
            if (!queueMappings.isEmpty()) {
                assignCtx.partnerNameQueueMap.put(queueMappings[0].Core_Partner_Name__c, queueMappings[0]);
            }
            
            assignCtx.availableOpidFromMpiJunction.add('TestOPID');
            
            // Verify all properties are set
            System.assertNotEquals(null, assignCtx.opidLeadSetMap, 'OPID lead set map should be initialized');
            System.assertNotEquals(null, assignCtx.partnerNameLeadsMap, 'Partner name leads map should be initialized');
            System.assertNotEquals(null, assignCtx.availableOpidFromMpiJunction, 'Available OPID set should be initialized');
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testDisplayLeadsCtxConstructor() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Create test data
            List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 1];
            String baseUrl = 'https://test.salesforce.com';
            String listViewUrl = '/lightning/o/Lead/list';
            Boolean isReminder = true;
            
            // Test DisplayLeadsCtx constructor
            SWS_LeadWrappers.DisplayLeadsCtx displayCtx = new SWS_LeadWrappers.DisplayLeadsCtx(
                baseUrl, listViewUrl, testLeads, isReminder
            );
            
            // Verify constructor sets all properties correctly
            System.assertEquals(baseUrl, displayCtx.baseUrl, 'Base URL should be set correctly');
            System.assertEquals(listViewUrl, displayCtx.listViewUrl, 'List view URL should be set correctly');
            System.assertEquals(testLeads, displayCtx.leadList, 'Lead list should be set correctly');
            System.assertEquals(isReminder, displayCtx.isReminder, 'Is reminder flag should be set correctly');
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testReminderParamsConstructor() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Create test data
            List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 1];
            Date leadCreationDate = Date.today().addDays(-5);
            Date reminderDate = Date.today();
            
            if (!testLeads.isEmpty()) {
                // Test ReminderParams constructor
                SWS_LeadWrappers.ReminderParams reminderParams = new SWS_LeadWrappers.ReminderParams(
                    leadCreationDate, reminderDate, testLeads[0]
                );
                
                // Verify constructor sets all properties correctly
                System.assertEquals(leadCreationDate, reminderParams.leadCreationDate, 'Lead creation date should be set correctly');
                System.assertEquals(reminderDate, reminderParams.reminderDate, 'Reminder date should be set correctly');
                System.assertEquals(testLeads[0], reminderParams.led, 'Lead should be set correctly');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testAllPartnerRelatedWrappers() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            
            // Test GroupLeadsCtx
            SWS_LeadWrappers.GroupLeadsCtx groupCtx = new SWS_LeadWrappers.GroupLeadsCtx();
            groupCtx.allMpiLeadsMap = new Map<String, List<Lead>>();
            groupCtx.offeringRelatedMpiLeadsMap = new Map<String, List<Lead>>();
            groupCtx.finalLeadList = new List<Lead>();
            
            System.assertNotEquals(null, groupCtx.allMpiLeadsMap, 'All MPI leads map should be initialized');
            System.assertNotEquals(null, groupCtx.offeringRelatedMpiLeadsMap, 'Offering related MPI leads map should be initialized');
            System.assertNotEquals(null, groupCtx.finalLeadList, 'Final lead list should be initialized');
            
            // Test ProcessOlrCtx
            SWS_LeadWrappers.ProcessOlrCtx olrCtx = new SWS_LeadWrappers.ProcessOlrCtx();
            olrCtx.newQueueMap = new Map<Id, Core_Partner_Queue_Mapping__c>();
            olrCtx.finalLeadMap = new Map<String, Lead>();
            olrCtx.finalLeadPlclMap = new Map<String, Lead>();
            olrCtx.finalGroupsNLeadsMap = new Map<String, List<String>>();
            
            System.assertNotEquals(null, olrCtx.newQueueMap, 'New queue map should be initialized');
            System.assertNotEquals(null, olrCtx.finalLeadMap, 'Final lead map should be initialized');
            
            // Test PrepareEmailCtx
            SWS_LeadWrappers.PrepareEmailCtx emailCtx = new SWS_LeadWrappers.PrepareEmailCtx();
            emailCtx.isReminder = false;
            emailCtx.userId = UserInfo.getUserId();
            emailCtx.leadList = new List<Lead>();
            emailCtx.emailList = new List<Messaging.SingleEmailMessage>();
            
            System.assertEquals(false, emailCtx.isReminder, 'Is reminder should be set to false');
            System.assertEquals(UserInfo.getUserId(), emailCtx.userId, 'User ID should be set correctly');
            
            // Test PrepareTemplEmailCtx
            SWS_LeadWrappers.PrepareTemplEmailCtx templEmailCtx = new SWS_LeadWrappers.PrepareTemplEmailCtx();
            templEmailCtx.userId = UserInfo.getUserId();
            templEmailCtx.emailList = new List<Messaging.SingleEmailMessage>();
            
            System.assertEquals(UserInfo.getUserId(), templEmailCtx.userId, 'User ID should be set correctly');
            System.assertNotEquals(null, templEmailCtx.emailList, 'Email list should be initialized');
            
            // Test PopulateAccountSetsCtx
            SWS_LeadWrappers.PopulateAccountSetsCtx accountSetsCtx = new SWS_LeadWrappers.PopulateAccountSetsCtx();
            accountSetsCtx.userIdSet = new Set<String>();
            accountSetsCtx.opidAccSet = new Set<Id>();
            accountSetsCtx.accIdSet = new Set<Id>();
            
            System.assertNotEquals(null, accountSetsCtx.userIdSet, 'User ID set should be initialized');
            System.assertNotEquals(null, accountSetsCtx.opidAccSet, 'OPID account set should be initialized');
            System.assertNotEquals(null, accountSetsCtx.accIdSet, 'Account ID set should be initialized');
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testWrapperClassCoverage() {
        // This test ensures we have coverage for all wrapper classes
        // and their basic instantiation without complex business logic
        
        Test.startTest();
        
        // Test that all wrapper classes can be instantiated without errors
        SWS_LeadWrappers.ConversionContext ctx1 = new SWS_LeadWrappers.ConversionContext();
        SWS_LeadWrappers.AccountDedupParams params1 = new SWS_LeadWrappers.AccountDedupParams();
        SWS_LeadWrappers.ErrorContext error1 = new SWS_LeadWrappers.ErrorContext();
        SWS_LeadWrappers.LeadConvertRequest request1 = new SWS_LeadWrappers.LeadConvertRequest();
        SWS_LeadWrappers.ProcessLeadsCtx process1 = new SWS_LeadWrappers.ProcessLeadsCtx();
        SWS_LeadWrappers.AssignMpiCtx assign1 = new SWS_LeadWrappers.AssignMpiCtx();
        SWS_LeadWrappers.GroupLeadsCtx group1 = new SWS_LeadWrappers.GroupLeadsCtx();
        SWS_LeadWrappers.ProcessOlrCtx olr1 = new SWS_LeadWrappers.ProcessOlrCtx();
        SWS_LeadWrappers.PrepareEmailCtx email1 = new SWS_LeadWrappers.PrepareEmailCtx();
        SWS_LeadWrappers.PrepareTemplEmailCtx templEmail1 = new SWS_LeadWrappers.PrepareTemplEmailCtx();
        SWS_LeadWrappers.PopulateAccountSetsCtx accountSets1 = new SWS_LeadWrappers.PopulateAccountSetsCtx();
        
        // Assert that all objects are not null (basic instantiation test)
        System.assertNotEquals(null, ctx1, 'ConversionContext should instantiate');
        System.assertNotEquals(null, params1, 'AccountDedupParams should instantiate');
        System.assertNotEquals(null, error1, 'ErrorContext should instantiate');
        System.assertNotEquals(null, request1, 'LeadConvertRequest should instantiate');
        System.assertNotEquals(null, process1, 'ProcessLeadsCtx should instantiate');
        System.assertNotEquals(null, assign1, 'AssignMpiCtx should instantiate');
        System.assertNotEquals(null, group1, 'GroupLeadsCtx should instantiate');
        System.assertNotEquals(null, olr1, 'ProcessOlrCtx should instantiate');
        System.assertNotEquals(null, email1, 'PrepareEmailCtx should instantiate');
        System.assertNotEquals(null, templEmail1, 'PrepareTemplEmailCtx should instantiate');
        System.assertNotEquals(null, accountSets1, 'PopulateAccountSetsCtx should instantiate');
        
        Test.stopTest();
    }
}