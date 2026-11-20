@isTest
public class Core_CRM_Utility_Test {
    @isTest
    static void getCustomSettinggCRMLabelTest(){
        List<Core_CRM_Labels__c> CRMLabelList = new List<Core_CRM_Labels__c>();
        CRMLabelList.add(new Core_CRM_Labels__c(Name='CRMLabel1', Value__c='Value1'));
        CRM_UCD_CIM_switch__c UCDSwitch = new CRM_UCD_CIM_switch__c(Name ='UCD_switch',Active__c = true);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert CRMLabelList;
            insert UCDSwitch;
        }
        Test.startTest();
        string label1 = Core_CRM_Utility.getCRMLabel('CRMLabel1');
        string label2 = Core_CRM_Utility.getCRMLabel('CRMLabel2');
        boolean check = Core_CRM_Utility.isUCDSwitchOn();
        Test.stopTest();
    }
    static testMethod void PCCDealReg_showTab_Test(){
        
          Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI(), Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
       
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
      
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'Opportunity to Lose 03-24-2024', RecordTypeId = DealOppRecTypeId,
                                          AccountId = acct.Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                          StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        //opp.Opportunity_Focus__c= 'Core';
        opp.Core_Opportunity_Type__c ='Deal: Partner Scale-enable';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opp;
        }
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        List<OpportunityLineItem> productList = new List<OpportunityLineItem>();
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id,
                                                                         Core_Status__c = 'Pending', UnitPrice = 100, Quantity = 100);
        productList.add(opportunityProduct);
        OpportunityLineItem opportunityProduct1 = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id,
                                                                         Core_Status__c = 'Pending', UnitPrice = 100, Quantity = 100);
        productList.add(opportunityProduct1);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c bp = new Core_Opp_Bypass_Validation_Rule__c();
            bp.Bypass__c = true;
            bp.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            insert bp;
            insert productList;
        }
        Test.startTest();
        Boolean isTest=Core_CRM_Utility.PCCDealReg_showTab(opp.id);
        Boolean isLock=Core_CRM_Utility.lockOpportunity(new List<Opportunity>{opp});
        Test.stopTest();
        System.assertEquals(True , isTest<>null );        
        System.assertEquals(True , isLock<>null );        

    }
    
    @isTest static void testCompetitorData(){
        //TWC4767-3990 
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;

        List<Account> accountList = Core_Test_Utility.createAccount(1);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Telecommunications';
        accountList[0].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[0].RecordTypeId =  newAccountRecTypeId;
        insert accountList;
        
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        Opportunity opp = listOpportunity[0];    
        opp.AccountId = accountList[0].Id;
        opp.Opportunity_Focus__c= 'Core';
        opp.Core_Opportunity_Type__c='Design: Original';
        
        System.runAs(Core_Test_Utility.systemAdminUser){          
            insert opp;
        }
        
        Product2   pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Sales_Visible_Flag__c = true,
                           Core_Group_Code_Short_Name__c = 'AAA');
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert pd2;
        }
        
        // Create and Insert a test PriceBook Entry
       PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        List<PricebookEntry> listPBE = new List<PricebookEntry>();
        for (Integer i = 0; i < 10; i++) {
            listPBE.add(testPBE);
        }
        
        Core_CRM_Utility.getDependantPickListValues('OpportunityLineItem.Core_Competitor_Product__c');
        Core_CRM_Utility.getOppItemPickListValues('OpportunityLineItem.Core_Competitor__c');
        
         List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;
        Core_CRM_Utility.updateCompetitorData( 'AMD' , 'None','Test', opp.Id);
       
        }
        
    @isTest static void getTagsCountTest(){
        Test.startTest();
        Map<String, Object> result = Core_CRM_Utility.getTagsWithCount(5, 0, '');
        Test.stopTest();
        System.assertEquals(true,result.size() > 1);
    }   
}