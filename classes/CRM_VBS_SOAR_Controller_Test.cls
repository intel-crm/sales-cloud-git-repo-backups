@isTest
public class CRM_VBS_SOAR_Controller_Test {
    @testsetup
    static void setupData() { 
        
        // create Account Record
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        testAccount.Core_Sales_Groups__c = 'PRC Sales Group';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert testAccount;
        }
        
        //create Pricebook Record
        Pricebook2 pricebook = new Pricebook2();
        pricebook.name = 'Standard Price Book';
        pricebook.isActive = TRUE;
        insert pricebook;  
        
        //create Product Records
        List<Product2> lstProduct = new List<Product2>();
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = TRUE;
        product1.Core_Avail_for_New_Designs__c = TRUE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Intel_vPro_Platform_Eligibility__c  = TRUE;
        lstProduct.add(product1);
        
        //Product2 price book entry create scenario
        Product2 product2 = new Product2();
        product2.Name = 'Write In Product';
        product2.IsActive = TRUE;
        product2.Core_Avail_for_New_Designs__c = FALSE;
        product2.Core_Sales_Visible_Flag__c = FALSE;
        product2.Core_Intel_vPro_Platform_Eligibility__c  = TRUE;
        lstProduct.add(product2);
        insert lstProduct;

        // Create a new price book entry using the product created above
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = lstProduct[0].Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 100, IsActive = true);
        PricebookEntryList.add(pbe1);
        PricebookEntry pbe2 = new PricebookEntry(Product2Id = lstProduct[1].Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 1000, IsActive = true);
        PricebookEntryList.add(pbe2); 
        insert PricebookEntryList;
        
        Id designOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = designOppRecTypeId,Core_VBS_Potential__c=true,Core_VBS_Status__c='SOAR1 Qualified',
                                                  AccountId = testAccount.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), 
                                                 Core_Opportunity_Type__c = 'Design: Original');
        insert opportunity;
    }
    
    static testMethod void searchAndFetchtest() {
        Test.startTest();
        String pbeName = [select Id,Name from PricebookEntry where Name = 'Intel Atom® CE4275 Media Processor' limit 1][0].Name;
        
        CRM_VBS_SOAR_Controller.pricebookEntryWrap pbeWrapSearch = CRM_VBS_SOAR_Controller.searchProducts(5,'','Intel',false);
        system.assertEquals(true, pbeWrapSearch<>null); 
        
        CRM_VBS_SOAR_Controller.pricebookEntryWrap pbeWrapSearch2 = CRM_VBS_SOAR_Controller.searchProducts(5,pbeName,'Intel',true);
        system.assertEquals(true, pbeWrapSearch2<>null); 
        
        CRM_VBS_SOAR_Controller.pricebookEntryWrap pbeWrapFetch1 = CRM_VBS_SOAR_Controller.fetchRecords(5,'');
        system.assertEquals(true, pbeWrapFetch1<>null); 
        
        CRM_VBS_SOAR_Controller.pricebookEntryWrap pbeWrapFetch2 = CRM_VBS_SOAR_Controller.fetchRecords(5,pbeName);
        system.assertEquals(true, pbeWrapFetch2<>null); 
        
        Test.stopTest();
    }
    static testMethod void insertSoarProdsDatatest() {
        Opportunity oppRecord = [select Id, Name, Core_VBS_Status__c from Opportunity limit 1];
        system.assertEquals(true, oppRecord<>null); 
        
        CRM_VBS_SOAR__c soar = new 	CRM_VBS_SOAR__c();
        soar.CRM_VBS_SOAR_Opportunity__c = oppRecord.Id;
        soar.CRM_VBS_SOAR_VBS_Decision__c =oppRecord.Core_VBS_Status__c;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert soar;
        }
        Id pd = [select id from Product2][0].Id;
        Id pd2 = [select id from Product2][1].Id;
        
        Test.startTest();
        String jsonSoarProduct = '[{\"CRM_VBS_SOAR__c\":\"'+soar.Id+'\",\"CRM_VBS_Quantity__c\":\"0\",\"CRM_VBS_Total_Price__c\":\"0\",\"CRM_VBS_UnitPrice__c\":350,\"CRM_VBS_Product__c\":\"'+pd+'\"}]';
        CRM_VBS_SOAR_Controller.checklistWrapper vbsProductwrap = CRM_VBS_SOAR_Controller.insertSoarProdsData(jsonSoarProduct,new List<Id> {pd},soar.Id);
        
        String jsonSoarProduct2 = '[{\"CRM_VBS_SOAR__c\":\"'+soar.Id+'\",\"CRM_VBS_Quantity__c\":\"1.2\",\"CRM_VBS_Total_Price__c\":\"0\",\"CRM_VBS_UnitPrice__c\":-35,\"CRM_VBS_Product__c\":\"'+pd2+'\"}]';
        CRM_VBS_SOAR_Controller.checklistWrapper vbsProductwrap2 = CRM_VBS_SOAR_Controller.insertSoarProdsData(jsonSoarProduct2,new List<Id> {pd2},soar.Id);
        
        Test.stopTest();
    }
}