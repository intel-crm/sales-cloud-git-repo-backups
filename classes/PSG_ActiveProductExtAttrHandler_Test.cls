/****************************************************************************************************
Apex Class Name : PSG_ActiveProductExtAttrHandler_Test
Version         : 1.0 
Created Date    : 07/15/2021
Function        : test class for PSG_ActiveProductExtAttrHandler
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya D                    07/15/2021               Created
*****************************************************************************************************/
@isTest
public class PSG_ActiveProductExtAttrHandler_Test {
    @isTest static void createUpdateExtAttrToActiveProductsTest(){
        Product2 preReleaseProduct = new Product2();
        preReleaseProduct.Name='testProduct';
        preReleaseProduct.Core_OPN__c='87067hgtew54s';
        preReleaseProduct.Core_Item_Signal_Cd__c='I2';
        preReleaseProduct.Core_Item_Class_Nm__c = 'SV';
        preReleaseProduct.Core_Hierarchy_ID__c = '59';
        preReleaseProduct.IsActive = true;
        preReleaseProduct.Core_Product_Org__c='Sales';
        insert preReleaseProduct;
        
        Core_Product_Ext_Attribute__c extendedAttribute = new Core_Product_Ext_Attribute__c();
        extendedAttribute.Core_Product_Id__c=preReleaseProduct.id;
        extendedAttribute.Core_Prod_Tool_Type_Nm__c='BASE';
        extendedAttribute.Core_SW_Lic_Type_Nm__c='FIXED';
        extendedAttribute.Core_SW_Lic_Enforcement_Method_Nm__c='File';
        extendedAttribute.Core_SW_Prod_Web_Dsc__c='Desc';
        extendedAttribute.Core_SW_Prod_Max_Rehost_Cnt__c=0;
        extendedAttribute.Core_SW_Lic_File_Data_Encryption_Std_Cd__c='3DES';
        extendedAttribute.Core_SW_Lic_Generator_Parameter_Txt__c='-a';
        insert extendedAttribute;
        Test.startTest();
        Product2 releaseProduct = new Product2();
        releaseProduct.Name='testProduct';
        releaseProduct.Core_OPN__c='87067hgtew54s';
        releaseProduct.Core_Item_Signal_Cd__c='E3';
        releaseProduct.Core_Item_Class_Nm__c = 'SV';
        releaseProduct.Core_Hierarchy_ID__c = '43';
        releaseProduct.IsActive = false;
        releaseProduct.Core_Product_Org__c='Sales';
        insert releaseProduct;
        System.assert(releaseProduct!=null, 'Product inserted');
        
        Product2 releaseProductUpdate = new Product2();
        releaseProductUpdate.Name='testProduct';
        releaseProductUpdate.Id = releaseProduct.Id;
        releaseProductUpdate.Core_OPN__c='87067hgtew54s';
        releaseProductUpdate.Core_Item_Signal_Cd__c='E3';
        releaseProductUpdate.Core_Item_Class_Nm__c = 'SV';
        releaseProductUpdate.Core_Hierarchy_ID__c = '43';
        releaseProductUpdate.IsActive = true;
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(releaseProductUpdate);
        update releaseProductUpdate;
        Test.stopTest();
    }    
}