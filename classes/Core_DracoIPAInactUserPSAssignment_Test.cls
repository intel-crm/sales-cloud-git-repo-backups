@isTest
public class Core_DracoIPAInactUserPSAssignment_Test {
    @TestSetup
    static void createTestData(){ 
        Profile p = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
        User testUser1 = new User(
            Username = 'testuser1@intel.com',
            Alias = 'test1',
            Email = 'testuser1@intel.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            LastName = 'User1'
        );
        insert testUser1;
    }   
    @isTest
    static void IPAInactUserPSAsnmentTest1() {
        List<User> userIds= [Select Id from user limit 1];
        List<Id> uIds = new List<Id>();
        uIds.add(userids[0].Id);
        Test.startTest();
        Core_DracoIPAInactUserPSAssignment.createPSAssignmentRecord(uIds);
        Test.stopTest();
    }
    
}