@IsTest
public class Pricing_SW_QuoteLineBusinessLogicTest {
    @TestSetup
    static void setupTestData() {
        // Create a test product for the test with the name "Intel Trust Authority - Custom"
        Product2 p = new Product2();
        p.Name = Label.Pricing_SW_ProductIntelTrustAuthorityCustom;
        p.Core_Product_Org__c = 'Sales';
        p.Core_Product_Type__c = 'Processors';
        p.Core_Sales_Visible_Flag__c = true;
        p.Core_Hierarchy_ID__c = '43';
        p.Core_Group_Code_Short_Name__c = 'DCG~DCAI';
        p.IsActive = true;
        insert p;

        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        insert quoteTemplate;
    }

    @IsTest
    static void testBeforeInsertUpdateOperation() {
        // Retrieve the custom product created in test setup
            Product2 customProduct = [SELECT Id FROM Product2 WHERE Name = :Label.Pricing_SW_ProductIntelTrustAuthorityCustom LIMIT 1];

        // Create a Quote object for the test
            Account acc = Pricing_SW_UtilityTest.createAccount('Test Account');
            Opportunity opp = Pricing_SW_UtilityTest.createOpportunity(acc, 'Prospecting', Date.today().addMonths(1));
            SBQQ__Quote__c quote = Pricing_SW_UtilityTest.createQuote(opp, 'Draft', acc.Id);
            RecordType quoteLineRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__QuoteLine__c' AND DeveloperName = 'Software_Services_Quote_Line' LIMIT 1];
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            RecordTypeId = quoteLineRecordType.Id,
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = customProduct.Id,
            
            SBQQ__ListPrice__c = 0 ,
            Pricing_Quote_Program_Nm__c='Software & Services'
        );
        insert quoteLine;
        Test.starttest();
        SBQQ__QuoteLine__c quoteLineclone=quoteLine.clone();
        insert quoteLineclone;
        System.assertEquals(quoteLineclone.SBQQ__ListPrice__c, 0, 'The List Price should be 0');
        Test.stoptest();        
       
    }
}