@isTest
public class Core_StartSchedulingController_Test {
    static testMethod void test1(){
        Account acct;
        Account acct2;
        
        acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
                                  Industry = 'Consulting',Core_Sub_Industry__c='Consulting');
        insert acct;
        acct2 = new Account(Name = 'Test Account2', BillingStreet = '122 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        insert acct2;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'Sales Manager'];
            List<User> lstUser = Core_Test_Utility.Core_User(1);
            lstUser[0].Profileid = p1.id;
            insert lstUser;
        Id dealRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        List<opportunity> oppListDeal = core_test_utility.createOpportunity(1);
        oppListDeal[0].Core_Opportunity_Type__c = 'Deal: Sell-to';
        oppListDeal[0].Core_Solution_Area__c ='DCG Compute Deal $';
        oppListDeal[0].AccountId = acct.Id;
        oppListDeal[0].RecordTypeId = dealRecordTypeId;
        
        insert oppListDeal;
        List<opportunity> oppListDesign = core_test_utility.createOpportunity(1); 
        oppListDesign[0].AccountId = acct.Id;
        oppListDesign[0].Core_Opportunity_Type__c = 'Design: Original';
        oppListDesign[0].Core_First_Customer_Ship_Date__c = Date.newInstance(2020, 12, 9);
        oppListDesign[0].Core_Intel_Platform__c = 'Agilex';
        oppListDesign[0].Core_Technical_Owner__c = lstUser[0].id;
        insert oppListDesign;
        //List<opportunity> prodList = core_test_utility.createProduct(1);
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        system.debug('pbe->'+pbe);
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        pbList.add(pbe);
        List <OpportunityLineItem> oppLineList =  core_test_utility.createOpportunityLineItems(1, pbList, oppListDeal[0]);
        oppLineList[0].UnitPrice=200;
        insert oppLineList;
        Core_StartSchedulingController.forecastWrapper frwrpr = new Core_StartSchedulingController.forecastWrapper();
            
        test.startTest();
        
        boolean warning = Core_StartSchedulingController.checkOldFCRecords(oppListDeal[0].id);
        //date startDate,integer selectedQuarters, String opportunityId
        frwrpr = Core_StartSchedulingController.showQuarters(oppListDeal[0].id);
        frwrpr = Core_StartSchedulingController.showQuarters(oppListDesign[0].id);
        frwrpr = Core_StartSchedulingController.submitData('2020-Q2',6,oppListDeal[0].id);
        frwrpr = Core_StartSchedulingController.submitData('2020-Q2',6,oppListDesign[0].id);
        test.stopTest();
        system.assertEquals(warning, false);
        
        
    }
    static testMethod void test2(){
        Account acct;
        
        acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
                                  Industry = 'Consulting',Core_Sub_Industry__c='Consulting');
        insert acct;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'Sales Manager'];
        List<User> lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        List<opportunity> oppListDesign = core_test_utility.createOpportunity(1); 
        oppListDesign[0].AccountId = acct.Id;
        oppListDesign[0].Core_Opportunity_Type__c = 'Design: Original';
        oppListDesign[0].Core_First_Customer_Ship_Date__c = Date.newInstance(2020, 12, 9);
        oppListDesign[0].Core_Intel_Platform__c = 'Agilex';
        oppListDesign[0].Core_Technical_Owner__c = lstUser[0].id;
        insert oppListDesign;

        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        system.debug('pbe->'+pbe);
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        pbList.add(pbe);
        List <OpportunityLineItem> oppLineList =  core_test_utility.createOpportunityLineItems(1, pbList, oppListDesign[0]);
        oppLineList[0].UnitPrice=300;
        insert oppLineList;
        Core_StartSchedulingController.forecastWrapper frwrpr = new Core_StartSchedulingController.forecastWrapper();
            
        test.startTest();
        
        frwrpr = Core_StartSchedulingController.showQuarters(oppListDesign[0].id);
        frwrpr = Core_StartSchedulingController.submitData('2020-Q2',6,oppListDesign[0].id);
        test.stopTest();
    }
}