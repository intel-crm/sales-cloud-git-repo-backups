@isTest
public class SK_OpportunityServiceTest {
    Private Static Id accountID;
    Private Static Id userID;
    
    @testSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        insert testAccount;        
        // Create test User (Owner)
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'IT Admin' LIMIT 1];
        
        accountID = testAccount.Id;
        userID =  testUser.Id;
        
        System.debug('account = ' + accountID + 'user =' + userID);
        // Create test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 10000,
            AccountId = testAccount.Id,
            OwnerId = testUser.Id
        );
        insert testOpportunity;
        
        // Create test Product
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;
        
        // Create test PricebookEntry
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPricebookEntry;
        
        // Create test OpportunityLineItem
        OpportunityLineItem testLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = testPricebookEntry.Id
        );
        insert testLineItem;
    }
    
    @isTest
    static void testGetOpportunitiesAndLineItemsAsJson() {
        // Get test Account and User
        Account testAccount = [SELECT Id FROM Account WHERE Id =:accountID LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Id =:userID LIMIT 1];
        
        // Call the method to get JSON response
        String jsonResponse = SK_OpportunityService.getOpportunitiesAndLineItemsAsJson(testAccount.Id, testUser.Id);
        
        // Verify the JSON response is not null or empty
        System.assertNotEquals(null, jsonResponse);
        System.assertNotEquals('', jsonResponse);
        
        // Optionally, deserialize the JSON response to verify its structure
        List<SK_OpportunityService.OpportunityWrapper> opportunities = (List<SK_OpportunityService.OpportunityWrapper>) JSON.deserialize(jsonResponse, List<SK_OpportunityService.OpportunityWrapper>.class);
        System.assertEquals(1, opportunities.size());
        System.assertEquals('Test Opportunity', opportunities[0].opportunity.Name);
        System.assertEquals(1, opportunities[0].lineItems.size());
        System.assertEquals(100, opportunities[0].lineItems[0].UnitPrice);
    }
}