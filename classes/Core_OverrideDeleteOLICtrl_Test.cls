/*
**************************************************************************************
Apex Class  : Core_OverrideDeleteOLICtrl_Test
Version     : 1.0 
Created Date: 24 Aug, 2022
Description : This Class is used validate the errors before submitting the opportunity for approval.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade           12 Sept, 2022             Updated Revision
*/
@isTest
public class Core_OverrideDeleteOLICtrl_Test{
     static testMethod void testMethod1(){
         Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        
     Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI() /*,Core_CIM_ID__c = '8675309'*/);
        insert acct;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        List<opportunity> olist = new List<opportunity>();
        olist.add(oppo);
        
        // Create and Insert a test Product
        Product2 pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA');
        
            insert pd2;
       
        // Create and Insert a test PriceBook Entry
        List<PricebookEntry> listPBE = new List<PricebookEntry>();
        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        
        listPBE = new List<PricebookEntry>();
        for (Integer i = 0; i < 10; i++) {
            listPBE.add(testPBE);
        }
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = oppo.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Lost',
                                                                   Core_Loss_Cancel_Reason__c = 'Lost - Business Relationship',
                                                                   Core_Loss_Cancel_Details__c= 'Lost - Business Relationship',
                                                                   Core_Competitor__c = 'AMD',
                                                                   Core_Competitor_Product__c = 'None',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
         
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = oppo.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');

        insert oppLineItem1;
        insert oppLineItem2;
        Test.startTest(); 
        //oppLineItem1.Core_Status__c = System.Label.Core_LineItem_Status;
        oppLineItemList.add(oppLineItem1);
        oppLineItemList.add(oppLineItem2);
        Update oppLineItemList;
         
        //Test.startTest();
        PageReference testPage = Page.Core_OverrideDeleteOLI;
        Test.setCurrentPage(testPage );
        testPage.getParameters().put('id', oppLineItemList[0].id); 
        ApexPages.StandardController stdController = new ApexPages.StandardController(oppLineItemList[0]);
        Core_OverrideDeleteOLICtrl ext = new Core_OverrideDeleteOLICtrl(stdController);
        ext.checkForDelete();
         testPage.getParameters().put('id', oppLineItemList[1].id); 
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(oppLineItemList[1]);
        Core_OverrideDeleteOLICtrl ext1 = new Core_OverrideDeleteOLICtrl(stdController1);
         ext1.proceed();
        ext1.checkForDelete();
        Test.stopTest();
        
     }
    
    static testMethod void testMethod2(){
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        
    Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI() /*,Core_CIM_ID__c = '8675309'*/);
        insert acct;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        List<opportunity> olist = new List<opportunity>();
        olist.add(oppo);
        
        // Create and Insert a test Product
        Product2 pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA');
        
            insert pd2;
       
        // Create and Insert a test PriceBook Entry
        List<PricebookEntry> listPBE = new List<PricebookEntry>();
        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        
        listPBE = new List<PricebookEntry>();
        for (Integer i = 0; i < 10; i++) {
            listPBE.add(testPBE);
        }
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();

         OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = oppo.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Delete In Progress (<15 min)',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
      
        insert oppLineItem2;
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = oppo.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Win Submitted',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        
        //oppLineItemList.add(oppLineItem);
        insert oppLineItem;   
        oppLineItem2.Core_Status__c = System.Label.Core_LineItem_Status;
        oppLineItemList.add(oppLineItem2);
         oppLineItemList.add(oppLineItem);
        Update oppLineItemList;
        
        Test.startTest();
        PageReference testPage = Page.Core_OverrideDeleteOLI;
        Test.setCurrentPage(testPage );
         /////////////////////////////////
         testPage.getParameters().put('id', oppLineItemList[0].id); 
        ApexPages.StandardController stdController = new ApexPages.StandardController(oppLineItemList[0]);
        Core_OverrideDeleteOLICtrl ext = new Core_OverrideDeleteOLICtrl(stdController);
        ext.checkForDelete();
        ext.back();
         testPage.getParameters().put('id', oppLineItemList[1].id); 
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(oppLineItemList[1]);
        Core_OverrideDeleteOLICtrl ext1 = new Core_OverrideDeleteOLICtrl(stdController1);
        ext1.checkForDelete();      
         ////////////////////////////////
        Test.stopTest();
        
     }
    
     static testMethod void testMethodException(){
     
        Test.startTest();
             List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        
          Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
          
        Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI() /*,Core_CIM_ID__c = '8675309'*/);
        insert acct;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        List<opportunity> olist = new List<opportunity>();
        olist.add(oppo);
        
        // Create and Insert a test Product
        Product2 pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA');
        
            insert pd2;
       
        // Create and Insert a test PriceBook Entry
        List<PricebookEntry> listPBE = new List<PricebookEntry>();
        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        
        listPBE = new List<PricebookEntry>();
        for (Integer i = 0; i < 10; i++) {
            listPBE.add(testPBE);
        }
   

         OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = oppo.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Lost',
                                                                   Core_Loss_Cancel_Reason__c = 'Lost - Business Relationship',
                                                                   Core_Loss_Cancel_Details__c = 'Lost - Business Relationship',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        
        //oppLineItemList.add(oppLineItem);
        insert oppLineItem;   
             
        PageReference testPage = Page.Core_OverrideDeleteOLI;
        Test.setCurrentPage(testPage );
         /////////////////////////////////
         testPage.getParameters().put('id', oppLineItem.id); 
        ApexPages.StandardController stdController = new ApexPages.StandardController(oppLineItem);
        Core_OverrideDeleteOLICtrl ext = new Core_OverrideDeleteOLICtrl(stdController);
       
        ext.checkForDelete();
         ////////////////////////////////
        Test.stopTest();
        
     }
     static testMethod void testMethodWin(){
     
        Test.startTest();
             List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        
          Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
          
        Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI() /*,Core_CIM_ID__c = '8675309'*/);
        insert acct;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        List<opportunity> olist = new List<opportunity>();
        olist.add(oppo);
        
        // Create and Insert a test Product
        Product2 pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA');
        
            insert pd2;
       
        // Create and Insert a test PriceBook Entry
        List<PricebookEntry> listPBE = new List<PricebookEntry>();
        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        
        listPBE = new List<PricebookEntry>();
        for (Integer i = 0; i < 10; i++) {
            listPBE.add(testPBE);
        }
   

         OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = oppo.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Win Submitted',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        
        //oppLineItemList.add(oppLineItem);
        insert oppLineItem;   
         OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = oppo.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'New',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        
        //oppLineItemList.add(oppLineItem);
        insert oppLineItem1;   
        oppLineItem.Core_Status__c = System.Label.Core_LineItem_Status;
        oppLineItemList.add(oppLineItem1);
         oppLineItemList.add(oppLineItem);
        Update oppLineItemList;
        
       
        PageReference testPage = Page.Core_OverrideDeleteOLI;
        Test.setCurrentPage(testPage );
         /////////////////////////////////
         testPage.getParameters().put('id', oppLineItemList[0].id); 
        ApexPages.StandardController stdController = new ApexPages.StandardController(oppLineItemList[0]);
        Core_OverrideDeleteOLICtrl ext = new Core_OverrideDeleteOLICtrl(stdController);
        ext.checkForDelete();
        ext.back();
         testPage.getParameters().put('id', oppLineItemList[1].id); 
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(oppLineItemList[1]);
        Core_OverrideDeleteOLICtrl ext1 = new Core_OverrideDeleteOLICtrl(stdController1);
        ext1.checkForDelete();      
        Test.stopTest();
        
     }

}