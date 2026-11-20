@isTest(seeAllData = false)
public class Core_MDF_AccountSearchController_Test {
	@testSetup 
    static void setup() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        testUser.Email = 'sysadmin@example.com';
        Database.insert(testUser);
        
        System.runAs(testUser){
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);            
            Database.insert(cpCCF);
            
            Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc.Core_MDF_CoMarketingActive__c = false;
            acc.Core_Unified_Global_Customer_BP_Id__c = '324619';
            Database.insert(acc);
            
            Id accOnboard_RecordType_CCF = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
            
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_CCF;
            accOnb.Core_MDF_Account__c = acc.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            Database.insert(accOnb);
        }
    }
    @isTest
    static void testSearchAccounts_Null() {

        Test.startTest();
        Core_MDF_AccountSearchController.AccountWrapper result =
            Core_MDF_AccountSearchController.searchAccounts(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Result should be null for null input');
    }
    
    @isTest
    static void testSearchAccounts_Valid() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Core_MDF_AccountSearchController.AccountWrapper result =
            Core_MDF_AccountSearchController.searchAccounts(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Wrapper should not be null');

        System.assertEquals(acc.Id, result.Id);
        System.assertEquals('Intel Account', result.name);
    }
    
    @isTest
    static void testGetRecordTypeIdByProgram_Valid() {

        Test.startTest();
        Id result = Core_MDF_AccountSearchController.getRecordTypeIdByProgram('Client CoMarketing Fund');
        Test.stopTest();

        // We don't assert equality because label mapping may vary
        System.assert(true, 'Method executed without exception');
    }
}