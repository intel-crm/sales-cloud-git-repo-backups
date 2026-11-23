/******************************************************************************************************************************************
Class Name  : Core_OpportunityTeamMemberHandler_Test
Version     : 1.0 
Created Date: May 19, 2015
Function    : Test class code for the trigger/class on OpportunityTeamMember
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Dave Hood         05/19/2015    Original version
*****************************************************************************************************************************************/
@isTest
public class Core_OpportunityTeamMemberHandler_Test {

    static final String OSC_DEPARTMENT = 'ONLINE SALES CENTER (OSC)';
    
    private class GeoFlags {
        Boolean bAPJ = false;
        Boolean bASMO = false;
        Boolean bEMEA = false;
        Boolean bPRC = false;
    }
    
    static List<User> createTestUserInGeo(Integer numUsers, Id profileId, String geo) {
        List<User> testUsers = new List<User>();
        for (Integer i=0; i<numUsers; i++) {
            User testUser = new User();
            testUser.Firstname = 'test';
            testUser.LastName = 'user ' + geo + i;
            testUser.UserName = 'testuser.' + geo + i + '@intel.com.crm';
            testUser.Email = 'testuser.' + geo + i + '@intel.com';
            testUser.Alias = geo + i;
            testUser.CommunityNickName = 'test.' + geo + i;
            testUser.ProfileId = profileId;
            testUser.LANGUAGELOCALEKEY = 'en_US';
            testUser.LOCALESIDKEY = 'en_US';
            testUser.TIMEZONESIDKEY = 'America/Los_Angeles';
            testUser.EMAILENCODINGKEY = 'ISO-8859-1';
            testUser.Core_User_Geo__c = geo;
            testUsers.add(testUser);
        }
        return testUsers;
    }
    
    static GeoFlags getGeoFlags(Id oppId) {
        GeoFlags oppGeoFlags = new GeoFlags();
        Opportunity opp = [select Core_Opportunity_Team_Geo_APJ__c, Core_Opportunity_Team_Geo_ASMO__c,
                           Core_Opportunity_Team_Geo_EMEA__c, Core_Opportunity_Team_Geo_PRC__c from Opportunity
                           where Id = :oppId limit 1][0];
        oppGeoFlags.bAPJ = opp.Core_Opportunity_Team_Geo_APJ__c;
        oppGeoFlags.bASMO = opp.Core_Opportunity_Team_Geo_ASMO__c;
        oppGeoFlags.bEMEA = opp.Core_Opportunity_Team_Geo_EMEA__c;
        oppGeoFlags.bPRC = opp.Core_Opportunity_Team_Geo_PRC__c;
        return oppGeoFlags;
    }

    static testMethod void testOpportunityWithNoTeamMemberUpdateGeoFlags() {
        
        // First, enable the trigger we're trying to test
        Core_Trigger_Executions__c opportunityTeamMemberHandler = new Core_Trigger_Executions__c();
        opportunityTeamMemberHandler.name = 'opportunityTeamMemberHandler';
        opportunityTeamMemberHandler.Core_Object__c = 'OpportunityTeamMember';
        opportunityTeamMemberHandler.Core_Active__c = TRUE;
        opportunityTeamMemberHandler.Core_Trigger_Events__c = 'After insert, after update, after delete';
        opportunityTeamMemberHandler.Core_Description__c = 'This is test description';
        opportunityTeamMemberHandler.Core_Class_Name__c = 'Test Class';
        insert opportunityTeamMemberHandler;
        
        // Get the profile we'll use for our test users
        Id profileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;
        
        // Test users
        User runAsUser = createTestUserInGeo(1, profileId, '')[0];
        List<User> apjUsers = createTestUserInGeo(150, profileId, 'APJ');
        List<User> asmoUsers = createTestUserInGeo(6, profileId, 'ASMO');
        List<User> emeaUsers = createTestUserInGeo(1, profileId, 'EMEA');
        List<User> prcUsers = createTestUserInGeo(55, profileId, 'PRC');
        
        insert runAsUser;
        insert apjUsers;
        insert asmoUsers;
        insert emeaUsers;
        insert prcUsers;
        
        // Create a few opportunities:
        // Oppty 1: no team members, so should have no flags set

        List<Opportunity> testOpps = Core_Test_Utility.createOpportunity(3);
        
        System.runAs(runAsUser) {
            insert testOpps;
        }
        System.Debug('Opportunity print :' + testOpps);
        test.startTest();

        // First make sure the opportunities with no team members have false checkboxes
        GeoFlags postUpdateFlags = getGeoFlags(testOpps[0].Id);
        System.Debug('GeoFlags print 0 : ' + postUpdateFlags);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.Debug('GeoFlags print 1 : ' + postUpdateFlags);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[2].Id);
        System.Debug('GeoFlags print 1 : ' + postUpdateFlags);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        test.stopTest();        
    }
    
    static testMethod void testOppWithAPJAndEMEATMUpdateGeoFlags() {
        
        // First, enable the trigger we're trying to test
        Core_Trigger_Executions__c opportunityTeamMemberHandler = new Core_Trigger_Executions__c();
        opportunityTeamMemberHandler.name = 'opportunityTeamMemberHandler';
        opportunityTeamMemberHandler.Core_Object__c = 'OpportunityTeamMember';
        opportunityTeamMemberHandler.Core_Active__c = TRUE;
        opportunityTeamMemberHandler.Core_Trigger_Events__c = 'After insert, after update, after delete';
        opportunityTeamMemberHandler.Core_Description__c = 'This is test description';
        opportunityTeamMemberHandler.Core_Class_Name__c = 'Test Class';
        insert opportunityTeamMemberHandler;
        
        // Get the profile we'll use for our test users
        Id profileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;
        
        // Test users
        User runAsUser = createTestUserInGeo(1, profileId, '')[0];
        List<User> apjUsers = createTestUserInGeo(150, profileId, 'APJ');
        List<User> asmoUsers = createTestUserInGeo(6, profileId, 'ASMO');
        List<User> emeaUsers = createTestUserInGeo(1, profileId, 'EMEA');
        List<User> prcUsers = createTestUserInGeo(55, profileId, 'PRC');
        
        insert runAsUser;
        insert apjUsers;
        insert asmoUsers;
        insert emeaUsers;
        insert prcUsers;
        
       
        // Oppty 2: 50 APJ team members, 1 EMEA team member, so should have APJ + EMEA set
        //          ...then make sure we can insert 100 APJ and 5 ASMO team members and have APJ + EMEA + ASMO set
        //          ...then make sure we can update 150 APJ members and still have flags set
        //          ...then make sure we can delete 100 APJ members and still have flags set
        //          ...then make sure we can delete the remaining 50 APJ and 5 ASMO and just have EMEA set
        
        List<Opportunity> testOpps = Core_Test_Utility.createOpportunity(3);
        
        System.runAs(runAsUser) {
            insert testOpps;
        }
        System.Debug('Opportunity print :' + testOpps);
        test.startTest();

        List<OpportunityTeamMember> oppTMs = new List<OpportunityTeamMember>();
        
        // Oppty 2: 50 APJ team members, 1 EMEA team member, so should have APJ + EMEA set

        for (Integer i=0; i<50; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=apjUsers[i].Id, TeamMemberRole='Team Member'));
        }
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=emeaUsers[0].Id, TeamMemberRole='Team Member'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=asmoUsers[0].Id, TeamMemberRole='Team Member'));
        insert oppTMs;
        
        GeoFlags postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.AssertEquals(true, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(true, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[2].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(true, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        test.stopTest();        
    }
    
     static testMethod void testOppWithMultipleAPJAndEMEATMUpdateGeoFlags() {
        
        // First, enable the trigger we're trying to test
        Core_Trigger_Executions__c opportunityTeamMemberHandler = new Core_Trigger_Executions__c();
        opportunityTeamMemberHandler.name = 'opportunityTeamMemberHandler';
        opportunityTeamMemberHandler.Core_Object__c = 'OpportunityTeamMember';
        opportunityTeamMemberHandler.Core_Active__c = TRUE;
        opportunityTeamMemberHandler.Core_Trigger_Events__c = 'After insert, after update, after delete';
        opportunityTeamMemberHandler.Core_Description__c = 'This is test description';
        opportunityTeamMemberHandler.Core_Class_Name__c = 'Test Class';
        insert opportunityTeamMemberHandler;
        
        // Get the profile we'll use for our test users
        Id profileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;
        
        // Test users
        User runAsUser = createTestUserInGeo(1, profileId, '')[0];
        List<User> apjUsers = createTestUserInGeo(150, profileId, 'APJ');
        List<User> asmoUsers = createTestUserInGeo(6, profileId, 'ASMO');
        List<User> emeaUsers = createTestUserInGeo(1, profileId, 'EMEA');
        List<User> prcUsers = createTestUserInGeo(55, profileId, 'PRC');
        
        insert runAsUser;
        insert apjUsers;
        insert asmoUsers;
        insert emeaUsers;
        insert prcUsers;
        
        // Create a few opportunities:
        // 
        // Oppty 2: 50 APJ team members, 1 EMEA team member, so should have APJ + EMEA set
        //          ...then make sure we can insert 100 APJ and 5 ASMO team members and have APJ + EMEA + ASMO set
        //          ...then make sure we can update 150 APJ members and still have flags set
        //          ...then make sure we can delete 100 APJ members and still have flags set
        //          ...then make sure we can delete the remaining 50 APJ and 5 ASMO and just have EMEA set
        // Oppty 3: 1 ASMO team member, so should have ASMO set
        //          ...then make sure we can insert 55 PRC team members and have ASMO + PRC set
        //          ...then make sure we can update 55 PRC team members and have ASMO + PRC set
        //          ...then make sure we can delete 55 PRC team members and just have ASMO set
        // 
        // Inserts, updates, & deletes will be performed all at once to test batch processing
        // 
        List<Opportunity> testOpps = Core_Test_Utility.createOpportunity(3);
        
        System.runAs(runAsUser) {
            insert testOpps;
        }
        System.Debug('Opportunity print :' + testOpps);
        test.startTest();

        // First make sure the opportunities with no team members have false checkboxes
        GeoFlags postUpdateFlags = getGeoFlags(testOpps[0].Id);
        System.Debug('GeoFlags print 0 : ' + postUpdateFlags);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.Debug('GeoFlags print 1 : ' + postUpdateFlags);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[2].Id);
        System.Debug('GeoFlags print 1 : ' + postUpdateFlags);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        List<OpportunityTeamMember> oppTMs = new List<OpportunityTeamMember>();
        
        for (Integer i=0; i<50; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=apjUsers[i].Id, TeamMemberRole='Team Member'));
        }
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=emeaUsers[0].Id, TeamMemberRole='Team Member'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=asmoUsers[0].Id, TeamMemberRole='Team Member'));
        
        
       // Oppty 2: make sure we can insert 100 APJ and 5 ASMO team members and have APJ + EMEA + ASMO set
        // Oppty 3: make sure we can insert 55 PRC team members and have ASMO + PRC set
        for (Integer i=0; i<100; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=apjUsers[50+i].Id, TeamMemberRole='Team Member'));
        }
        for (Integer i=0; i<5; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=asmoUsers[1+i].Id, TeamMemberRole='Team Member'));
        }
        for (Integer i=0; i<55; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=prcUsers[i].Id, TeamMemberRole='Team Member'));
        }
        insert oppTMs;
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.Debug('GeoFlags print 11 : ' + postUpdateFlags);
        System.AssertEquals(true, postUpdateFlags.bAPJ);
        System.AssertEquals(true, postUpdateFlags.bASMO);
        System.AssertEquals(true, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[2].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(true, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(true, postUpdateFlags.bPRC);
        
        // Oppty 2: make sure we can update 150 APJ members and still have flags set
        // Oppty 3: make sure we can update 55 PRC team members and have ASMO + PRC set
        List<OpportunityTeamMember> preUpdateOppTMs = [select Id, TeamMemberRole from OpportunityTeamMember
                                                       where Id = :testOpps[1].Id or Id = :testOpps[2].Id];
        for (OpportunityTeamMember oppTM : preUpdateOppTMs) {
            oppTM.TeamMemberRole = 'Technical Owner';
        }
        update preUpdateOppTMs;
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.AssertEquals(true, postUpdateFlags.bAPJ);
        System.AssertEquals(true, postUpdateFlags.bASMO);
        System.AssertEquals(true, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[2].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(true, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(true, postUpdateFlags.bPRC);
        
        // Oppty 2: make sure we can delete 100 APJ members and still have flags set
        // Oppty 3: make sure we can delete 55 PRC team members and just have ASMO set
        preUpdateOppTMs = [select Id from OpportunityTeamMember
                           where OpportunityId = :testOpps[1].Id and User.Core_User_Geo__c = 'APJ' limit 100];
        delete preUpdateOppTMs;
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.AssertEquals(true, postUpdateFlags.bAPJ);
        System.AssertEquals(true, postUpdateFlags.bASMO);
        System.AssertEquals(true, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        

        test.stopTest();        
    }
    
    
    static testMethod void testUpdateOSCType() {
        
        // First, enable the trigger we're trying to test
        Core_Trigger_Executions__c opportunityTeamMemberHandler = new Core_Trigger_Executions__c();
        opportunityTeamMemberHandler.name                       = 'opportunityTeamMemberHandler';
        opportunityTeamMemberHandler.Core_Object__c             = 'OpportunityTeamMember';
        opportunityTeamMemberHandler.Core_Active__c             = TRUE;
        opportunityTeamMemberHandler.Core_Trigger_Events__c     = 'After insert, after update, after delete';
        opportunityTeamMemberHandler.Core_Description__c        = 'This is test description';
        opportunityTeamMemberHandler.Core_Class_Name__c         = 'Test Class';
        insert opportunityTeamMemberHandler;
        
        List<User> users = Core_Test_Utility.Core_User(6);

        User oscUser       = users[0];
        oscUser.Department = OSC_DEPARTMENT;
        insert oscUser;
        
        User nonOSCUser       = users[1];
        nonOSCUser.Department = '';        
        insert nonOSCUser;

        User oscTm       = users[2];
        oscTm.Department = OSC_DEPARTMENT;
        insert oscTm;
        
        User nonOSCTm       = users[3];
        nonOSCTm.Department = '';        
        insert nonOSCTm;

        User oscTo       = users[4];
        oscTo.Department = OSC_DEPARTMENT;
        insert oscTo;
        
        User nonOSCTo       = users[5];
        nonOSCTo.Department = '';        
        insert nonOSCTo;

                        
        List<Opportunity> testOpps = Core_Test_Utility.createOpportunity(8);

        // OSC Opps
        testOpps[0].Core_Technical_Owner__c = oscTo.Id;     // Owner=OSC,     Tech Owner='OSC',     Team='OSC'        
        testOpps[1].Core_Technical_Owner__c = nonOSCTo.Id;    // Owner=OSC,     Tech Owner='NON-OSC', Team='OSC'       
        testOpps[2].Core_Technical_Owner__c = oscTo.Id;     // Owner=OSC,     Tech Owner='OSC',     Team='NON-OSC'       
        testOpps[3].Core_Technical_Owner__c = nonOSCTo.Id;       // Owner=OSC,     Tech Owner='NON-OSC', Team='NON-OSC'  

        // NON OSC Opps
        testOpps[4].Core_Technical_Owner__c = nonOSCTo.Id;  // Owner=NON-OSC, Tech Owner='NON-OSC', Team='NON-OSC'       
        testOpps[5].Core_Technical_Owner__c = oscTo.Id;     // Owner=NON-OSC, Tech Owner='OSC',     Team='NON-OSC'       
        testOpps[6].Core_Technical_Owner__c = nonOSCTo.Id;    // Owner=NON-OSC, Tech Owner='NON-OSC', Team='OSC'       
        testOpps[7].Core_Technical_Owner__c = oscTo.Id;    // Owner=NON-OSC, Tech Owner='OSC', Team='OSC'       

        System.runAs(oscUser) {
            insert testOpps[0];
           insert testOpps[1];
           insert testOpps[2];
           insert testOpps[3];
        }

    System.runAs(nonOSCUser) {
        insert testOpps[4];
        insert testOpps[5];
        insert testOpps[6];
        insert testOpps[7];
        }

        test.startTest();

        List<OpportunityTeamMember> oppTMs = new List<OpportunityTeamMember>();
        
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[0].Id, UserId=oscUser.Id, Core_OSC_Snapshot__c = 1,     TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[0].Id, UserId=oscTo.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Technical Owner (100%)'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[0].Id, UserId=oscTm.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Team Member (100%)'));

        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=oscUser.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=nonOscTo.Id,Core_OSC_Snapshot__c = 0,     TeamMemberRole='Technical Owner (100%)'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=oscTm.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Team Member (100%)'));

        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=oscUser.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=oscTo.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Technical Owner (100%)'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=nonOSCTm.Id,Core_OSC_Snapshot__c = 0,  TeamMemberRole='Team Member (100%)'));

        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[3].Id, UserId=oscUser.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[3].Id, UserId=nonOscTo.Id,Core_OSC_Snapshot__c = 0,     TeamMemberRole='Technical Owner (100%)'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[3].Id, UserId=nonOSCTm.Id,Core_OSC_Snapshot__c = 0,  TeamMemberRole='Team Member (100%)'));

        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[4].Id, UserId=nonOscUser.Id,Core_OSC_Snapshot__c = 0,     TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[4].Id, UserId=nonOscTo.Id,Core_OSC_Snapshot__c = 0,     TeamMemberRole='Technical Owner (100%)'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[4].Id, UserId=nonOSCTm.Id,Core_OSC_Snapshot__c = 0,  TeamMemberRole='Team Member (100%)'));

        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[5].Id, UserId=nonOscUser.Id,Core_OSC_Snapshot__c = 0,     TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[5].Id, UserId=oscTo.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Technical Owner (100%)'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[5].Id, UserId=nonOSCTm.Id,Core_OSC_Snapshot__c = 0,  TeamMemberRole='Team Member (100%)'));

        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[6].Id, UserId=nonOscUser.Id,Core_OSC_Snapshot__c = 0,     TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[6].Id, UserId=nonOscTo.Id,Core_OSC_Snapshot__c = 0,     TeamMemberRole='Technical Owner (100%)'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[6].Id, UserId=oscTm.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Team Member (100%)'));
        
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[7].Id, UserId=nonOscUser.Id,Core_OSC_Snapshot__c = 0,     TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[7].Id, UserId=oscTo.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Technical Owner (100%)'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[7].Id, UserId=oscTm.Id,Core_OSC_Snapshot__c = 1,     TeamMemberRole='Team Member (100%)'));

        System.debug('#92 oppTMs.size(): ' + oppTMs.size() + '  ' + oppTms);        
        insert oppTMs;
        
        Set <Id> oppIds = new Set<Id>();
        for (OpportunityTeamMember oppMbr : oppTMs)
            oppIds.add(oppMbr.Id);        
                        
        List<OpportunityTeamMember> preUpdateOppTMs = [SELECT Id 
                                                       FROM OpportunityTeamMember
                                                       WHERE OpportunityId IN :oppIds];
                           
        delete preUpdateOppTMs;
        
        test.stopTest();        
    }




    static testMethod void testUpdateOSCType_II() {
        
        // First, enable the trigger we're trying to test
        Core_Trigger_Executions__c opportunityTeamMemberHandler = new Core_Trigger_Executions__c();
        opportunityTeamMemberHandler.name                       = 'opportunityTeamMemberHandler';
        opportunityTeamMemberHandler.Core_Object__c             = 'OpportunityTeamMember';
        opportunityTeamMemberHandler.Core_Active__c             = TRUE;
        opportunityTeamMemberHandler.Core_Trigger_Events__c     = 'After insert, after update, after delete';
        opportunityTeamMemberHandler.Core_Description__c        = 'This is test description';
        opportunityTeamMemberHandler.Core_Class_Name__c         = 'Test Class';
        insert opportunityTeamMemberHandler;

        test.startTest();

        Core_OpportunityTeamMemberHandler.updateOSCType(NULL);
        
        test.stopTest();        
    }
    
}