/****************************************************************************************************************************************
* Class Name       : Core_MDF_OutcomeBasedDetailCntllrTest
* Test Class For   : Core_MDF_OutcomeBasedCampDetailCntllr
* Version          : 1.0 
* Created Date     : 23/03/2026
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Test         23/03/2026         Test class for Core_MDF_OutcomeBasedCampDetailCntllr
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_OutcomeBasedDetailCntllrTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test account for testing
        
        Account testAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', 
                                                                           Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            testAccount.BillingStateCode = '';
            
            //accListUlt.add(testAccount);
            insert testAccount;
        
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        List<user> usrList=new List<User>();
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'MDF UserTest';
        testUser.profileId = systemAdminProfile.Id;
        //usrList.add(usr);
        insert testUser;
        // Create test user with standard profile
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
        //insert testUser;
    }
    
    @isTest
    static void testCheckUserRecordAccess_BlankRecordId() {
        Test.startTest();
        
        // Test with blank record ID
        Core_MDF_OutcomeBasedCampDetailCntllr.UserAccessResult result = 
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess('', 'Account');
        
        Test.stopTest();
        
        // Assertions
        //System.assertNotNull(result, 'Result should not be null');
        System.assertEquals(false, result.hasAccess, 'User should not have access with blank record ID');
    }
    
    @isTest
    static void testCheckUserRecordAccess_NullRecordId() {
        Test.startTest();
        
        // Test with null record ID
        Core_MDF_OutcomeBasedCampDetailCntllr.UserAccessResult result = 
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess(null, 'Account');
        
        Test.stopTest();
        
        // Assertions
        //System.assertNotNull(result, 'Result should not be null');
        System.assertEquals(false, result.hasAccess, 'User should not have access with null record ID');
    }

    
    @isTest
    static void testCheckUserRecordAccess_InvalidRecordId() {
        Test.startTest();
        
        // Test with invalid record ID format
        Core_MDF_OutcomeBasedCampDetailCntllr.UserAccessResult result = 
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess('invalid_id', 'Account');
        
        Test.stopTest();
        
        // Assertions
        //System.assertNotNull(result, 'Result should not be null');
        System.assertEquals(false, result.hasAccess, 'User should not have access with invalid record ID');
    }
    
    @isTest
    static void testCheckUserRecordAccess_NonExistentRecord() {
        // Create a fake Account ID that doesn't exist
        String fakeAccountId = '001000000000000';
        
        Test.startTest();
        
        // Test with non-existent record ID
        Core_MDF_OutcomeBasedCampDetailCntllr.UserAccessResult result = 
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess(fakeAccountId, 'Account');
        
        Test.stopTest();
        
        // Assertions
        //System.assertNotNull(result, 'Result should not be null');
        System.assertEquals(false, result.hasAccess, 'User should not have access to non-existent record');
    }
    
    @isTest
    static void testUserAccessResult_DefaultConstructor() {
        Test.startTest();
        
        // Test the wrapper class constructor
        Core_MDF_OutcomeBasedCampDetailCntllr.UserAccessResult result = 
            new Core_MDF_OutcomeBasedCampDetailCntllr.UserAccessResult();
        
        Test.stopTest();
        
        // Assertions
        //System.assertNotNull(result, 'Result should not be null');
        System.assertEquals(false, result.hasAccess, 'Default hasAccess should be false');
        System.assertEquals(null, result.recordId, 'Default recordId should be null');
        System.assertEquals(null, result.errorMessage, 'Default errorMessage should be null');
    }
}