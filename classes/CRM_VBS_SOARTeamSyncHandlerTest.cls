@isTest
public class CRM_VBS_SOARTeamSyncHandlerTest {
    @testsetup
    static void setupData() {        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Id profileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;
            
            //user Creation
            List<User> testUsers = new List<User>();
            User testUser = new User();
            testUser.Firstname = 'test Abcdsfe';
            testUser.LastName = 'userabcdjkte ' + 'APJ';
            testUser.UserName = 'testusertestsstes.' + 'APJ'+ '@intel.com.crm';
            testUser.Email = 'testusertestt.' + 'APJ' + '@intel.com';
            testUser.Alias = 'APJ' ;
            testUser.CommunityNickName = 'testsss.' + 'APJ';
            testUser.ProfileId = profileId;
            testUser.LANGUAGELOCALEKEY = 'en_US';
            testUser.LOCALESIDKEY = 'en_US';
            testUser.TIMEZONESIDKEY = 'America/Los_Angeles';
            testUser.EMAILENCODINGKEY = 'ISO-8859-1';
            testUser.Core_User_Geo__c = 'APJ';
            testUsers.add(testUser);
            
            User testUser2 = new User();
            testUser2.Firstname = 'test Abcdsfe';
            testUser2.LastName = 'userabcdjkte ' + 'ASMO';
            testUser2.UserName = 'testusertestsstes.' + 'ASMO'+ '@intel.com.crm';
            testUser2.Email = 'testusertestt.' + 'ASMO' + '@intel.com';
            testUser2.Alias = 'ASMO' ;
            testUser2.CommunityNickName = 'testsss.' + 'ASMO';
            testUser2.ProfileId = profileId;
            testUser2.LANGUAGELOCALEKEY = 'en_US';
            testUser2.LOCALESIDKEY = 'en_US';
            testUser2.TIMEZONESIDKEY = 'America/Los_Angeles';
            testUser2.EMAILENCODINGKEY = 'ISO-8859-1';
            testUser2.Core_User_Geo__c = 'ASMO';
            testUsers.add(testUser2);
            
            
            User testUser3 = new User();
            testUser3.Firstname = 'test Abcdsfe';
            testUser3.LastName = 'userabcdjkte SOAR' + 'ASMO';
            testUser3.UserName = 'testusertestsstes.SOAR' + 'ASMO'+ '@intel.com.crm';
            testUser3.Email = 'testusertestt.' + 'SOAR' + '@intel.com';
            testUser3.Alias = 'SOAR' ;
            testUser3.CommunityNickName = 'testsss.' + 'SOAR';
            testUser3.ProfileId = profileId;
            testUser3.LANGUAGELOCALEKEY = 'en_US';
            testUser3.LOCALESIDKEY = 'en_US';
            testUser3.TIMEZONESIDKEY = 'America/Los_Angeles';
            testUser3.EMAILENCODINGKEY = 'ISO-8859-1';
            testUser3.Core_User_Geo__c = 'ASMO';
            testUsers.add(testUser3);
            
            Insert   testUsers;      
            
            // create Account Record
            Account testAccount = Core_Test_Utility.createAccount(1)[0];
            insert testAccount;
            
            
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            Opportunity opportunity = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                      AccountId = testAccount.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), 
                                                      Core_Opportunity_Type__c = 'Design: Original');
            insert opportunity;
        }
    }
    
    static testMethod void syncSOARTeamTest(){
        Opportunity oppRecord = [select Id, Name, Core_VBS_Status__c from Opportunity limit 1];
        
        List<User> userList = [Select id from user where Email IN( 'testusertestt.SOAR@intel.com ','testusertestt.APJ@intel.com','testusertestt.ASMO@intel.com') limit 2];
        system.debug('testSOAR--'+ userList.size());
        
        OpportunityTeamMember newTeamem = new OpportunityTeamMember(
            OpportunityId = oppRecord.Id,
            UserId =userList[0].id ,
            OpportunityAccessLevel = 'Read' ,
            Core_Description_of_Contribution__c = 'testing ',
            TeamMemberRole = 'Team Member (100%)'
        );
        insert newTeamem;
        
        oppRecord.Core_VBS_Potential__c = true;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Update oppRecord;
        }
        
        
        CRM_VBS_SOAR__c testSOAR = [Select id,CRM_VBS_QB_Resource__c,CRM_VBS_SOAR_VBS_Decision__c,CRM_VBS_SOAR_Stage__c from CRM_VBS_SOAR__c where CRM_VBS_SOAR_Opportunity__c =: oppRecord.id  limit 1];
        system.debug('testSOAR--'+ testSOAR);
        
        List<CRM_VBS_SOAR_Team__c> teammember = [select id,CRM_VBS_Team_Role__c,CRM_VBS_Team_member__r.name,CRM_VBS_Description_of_Contribution__c from CRM_VBS_SOAR_Team__c where CRM_VBS_SOAR__c =: testSOAR.id and CRM_VBS_Team_Role__c= 'Team Member (100%)' ];
        system.debug('teammember--'+ teammember.size());  
        if(teammember.size() > 0)
            delete teammember;
        
        teammember = [select id,CRM_VBS_Team_Role__c,CRM_VBS_Team_member__r.name,CRM_VBS_Description_of_Contribution__c from CRM_VBS_SOAR_Team__c where CRM_VBS_SOAR__c =: testSOAR.id ];
        system.debug('teammember--'+ teammember);  
        if(teammember.size() > 0)
            teammember[0].CRM_VBS_Description_of_Contribution__c = 'testing Owner';
        
        update teammember;
        
        
        // Create test data for SOAR Team
        CRM_VBS_SOAR_Team__c testSOARTeam = new CRM_VBS_SOAR_Team__c(
            CRM_VBS_Team_member__c = userList[1].Id,
            CRM_VBS_Team_Role__c = 'Technical Owner (100%)',
            CRM_VBS_Description_of_Contribution__c = 'Test Description VBS',
            CRM_VBS_SOAR__c = testSOAR.Id
        );
        insert testSOARTeam;
        
        
        testSOAR.CRM_VBS_SOAR_VBS_Decision__c = 'SOAR1 Qualified';
        testSOAR.CRM_VBS_QB_Resource__c = UserInfo.getUserId();
        update testSOAR;
        
        
        testSOAR.CRM_VBS_SOAR_VBS_Decision__c = 'SOAR3 Approved';
        testSOAR.CRM_VBS_SOAR_Stage__c = 'SOAR3 - Gain Intel Approval';
        update testSOAR;
        List<Id> soarId = new List<Id>();
        soarId.add(testSOAR.id);
        Test.startTest();
        //System.runAs(UserInfo.getUserId()) {
        CRM_VBS_SOARTeamSyncHandler.syncTeams(soarId);
        //}
        Test.stopTest();
        
    }
    
}