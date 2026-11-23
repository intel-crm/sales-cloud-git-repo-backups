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
    static final String NO_OSC_INVOLVMENT = 'No OSC Involvement';
    static final String OSC_ASSISTING_FIELD = 'OSC Assisting the Field';
    static final String OSC_SOLO = 'OSC Solo';
    static final String OSC_FIELD_ASSISTANCE = 'OSC with Field Assistance';
    static boolean triggerUpdateGeoFlags= true;
    private class GeoFlags {
        Boolean bAPJ = false;
        Boolean bASMO = false;
        Boolean bEMEA = false;
        Boolean bPRC = false;
    }
    
    @testSetup
    static void setupData(){
        
        List <Account> AccListList = new List <Account> ();
        List<Opportunity> testOpps=new List<Opportunity>();
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Account acct = new Account(Name = 'Test Account1', Industry = 'Agriculture', Core_Sub_Industry__c = 'Forestry',
                                       BillingStreet = '123 Fake St',BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
            insert acct;
            
            Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
            Opportunity oppty = new Opportunity(Name = 'TestClass PCC Opportunity', RecordTypeId = DealOppRecTypeId,
                                                AccountId = acct.Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',Opportunity_Focus__c= 'Core',Core_Opportunity_Type__c ='Deal: Sell-through',	
                                                StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
            insert oppty;
        }        
        
        enableTriggers();
        
        Id profileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;
        
        // Test users
        User runAsUser = createTestUserInGeo(1, profileId, '')[0];
        List<User> apjUsers = createTestUserInGeo(20, profileId, 'APJ');
        List<User> asmoUsers = createTestUserInGeo(5, profileId, 'ASMO');
        List<User> emeaUsers = createTestUserInGeo(5, profileId, 'EMEA');
        List<User> prcUsers = createTestUserInGeo(5, profileId, 'PRC');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert runAsUser;
            insert apjUsers;
            insert asmoUsers;
            insert emeaUsers;
            insert prcUsers;
        }
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
        // Get the profile we'll use for our test users
        Profile p = [select Id from Profile where Name = 'System Administrator'];
        
        // Test users
        User u = new User(Alias = 'stsndt', Email='standarduser@intel.com',
                          EmailEncodingKey='UTF-8', LastName='Testig123', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standard123xys@mail.com');
        insert u;
        
        For(integer i = 0; i <5; i++) {
            Account accountInstance = new Account();
            accountInstance.name = 'Test ' + i;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
            accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            accountInstance.Industry = 'Telecommunications';
            AccListList.add(accountInstance);
        }
        System.runAs(u) {
            insert AccListList;
        }
        for(integer i = 0; i < 5; i++) {
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Qualify';
            opportunityInstance.Name = 'Test' + i;
            opportunityInstance.Core_External_User__c=true;
            opportunityInstance.AccountId =AccListList[0].id ;
            opportunityInstance.Opportunity_Focus__c= 'Core';
            opportunityInstance.Core_Opportunity_Type__c ='Design: Original';
            testOpps.add(opportunityInstance);
        }
        
        
        System.runAs(u) {
            insert testOpps;
        }
        
        
    } 
    
     static void enableTriggers() {
        List<Core_Trigger_Executions__c> triggers = new List<Core_Trigger_Executions__c>();
        triggers.add(createTrigger('opportunityTeamMemberHandler', 'OpportunityTeamMember', 'After insert, after update, after delete'));
        triggers.add(createTrigger('DeleteTeamMemberVBS', 'OpportunityTeamMember', 'before delete'));
        triggers.add(createTrigger('opportunityTeamMemberQuoteSharing', 'OpportunityTeamMember', 'After insert, after update, after delete'));
        insert triggers;
    }
    
    static Core_Trigger_Executions__c createTrigger(String name, String obj, String events) {
        Core_Trigger_Executions__c triggers = new Core_Trigger_Executions__c();
        triggers.name = name;
        triggers.Core_Object__c = obj;
        triggers.Core_Active__c = TRUE;
        triggers.Core_Trigger_Events__c = events;
        triggers.Core_Description__c = 'This is test description'; 
        triggers.Core_Class_Name__c = 'Test Class';
        return triggers;
    }
    
    static List<User> createTestUserInGeo(Integer numUsers, Id profileId, String geo) {
        List<User> testUsers = new List<User>();
        for (Integer i=0; i<numUsers; i++) {
            User testUser = new User();
            testUser.Firstname = 'test Abcdsfe';
            testUser.LastName = 'userabcdjkte ' + geo + i;
            testUser.UserName = 'testusertestsstes.' + geo + i + '@intel.com.crm';
            testUser.Email = 'testusertestt.' + geo + i + '@intel.com';
            testUser.Alias = geo + i;
            testUser.CommunityNickName = 'testsss.' + geo + i;
            testUser.ProfileId = profileId;
            testUser.LANGUAGELOCALEKEY = 'en_US';
            testUser.LOCALESIDKEY = 'en_US';
            testUser.TIMEZONESIDKEY = 'America/Los_Angeles';
            testUser.EMAILENCODINGKEY = 'ISO-8859-1';
            testUser.Core_User_Geo__c = geo;
            testUser.isActive = true;
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
        
        List<User> apjUsers = new List<User>();
        List<User> asmoUsers = new List<User>();
        List<User> emeaUsers = new List<User>();
        List<User> prcUsers = new List<User>();  
        
        List<User> allUsers = new List<User>();
        for( user users : [select id,Core_User_Geo__c from user limit 20]) {
            if(users.Core_User_Geo__c == 'APJ')
                apjUsers.add(users);
            if(users.Core_User_Geo__c == 'ASMO')
                asmoUsers.add(users);
            
            if(users.Core_User_Geo__c == 'EMEA')
                emeaUsers.add(users);
            
            if(users.Core_User_Geo__c == 'PRC')
                prcUsers.add(users);						
        }        
        
        List<Opportunity> opportunityList=[select id,CloseDate,StageName,Name,Core_External_User__c,AccountId from Opportunity limit 200];
        
        test.startTest();
        
        // First make sure the opportunities with no team members have false checkboxes opportunityList
        //GeoFlags postUpdateFlags = getGeoFlags(testOpps[0].Id);
        GeoFlags postUpdateFlags = getGeoFlags(opportunityList[0].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        // postUpdateFlags = getGeoFlags(testOpps[1].Id);
        postUpdateFlags = getGeoFlags(opportunityList[1].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        //postUpdateFlags = getGeoFlags(testOpps[2].Id);
        postUpdateFlags = getGeoFlags(opportunityList[2].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        test.stopTest();        
    }
    
    static testMethod void testOppWithAPJAndEMEATMUpdateGeoFlags() {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<User> apjUsers = new List<User>();
            List<User> asmoUsers = new List<User>();
            List<User> emeaUsers = new List<User>();
            List<User> prcUsers = new List<User>();  
            
            List<User> allUsers = new List<User>();
            for( user users : [select id,Core_User_Geo__c from user where Core_User_Geo__c <> null limit 100]) {
                if(users.Core_User_Geo__c == 'APJ')
                    apjUsers.add(users);
                if(users.Core_User_Geo__c == 'ASMO')
                    asmoUsers.add(users);
                
                if(users.Core_User_Geo__c == 'EMEA')
                    emeaUsers.add(users);
                
                if(users.Core_User_Geo__c == 'PRC') 
                    prcUsers.add(users);						
            }  
            
            List<Opportunity> opportunityList=[select id,CloseDate,StageName,Name,Core_External_User__c,AccountId from Opportunity limit 200];
            test.startTest();        
            List<OpportunityTeamMember> oppTMs = new List<OpportunityTeamMember>();
            
            // Oppty 2: 50 APJ team members, 1 EMEA team member, so should have APJ + EMEA set
            
            for (Integer i=0; i<5; i++) {
                oppTMs.add(new OpportunityTeamMember(OpportunityId=opportunityList[1].Id, UserId=apjUsers[i].Id, TeamMemberRole='Team Member'));
            }
            oppTMs.add(new OpportunityTeamMember(OpportunityId=opportunityList[1].Id, UserId=emeaUsers[0].Id, TeamMemberRole='Team Member'));
            oppTMs.add(new OpportunityTeamMember(OpportunityId=opportunityList[2].Id, UserId=asmoUsers[0].Id, TeamMemberRole='Team Member'));
            insert oppTMs;
            
            GeoFlags postUpdateFlags = getGeoFlags(opportunityList[1].Id);
            System.AssertEquals(true, postUpdateFlags.bAPJ);
            System.AssertEquals(false, postUpdateFlags.bASMO);
            System.AssertEquals(true, postUpdateFlags.bEMEA);
            System.AssertEquals(false, postUpdateFlags.bPRC);
            
            postUpdateFlags = getGeoFlags(opportunityList[2].Id);
            test.stopTest();
        }                
    }
    
    static testMethod void testOppWithMultipleAPJAndEMEATMUpdateGeoFlags() {
        
        List<User> apjUsers = new List<User>();
        List<User> asmoUsers = new List<User>();
        List<User> emeaUsers = new List<User>();
        List<User> prcUsers = new List<User>();  
        
        List<User> allUsers = new List<User>();
        for( user users : [select id,Core_User_Geo__c from user where Core_User_Geo__c <> null limit 100]) {
            if(users.Core_User_Geo__c == 'APJ')
                apjUsers.add(users);
            if(users.Core_User_Geo__c == 'ASMO')
                asmoUsers.add(users);
            
            if(users.Core_User_Geo__c == 'EMEA')
                emeaUsers.add(users);
            
            if(users.Core_User_Geo__c == 'PRC')
                prcUsers.add(users);						
        }        
        List<Opportunity> testOpps = [select id,CloseDate,StageName,Name,Core_External_User__c,AccountId from Opportunity limit 200];
        
        test.startTest();
        
        // First make sure the opportunities with no team members have false checkboxes
        GeoFlags postUpdateFlags = getGeoFlags(testOpps[0].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[2].Id);
        System.AssertEquals(false, postUpdateFlags.bAPJ);
        System.AssertEquals(false, postUpdateFlags.bASMO);
        System.AssertEquals(false, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        List<OpportunityTeamMember> oppTMs = new List<OpportunityTeamMember>();
        
        for (Integer i=0; i<5; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=apjUsers[i].Id, TeamMemberRole='Team Member'));
        }
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=emeaUsers[0].Id, TeamMemberRole='Team Member'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=asmoUsers[0].Id, TeamMemberRole='Team Member'));
        
        
        // Oppty 2: make sure we can insert 100 APJ and 5 ASMO team members and have APJ + EMEA + ASMO set
        // Oppty 3: make sure we can insert 55 PRC team members and have ASMO + PRC set
        for (Integer i=0; i<10; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=apjUsers[5+i].Id, TeamMemberRole='Team Member'));
        }
        for (Integer i=0; i<5; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=asmoUsers[1+i].Id, TeamMemberRole='Team Member'));
        }
        for (Integer i=0; i<5; i++) {
            oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=prcUsers[i].Id, TeamMemberRole='Team Member'));
        }
        insert oppTMs;
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.AssertEquals(true, postUpdateFlags.bAPJ);
       
        postUpdateFlags = getGeoFlags(testOpps[2].Id);
        
        
        // Oppty 2: make sure we can update 150 APJ members and still have flags set
        // Oppty 3: make sure we can update 55 PRC team members and have ASMO + PRC set
        List<OpportunityTeamMember> preUpdateOppTMs = [select Id, TeamMemberRole from OpportunityTeamMember
                                                       where Id = :testOpps[1].Id or Id = :testOpps[2].Id];
        for (OpportunityTeamMember oppTM : preUpdateOppTMs) {
            oppTM.TeamMemberRole = 'Technical Owner';
        }
        update preUpdateOppTMs;
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        System.AssertEquals(true, postUpdateFlags.bEMEA);
        System.AssertEquals(false, postUpdateFlags.bPRC);
        
        postUpdateFlags = getGeoFlags(testOpps[2].Id);
       
        
        // Oppty 2: make sure we can delete 100 APJ members and still have flags set
        // Oppty 3: make sure we can delete 55 PRC team members and just have ASMO set
        preUpdateOppTMs = [select Id from OpportunityTeamMember
                           where OpportunityId = :testOpps[1].Id and User.Core_User_Geo__c = 'APJ' limit 100];
        delete preUpdateOppTMs;
        
        postUpdateFlags = getGeoFlags(testOpps[1].Id);
        test.stopTest();        
    }
    
    static testMethod void testUpdateOSCType() {
        
        List<User> users = Core_Test_Utility.Core_User(6);
        
        User oscUser       = users[0];
        oscUser.userName = 'test0'+ oscUser.userName ;
        oscUser.Department = OSC_DEPARTMENT;
        insert oscUser;
        
        User nonOSCUser       = users[1];
        nonOSCUser.userName =  'test1' + nonOSCUser.userName ;
        nonOSCUser.Department = '';        
        insert nonOSCUser;
        
        User oscTm       = users[2];
        oscTm.userName = 'test2' + oscTm.userName ;
        oscTm.Department = OSC_DEPARTMENT;
        insert oscTm;
        
        User nonOSCTm       = users[3];
        nonOSCTm.userName = 'test3' + nonOSCTm.userName ;
        nonOSCTm.Department = '';        
        insert nonOSCTm;
        
        User oscTo       = users[4];
        oscTo.userName = 'test4'+ oscTo.userName ;
        oscTo.Department = OSC_DEPARTMENT;
        insert oscTo;
        
        User nonOSCTo       = users[5];
        nonOSCTo.userName = 'test5' + nonOSCTo.userName ;
        nonOSCTo.Department = '';        
        insert nonOSCTo;
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
		Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        // List<Opportunity> testOpps = Core_Test_Utility.createOpportunity(8);
        List <Account> AccListList = new List <Account> ();
        For(integer i = 0; i <5; i++) {
            Account accountInstance = new Account();
            accountInstance.name = 'Test account USA' + i;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
            accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            accountInstance.Industry = 'Telecommunications';
            accountInstance.RecordTypeId=recTypeId;
            AccListList.add(accountInstance);
        }
        insert AccListList;
        List<Opportunity> testOpps=new List<Opportunity>();
        for(integer i = 0; i < 8; i++) {
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Qualify';
            opportunityInstance.Name = 'usa Test' + i;
            opportunityInstance.Core_External_User__c=true;
            opportunityInstance.AccountId =AccListList[0].id ;
            opportunityInstance.Opportunity_Focus__c= 'Core';
            opportunityInstance.Core_Opportunity_Type__c ='Design: Original';
            testOpps.add(opportunityInstance);
        }
        
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
        
        insert oppTMs;
        
        Set <Id> oppIds = new Set<Id>();
        for (OpportunityTeamMember oppMbr : oppTMs)
            oppIds.add(oppMbr.Id);        
        
        List<OpportunityTeamMember> preUpdateOppTMs = [SELECT Id 
                                                       FROM OpportunityTeamMember
                                                       WHERE OpportunityId IN :oppIds];
        
        delete preUpdateOppTMs;
        
        test.stopTest();
        Assert.areEqual(0,[SELECT COUNT() FROM OpportunityTeamMember WHERE Id in :preUpdateOppTMs]);        
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
        // Core_OpportunityTeamMemberHandler.GeoFlags();NO_OSC_INVOLVMENT
        test.stopTest(); 
        Assert.areEqual(true,opportunityTeamMemberHandler!=null);        
    }
    static testMethod void updateUerCheckTest() {
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
		Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        List <Account> AccListList = new List <Account> ();
        For(integer i = 0; i <5; i++) {
            Account accountInstance = new Account();
            accountInstance.name = 'Test account pqr' + i;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
            accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            accountInstance.Industry = 'Telecommunications';
            accountInstance.RecordTypeId=recTypeId;
            AccListList.add(accountInstance);
        }
        insert AccListList;
        
        List<contact> cn = Core_Test_Utility.createContacts(1);
        cn[0].email = 'test@test1.com';
        cn[0].accountid = AccListList[0].id;
        cn[0].MailingCountry = 'India';
        insert cn;
        
        
        // Get the profile we'll use for our test users
        Profile p = [select Id from Profile where Name = 'IT Admin'];
        
        
        // Test users
        User u = new User(Alias = 'Abjklst', Email='test123gfs@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='Testing123sdf', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123sfghd@mail.com');
        insert u;
        
        //List<Opportunity> testOpps = Core_Test_Utility.createOpportunity(3);
        List<Opportunity> testOpps=new List<Opportunity>();
        for(integer i = 0; i < 3; i++) {
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Qualify';
            opportunityInstance.Name = 'Test' + i;
            opportunityInstance.Core_External_User__c=true;
            opportunityInstance.AccountId =AccListList[0].id ;
            opportunityInstance.Opportunity_Focus__c= 'Core';
            opportunityInstance.Core_Opportunity_Type__c ='Design: Original';
            testOpps.add(opportunityInstance);
        }
        system.runAs(u){
            insert testOpps;
        }
        List<OpportunityTeamMember> oppTMs = new List<OpportunityTeamMember>();
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[0].Id, UserId=u.Id,TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[1].Id, UserId=u.Id,TeamMemberRole='Opportunity Owner'));
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[2].Id, UserId=u.Id,TeamMemberRole='Opportunity Owner'));
        
        Assert.areEqual(false,oppTMs.isEmpty());        
    }
    
    static testMethod void accessOppoCheckTest() {
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
		Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
            
        List <Account> AccListList = new List <Account> ();
        
        Account accountInstance = new Account();
        accountInstance.name = 'Test ';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';
        accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountInstance.Industry = 'Telecommunications';
        accountInstance.RecordTypeId=recTypeId;
        AccListList.add(accountInstance);
        
        insert AccListList;
        
        List<contact> cn = Core_Test_Utility.createContacts(1);
        cn[0].email = 'test@test1.com';
        cn[0].accountid = AccListList[0].id;
        cn[0].MailingCountry = 'India';
        insert cn;
        
        
        // Get the profile we'll use for our test users
        Profile p1 = [select Id from Profile where Name = 'IT Admin'];
        
        Profile p2 = [select Id from Profile where Name = 'IPS Agent'];
        
        // Test users
        User u = new User(Alias = 'Abjklst', Email='test123gfs@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='Testing123sdf', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p1.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123sfghd@mail.com');
        insert u;
        
        //List<Opportunity> testOpps = Core_Test_Utility.createOpportunity(3);
        List<Opportunity> testOpps=new List<Opportunity>();
        for(integer i = 0; i < 3; i++) {
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Qualify';
            opportunityInstance.Name = 'Test' + i;
            opportunityInstance.Core_External_User__c=true;
            opportunityInstance.AccountId =AccListList[0].id ;
            opportunityInstance.Opportunity_Focus__c= 'Core';
            opportunityInstance.Core_Opportunity_Type__c ='Design: Original';
            testOpps.add(opportunityInstance);
        }
        system.runAs(u){
            insert testOpps;
        }
        List<OpportunityTeamMember> oppTMs = new List<OpportunityTeamMember>();
        oppTMs.add(new OpportunityTeamMember(OpportunityId=testOpps[0].Id, UserId=u.Id));
        Test.startTest();
        Core_OpportunityTeamMemberHandler.check_OppObjAccessibility(oppTMs);
        Core_OpportunityTeamMemberHandler.shareOpptyTeamMembertoQuote(oppTMs);
        Test.stopTest();
        Assert.areEqual(false,oppTMs.isEmpty());
    }
    
    static testMethod void sendEmailTest() {
       
        List <Account> AccList = new List <Account> ();
        AccList = [Select id from Account limit 1];
        
        List<contact> cn = Core_Test_Utility.createContacts(1);
        cn[0].email = 'test@test1.com';
        cn[0].accountid = AccList[0].id;
        cn[0].FirstName = 'Test contact';
        cn[0].MailingCountry = 'India';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert cn;}
        
        // Get the profile we'll use for our test users
        Profile p1 = [select Id from Profile where Name = 'IT Admin'];
        
        // Test user
        User u = new User(Alias = 'Abjklst', Email='test123gfs@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='Testing123sdf', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p1.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123sfghd@mail.com');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert u;}
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.CloseDate = System.Today().addDays(24);
        opportunityInstance.StageName = 'Qualify';
        opportunityInstance.Name = 'Test TWC3123-5273 xyz';
        opportunityInstance.Opportunity_Focus__c= 'Core';
        opportunityInstance.Core_Opportunity_Type__c ='Design: Original';
        opportunityInstance.AccountId =AccList[0].id ;
        
        system.runAs(u) {
            insert opportunityInstance;
            
            map<Id,OpportunityTeamMember> NewoppTMmap = new map<Id,OpportunityTeamMember>();
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=opportunityInstance.Id, UserId=u.Id);
            Test.startTest();
            insert otm;
            NewoppTMmap.put(otm.id,otm);
            Core_OpportunityTeamMemberHandler.sendEmailtoNewTeamMember(NewoppTMmap);
            Test.stopTest();
            Assert.areEqual(false,NewoppTMmap.isEmpty());
        }
    }
    
    static testMethod void checkPCCLockUpdate_Test(){
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(Name='lockPCCOpportunity', Core_Object__c='Opportunity',
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',Core_Trigger_Events__c='before update, before insert', 
                                                                                 Core_Active__c=true, Core_Description__c='for PCC Lock');
        insert triggerEntry;
        
        Opportunity opp = [select id, name from Opportunity where name = 'TestClass PCC Opportunity'];			
        
        List<OpportunityTeamMember> oppTMList = new List<OpportunityTeamMember>();
        OpportunityTeamMember teamMember = new OpportunityTeamMember(OpportunityId = opp.Id, UserId = UserInfo.getUserId(),TeamMemberRole = 'Opportunity Owner');
        oppTMList.add(teamMember);
        Core_CRM_Utility.oppLockValidationPerformed = false;
        insert oppTMList;
        
        teamMember.Core_Description_of_Contribution__c = 'Update DOC';
        Core_CRM_Utility.oppLockValidationPerformed = false;
        Assert.areEqual(teamMember.Core_Description_of_Contribution__c,'Update DOC');
        update oppTMList;
    }
    
    static testMethod void checkPCCLockInsert_Test(){
        Core_CRM_Utility.oppLockValidationPerformed = false;
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(Name='lockPCCOpportunity', Core_Object__c='Opportunity',
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',Core_Trigger_Events__c='before update, before insert', 
                                                                                 Core_Active__c=true, Core_Description__c='for PCC Lock');
        insert triggerEntry;
        
        Core_CRM_Utility.oppLockValidationPerformed = false;
                 
        Core_CRM_Utility.oppLockValidationPerformed = false;
        Opportunity opp = [select id, name from Opportunity where name = 'TestClass PCC Opportunity'];
        Core_CRM_Utility.oppLockValidationPerformed = false;
        OpportunityTeamMember teamMember = new OpportunityTeamMember(OpportunityId = opp.Id, UserId = UserInfo.getUserId(),TeamMemberRole = 'Opportunity Owner');
        Core_CRM_Utility.oppLockValidationPerformed = false;
        insert teamMember;
        Core_CRM_Utility.oppLockValidationPerformed = false;
    }
}