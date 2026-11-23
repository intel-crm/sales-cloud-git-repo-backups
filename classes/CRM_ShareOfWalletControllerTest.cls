@isTest
public class CRM_ShareOfWalletControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a mock Account Plan record
        AccountPlan accountPlan = new AccountPlan(Name = 'Test Account Plan');
        insert accountPlan;

        // Create mock Share of Wallet records linked to the Account Plan
        List<CRM_Share_of_Wallet__c> sowRecords = new List<CRM_Share_of_Wallet__c>{
            new CRM_Share_of_Wallet__c(
                CRM_Account_Plan__c = accountPlan.Id,
                CRM_Year__c = 2024,
                CRM_Offering__c = 'SEO',
                CRM_Spend__c = 5000,
                CRM_With__c = 'Us',
                CRM_Competitor__c = 'Competitor A',
                CRM_Contract_End_Date__c = Date.today().addMonths(6),
                CRM_Comments__c = 'Test Comment 1'
            ),
            new CRM_Share_of_Wallet__c(
                CRM_Account_Plan__c = accountPlan.Id,
                CRM_Year__c = 2023,
                CRM_Offering__c = 'SEO',
                CRM_Spend__c = 7000,
                CRM_With__c = 'Competitor',
                CRM_Competitor__c = 'Competitor B',
                CRM_Contract_End_Date__c = Date.today().addMonths(12),
                CRM_Comments__c = 'Test Comment 2'
            )
        };
        insert sowRecords;
    }

    @isTest
    static void testGetShareOfWalletData() {
        // Fetch the Account Plan created in @testSetup
        AccountPlan accountPlan = [SELECT Id FROM AccountPlan LIMIT 1];

        // Call the method
        Test.startTest();
        List<CRM_Share_of_Wallet__c> result = CRM_ShareOfWalletController.getShareOfWalletData(accountPlan.Id);
        Test.stopTest();

        // Assert that data is returned
        System.assertNotEquals(0, result.size(), 'Expected at least one Share of Wallet record.');
        System.assertEquals(2, result.size(), 'Expected exactly two records.');
        System.assertEquals('SEO', result[0].CRM_Offering__c, 'First record should have correct offering.');
    }

   

    @isTest
    static void testSaveShareOfWalletData() {
        // Fetch the Account Plan created in @testSetup
        AccountPlan accountPlan = [SELECT Id FROM AccountPlan LIMIT 1];

        // Create new Share of Wallet records
        List<CRM_Share_of_Wallet__c> newRecords = new List<CRM_Share_of_Wallet__c>{
            new CRM_Share_of_Wallet__c(
                CRM_Account_Plan__c = accountPlan.Id,
                CRM_Year__c = 2025,
                CRM_Offering__c = 'SEO',
                CRM_Spend__c = 8000,
                CRM_With__c = 'Unknown',
                CRM_Competitor__c = 'Competitor C',
                CRM_Contract_End_Date__c = Date.today().addYears(1),
                CRM_Comments__c = 'New Comment'
            )
        };

        // Call the method
        Test.startTest();
        CRM_ShareOfWalletController.saveShareOfWalletData(newRecords);
        Test.stopTest();

        // Query database to verify record was saved
        CRM_Share_of_Wallet__c savedRecord = [SELECT CRM_Year__c, CRM_Offering__c FROM CRM_Share_of_Wallet__c WHERE CRM_Year__c = 2025 LIMIT 1];
        System.assertNotEquals(null, savedRecord, 'Record should be saved successfully.');
        System.assertEquals('SEO', savedRecord.CRM_Offering__c, 'Offering should match the inserted value.');
    }

    @isTest
    static void testSaveShareOfWalletData_EmptyList() {
        try {
            Test.startTest();
            CRM_ShareOfWalletController.saveShareOfWalletData(new List<CRM_Share_of_Wallet__c>());
            Test.stopTest();
            System.assert(true, 'Expected no operation or error for empty list but the method executed.');
        } catch (Exception e) {
            System.assert(false, 'No exception should be thrown when saving an empty list.');
        }
    }
}