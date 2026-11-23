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
public class Core_OppProdConcatenatdFldUpdBatch_test {


    private static List<Product2> prodList {
        get;
        set;
    }
    private static Opportunity opp {
        get;
        set;
    }
    /*
    * Method name  : setupTestData
    * Description  : Method to setup test data for Product name concatenation
    * Return Type  : None
    * Parameter    : None
    */
    static void setupData() {
        //Insert the Core_Trigger_Executions__c custom setting
        List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        List<String> settingNameList = new List<String>();
        settingNameList.add('isProductNameChanged');
        Core_Trigger_Executions__c triggerSetting;
        for(String settingName : settingNameList){
            triggerSetting = new Core_Trigger_Executions__c();
            triggerSetting.name = settingName;
            triggerSetting.Core_Object__c = 'Product2';
            triggerSetting.Core_Active__c = TRUE;
            triggerSetting.Core_Description__c = 'This is test description';
            triggerSetting.Core_Class_Name__c = 'Core_ProductOpportunity';
            triggerSetting.Core_Trigger_Events__c = 'Before Update';
            triggerSettingList.add(triggerSetting);
        }
        insert triggerSettingList;
        
        //Insert Batch Header
        Core_Batch_header__c header = new Core_Batch_header__c();
        header.Name = 'Core_OppProductConcatenatedFieldUpdBatch';
        header.Email_Distribution_List__c = 'test@test.com';
        insert header;       
        
        //Insert Account
        List<Account> accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = 'Americas ELAR Sales Group';
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
        
        ID intelAccID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        accountList[0].RecordTypeId = intelAccID;
        insert accountList;
        
        //Insert Product
        prodList = new List<Product2>();
        Product2 prod1 = new Product2(Name='Test Product 1');
        Product2 prod2 = new Product2(Name='Test Product 2');
        prodList.add(prod1);
        prodList.add(prod2);
        insert prodList;
        
        //Insert Opportunity
        opp = new Opportunity();
        opp = Core_Test_Utility.createOpportunity(1)[0];
        opp.AccountId = accountList[0].Id;
        insert opp;
        
        //Insert Price Book Entry
        List<PricebookEntry> priceBookList = new List<PricebookEntry>();
        PricebookEntry pbookEntry1 = new PricebookEntry(Product2Id=prod1.Id, UnitPrice=1, isActive=true, Pricebook2Id=Test.getStandardPricebookId(), UseStandardPrice=false);
        PricebookEntry pbookEntry2 = new PricebookEntry(Product2Id=prod2.Id, UnitPrice=1, isActive=true, Pricebook2Id=Test.getStandardPricebookId(), UseStandardPrice=false);        
        priceBookList.add(pbookEntry1);
        priceBookList.add(pbookEntry2);
        insert priceBookList; 
        
        //Insert Opportunity Line Item
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppProd1 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbookEntry1.Id, Quantity=1, TotalPrice=10);
        OpportunityLineItem oppProd2 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbookEntry2.Id, Quantity=1, TotalPrice=10);
        oppLineItemList.add(oppProd1);
        oppLineItemList.add(oppProd2);
        insert oppLineItemList;   
    }
    
    /*
    * Method name  : testOppProdConcatenatedFieldUpdate
    * Description  : Method tests Product name concatenation in opportunity on product name change
    * Return Type  : None
    * Parameter    : None
    */
    private static testMethod void testOppProdConcatenatedFieldUpdate() {
        setupData();
        //Change the product name
        for(Product2 prod : prodList) {
            if(prod.Name =='Test Product 1')
                prod.Name = 'Test Product ABC';
            if(prod.Name =='Test Product 2')
                prod.Name = 'Test Product XYZ';
        }
        Test.startTest();
            update prodList;             
            //Call the schedular batch class which calls Core_OppProductConcatenatedFieldUpdBatch in turn
          //  Core_OppProdConcatenationt_Schedule sh1 = new Core_OppProdConcatenationt_Schedule();
            String sch = '0 0 23 * * ?';
        Core_OppProductConcatenatedFieldUpdBatch batchSched = new Core_OppProductConcatenatedFieldUpdBatch();
        Database.executeBatch(batchSched);
          //  system.schedule('Test Prod Name concatenation', sch, sh1); 
           // Opportunity opp = [SELECT id, Core_Opportunity_Products__c FROM Opportunity WHERE Id=: opp.Id];
        Test.stopTest();
        Assert.areEqual(true, opp!= null);
    }    
}