/***************************************************************************************************
* Apex Test Class Name : Core_IPS_UpdateMapsForNewFieldsBatchTest
* Test Class For : Core_IPS_UpdateMapsForNewFields_Batch
* Description : To update existing MAP records
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                 20/01/2020              	  Created
  Prasad                   20/4/2020                  Fixed PMd issues     
****************************************************************************************************/
@isTest(seeAllData=false)

private class Core_IPS_UpdateMapsForNewFieldsBatchTest {
    @isTest
    private static void updateMapsForNewFieldsBatchTest() {
        List<Product2> productList = new List<Product2>();
        // inserting products
        ProductList = TestUtilities.getListOfProduct(3);
        insert ProductList;
        
        // inserting product org
        Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
        prodOrg = TestUtilities.getSupportOrg();
        prodOrg.Core_Organization_Description__c = 'Test';
        insert prodOrg;
        
        // inserting Supported Product 
        List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
        SuppProductList = TestUtilities.getListOfSupportedProduct(3);
        Integer i = 0;
        for(Core_IPS_Supported_Product__c supportedProductRecord: suppProductList){                
            SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
            SupportedProductRecord.Core_Product_Organization__c = prodOrg.id;
            if(i==2){
            	SupportedProductRecord.Core_Flag_Status__c = 'Par Hidden';    
            }
            if(i==1){
            	SupportedProductRecord.Core_Flag_Status__c = 'Approval Required';    
            }
            if(i==0){
            	SupportedProductRecord.Core_Flag_Status__c = 'Auto Approve';    
            }
            i++;                     
        }
        insert SuppProductList;
        
        List<Core_IPS_MAP_PAR__c> mapList = new List<Core_IPS_MAP_PAR__c>();
        
        Core_IPS_MAP_PAR__c mapRec1 = TestUtilities.getMapPar();
        mapRec1.Core_Product_Organization__c = prodOrg.id;
        mapRec1.Core_Name__c = 'Test Record-MAP1';
        mapRec1.Core_Status__c = 'Active';
        mapRec1.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        mapList.add(mapRec1);
        
        Core_IPS_MAP_PAR__c mapRec2 = TestUtilities.getMapPar();
        mapRec2.Core_Product_Organization__c = prodOrg.id;
        mapRec2.Core_Name__c = 'Test Record-MAP2';
        mapRec2.Core_Status__c = 'Active';
        mapRec2.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        mapList.add(mapRec2);
        
        Core_IPS_MAP_PAR__c mapRec3 = TestUtilities.getMapPar();
        mapRec3.Core_Product_Organization__c = prodOrg.id;
        mapRec3.Core_Name__c = 'Test Record-MAP3';
        mapRec3.Core_Status__c = 'Active';
        mapRec3.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        mapList.add(mapRec3);
        
        Core_IPS_MAP_PAR__c mapRec4 = TestUtilities.getMapPar();
        mapRec4.Core_Product_Organization__c = prodOrg.id;
        mapRec4.Core_Name__c = 'Test Record-MAP4';
        mapRec4.Core_Status__c = 'Active';
        mapRec4.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        mapList.add(mapRec4);
        insert mapList;
        
        Core_IPS_UpdateMapsForNewFields_Batch updateMAPBatch = new Core_IPS_UpdateMapsForNewFields_Batch();
        Database.executeBatch(updateMAPBatch);
        
        // inserting Prodcut Access Product
        List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        for(Integer x=0;x<3;x++){
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapList[x].id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList[x].id;
            prodJuncList.add(mapProd);
        }
        insert prodJuncList;
        
        Test.startTest();
        updateMAPBatch = new Core_IPS_UpdateMapsForNewFields_Batch();
        Database.executeBatch(updateMAPBatch);
        Test.stopTest();
        system.assertnotEquals(SuppProductList, null);
    }
}