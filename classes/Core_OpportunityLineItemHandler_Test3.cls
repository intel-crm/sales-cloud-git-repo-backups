/****************************************************************************************************
Apex Class Name : Core_OpportunityLineItemHandler_Test3
Version         : 1.0 
Created Date    : 07/28/16
Function        : Test class for OpportunityLineItem tests related to History Tracking 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Dave Hood                   07/28/16               Original Version
****************************************************************************************************/
@isTest
public class Core_OpportunityLineItemHandler_Test3 {

    @testSetup
    private static void setupTestData() {
        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='trackOpportunityProductHistory', Core_Object__c='OpportunityLineItem', Core_Class_Name__c='Core_OpportunityLineItemHandler',
            Core_Trigger_Events__c='before update, before delete', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        insert testAcct;
        
        List<RecordType> recIds = [select id from RecordType where DeveloperName = 'Mastered_Account' limit 1];
        testAcct.RecordTypeId = recIds[0].id;
        Update testAcct;
        // Simple test data
        Opportunity testOpp = Core_Test_Utility.createOpportunity(1)[0];
        testOpp.AccountId = testAcct.Id;
        insert testOpp;
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[1].Id,
                                                  Description='Test 12', UnitPrice=12, Quantity=12,
                                                  Core_Loss_Cancel_Reason__c='', Core_Status__c='Pending');
        insert testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[2].Id,
                                                  Description='Test 13', UnitPrice=13, Quantity=13,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        
        // Bulk test data
        List<Opportunity> bulkTestOpps = Core_Test_Utility.createOpportunity(10);
        for (Opportunity opp : bulkTestOpps)
            opp.AccountId = testAcct.Id;
        insert bulkTestOpps;
        
        List<Product2> bulkTestProducts = Core_Test_Utility.createProduct(5);
        insert bulkTestProducts;
        
        List<PricebookEntry> bulkTestPBEs = Core_Test_Utility.createPriceBookEntry(5, bulkTestProducts, Test.getStandardPricebookId());
        insert bulkTestPBEs;
        
        List<OpportunityLineItem> bulkTestOppLineItems = new List<OpportunityLineItem>();
        for (Opportunity opp : bulkTestOpps) {
            for (PricebookEntry pbe : bulkTestPBEs) {
                bulkTestOppLineItems.add(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbe.Id,
                                                                 Description='Bulk 11', UnitPrice=11, Quantity=11,
                                                                 Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
            }
        }
        insert bulkTestOppLineItems;
    }
    
    // Test a simple update of a few line items
    testMethod static void testUpdate() {
        
        // First make sure we don't already have any field history entries
        //System.assertEquals(0, [select count() from Core_Opportunity_Product_History__c]);
        
        // Update a bunch of fields on multiple records
        List<OpportunityLineItem> testOppLineItems = [select Description, UnitPrice, Quantity,
                                                             Core_Loss_Cancel_Reason__c, Core_Status__c
                                                      from OpportunityLineItem where Description like 'Test%'];
        
        testOppLineItems[0].Core_Loss_Cancel_Reason__c = 'Testing testing';
        testOppLineItems[0].Core_Status__c = 'On Hold';
        testOppLineItems[0].Description = 'Test 21';
        testOppLineItems[0].Quantity = 21;
        testOppLineItems[0].UnitPrice = 21;
        testOppLineItems[1].Core_Loss_Cancel_Reason__c = 'Testing testing';
        testOppLineItems[1].Core_Status__c = 'Lost';
        testOppLineItems[1].Core_Competitor__c ='Acer';
        testOppLineItems[1].Core_Competitor_Product__c='AMD Athlon';
        testOppLineItems[1].Description = '';
        testOppLineItems[1].Core_Loss_Cancel_Details__c = 'Lost';
        testOppLineItems[2].Core_Group_Code__c = 'GC23'; // We're not tracking this field!
        
        Test.startTest();
        update testOppLineItems;
        Test.stopTest();
        
        List<Core_Opportunity_Product_History__c> oppProdHistory = [select Core_Opportunity__c, Core_Opportunity_Product_ID__c,
                                                                           Core_Field__c, Core_Old_Value__c, Core_New_Value__c
                                                                    from Core_Opportunity_Product_History__c
                                                                    order by Core_Opportunity_Product_ID__c, Core_Field__c LIMIT 10];
        //for (Core_Opportunity_Product_History__c oppProdHist : oppProdHistory)
        //  System.debug(oppProdHist);
        
        // Make sure we now have the expected amount of field history entries
        //System.assertEquals(9, oppProdHistory.size());
        
        // Spot check some entries to make sure they're correct
        //System.assertEquals('Core_Loss_Cancel_Reason__c', oppProdHistory[0].Core_Field__c);
        //System.assertEquals(null, oppProdHistory[0].Core_Old_Value__c);
        //System.assertEquals('Testing testing', oppProdHistory[0].Core_New_Value__c);
        
        //System.assertEquals('Description', oppProdHistory[2].Core_Field__c);
        //System.assertEquals('Test 11', oppProdHistory[2].Core_Old_Value__c);
        //System.assertEquals('Test 21', oppProdHistory[2].Core_New_Value__c);
        
        //System.assertEquals('Description', oppProdHistory[7].Core_Field__c);
        //System.assertEquals('Test 12', oppProdHistory[7].Core_Old_Value__c);
        //System.assertEquals(null, oppProdHistory[7].Core_New_Value__c);
    }
    
    // Test a simple delete of a few line items
    testMethod static void testDelete() {
        
        // First make sure we don't already have any field history entries
        //System.assertEquals(0, [select count() from Core_Opportunity_Product_History__c]);
        
        // Delete the line items
        List<OpportunityLineItem> testOppLineItems = [select Id
                                                      from OpportunityLineItem where Description like 'Test%'];
        Test.startTest();
        delete testOppLineItems;
        Test.stopTest();
        
        List<Core_Opportunity_Product_History__c> oppProdHistory = [select Core_Opportunity__c, Core_Opportunity_Product_ID__c,
                                                                           Core_Field__c, Core_Old_Value__c, Core_New_Value__c
                                                                    from Core_Opportunity_Product_History__c
                                                                    order by Core_Opportunity_Product_ID__c, Core_Field__c LIMIT 10];
        //for (Core_Opportunity_Product_History__c oppProdHist : oppProdHistory)
        //  System.debug(oppProdHist);
        
        // Make sure we now have the expected amount of field history entries
        //System.assertEquals(24, oppProdHistory.size());
        
        // Spot check some entries to make sure they're correct
        //System.assertEquals('Core_BU_Short_Name__c', oppProdHistory[0].Core_Field__c);
        //System.assertEquals('T11', oppProdHistory[0].Core_Old_Value__c);
        //System.assertEquals(null, oppProdHistory[0].Core_New_Value__c);
    }
    
    // Test a bulk update of many line items
    testMethod static void testUpdateBulk() {
        
        // First make sure we don't already have any field history entries
        //System.assertEquals(0, [select count() from Core_Opportunity_Product_History__c]);
        
        // Update a bunch of fields on multiple records
        List<OpportunityLineItem> testOppLineItems = [select Description, UnitPrice, Quantity, Core_BU_ShortName__c,
                                                             Core_Loss_Cancel_Reason__c, Core_Status__c
                                                      from OpportunityLineItem where Description like 'Bulk%'];
        
        for (OpportunityLineItem oppLineItem : testOppLineItems) {
            oppLineItem.Description = oppLineItem.Description + ' after update';
            oppLineItem.UnitPrice = oppLineItem.UnitPrice * 2;
            oppLineItem.Quantity = oppLineItem.Quantity * 3;
            //oppLineItem.Core_BU_Short_Name__c = oppLineItem.Core_BU_Short_Name__c + 'X';
            oppLineItem.Core_Loss_Cancel_Reason__c = 'Testing';
            oppLineItem.Core_Status__c = 'On Hold';
        }
        
        Test.startTest();
        update testOppLineItems;
        Test.stopTest();
        
        // Make sure we now have the expected amount of field history entries
        //System.assertEquals(300, [select count() from Core_Opportunity_Product_History__c]);
    }
    
    // Test a bulk delete of many line items
    testMethod static void testDeleteBulk() {
        
        // First make sure we don't already have any field history entries
        //System.assertEquals(0, [select count() from Core_Opportunity_Product_History__c]);
        
        // Delete a bunch of records
        List<OpportunityLineItem> testOppLineItems = [select Id from OpportunityLineItem where Description like 'Bulk%'];
        
        Test.startTest();
        delete testOppLineItems;
        Test.stopTest();
        
        // Make sure we now have the expected amount of field history entries
        //System.assertEquals(400, [select count() from Core_Opportunity_Product_History__c]);
    }
}