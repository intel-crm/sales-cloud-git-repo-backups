@IsTest
public with sharing class Product_HierarchyDataTest {
    @testSetup static void setup() {
        List<Product2> productInsertList = new List<Product2>();
        // Create Product
        Product2 productRecord = new Product2(
            Name = 'Haswell EP',
            Core_Sales_Visible_Flag__c = true,
            Core_Product_Org__c = 'Sales',
            IsActive = true,
            Core_Hierarchy_ID__c = '43',
            Core_Unique_ID__c = '123456;12345',
            Core_Product_Name_EPM_ID__c='12345',
            Core_Product_Group_EPM_ID__c='12345',
            Core_Product_Series_EPM_ID__c='12345',
            Core_Product_Family_EPM_ID__c='12345',
            Core_Product_Type_EPM_ID__c='12345'
        );
        productInsertList.add(productRecord);
        productRecord = new Product2(
            Name = 'Haswell EP',
            Core_Sales_Visible_Flag__c = true,
            Core_Product_Org__c = 'Sales',
            IsActive = true,
            Core_Hierarchy_ID__c = '43',
            Core_Unique_ID__c = '12347',
            Core_Product_Name_EPM_ID__c='12347',
            Core_Product_Group_EPM_ID__c='12345',
            Core_Product_Series_EPM_ID__c='12345',
            Core_Product_Family_EPM_ID__c='12345',
            Core_Product_Type_EPM_ID__c='12345'
        );
        productInsertList.add(productRecord);
        productRecord = new Product2(
            Name = 'Haswell EP2',
            Core_Sales_Visible_Flag__c = true,
            Core_Product_Org__c = 'Sales',
            IsActive = true,
            Core_Hierarchy_ID__c = '59',
            Core_Code_Name_EPM_ID__c='21234',
            Core_Platform_Config_EPM_ID__c='2333',
            Core_Platform_EPM_ID__c='333',
            Core_Unique_ID__c = '12346'
        );
        productInsertList.add(productRecord);	
        insert productInsertList;
    }
    @isTest
    static void testgetProducts() {
        test.startTest();
        Product_HierarchyData.WrapperClass phWarpper = Product_HierarchyData.getProducts('43','true');
        Product_HierarchyData.getProducts('59','false');
        Product_HierarchyData.getProducts('59','true');
        test.stopTest();
        System.assertEquals(2, phWarpper.prodData.size());
    }
    @isTest
    static void testgetProductHistory() {
        List<product2> prodList = [Select Id from Product2];
        test.startTest();
        List<Product2History> phList = Product_HierarchyData.getProductHistory(prodList[0].Id);
        test.stopTest();
        System.assertEquals(0, phList.size());            
    }    
}