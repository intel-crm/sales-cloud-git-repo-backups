/**************************************************************************************
Apex Class Name:  Core_IPS_SupportedProduct_Dispatch_Test
Version     : 1.0 
Created Date: 5/10/16
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              5/10/16                Initial Revision
*************************************************************************************/
@istest
public class Core_IPS_SupportedProduct_Dispatch_Test {
 
    static testmethod void test() {
   
        Test.startTest();
        // Insert IPS Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        insert IPSLabels;
 
        Core_IPS_Product_Organization__c suppOrg = Core_IPS_Backend_TestClass_Utility.getSupportOrg();
        insert suppOrg;     
 
        List<Product2> prodlist = new List<Product2>();
        Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
        prod.Core_Product_Org__c='IPS'; //3rd Feb 2016--Validation if we make IPS Flag visible without setting Core_Product_Org__c='IPS'
        Product2 prod1 = new Product2(Name = 'sofia',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
        prod1.Core_Product_Org__c='IPS';
        prodList.add(prod);
        prodList.add(prod1);
        insert prodList;
        
        List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
        Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
        suppProd.Core_Product__c=prod.id;
        suppProd.Core_Product_Organization__c=suppOrg.id;
        suppProdList.add(suppProd);
        
        Core_IPS_Supported_Product__c suppProd1 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
        suppProd1.Core_Product__c=prod1.id;
        suppProd1.Core_Product_Organization__c=suppOrg.id;
        suppProdList.add(suppProd1);            
        
        insert suppProd;
         
        Test.stopTest(); 
    }
        
}