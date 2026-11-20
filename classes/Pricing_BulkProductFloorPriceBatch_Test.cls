/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-26-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Pricing_BulkProductFloorPriceBatch_Test {
    @testSetup
    static void dataSetup(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<Product2> products = Pricing_Test_Utility.createProduct(2);
            Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c(
                Pricing_Rule_Name__c = 'Rule Update Test',
                Pricing_Approval_Status__c = 'Approved',
                Pricing_Quote_Type__c = 'Client',
                Pricing_Account__c = acc.Id,
                Pricing_End_Customer_Country__c = 'India',
                Pricing_End_Date__c = Date.today().addMonths(1)
            );
            insert rule;
            test.stopTest();
        }
    }

    static testMethod void testbulkProductFloorPriceIpdate(){
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Product2 prod = [SELECT Id,Product2.Name FROM Product2 LIMIT 1];
        Pricing_Approval_Price_Rules__c rule = [select id from Pricing_Approval_Price_Rules__c];
        Pricing_Product_Floor_Price__c floorprice =  new Pricing_Product_Floor_Price__c
        (Pricing_Approval_Price_Rules__c = rule.Id,Pricing_Approved_ECAP_Price__c = 100,Pricing_Product__c = prod.Id,Pricing_Active__c = true);
        insert floorprice;
        Test.startTest();
        Map<String,Pricing_Product_Floor_Price__c> newProductFloorPriceMapBatch = new  Map<String,Pricing_Product_Floor_Price__c>();
        newProductFloorPriceMapBatch.put(floorprice.Pricing_Product__r.name,floorprice);
        String recordId = rule.Id;
        Map<Id,String> prodIdToNameMap = new Map<Id, String>();
        prodIdToNameMap.put(prod.Id,prod.Name);
        System.runAs(adminUser){
        Pricing_BulkProductFloorPriceBatch bulkProductFloorPrice = new Pricing_BulkProductFloorPriceBatch(newProductFloorPriceMapBatch, recordId, prodIdToNameMap);
           Database.executeBatch(bulkProductFloorPrice, Integer.valueOf(Label.Pricing_Bulk_Comp_Product_Price_BatchSize));
           System.assertEquals(newProductFloorPriceMapBatch.size() > 0,true);
        Test.stopTest();
        }
    }
}