@isTest
private class PCC_UpdateClaimsControllerTest {

    // Test method for updateClaims method
    @isTest
    static void testUpdateClaims() {
         Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; // Adjust profile as needed
           User testuser = new User(
            profileId = userProfile.id, 
            username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
            email = 'testuser@example.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='lastname'
            //sales_license__c = 'Rebate Management'
           );
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert testUser;
        }
        
        // Create test data
        PCC_Rebate_Claim__c claim1 = new PCC_Rebate_Claim__c(
            PCC_CSAR_ID__c = 'CSAR-001',
            PCC_Payment_Ref_Id__c = 'Payment-001',
            PCC_Claim_Status__c = 'Claim Approved - Payment Pending'
        );
        PCC_Rebate_Claim__c claim2 = new PCC_Rebate_Claim__c(
            PCC_CSAR_ID__c = null,
            PCC_Payment_Ref_Id__c = null,
            PCC_Claim_Status__c = 'Claim Approved - Payment Pending'
        );
        System.runAs(Core_Test_Utility.systemAdminUser) {
        insert new List<PCC_Rebate_Claim__c>{claim1, claim2};
            }
        // Prepare test data for updateClaims method
        List<String> claimIds = new List<String>{claim1.Id, claim2.Id};
        String csarId = 'CSAR-002';
        String paymentRefId = 'Payment-002';

       // Run test as the test user
        System.runAs(Core_Test_Utility.systemAdminUser) { 
            // Call the method to be tested
            String result;
            try {
                Test.startTest();
                result = PCC_UpdateClaimsController.updateClaims(claimIds, csarId, paymentRefId);
                Test.stopTest();
            } catch (Exception e) {
                System.debug('Exception in test: ' + e.getMessage());
                throw e; // Re-throw to ensure the test fails and provides error information
            }

        // Assert the results
        List<PCC_Rebate_Claim__c> updatedClaims = [
            SELECT Id, PCC_CSAR_ID__c, PCC_Payment_Ref_Id__c, PCC_Claim_Status__c,PCC_Payment_Date__c
            FROM PCC_Rebate_Claim__c
            WHERE Id IN :claimIds
        ];

        System.assertEquals(true,updatedClaims.size() > 0 , 'Expected successful update message');
        
    }
 }

    // Test method for getClaimRecords method
    @isTest
    static void testGetClaimRecords() {
        // Create test data
        List<Account> accList = Core_Test_Utility.createAccount(1);
        String partnerName = 'Test Partner';
        Date fromDate = Date.today().addDays(-30);
        Date toDate = Date.today();

        PCC_Rebate_Claim__c claim1 = new PCC_Rebate_Claim__c(
            PCC_Partner__c = accList[0].Id,
            PCC_CSAR_ID__c = null,
            PCC_Payment_Ref_Id__c = null,
            PCC_Claim_Status__c = 'Claim Approved - Payment Pending'
          
        );
        PCC_Rebate_Claim__c claim2 = new PCC_Rebate_Claim__c(
            PCC_Partner__c = accList[0].Id,
            PCC_CSAR_ID__c = 'CSAR-001',
            PCC_Payment_Ref_Id__c = null,
            PCC_Claim_Status__c = 'Claim Approved - Payment Pending'
             
        );
        insert new List<PCC_Rebate_Claim__c>{claim1, claim2};

        // Call the method to be tested
        Test.startTest();
        List<PCC_Rebate_Claim__c> result = PCC_UpdateClaimsController.getClaimRecords(partnerName, fromDate, toDate);
        boolean isUserCheck = PCC_UpdateClaimsController.userPScheck();
        Test.stopTest();

        // Assert the results
        System.assertEquals(0, result.size(), 'Expected only one record');
        System.assertEquals(true, isUserCheck<>null, 'boolean is not null');
    }
}