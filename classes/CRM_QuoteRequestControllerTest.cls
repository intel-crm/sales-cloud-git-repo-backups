@isTest
private class CRM_QuoteRequestControllerTest {
    
    private static testmethod void setupTestData() {
       Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
		
       Account acct = new Account(Name = 'Test Account1', Industry = 'Agriculture', Core_Sub_Industry__c = 'Forestry', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', /*Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c= 'PRC Sales Group');
       	acct.recordtypeID = accountRecordTypeIntel;
        insert acct;

        // Create a new product
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        
        // Create a new opportunity using the account created above
        List<Opportunity> opptyList = new List<Opportunity>();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        opptyList.add(opportunity);
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'Opportunity to Lose 03-24-2024', RecordTypeId = DealOppRecTypeId,
                                          AccountId = acct.Id, OwnerId= UserInfo.getUserId(),
                                          StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        opptyList.add(opp);
        insert opptyList;
        
        
        List<OpportunityLineItem> productList = new List<OpportunityLineItem>();
        // Create a new opportunity line item using the price book entry created above
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opportunity.Id, PricebookEntryId = pbe.Id,
                                                                         Core_Status__c = 'Pending', UnitPrice = 100, Quantity = 100);
        productList.add(opportunityProduct);
        OpportunityLineItem opportunityProduct1 = new OpportunityLineItem(OpportunityId = opportunity.Id, PricebookEntryId = pbe.Id,
                                                                         Core_Status__c = 'Pending', UnitPrice = 100, Quantity = 100);
        productList.add(opportunityProduct1);
        
        insert productList;
        
        Test.startTest();
        CRM_QuoteRequestController.DataFieldsWrapper result = CRM_QuoteRequestController.getQLIWithFieldSet(productList[0].Id);
        system.assert(result.QuoteLineItems.size()==0);
        Test.stopTest();
    }    
}