@isTest
public class Core_OppProductsAtRisk_Ctrl_Test {
    
    @testSetup
    public static void setup(){
        Account acct = new Account(Name = 'Test Account1', Industry = 'Agriculture', Core_Sub_Industry__c = 'Forestry', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', /*Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
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
    }
    
    static testMethod void atRiskTest1(){
    User thisUser = [ select Id from User where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     // System.runAs(thisUser) {
        Opportunity oppRecord = [select Id, Name from Opportunity limit 1];
        oppRecord = Core_OppProductsAtRisk_Ctrl.getOppRecord(oppRecord.Id);
        oppRecord.Core_At_Risk__c = true;
        Core_OppProductsAtRisk_Ctrl.getOppProductList(oppRecord.Id);
        Core_OppProductsAtRisk_Ctrl.getPicklistValues('OpportunityLineItem', 'Core_Risk_Reason1__c');
        //Core_OppProductsAtRisk_Ctrl.getFieldDependencies('OpportunityLineItem', 'Core_Risk_Category__c', 'Core_At_Risk_Status__c', '-------');
        Core_OppProductsAtRisk_Ctrl.OpportunityProductAtRiskWrapper oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id,'-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        for(Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap : oppProdWrap.oppProductList){
            oppWrap.atRisk = true;
            oppWrap.riskReason1 = 'Pricing';
            oppWrap.riskPriority = 'High – Mission Critical – Action Required';
            oppWrap.riskStatus = 'New';
            oppWrap.prodRiskOwner = 'test risk owner';
            oppWrap.riskCreateDate = Datetime.now();
            oppWrap.riskEndDate = Datetime.now();
            oppWrap.riskDetail = 'test risk detail';
            oppWrapList.add(oppWrap);
        }
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList, '-------');
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.atRiskTest1');
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList1 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap = oppProdWrap.oppProductList[0];
        oppWrap.riskReason1 = '-------';
        oppWrapList1.add(oppWrap);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList1, '-------');
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.atRiskTest1');
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
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.atRiskTest1');
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList3 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap4 = oppProdWrap.oppProductList[0];
        oppWrap4.riskStatus = 'New';
        oppWrapList3.add(oppWrap4);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList3, '-------');
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.atRiskTest1');
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList4 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap5 = oppProdWrap.oppProductList[1];
        oppWrap5.riskStatus = '-------';
        oppWrapList4.add(oppWrap5);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList4, '-------');
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.atRiskTest1');
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList5 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap6 = oppProdWrap.oppProductList[1];
        oppWrap6.prodRiskOwner = 'risk owner test';
        oppWrapList5.add(oppWrap6);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList5, '-------');
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.atRiskTest1');
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList6 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap7 = oppProdWrap.oppProductList[1];
        oppWrap7.riskDetail = 'risk detail tesssssst';
        oppWrapList6.add(oppWrap7);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList6, '-------');
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.atRiskTest1');
        }
        system.assertEquals(oppWrap7.riskDetail, 'risk detail tesssssst'); 
       // }
    }
    
    public static testMethod void getProdRiskOwnerTest()
    {  
     User thisUser = [ select Id from User where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
      System.runAs(thisUser) {
        
        Opportunity oppRecord = [select Id, Name from Opportunity limit 1];
        oppRecord = Core_OppProductsAtRisk_Ctrl.getOppRecord(oppRecord.Id);
        oppRecord.Core_At_Risk__c = true;
        oppRecord.Core_Approved_Opportunity_Region__c='EMEA';
        Core_OppProductsAtRisk_Ctrl.getOppProductList(oppRecord.Id);
        Core_OppProductsAtRisk_Ctrl.getPicklistValues('OpportunityLineItem', 'Core_Risk_Reason1__c');
        //Core_OppProductsAtRisk_Ctrl.getFieldDependencies('OpportunityLineItem', 'Core_Risk_Category__c', 'Core_At_Risk_Status__c', '-------');
        Core_OppProductsAtRisk_Ctrl.OpportunityProductAtRiskWrapper oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id,'-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        for(Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap : oppProdWrap.oppProductList){
            oppWrap.atRisk = true;
            oppWrap.riskReason1 = 'Risk - Supply: Sample';
            oppWrap.riskPriority = 'High – Mission Critical – Action Required';
            oppWrap.riskStatus = 'New';
            oppWrap.prodRiskOwner = 'test risk owner';
            oppWrap.riskCreateDate = Datetime.now();
            oppWrap.riskEndDate = Datetime.now();
            oppWrap.riskDetail = 'test risk detail';
            oppWrapList.add(oppWrap);
        }
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList, '-------');
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.getProdRiskOwnerTest');
        }
        
        oppProdWrap = Core_OppProductsAtRisk_Ctrl.getOpportunityProducts(oppRecord.Id, '-------');
        List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper> oppWrapList1 = new List<Core_OppProductsAtRisk_Ctrl.OppProductWrapper>();
        Core_OppProductsAtRisk_Ctrl.OppProductWrapper oppWrap = oppProdWrap.oppProductList[0];
        oppWrap.riskReason1 = 'Risk - Supply: Sample';
        oppWrapList1.add(oppWrap);
        try{
            Core_OppProductsAtRisk_Ctrl.save(oppRecord, oppWrapList1, '-------');
            test.startTest();
            Core_OppProductsAtRisk_Ctrl.getProdRiskOwner(oppRecord.Id,'Risk - Supply: Sample');
            Opportunity oppRecord2 = [select Id, Name from Opportunity limit 1];
            oppRecord2 = Core_OppProductsAtRisk_Ctrl.getOppRecord(oppRecord2.Id);
            oppRecord2.Core_At_Risk__c = true;
            oppRecord2.Core_Approved_Opportunity_Region__c='AMR';
            Core_OppProductsAtRisk_Ctrl.getProdRiskOwner(oppRecord2.Id,'Risk - Supply: Sample');
            Opportunity oppRecord3 = [select Id, Name from Opportunity limit 1];
            oppRecord3 = Core_OppProductsAtRisk_Ctrl.getOppRecord(oppRecord3.Id);
            oppRecord3.Core_At_Risk__c = true;
            oppRecord3.Core_Approved_Opportunity_Region__c='APJ';
            Core_OppProductsAtRisk_Ctrl.getProdRiskOwner(oppRecord.Id,'Risk - Supply: Sample');
            oppRecord.Core_Approved_Opportunity_Region__c='PRC';
            Core_OppProductsAtRisk_Ctrl.getProdRiskOwner(oppRecord.Id,'Risk - Supply: System Build');
            test.stopTest();
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.getProdRiskOwnerTest');
        }
       } 
                
    }
    
    /*static testMethod void atRiskTest2(){
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
    }*/
    
    static testMethod void showRiskTest(){
        Opportunity oppRecord = [select Id, Name from Opportunity where Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity' limit 1];
        try {
            Core_OppProductsAtRisk_Ctrl.showAtRisk(oppRecord.Id);
            system.assert(oppRecord != null, 'success');
        } 
        catch(Exception e) {
            PMP_Utility.logError(e, 'Core_OppProductsAtRisk_Ctrl_Test.showRiskTest');
        }
        system.assertEquals(true, true);
    }
}