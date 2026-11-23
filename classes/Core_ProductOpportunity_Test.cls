/***********************************************************************************************
Apex Class Name:  Core_ProductOpportunity_Test
Version     : 1.0 
Created Date: 19 OCT 2015
Function    : Test Class for the Core_ProductOpportunity trigger
Modification Log :
* Developer                 Date                   Description
* ----------------------------------------------------------------------------                 
* Dave Hood                 10/19/2015             Original version
***********************************************************************************************/
@isTest
public class Core_ProductOpportunity_Test {

    private static testMethod void testOppProdConcatenatedFieldUpdate() {
        
        // Enable the trigger execution        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='oppProdConcatenatedFieldUpdate', Core_Object__c='Product2', Core_Class_Name__c='Core_ProductHandler',
            Core_Trigger_Events__c='after update', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        triggerEntry = new Core_Trigger_Executions__c(
            Name='opportunityLineItemAfterHandler', Core_Object__c='OpportunityLineItem', Core_Class_Name__c='Core_OpportunityLineItem',
            Core_Trigger_Events__c='after insert, after update, after delete', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        // Create a couple of products, add them to an opportunity, check the concatenated field,
        // then change the name of one of the products and check the concatenated field to make sure
        // it was updated
    
    	Product2 prod1 = new Product2(Name='Test Product 1');
    	Product2 prod2 = new Product2(Name='Test Product 2');
        insert prod1;
        insert prod2;
            
        Opportunity opp = Core_Test_Utility.createOpportunity(1)[0];
        insert opp;
        
        PricebookEntry pbookEntry1 = new PricebookEntry(Product2Id=prod1.Id, UnitPrice=1, isActive=true, Pricebook2Id=Test.getStandardPricebookId(), UseStandardPrice=false);
        PricebookEntry pbookEntry2 = new PricebookEntry(Product2Id=prod2.Id, UnitPrice=1, isActive=true, Pricebook2Id=Test.getStandardPricebookId(), UseStandardPrice=false);
        
        insert pbookEntry1;
        insert pbookEntry2;
        
        OpportunityLineItem oppProd1 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbookEntry1.Id, Quantity=1, TotalPrice=10);
        OpportunityLineItem oppProd2 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbookEntry2.Id, Quantity=1, TotalPrice=10);
        
        insert oppProd1;
        insert oppProd2;
        
        opp = [select Id, Core_Opportunity_Products__c from Opportunity where Id = :opp.Id];
        String oppConcatValue = opp.Core_Opportunity_Products__c;
        System.assert(oppConcatValue.contains('Test Product 1'));
        System.assert(oppConcatValue.contains('Test Product 2'));
        System.assert(!oppConcatValue.contains('Test Product ABC'));
        
        prod1.Name = 'Test Product ABC';
        Test.startTest();
        update prod1;
        Test.stopTest();
        
        opp = [select Id, Core_Opportunity_Products__c from Opportunity where Id = :opp.Id];
        oppConcatValue = opp.Core_Opportunity_Products__c;
        System.assert(!oppConcatValue.contains('Test Product 1'));
        System.assert(oppConcatValue.contains('Test Product 2'));
        System.assert(oppConcatValue.contains('Test Product ABC'));
    }
}