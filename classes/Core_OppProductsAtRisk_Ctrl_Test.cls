@isTest
public class Core_OppProductsAtRisk_Ctrl_Test {
    
    @testSetup
    static void setup(){
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
        insert acct;
        
        // Create a new product
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        insert opportunity;
        
        List<OpportunityLineItem> productList = new List<OpportunityLineItem>();
        // Create a new opportunity line item using the price book entry created above
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opportunity.Id, PricebookEntryId = pbe.Id,
                                                                         Core_Status__c = 'Pending', UnitPrice = 100, Quantity = 100);
        productList.add(opportunityProduct);
        OpportunityLineItem opportunityProduct1 = new OpportunityLineItem(OpportunityId = opportunity.Id, PricebookEntryId = pbe.Id,
                                                                         Core_Status__c = 'Pending', UnitPrice = 100, Quantity = 100);
        productList.add(opportunityProduct1);
        
        insert productList;
    }
    
    static testMethod void atRiskTest1(){
        Opportunity oppRecord = [select Id, Name from Opportunity limit 1];
        oppRecord = Core_OppProductsAtRisk_Ctrl.getOppRecord(oppRecord.Id);
        oppRecord.Core_At_Risk__c = true;
        Core_OppProductsAtRisk_Ctrl.getOppProductList(oppRecord.Id);
        Core_OppProductsAtRisk_Ctrl.getPicklistValues('OpportunityLineItem', 'Core_Risk_Reason1__c');
        Core_OppProductsAtRisk_Ctrl.getFieldDependencies('OpportunityLineItem', 'Core_Risk_Category__c', 'Core_At_Risk_Status__c', '-------');
        Core_OppProductsAtRisk_Ctrl.OpportunityProductAtRiskWrapper oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id,'-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        for(Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap : oppProdWrap.oppProductList){
            oppWrap.atRisk = true;
            oppWrap.riskReason1 = 'Pricing';
            oppWrap.riskReason2 = 'Pricing';
            oppWrap.riskPriority = 'High – Mission Critical – Action Required';
            oppWrap.riskCategory = 'FYI Only';
            oppWrap.riskStatus = 'Support Not Required';
            oppWrapList.add(oppWrap);
        }
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList, '-------');
        }catch(Exception e){
            system.debug('error '+e.getMessage());
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList1 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap = oppProdWrap.oppProductList[0];
        oppWrap.riskReason1 = '-------';
        oppWrapList1.add(oppWrap);
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap1 = oppProdWrap.oppProductList[1];
        oppWrap1.riskReason2 = '-------';
        oppWrapList1.add(oppWrap1);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList1, '-------');
        }catch(Exception e){
            system.debug('error '+e.getMessage());
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList2 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap2 = oppProdWrap.oppProductList[0];
        oppWrapList2.add(oppWrap2);
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap3 = oppProdWrap.oppProductList[1];
        oppWrap3.riskPriority = '-------';
        oppWrapList2.add(oppWrap3);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList2, '-------');
        }catch(Exception e){
            system.debug('Errors '+e.getMessage());
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList3 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap4 = oppProdWrap.oppProductList[0];
        oppWrap4.riskCategory = 'FYI Only';
        oppWrap4.riskStatus = '-------';
        oppWrapList3.add(oppWrap4);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList3, '-------');
        }catch(Exception e){
            system.debug('Errors '+e.getMessage());
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList4 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap6 = oppProdWrap.oppProductList[1];
        oppWrap6.riskCategory = '-------';
        oppWrap6.riskStatus = '-------';
        oppWrapList4.add(oppWrap6);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList4, '-------');
        }catch(Exception e){
            system.debug('Errors '+e.getMessage());
        }
    }
    
    static testMethod void atRiskTest2(){
        Opportunity oppRecord = [select Id, Name from Opportunity limit 1];
        List<OpportunityLineItem> oppProductList = [select Id, Core_Risk_Category__c, Core_At_Risk_Status__c from OpportunityLineItem where OpportunityId =: oppRecord.Id];
        oppProductList[0].Core_Risk_Category__c = 'Support Requested';
        oppProductList[0].Core_At_Risk_Status__c = null;
        update oppProductList[0];
        Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        oppProductList[0].Core_Risk_Category__c = 'Support Requested';
        oppProductList[0].Core_At_Risk_Status__c = 'In-Progress';
        update oppProductList[0];
        Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        oppProductList[0].Core_Risk_Category__c = 'Support Requested';
        oppProductList[0].Core_At_Risk_Status__c = 'Support Granted By HQ';
        update oppProductList[0];
        Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        oppProductList[0].Core_Risk_Category__c = 'Support Requested';
        oppProductList[0].Core_At_Risk_Status__c = 'Support Provided';
        update oppProductList[0];
        Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
    }
}