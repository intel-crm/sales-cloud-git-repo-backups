@isTest
private class Core_AAQC_LookupController_Test {

    @testSetup static void setup() {
        
        List<user> lstuser = new List<user>(); // variable to hold different user which need to be insert
        
        Id profId = [select Id from Profile where Name = 'Standard User' limit 1][0].Id;
        
        User nikhilUser = new User(UserName = 'test123GeoUpdate1@intel.com.crm.testclass', LastName = 'Nikhil', Email = 'test.user1@intel.com',
            Alias = 'tclass1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            ProfileId = profId, LanguageLocaleKey = 'en_US', Core_User_Country_Code__c = 'USA');  
        lstuser.add(nikhilUser);
        
        Id profId2 = [select Id from Profile where Name = 'Commissions Office Inquiries Admin User' limit 1][0].Id;
        
        User testUser = new User(UserName = 'testGeo4567812345Update1@intel.com.crm.testclass', LastName = 'testUser', Email = 'test.user1@intel.com',
            Alias = 'tclass1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            ProfileId = profId2,LanguageLocaleKey = 'en_US', Core_User_Country_Code__c = 'USA');  
        lstuser.add(testUser);
            
        User keyur = new User(UserName = 'testGeoUpdate1@intel.com.crm.testclass', LastName = 'keyur', Email = 'test.user1@intel.com',
            Alias = 'tclass1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            ProfileId = profId,ManagerId=UserInfo.getUserId() ,LanguageLocaleKey = 'en_US', Core_User_Country_Code__c = 'USA'); 
        lstuser.add(keyur);
        
        
        User Priti = new User(UserName = 'testGeoUpdaddfdte1@intel.com.crm.testclass', LastName = 'Priti', Email = 'test.user1@intel.com',
            Alias = 'tclass1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            ProfileId = profId,LanguageLocaleKey = 'en_US', Core_User_Country_Code__c = 'USA'); 
        lstuser.add(Priti);
        
        insert lstuser;
                  
    }
    
    @isTest
    public static void userWithProfile()
    {
        Test.StartTest();
            List<User> userObj = [select id,name from user where name = 'testUser'];
            PageReference pageRef = Page.Core_AAQC_Custom_Lookup;
            pageRef.getParameters().put('queryParam','testUser');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(userObj[0]);
            Core_AAQC_LookupController userLookup = new Core_AAQC_LookupController();
            userLookup.pageLoad();
            userLookup.getRecords();
            
        Test.StopTest();
    }    
        
   @isTest
    public static void userWithManager()
    {
        Test.StartTest();
            List<User> userObj1 = [select id,name from user where name = 'Nikhil'];
            PageReference pageRef = Page.Core_AAQC_Custom_Lookup;
            pageRef.getParameters().put('queryParam','keyur');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(userObj1[0]);
            Core_AAQC_LookupController userLookup = new Core_AAQC_LookupController();
            userLookup.pageLoad();
            userLookup.getRecords();
        Test.StopTest();
    }
    
    @isTest
    public static void userWithNoMatch()
    {
        Test.StartTest();
        List<User> userObj = [select id,name from user where name = 'testUser'];
        PageReference pageRef = Page.Core_AAQC_Custom_Lookup;
        pageRef.getParameters().put('queryParam','UrviUrvi');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(userObj[0]);
        Core_AAQC_LookupController userLookup = new Core_AAQC_LookupController();
        userLookup.pageLoad();
        userLookup.getRecords();
        Test.StopTest();
    }
    
    @isTest
    public static void userWithNotAppropraiteMatch()
    {
        Test.StartTest();
            List<User> userObj = [select id,name from user where name = 'testUser'];
            PageReference pageRef = Page.Core_AAQC_Custom_Lookup;
            pageRef.getParameters().put('queryParam','Priti');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(userObj[0]);
            Core_AAQC_LookupController userLookup = new Core_AAQC_LookupController();
            userLookup.pageLoad();
            userLookup.getRecords();
        Test.StopTest();
    }
        
    @isTest
    public static void userWithOneCharacter()
    {
        Test.StartTest();
            List<User> userObj = [select id,name from user where name = 'testUser'];
            PageReference pageRef = Page.Core_AAQC_Custom_Lookup;
            pageRef.getParameters().put('queryParam','U');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(userObj[0]);
            Core_AAQC_LookupController userLookup = new Core_AAQC_LookupController();
            userLookup.pageLoad();
            userLookup.getRecords();
        Test.StopTest();
    }
}