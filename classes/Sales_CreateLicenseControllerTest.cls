/******************************************************
    Component Name    : classSales_CreateLicenseControllerTest
    Created Date  : Jun 2021
    Function      : US981428 test class of classSales_CreateLicenseController
    Modification Log :
    Developer                       Date                    Description
    ananga.mohan.sen@accenture.com  21/06/2021               US981428
    *****************************************************/
@isTest
public class Sales_CreateLicenseControllerTest{
    /*@TestSetup
    static void setupData() {
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        List<Product2> productsToInsert = new List<Product2>();
        Product2 p = Sales_TestDataFactory.createProduct();
        p.SBQQ__SubscriptionTerm__c=10;
        productsToInsert.add(p); 
        Product2 p2 = Sales_TestDataFactory.createProduct();
        productsToInsert.add(p2);
        insert productsToInsert;
        SBQQ__ProductOption__c op1 = Sales_TestDataFactory.createOptionProduct();
        op1.SBQQ__OptionalSKU__c=p.Id;
        op1.SBQQ__ConfiguredSKU__c=p2.Id;
        insert op1;
        List<Core_Product_Ext_Attribute__c> extendedAttributesToInsert = new List<Core_Product_Ext_Attribute__c>();
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Employee';
        l1.Core_Foundation_Product_Id__c=p.id;
        l1.Core_Product_Id__c=p.id;
        extendedAttributesToInsert.add(l1);
        Core_Product_Ext_Attribute__c l2 = Sales_TestDataFactory.createProductExternalAttributes();
        l2.Core_SW_Lic_Group_Id__c = lgp.id;
        l2.Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Free';
        l2.Core_Foundation_Product_Id__c=p2.id;
        l2.Core_Product_Id__c=p2.id;
        l2.Core_SW_Prod_Web_Dsc__c='1 one Quartus';
        l2.Core_SW_Lic_Rehostable_Ind__c=true;
        extendedAttributesToInsert.add(l2);
        insert extendedAttributesToInsert;
    }
    @isTest
    static void shouldGetProductListForEmployee(){
        Test.startTest();
        List<Sales_CreateLicenseController.Sales_CreateLicenseControllerWrapper> wrapObj=Sales_CreateLicenseController.getProductList('Employee');
        Test.stopTest();
        System.assert(wrapObj.size()!=0);
    }
    @isTest
    static void shouldGetProductListForEvalution(){
        Test.startTest();
        List<Sales_CreateLicenseController.Sales_CreateLicenseControllerWrapper> wrapObj=Sales_CreateLicenseController.getProductList('Evalution');
        Test.stopTest();
        System.assert(wrapObj.size()!=0);
    }*/
}