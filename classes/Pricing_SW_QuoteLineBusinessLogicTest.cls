/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-18-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public class Pricing_SW_QuoteLineBusinessLogicTest {
    @TestSetup
    static void setupTestData() {
        Account acc = Pricing_SW_UtilityTest.createAccount('Test Account');
        Opportunity opp = Pricing_SW_UtilityTest.createOpportunity(acc, 'Prospecting', Date.today().addMonths(1));
        SBQQ__Quote__c quote = Pricing_SW_UtilityTest.createQuote(opp, 'Draft', acc.Id);
        
        
        // Create a test product for the test with the name "Intel Trust Authority - Custom"
        Product2 p = new Product2();
        List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
        p.Name = Label.Pricing_SW_PLI_Support_ProductName;
        p.Core_Product_Org__c = 'Sales';
        p.Core_Product_Type__c = 'Processors';
        p.Core_Sales_Visible_Flag__c = true;
        p.Core_Hierarchy_ID__c = '43';
        p.Core_Line_of_Business__c = lobValuesList[0];
        p.IsActive = true;
        insert p;
        RecordType quoteLineRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__QuoteLine__c' AND DeveloperName = 'Software_Services_Quote_Line'];
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(quote);
        quoteLine.RecordTypeId=quoteLineRecordType.id;
        update quoteLine;

        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        insert quoteTemplate;
        
        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = p.Id;      
        testPBE.UseStandardPrice = false;
        insert testPBE;
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBE.Id,
                                                                      Description='Test 11', UnitPrice=11, Quantity=11,
                                                                      Core_Loss_Cancel_Reason__c='test', Core_Status__c='Pending');
        insert testOppLineItem;
    }

    @IsTest
    static void testBeforeInsertUpdateOperation() {
        // Retrieve the custom product created in test setup
            List<Product2> customProduct = [SELECT Id FROM Product2 WHERE Name = :Label.Pricing_SW_PLI_Support_ProductName];
            RecordType quoteLineRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__QuoteLine__c' AND DeveloperName = 'Software_Services_Quote_Line'];
        // Create a Quote object for the test
            Account acc = [Select id,name from Account where name ='Test Account'];
            Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];
            SBQQ__Quote__c quote = [Select id,ApprovalStatus__c from SBQQ__Quote__c where SBQQ__Account__c=:acc.id];            
            SBQQ__QuoteLine__c quoteLine = [Select id,SBQQ__ListPrice__c,SBQQ__Quote__c,SBQQ__Product__c,RecordTypeId from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quote.id];
            quoteLine.SBQQ__Product__c=customProduct[0].id;
            quoteLine.RecordTypeId=quoteLineRecordType.id;
        	quoteLine.SBQQ__Quantity__c = 1;
            update quoteLine;
        Test.starttest();
        SBQQ__QuoteLine__c quoteLineclone=quoteLine.clone();
        insert quoteLineclone;
        Test.stoptest();        
       
    }
    
    @IsTest
    static void testBeforeInsertUpdateOperationLostoppty() {
        // Retrieve the custom product created in test setup
            List<Product2> customProduct = [SELECT Id FROM Product2 WHERE Name = :Label.Pricing_SW_PLI_Support_ProductName];
            RecordType quoteLineRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__QuoteLine__c' AND DeveloperName = 'Software_Services_Quote_Line'];
        // Create a Quote object for the test
            Account acc = [Select id,name from Account where name ='Test Account'];
            Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];
            SBQQ__Quote__c quote = [Select id,ApprovalStatus__c from SBQQ__Quote__c where SBQQ__Account__c=:acc.id];            
            SBQQ__QuoteLine__c quoteLine = [Select id,SBQQ__ListPrice__c,SBQQ__Quote__c,SBQQ__Product__c,RecordTypeId from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quote.id];
            quoteLine.SBQQ__Product__c=customProduct[0].id;
            quoteLine.RecordTypeId=quoteLineRecordType.id;
        	quoteLine.SBQQ__Quantity__c = 1;
            update quoteLine;
            
        Test.starttest();
        SBQQ__QuoteLine__c quoteLineclone=quoteLine.clone();
        insert quoteLineclone;
        PricebookEntry pbe=[select id from PricebookEntry];
        List<OpportunityLineItem> testOppLineItem = [Select id,Core_Status__c from OpportunityLineItem where OpportunityId=:opp.id];
        testOppLineItem[0].Core_Status__c='Lost';
        Update testOppLineItem;
        System.assertEquals(quoteLineclone.SBQQ__ListPrice__c, 200, 'The List Price should be 200');
        Test.stoptest();   
        Set<Id> opportunityIds = new Set<Id>{opp.id};
        Pricing_SW_QuoteLineBusinessLogic.getOpportunityLostStatusMap(opportunityIds);
        Map<Id, Boolean> opportunityLostStatusMap= Pricing_SW_QuoteLineBusinessLogic.getOpportunityLostStatusMap(opportunityIds);
        Pricing_SW_QuoteLineBusinessLogic.validateQuoteLineRestrictions(quoteLine, null, opportunityLostStatusMap, true);
        Pricing_SW_QuoteLineBusinessLogic.validateQuoteLineRestrictions(quoteLine, null, opportunityLostStatusMap, false);
        
    }
    
    
    
}