@isTest
public class Product_DeactivationAndLogEntryTest {
    @isTest
    public static void testProductDeactivation(){
        List<Product2> productRecordsList= new List<Product2>();
        Product2 productRecord=new Product2();
        productRecord.Core_iPaaS_Load_ID__c='654890';
        productRecord.Core_Product_Org__c='Sales';
        productRecord.Name='Private Wireless Network';	
        productRecord.Core_Hierarchy_ID__c='43';
        productRecord.Core_Hierarchy_Name__c='Valid Product Hierarchy';
        productRecord.Core_Product_Type_EPM_ID__c='86547';
        productRecord.Core_Product_Type__c='Programs';
        productRecord.Core_Product_Status__c='AC';
        productRecord.Core_Product_Name_EPM_ID__c='65498';
        productRecord.IsActive=true;
        productRecordsList.add(productRecord);        
        insert productRecordsList;
        
        Test.startTest();
        Product_DeactivationAndLogEntry obj = new Product_DeactivationAndLogEntry('946598');
        DataBase.executeBatch(obj); 
        Test.stopTest();
        System.assertEquals('Private Wireless Network',productRecord.Name);

    }
            

}