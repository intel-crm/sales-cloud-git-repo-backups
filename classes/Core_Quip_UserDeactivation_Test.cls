@isTest
public class Core_Quip_UserDeactivation_Test {
    @isTest
    static void testDeactivateQUIPUser() {
        Id profId = [select Id from Profile where Name = 'Standard User' limit 1 ][0].Id;
		User testUser = new User(IsActive = true,
            Email = 'inactive@example.com',
            UserName = 'testGeoUpdate1@intel.com.crm.testclass', 
            LastName = 'User',            
            Alias = 'tclass1', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8',
            ProfileId = profId, 
            LanguageLocaleKey = 'en_US', 
            Core_User_Country_Code__c = 'USA');
        insert testUser;
        

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Quip' limit 1];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        
        QUIP__c customSetting = new QUIP__c(
            Name = 'Test Setting',
            Token__c = 'testToken',
            Email_EndPoint_URL__c = 'https://example.com/user/',
            Delete_EndPoint_URL__c = 'https://example.com/delete/'
        );
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert customSetting;
        }
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        User u = [Select id, IsActive from User where Email = 'inactive@example.com'];
        u.IsActive = false;
        update u;
        Core_Quip_UserDeactivation.deactivateQUIPUser(new List<String>{ 'inactive@example.com' });
        Test.stopTest();

        List<Core_Log_Entry__c> logEntries = [SELECT Id FROM Core_Log_Entry__c where Core_Origin__c='Core_Quip_UserDeactivation.deactivateQUIPUser'];
        System.assertNotEquals(1, logEntries.size());
    }
    
    @isTest
    static void testInactiveUserQuip() {
        
        QUIP__c customSetting = new QUIP__c(Name = 'Test Setting',Token__c = 'testToken',Email_EndPoint_URL__c = 'https://example.com/user/',
                                            Delete_EndPoint_URL__c = 'https://example.com/delete/',IsActive__c=true);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {  
            insert customSetting;
        }
        
        Profile prof = [select Id from Profile where Name = 'IT Admin' limit 1 ];
        List < User > userList = new List < User > ();
        userList.add(new User(IsActive = true,Email = 'active@example.com',UserName = 'testGeoUpdate1@intel.com.crm.testclass1',
                              LastName = 'User',Alias = 'tclass1',TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', 
                              EmailEncodingKey = 'UTF-8', ProfileId = prof.Id,LanguageLocaleKey = 'en_US',Core_User_Country_Code__c = 'USA'));
        System.runAs(Core_Test_Utility.systemAdminUser) {  
            insert userList;
        }
        Map<Id,User> userMap = new Map<Id,User>();
        userMap.put(userList[0].id, userList[0]);

        /*PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Quip' limit 1];
        List<PermissionSetAssignment> psl = new List<PermissionSetAssignment>();
        PermissionSetAssignment psa =new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userList[0].Id);
        psl.add(psa);
        system.runas(Core_Test_Utility.systemAdminUser){
            insert psl;
        }*/  
        
        Test.startTest();
        user u = [select id,isactive,Email from user where Email = 'active@example.com'];
        u.IsActive = false;
        System.runAs(Core_Test_Utility.systemAdminUser) {  
            update u;
            Core_Quip_UserDeactivation.inactiveUserQuip(new List<User>{u}, userMap);
        }
        Test.stopTest();
        List<Core_Log_Entry__c> logEntries = [SELECT Id FROM Core_Log_Entry__c where Core_Origin__c='Core_Quip_UserDeactivation.inactiveUserQuip'];
        System.assertEquals(0, logEntries.size());
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Resources": [{"id": "mockedQuipUserId","active": true}]}');
            res.setStatusCode(200);
            return res;
        }
    }

}