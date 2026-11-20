@isTest
public class Core_IPS_MapCreationController_LWC_Test {
    
    
    public static Core_IPS_Supported_Product__c ProdOrg;
    public static List<Product2> ProductList = new List<Product2>();
    public static List<Core_IPS_Supported_Product__c> SuppProductList = new List<Core_IPS_Supported_Product__c> ();
    public static List<User> ListOfUser = new List<User> ();
    public static Core_IPS_Product_Organization__c orgProd;
    public static Account a;
    public static List<Account> lstAcc = new List<Account>();

    public static void testSetupdata(){

        Account a = TestUtilities.getAccountRecord();
        a.Name = 'Test';
        a.Core_IPS_Active__c = true;
        a.Core_CNDA_Number__c = '121';
        insert a;
        lstAcc.add(a);
        orgProd = new Core_IPS_Product_Organization__c(
            Core_IPS_Support_Org_Name__c = 'Test',
            Core_Organization_Description__c = 'Test'        
        );
        
        insert orgProd;
        
        
        ProductList = TestUtilities.getListOfProduct(2);
        ProductList[0].Name = 'Intel';
        ProductList[1].Name = 'Intel2';
        insert ProductList;
        
        ProdOrg = TestUtilities.getSupportedProduct();
        ProdOrg.Core_Product__c = ProductList[0].id;
        ProdOrg.Core_EOIS__c = false;
        ProdOrg.core_IPS_public_product__c = false;
        ProdOrg.Core_Product_Organization__c = orgProd.id;
        insert ProdOrg;

    }
    
    @isTest
    public static void searchAccountTest(){       
        Test.startTest();
        Core_IPS_MapCreationController_LWC.searchAccounts('test', 10, 0);
        Test.stopTest();
    }
    
    @isTest
    public static void testAllMethods(){
        
        testSetupdata();
        
        Core_IPS_Product_Organization__c rec = [SELECT Id, name from Core_IPS_Product_Organization__c where Id = :orgProd.id];
        
        Test.startTest();
        Core_IPS_MapCreationController_LWC.ProductAndMapProdToSupProd proMap = Core_IPS_MapCreationController_LWC.searchProducts(rec.id, 'Intel', 10, 0);
        Core_IPS_MapCreationController_LWC.getProductList(ProductList);
        List<Core_IPS_MapCreationController_LWC.WrapLineItem> items = Core_IPS_MapCreationController_LWC.getLineItemsmethod(lstAcc, proMap.searchProducts, rec.Id, proMap.mapProdToSupProd1 );
        Core_IPS_MAP_PAR__c map1  = Core_IPS_MapCreationController_LWC.createMapNew(items, proMap.mapProdToSupProd1, 'Test', rec.Id );
        Test.stopTest();
        
    }
    
}