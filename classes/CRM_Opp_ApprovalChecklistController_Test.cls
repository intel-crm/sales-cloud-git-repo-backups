@isTest
public class CRM_Opp_ApprovalChecklistController_Test {
    
    public static User testUser = new User();
    
    @testSetup
    public static void setUpData() {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
            rec.Bypass__c = true;
            insert rec;   
        }
        Id profileId = [SELECT id, Name FROM Profile WHERE Name='IT Admin'][0].Id;
        
        List<User> users = Core_Test_Utility.Core_User(1);        
        User testUser        = users[0];
        testUser.ProfileId   = profileId;
        testUser.userName    = 'test0'+ testUser.userName ;
        insert testUser;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name = 'Write In Product';
        prod1.IsActive = True;
        prodList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Intel Atom® CE4275 Media Processor';
        prod2.IsActive = TRUE;
        prod2.Core_Avail_for_New_Designs__c = TRUE;
        prod2.Core_Sales_Visible_Flag__c = TRUE;
        prod2.Core_Intel_vPro_Platform_Eligibility__c  = TRUE;       
        prod2.Core_Product_Org__c = 'Sales';
        prod2.Core_Product_Type__c = 'Processors';
        prod2.Core_Hierarchy_ID__c = '43';
        prod2.Core_Group_Code_Short_Name__c = 'CCG';
        prod2.Core_Processor_Number_Nm__c = '1234';
        prodList.add(prod2);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert prodList;
        }
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = prodList[1].Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 10, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        
        List<Account> accountList = new List<Account>();
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id accountRecordTypeInactive = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Inactive Account').getRecordTypeId();
        Account accountInstance = new Account(Name = 'TestoppAcchandle', BillingStreet = '123 Fake St', recordTypeId = accountRecordTypeIntel,
                                              BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                              BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        accountList.add(accountInstance);
        
        Account accountInstance2 = new Account(Name = 'TestoppAcchandleVendor', BillingStreet = '123 Fake St', recordTypeId = accountRecordTypeInactive,
                                              BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                              BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        accountList.add(accountInstance2);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert accountList;
        }
        
        Contact con = Core_Test_Utility.createContacts(1)[0];
        
        Id designOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Id dealOppRecTypeId = [select Id,DeveloperName from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        List<Opportunity> oppList = new List<Opportunity>();
        
        Opportunity opportunityInstance = new Opportunity(RecordTypeId = designOppRecTypeId, Name = 'TestRE1', CloseDate = System.Today().addDays(24), StageName = 'Define', 
                                          AccountId =accountList[0].Id, Core_Product_Segment__c='Client Computing', Core_Consumption_Market__c = 'Education',
                                          Core_Product_Application__c ='Business Mobility', Core_Opportunity_Type__c = 'Design: Original', Description = 'test',
                                          Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity', Core_IsClone__c = False, OwnerId= UserInfo.getUserId(),
                                          Core_Intel_Platform__c='AGILEX', Core_First_Customer_Ship_Date__c=system.today().addDays(5),Core_Exclude_From_KPIs__c=False,
                                          Core_Production_End_Date__c =System.Today().addDays(-10), Core_Military_Aerospace_Govmt_End_Use__c = 'Yes');
        oppList.add(opportunityInstance);
        
        Opportunity opportunityInstance2 = new Opportunity(Name = 'OpportunityBonusPreSubmit', Core_Exclude_From_KPIs__c=True,
                                           Core_Product_Application__c ='Business Mobility',Core_Opportunity_Type__c='Deal: Sell-to',RecordTypeId = dealOppRecTypeId,
                                           AccountId = accountList[0].Id, Core_Product_Segment__c='Client Computing', Core_Competitive_Architecture__c ='DSP',
                                           Core_Consumption_Market__c = 'Education', Description = 'test', Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                                           StageName = 'Define', CloseDate = System.Date.today().addYears(1));
        oppList.add(opportunityInstance2);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppList;
        }
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        OpportunityLineItem OLI_line = new OpportunityLineItem();
        OLI_line.OpportunityId = oppList[0].Id;
        OLI_line.Quantity = 100;
        OLI_line.TotalPrice = 500;
        OLI_line.Product2Id = prodList[1].Id;
        OLI_line.PricebookEntryId = pbe.Id;
        OLI_line.Core_Vendor__c=null;
        OLI_line.Core_Write_In_Product_Flag__c = True;
        oliList.add(OLI_line);
        
        OpportunityLineItem OLI_line2 = new OpportunityLineItem();
        OLI_line2.OpportunityId = oppList[0].Id;
        OLI_line2.Quantity = 100;
        OLI_line2.TotalPrice = 500;
        OLI_line2.Product2Id = prodList[1].Id;
        OLI_line2.PricebookEntryId = pbe.Id;
        OLI_line2.Core_Vendor__c=accountList[1].Id;
        oliList.add(OLI_line2);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oliList;
        }
        
        Note n = new note(parentid=oppList[1].Id,title='test note',body='test note contents');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert n;
        }
        
        Attachment attach=new Attachment();      
        attach.Name='Unit Test Attachment POP';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=oppList[1].Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert attach;
        }
        
        List<Core_CRM_Labels__c> customLabels = new List<Core_CRM_Labels__c>();
        Core_CRM_Labels__c cs1 = new Core_CRM_Labels__c(Name = 'CRM_CheckList_Partner', Value__c = 'Partner');
        customLabels.add(cs1);
        Core_CRM_Labels__c cs2 = new Core_CRM_Labels__c(Name = 'CRM_CheckList_ManuRegion', Value__c = 'Partner');
        customLabels.add(cs2);
        Core_CRM_Labels__c cs3 = new Core_CRM_Labels__c(Name = 'CRM_CheckList_ExcludeFromKPIs', Value__c = 'Partner');
        customLabels.add(cs3);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert customLabels;
        }
        
    }
    
    @isTest
    public static void testFetchDataDesign() {
        
        User testUser = [select id from User limit 1];
        system.runAs(testUser){
            List<Opportunity> optyList = [Select id, Name, CloseDate, StageName, AccountId, Account.RecordType.name from Opportunity where RecordType.DeveloperName = 'Core_Design_Opportunity' limit 1];
            
            Test.startTest();
            CRM_Opp_ApprovalChecklistController.checklistWrapper response = CRM_Opp_ApprovalCheckListController.fetchData(optyList[0].id);
            CRM_Opp_ApprovalChecklistController.checklistTextWrapper response1 = CRM_Opp_ApprovalCheckListController.getCustomLabels();
            Test.stopTest();
            system.assertEquals(true, response<>null);
            system.assertEquals(true, response1<>null);
        }
    }
    
    @isTest
    public static void testFetchDataDeal() {
        
        User testUser = [select id from User limit 1];
        system.runAs(testUser){
            List<Opportunity> optyList = [Select id, Name, CloseDate, StageName, AccountId, Account.RecordType.name from Opportunity where RecordType.DeveloperName = 'Core_Deal_Opportunity' limit 1];            
            Test.startTest();
             CRM_Opp_ApprovalChecklistController.checklistWrapper response = CRM_Opp_ApprovalCheckListController.fetchData(optyList[0].id);
            Test.stopTest();
            system.assertEquals(true, response<>null);
        }
    }
    
    @isTest
    public static void testproductionDateCheck() {
        
        date FirstCustomerShipDate = System.Today();
        date ProductionEndDate = System.Today().addDays(-24);
        
        test.startTest();
        boolean positiveCase1= CRM_Opp_ApprovalChecklistController.productionDateCheck(FirstCustomerShipDate, ProductionEndDate);
        boolean negativeCase1= CRM_Opp_ApprovalChecklistController.productionDateCheck(null, ProductionEndDate);
        boolean negativeCase2= CRM_Opp_ApprovalChecklistController.productionDateCheck(FirstCustomerShipDate, System.Today().addDays(24));
        test.stopTest();
        
        system.assertEquals(false, positiveCase1);
        system.assertEquals(true, negativeCase2);
        system.assertEquals(false, negativeCase1);
    }
    
}