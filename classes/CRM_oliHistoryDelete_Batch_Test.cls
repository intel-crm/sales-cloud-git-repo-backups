@isTest
public class CRM_oliHistoryDelete_Batch_Test {
    static List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
	@testSetup
    static void setup(){
        CRM_oliHistoryDeleteDates__c config = new CRM_oliHistoryDeleteDates__c();
        config.Name = Label.Core_FY_to_delete_OLI_History;
        config.Start_Date__c = Date.today().addDays(-5);
        config.End_Date__c = Date.today().addDays(5);
        insert config;
       	
        Account acc= new Account();
        acc.Name = 'Test Account1';
        acc.BillingCountryCode = 'USA';
        acc.BIllingStateCode = 'AL';
        acc.BillingCity = 'Alabama';
        acc.BillingStreet = 'test ' + (Math.random() * 1000);
        acc.Core_Sales_Groups__c = 'Americas US Sales Group';
        acc.Industry = 'Agriculture';
        acc.Core_Sub_Industry__c = 'Crop Production';
        
        insert acc;
        
        Id oppDesignID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.Core_Commissionable__c='No'; 
        opp.RecordTypeId = oppDesignID;
        opp.StageName = 'Qualify';    
        opp.Core_Opportunity_Type__c='Design: Original';
        opp.CloseDate = System.Date.today().addYears(1);
        opp.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opp.Opportunity_Focus__c = 'Core';
        insert opp;
        
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBEs[0].Id,
                                                                      Description='Test 1', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);
        oliList.add(testOppLineItem);
        OpportunityLineItem testOppLineItem2 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBEs[0].Id,
                                                                       Description='Test 2', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                       Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);  
        oliList.add(testOppLineItem2);      
        OpportunityLineItem testOppLineItem3 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBEs[0].Id,Core_Vendor__c=null,
                                                                       Description='Test 3', UnitPrice=11, Quantity=11,Core_BU_Mapping_record__c=null,
                                                                       Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        oliList.add(testOppLineItem3);
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert oliList;
        }
        Core_Opportunity_Product_History__c testOLIHistory1 = new Core_Opportunity_Product_History__c(Core_Opportunity_Product_ID__c = testOppLineItem.id,
                                                                                                     Core_Field__c = 'Core_Status__C');
        
    }
    @isTest
    static void testBatchExecution(){
        //String customSettingName = Label.Core_FY_to_delete_OLI_History;
        Test.startTest();
        CRM_oliHistoryDelete_Batch testBatch = new CRM_oliHistoryDelete_Batch();
        Database.executeBatch(testBatch);
        Test.stopTest();
    }
    
}