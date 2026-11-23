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

    private static List<Product2> prodList {
        get;
        set;
    }
    private static List<OpportunityLineItem> oppLineItemList{
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
        List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        List<String> settingNameList = new List<String>();
        settingNameList.add('isProductNameChanged');
        settingNameList.add('updateProductEOL');
        settingNameList.add('updateProcessorNumber');
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
        /***
        List<Account> accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
		***/
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test Account',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI());        
    
        insert acct;
        
        prodList = new List<Product2>();
        Product2 prod1 = new Product2(Name='Test Product 1');
        Product2 prod2 = new Product2(Name='Test Product 2');
        prodList.add(prod1);
        prodList.add(prod2);
        insert prodList;
        prodList[0].Core_SA_Is_EOL__c =true;
        update prodList;
        
        Product2 prod3 = new Product2();
        prod3.Id=prod2.Id;
        prod3.Core_Processor_Number_Ta_Nm__c='testprocessornumber';
        prod3.Core_Product_Type__c ='Processors';
        update prod3;
        
        Product2 prod4 = new Product2();
        prod4.Id=prod2.Id;
        prod4.Core_Processor_Number_Ta_Nm__c='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper portauris massa. Vestibulum lacinia arcu eget nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur sodales ligula in libero. Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor. Morbi lectus risus, iaculis vel, suscipit quis, luctus non, massa. Fusce ac turpis quis ligula lacinia aliquet. Mauris ipsum. Nulla metus metus, ullamcorper vel, tincidunt sed';
        prod4.Core_Product_Type__c ='Processors';
        update prod4;
        
        
        Opportunity opp = Core_Test_Utility.createOpportunity(1)[0];
        opp.AccountId = acct.Id;
        insert opp;
        
        List<PricebookEntry> priceBookList = new List<PricebookEntry>();
        PricebookEntry pbookEntry1 = new PricebookEntry(Product2Id=prod1.Id, UnitPrice=1, isActive=true, Pricebook2Id=Test.getStandardPricebookId(), UseStandardPrice=false);
        PricebookEntry pbookEntry2 = new PricebookEntry(Product2Id=prod2.Id, UnitPrice=1, isActive=true, Pricebook2Id=Test.getStandardPricebookId(), UseStandardPrice=false);        
        priceBookList.add(pbookEntry1);
        priceBookList.add(pbookEntry2);
        insert priceBookList; 
        
        
        
        
        oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppProd1 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbookEntry1.Id, Quantity=1, TotalPrice=10);
        OpportunityLineItem oppProd2 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbookEntry2.Id, Quantity=1, TotalPrice=10);
        oppLineItemList.add(oppProd1);
        oppLineItemList.add(oppProd2);
        insert oppLineItemList;
        
    }
    
    private static testMethod void testOppProdConcatenatedFieldUpdate() {
        setupData();
        for(Product2 prod : prodList){
            if(prod.Name =='Test Product 1')
                prod.Name = 'Test Product ABC';
            if(prod.Name =='Test Product 2')
                prod.Name = 'Test Product XYZ';
        }
        Set<String> lineitemSet = new Set<String>();
        for(OpportunityLineItem o : oppLineItemList){
            lineitemSet.add(o.id);
        }
        Test.startTest();
        update prodList;
        Core_Batch_updateEOL_Retry obj = new Core_Batch_updateEOL_Retry(lineitemSet,prodList,0); 
        DataBase.executeBatch(obj);
        Product2 prod = [SELECT id, Core_Is_Name_Changed_Chk__c FROM Product2 WHERE Id=: prodList[0].Id];
        System.assertEquals(True , prod.Core_Is_Name_Changed_Chk__c );
        Test.stopTest();
    }    
}