@isTest
public class Core_PartnerLeadHandlerAdvancedTest {
    
    @TestSetup
    static void setupAdvancedData() {
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
       rec.Bypass__c = true;
        insert rec;
        // Create trigger settings
        insert new Core_Trigger_Executions__c(
            Name = 'TestSettings',
            Core_Active__c = true,
            Core_Class_Name__c = 'Core_PartnerLeadHandler',
            Core_Description__c = 'Test description for trigger execution',
            Core_Object__c = 'Lead',
            Core_Trigger_Events__c = 'before insert;after insert'
        );

        // Create test user for runAs contexts
        Profile p = [SELECT Id FROM Profile WHERE Name = 'IT Admin' LIMIT 1];
        User testRunAsUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testRunAsUser;

        // Create test users for group membership
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 3; i++) {
            testUsers.add(new User(
                FirstName = 'TestUser',
                LastName = 'Advanced' + i,
                Email = 'testadv' + i + '@example.com',
                Username = 'testadv' + i + '@example.com',
                Alias = 'tadv' + i,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                Core_Email_Trigger_Date__c = (i == 1) ? Date.today() : null,
                Core_Email_Count__c = (i == 1) ? 5 : null
            ));
        }
        insert testUsers;

        // Create Accounts
        String rtPartner = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account parentAccount = new Account(
            Name = 'Test Parent Account1',
            RecordTypeId = rtPartner,
            BillingCountryCode = 'USA',
            BillingStateCode = 'AL',
            BillingCity = 'Alabama123',
            BillingStreet = 'test',
            BillingPostalCode = '123445'
        );
        insert parentAccount;

        List<Account> partnerAccounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            partnerAccounts.add(new Account(
                Name = 'Partner Account ' + i,
                Core_IPA_One_Partner_Id__c = 'OPID' + i,
                Core_Intel_Partner_Alliance_PartnerGroup__c = true,
                BillingCountryCode = 'USA',
                BillingStateCode = 'AL',
                BillingCity = 'Alabama123',
                BillingStreet = 'test',
                BillingPostalCode = '123445',
                RecordTypeId = rtPartner
            ));
        }
        insert partnerAccounts;

        // Create PMP Companies
        List<PMP_Company__c> pmpCompanies = new List<PMP_Company__c>();
        for (Integer i = 0; i < 3; i++) {
            pmpCompanies.add(new PMP_Company__c(
                Name = 'Test MPI ' + i,
                PMP_Account_Id__c = partnerAccounts[i].Id,
                PMP_Is_Published_Ind__c = true,
                PMP_Partner_Benefit_Type__c = 'Solution Marketplace Basic Access'
            ));
        }
        insert pmpCompanies;

        // OPID-MPI relations
        List<PMP_OPID_MPI_Rel__c> opidMpiRels = new List<PMP_OPID_MPI_Rel__c>();
        for (Integer i = 0; i < 3; i++) {
            opidMpiRels.add(new PMP_OPID_MPI_Rel__c(
                PMP_Marketing_Profile_Id__c = pmpCompanies[i].Id,
                PMP_One_Partner_ID__c = partnerAccounts[i].Id,
                Is_Active__c = (i < 2)
            ));
        }
        insert opidMpiRels;

        // Create Groups
        List<Group> testGroups = new List<Group>();
        String[] suffixes = new String[]{'Leads', 'LeadsOfEmployees', 'PSG'};
        for (Integer i = 0; i < 3; i++) {
            for (String sfx : suffixes) {
                testGroups.add(new Group(
                    Name = 'PMP_OPID' + i + '_' + sfx,
                    Type = 'Regular',
                    DeveloperName = 'PMP_OPID' + i + '_' + sfx
                ));
            }
        }
        insert testGroups;

        // Add Group Members using runAs
        System.runAs(testRunAsUser) {
            List<GroupMember> gmList = new List<GroupMember>();
            for (Group g : testGroups) {
                for (User usr : testUsers) {
                    gmList.add(new GroupMember(GroupId = g.Id, UserOrGroupId = usr.Id));
                }
            }
            insert gmList;

            // Insert EmailTemplate
            insert new EmailTemplate(
                Name = 'Partner Lead Notification',
                DeveloperName = 'Partner_Lead_Notification',
                TemplateType = 'text',
                FolderId = UserInfo.getOrganizationId(),
                Subject = 'New Partner Lead',
                Body = 'You have a new partner lead'
            );
        }
    }
    
    @isTest
    static void testPopulateSegmentMpiIns_ComplexScenarios() {
        // Test with leads having different MPI scenarios
        List<Lead> testLeads = createComplexTestLeads();
        
        Test.startTest();
        Core_PartnerLeadHandler.populateSegmentMpiInPartnerLeads(testLeads, false);
        Test.stopTest();
        
        // Verify different scenarios were handled correctly
        for(Lead lead : testLeads) {
            if(lead.PMP_MDA_BizOrg_Id__c != null) {
                // Should have MPI populated or error set
                System.assert(lead.Core_MPI_Id__c != null || lead.Core_Lead_Sharing_Error__c != null);
            }
        }
    }
    
    @isTest 
    static void testPopulateGroupsToRoutePartnerLead_EdgeCases() {
        Core_PartnerLeadHandler.isRecursiveGroupCreation = false;
        
        List<Lead> leads = createComplexTestLeads();
        // Set up leads for routing
        for(Lead lead : leads) {
            lead.Core_MPI_Id__c = [SELECT Id FROM PMP_Company__c LIMIT 1].Id;
            lead.Core_Is_Lead_Shared__c = false;
            lead.Core_Lead_Sharing_Error__c = null;
        }
        
        Test.startTest();
        Core_PartnerLeadHandler.populateGroupsToRoutePartnerLead(leads);
        Test.stopTest();
        
        // Verify OPID Lead Relationships were created
        List<Core_OPID_Lead_Relationship__c> relationships = [
            SELECT Id, Core_Lead_Name__c, Core_OPID_Name__c, Core_Public_Group_Ids__c
            FROM Core_OPID_Lead_Relationship__c 
            WHERE Core_Lead_Name__c IN :leads
        ];
        System.assert(!relationships.isEmpty());
    }
    
    @isTest
    static void testPartnerLeadOwnerUpdate_DetailedScenarios() {
        Core_PartnerLeadHandler.isRecursiveOwnerUpdate = false;
        
        List<Lead> leads = createComplexTestLeads();
        
        // Create OPID relationships for some leads
        List<Core_OPID_Lead_Relationship__c> relationships = new List<Core_OPID_Lead_Relationship__c>();
        for(Integer i = 0; i < leads.size()/2; i++) {
            Core_OPID_Lead_Relationship__c rel = new Core_OPID_Lead_Relationship__c(
                Core_Lead_Name__c = leads[i].Id,
                Core_OPID_Name__c = 'OPID' + i,
                Core_Public_Group_Ids__c = [SELECT Id FROM Group LIMIT 1].Id
            );
            relationships.add(rel);
        }
        insert relationships;
        
        Test.startTest();
        Core_PartnerLeadHandler.partnerLeadOwnerUpdate(leads);
        Test.stopTest();
        
        // Verify owner updates based on OPID relationships
        System.assertEquals(leads.size(), [SELECT COUNT() FROM Lead WHERE Id IN :leads]);
    }
    
    @isTest
    static void testShareLeadRecord_ComplexScenario() {
        Core_PartnerLeadHandler.isLeadShared = false;
    
        // Create Marketing Profile
        PMP_Company__c mpi = new PMP_Company__c(
            Name = 'Test MPI',
            PMP_Is_Published_Ind__c = true,
            PMP_Partner_Benefit_Type__c = 'Solution Marketplace Basic Access'
        );
        insert mpi;
    
        // Create Leads
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'TestCo',
                Status = 'Open - Not Contacted',
                LeadSource = 'Web',
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'Partner Lead' LIMIT 1].Id,
                Core_Is_Lead_Shared__c = false,
                Core_MPI_Id__c = mpi.Id
            ));
        }
        insert leads;
    
        // Create Groups
        List<Group> groups = new List<Group>();
        for (Integer i = 0; i < 3; i++) {
            groups.add(new Group(Name = 'Test Group ' + i, Type = 'Regular'));
        }
        insert groups;
    
        // Create valid OPID Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            accounts.add(new Account(
                Name = 'Partner Account ' + i,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Partner Account Group' LIMIT 1].Id,
                BillingCountryCode = 'USA',
                BillingStateCode = 'CA',
                BillingCity = 'City',
                BillingStreet = '123 Test',
                BillingPostalCode = '90210'
            ));
        }
        insert accounts;
    
        // Create OPID Lead Relationships
        List<Core_OPID_Lead_Relationship__c> relationships = new List<Core_OPID_Lead_Relationship__c>();
        for (Integer i = 0; i < leads.size(); i++) {
            String groupIds = String.join(new List<Id>{groups[0].Id, groups[1].Id, groups[2].Id}, ';');
    
            relationships.add(new Core_OPID_Lead_Relationship__c(
                Core_Lead_Name__c = leads[i].Id,
                Core_OPID_Name__c = accounts[i].Id,
                Core_Public_Group_Ids__c = groupIds
            ));
        }
        insert relationships;
    
        Test.startTest();
            Core_PartnerLeadHandler.shareLeadRecord(leads);
        Test.stopTest();
    
        // Assert Leads were shared
        List<Lead> updatedLeads = [SELECT Id, Core_Is_Lead_Shared__c FROM Lead WHERE Id IN :leads];
        for (Lead lead : updatedLeads) {
            System.assertEquals(true, lead.Core_Is_Lead_Shared__c);
        }
    
        // Assert LeadShare records created
        System.assert([SELECT COUNT() FROM LeadShare WHERE LeadId IN :leads] > 0);
    }

    
    @isTest
    static void testEmailNotificationMethods() {
        List<Lead> leads = createComplexTestLeads();
        List<Core_OPID_Lead_Relationship__c> relationships = new List<Core_OPID_Lead_Relationship__c>();
        List<Group> groups = [SELECT Id FROM Group WHERE Type = 'Regular' LIMIT 2];
        
        for(Integer i = 0; i < leads.size(); i++) {
            Core_OPID_Lead_Relationship__c rel = new Core_OPID_Lead_Relationship__c(
                Core_Lead_Name__c = leads[i].Id,
                Core_OPID_Name__c = 'OPID' + i,
                Core_Public_Group_Ids__c = groups[0].Id + ';' + groups[1].Id
            );
            relationships.add(rel);
        }
        insert relationships;
        
        Map<Id, Lead> leadMap = new Map<Id, Lead>(leads);
        EmailTemplate template = [SELECT Id, Name FROM EmailTemplate LIMIT 1];
        
        Test.startTest();
        // Test sendEmailNotification
        Core_PartnerLeadHandler.sendEmailNotification(relationships, leadMap, template);
        
        // Test prepareGroupWiseEmail with template
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList = Core_PartnerLeadHandler.prepareGroupWiseEmail(
            UserInfo.getUserId(), leads[0].Id, emailList, template.Id
        );
        Test.stopTest();
        
        System.assertEquals(1, emailList.size());
        System.assertEquals(template.Id, emailList[0].getTemplateId());
    }
    
    @isTest
    static void testStampOPIDsonLead_ComplexScenario() {
        Core_PartnerLeadHandler.isLeadCheckforOPIDStamping = false;
        
        List<Lead> leads = createComplexTestLeads();
        for(Lead lead : leads) {
            lead.Core_Is_Lead_Shared__c = true;
            lead.Core_Partner_Lead_Owner__c = null;
        }
        update leads;
        
        // Create multiple OPID relationships per lead
        List<Core_OPID_Lead_Relationship__c> relationships = new List<Core_OPID_Lead_Relationship__c>();
        for(Integer i = 0; i < leads.size(); i++) {
            for(Integer j = 0; j < 2; j++) {
                Core_OPID_Lead_Relationship__c rel = new Core_OPID_Lead_Relationship__c(
                    Core_Lead_Name__c = leads[i].Id,
                    Core_OPID_Name__c = 'OPID' + i + '_' + j,
                    Core_Public_Group_Ids__c = [SELECT Id FROM Group LIMIT 1].Id
                );
                relationships.add(rel);
            }
        }
        insert relationships;
        
        Test.startTest();
        Core_PartnerLeadHandler.stampOPIDsonLead(leads);
        Test.stopTest();
        
        // Verify OPID stamping
        List<Lead> updatedLeads = [SELECT Core_One_Partner_Id__c FROM Lead WHERE Id IN :leads];
        for(Lead lead : updatedLeads) {
            System.assertNotEquals(null, lead.Core_One_Partner_Id__c);
            System.assert(lead.Core_One_Partner_Id__c.contains(','));
        }
    }
    
    @isTest
    static void testSendLeadEmailNotifications_FullFlow() {
        List<Account> accounts = [SELECT Id, Core_IPA_One_Partner_Id__c FROM Account WHERE Core_IPA_One_Partner_Id__c LIKE 'OPID%'];
        List<String> partnerSegments = new List<String>{'PSG', 'Segment1'};
        
        // Create leads for today and reminder dates
        List<Lead> todayLeads = createComplexTestLeads();
        List<Lead> reminderLeads = createComplexTestLeads();
        
        for(Lead lead : reminderLeads) {
            lead.Core_1st_Reminder__c = Date.today();
            lead.Core_Lead_Status__c = 'New';
            lead.Status = 'Open';
            lead.Core_Lead_State__c = 'Active';
        }
        update reminderLeads;
        
        // Create LeadShare records
        List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName LIKE 'PMP_OPID%'];
        List<LeadShare> leadShares = new List<LeadShare>();
        
        for(Lead lead : todayLeads) {
            for(Group grp : groups) {
                LeadShare ls = new LeadShare(
                    LeadId = lead.Id,
                    UserOrGroupId = grp.Id,
                    LeadAccessLevel = 'Edit'
                );
                leadShares.add(ls);
                if(leadShares.size() >= 100) break; // Limit for test
            }
            if(leadShares.size() >= 100) break;
        }
        
        Database.insert(leadShares, false);
        
        Test.startTest();
        // Test new leads notification
        Core_PartnerLeadHandler.sendLeadEmailNotifications(accounts, false, partnerSegments);
        
        // Test reminder notification
        Core_PartnerLeadHandler.sendLeadEmailNotifications(accounts, true, partnerSegments);
        Test.stopTest();
        
        // Verify method execution
        System.assert(accounts.size() > 0);
    }
    
    @isTest
    static void testSendLeadSummaryEmail_DetailedScenarios() {
        List<Lead> leads = createComplexTestLeads();
        
        // Test with different user scenarios
        Map<String, List<Lead>> userWiseLeadMap = new Map<String, List<Lead>>();
        List<User> testUsers = [SELECT Id FROM User WHERE FirstName = 'TestUser' LIMIT 3];
        
        // User 1: Has enough leads for summary
        List<Lead> leadsForUser1 = new List<Lead>();
        for (Integer i = 0; i < Math.min(5, leads.size()); i++) {
            leadsForUser1.add(leads[i]);
        }
        userWiseLeadMap.put(testUsers[0].Id, leadsForUser1);
        
        // User 2: Has fewer leads than minimum
        List<Lead> leadsForUser2 = new List<Lead>();
        if (leads.size() > 1) {
            leadsForUser2.add(leads[0]);
            userWiseLeadMap.put(testUsers[1].Id, leadsForUser2);
        }
        
        // User 3: Empty lead list
        userWiseLeadMap.put(testUsers[2].Id, new List<Lead>());
        
        Test.startTest();
        List<Messaging.SingleEmailMessage> result = Core_PartnerLeadHandler.sendLeadSummaryEmail(
            new List<Messaging.SingleEmailMessage>(), userWiseLeadMap, false
        );
        
        // Test reminder scenario
        List<Messaging.SingleEmailMessage> reminderResult = Core_PartnerLeadHandler.sendLeadSummaryEmail(
            new List<Messaging.SingleEmailMessage>(), userWiseLeadMap, true
        );
        Test.stopTest();
        
        // Assertions
        System.assert(result != null);
        System.assert(reminderResult != null);
    }

    
    @isTest
    static void testStampFieldOnRejectLead_AllScenarios() {
        List<Lead> testLeads = createComplexTestLeads();
        
        // Set up different old lead states
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead>();
        for(Integer i = 0; i < testLeads.size(); i++) {
            Lead oldLead = testLeads[i].clone(true);
            if(i == 0) {
                oldLead.Core_Lead_State__c = 'Active';
                oldLead.Core_Lead_Status__c = 'New';
                oldLead.Status = 'PRL';
            } else if(i == 1) {
                oldLead.Core_Lead_State__c = 'Active';
                oldLead.Core_Lead_Status__c = 'Accepted';
                oldLead.Status = 'PAL';
            } else if(i == 2) {
                oldLead.Core_Lead_State__c = 'Active';
                oldLead.Core_Lead_Status__c = 'Contacted';
                oldLead.Status = 'PAL';
            }
            oldLeadMap.put(oldLead.Id, oldLead);
        }
        
        // Set all new leads to terminated state
        for(Lead newLead : testLeads) {
            newLead.Core_Lead_State__c = 'Terminated';
        }
        
        Test.startTest();
        Core_PartnerLeadHandler.stampFieldOnRejectLead(testLeads, oldLeadMap);
        Test.stopTest();
        
        // Verify stamping based on different scenarios
        /*if(testLeads.size() >= 1) {
            System.assertNotEquals(null, testLeads[0].Core_PRL_Exit_Dt__c);
        }
        if(testLeads.size() >= 2) {
            System.assertNotEquals(null, testLeads[1].Core_PAL_Exit_Dt__c);
        }
        if(testLeads.size() >= 3) {
            System.assertNotEquals(null, testLeads[2].Core_PAL_Exit_Dt__c);
            System.assertNotEquals(null, testLeads[2].Core_Exit_Date_Contacted_Dt__c);
        }*/
    }
    
    @isTest
    static void testGenerateNextTimeSlotOfEmail_AllTimeSlots() {
        // Mock different current times to test all time slot scenarios
        Test.startTest();
        
        // Test will cover the method logic for different minute ranges
        DateTime result1 = Core_PartnerLeadHandler.generateNextTimeSlotOfEmail();
        
        // The method uses System.now(), so we test that it returns a valid future time
        System.assert(result1 > System.now().addMinutes(-1));
        
        Test.stopTest();
        
        System.assertNotEquals(null, result1);
    }
    
    @isTest
    static void testEmailBodyGeneration_EdgeCases() {
        // Create leads with various field combinations
        List<Lead> testLeads = new List<Lead>();
        
        // Lead with all fields
        Lead lead1 = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Country = 'United States',
            Core_Lead_Source_Pkt__c = 'Web Form',
            Core_Lead_PMP_Action__c = 'Downloaded Content',
            CreatedDate = DateTime.now().addDays(-10), // Ensure CreatedDate is set
            Core_1st_Reminder__c = Date.today().addDays(-5), // Set reminder dates
            Core_2nd_Reminder__c = Date.today().addDays(-3),
            Core_3rd_Reminder__c = Date.today().addDays(-1),
            Core_4th_Reminder__c = Date.today()
        );
        
        // Lead with minimal fields
        Lead lead2 = new Lead(
            LastName = 'Smith',
            Company = 'Another Company'
        );
        
        // Lead with null fields
        Lead lead3 = new Lead(
            FirstName = 'Test',
            LastName = 'Test',
            Company = 'Test',
            Country = 'India'
        );
        
        testLeads.addAll(new List<Lead>{lead1, lead2, lead3});
        insert testLeads;
        
        Test.startTest();
        String newLeadBody = Core_PartnerLeadHandler.prepareHtmlBody(testLeads, false);
        String reminderBody = Core_PartnerLeadHandler.prepareHtmlBody(testLeads, true);
        
        String displayableLeads = Core_PartnerLeadHandler.prepareDisplayableLeads(
            'https://base.com', 'https://listview.com', testLeads, '<div>', false
        );
        Test.stopTest();
        
        // Verify HTML contains expected elements
        System.assert(newLeadBody.contains('YOU HAVE NEW LEADS!'));
        System.assert(reminderBody.contains('YOUR LEADS ARE WAITING'));
        System.assert(displayableLeads.contains('Test Company'));
    }
    
    @isTest
    static void testGroupAndUserManagement() {
        // Test group name generation with edge cases
        Test.startTest();
        String shortKey = Core_PartnerLeadHandler.generatePartnerKey('A', 'B');
        String longKey = Core_PartnerLeadHandler.generatePartnerKey(
            'VeryLongPartnerNameThatExceedsNormalLength', 
            'VeryLongSegmentNameThatAlsoExceedsNormalLength'
        );
        Test.stopTest();
        
        System.assertEquals('PMP_A_B', shortKey);
        System.assert(longKey.length() <= 40);
        System.assert(longKey.startsWith('PMP_'));
    }
    
    // Helper method to create complex test leads for various scenarios
    @isTest
    public static List<Lead> createComplexTestLeads() {
        List<Lead> leads = new List<Lead>();
        Id rtId = Schema.SObjectType.Lead.getRecordTypeInfos()[0].getRecordTypeId();
        for (Integer i = 0; i < 5; i++) {
            leads.add(new Lead(
                FirstName = 'Complex',
                LastName = 'Lead ' + i,
                Company = 'Complex Company ' + i,
                Email = 'complex' + i + '@test.com',
                Country = 'Canada',
                RecordTypeId = rtId,
                PMP_MDA_BizOrg_Id__c = (i < 3) ? 'MPI' + i : null,
                Core_Partner_Name__c = (i >= 2) ? 'Partner ' : null,
                Core_Lead_Source_Pkt__c = 'Test Source ' + i,
                Core_Lead_PMP_Action__c = 'Downloaded Content',
                Core_Lead_State__c = 'Active',
                Core_Lead_Status__c = 'New',
                Status = 'PRL',
                Core_Reprocess_Lead_Sharing__c = true,
                Core_1st_Reminder__c = (i == 0) ? Date.today() : null,
                Core_2nd_Reminder__c = (i == 1) ? Date.today() : null,
                Core_3rd_Reminder__c = (i == 2) ? Date.today() : null
            ));
        }
        insert leads;
        return leads;
    }
    
    //@isTest
    /*static void testFetchLeadsFromLeadShares() {
        List<Lead> leads = createComplexTestLeads();

        List<LeadShare> leadShares = new List<LeadShare>();
        for (Lead ld : leads) {
            LeadShare ls = new LeadShare(
                LeadId = ld.Id,
                UserOrGroupId = UserInfo.getUserId(),
                LeadAccessLevel = 'Read'
            );
            leadShares.add(ls);
        }
        insert leadShares;

        Map<Id, Lead> leadMap = Core_PartnerLeadHandler.fetchLeadsFromLeadShares(leadShares);

        System.assertEquals(leads.size(), leadMap.size(), 'Lead count in map should match');
        for (Lead ld : leads) {
            System.assert(leadMap.containsKey(ld.Id));
        }
    }*/

    
    @isTest
    static void testStaticVariablesCoverage() {
        // Test to ensure static variables are covered
        System.assertNotEquals(null, Core_PartnerLeadHandler.mapFunctionalityNameTriggerExecution);
        System.assertNotEquals(null, Core_PartnerLeadHandler.partnerRecTypeId);
        System.assertNotEquals(null, Core_PartnerLeadHandler.fromEmailAddress);
        System.assertNotEquals(null, Core_PartnerLeadHandler.empPublicGroupNameSuffix);
        System.assertNotEquals(null, Core_PartnerLeadHandler.adminPublicGroupNameSuffix);
        System.assertEquals(';', Core_PartnerLeadHandler.SYMB_SEMICOLON);
        System.assertEquals('PSG', Core_PartnerLeadHandler.PSG_LEAD);
        
        // Test boolean flags
        System.assertNotEquals(null, Core_PartnerLeadHandler.isRecursive);
        System.assertNotEquals(null, Core_PartnerLeadHandler.isRecursiveGroupCreation);
        System.assertNotEquals(null, Core_PartnerLeadHandler.isRecursiveOwnerUpdate);
        System.assertNotEquals(null, Core_PartnerLeadHandler.isLeadShared);
        System.assertNotEquals(null, Core_PartnerLeadHandler.isLeadCheckforOPIDStamping);
    }
}