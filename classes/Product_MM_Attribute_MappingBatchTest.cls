@isTest
public class Product_MM_Attribute_MappingBatchTest {
    @isTest
	static void TestMethod1(){
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
        productRecord.Core_Unique_ID__c = '65498;65477;67282;86547';
        productRecord.IsActive=true;
        productRecordsList.add(productRecord); 
        insert productRecordsList;
        
        List<Product_MM_Attribute_Mapping__c> mmList = new List<Product_MM_Attribute_Mapping__c>();
        Product_MM_Attribute_Mapping__c mmAttributes = new Product_MM_Attribute_Mapping__c();
		mmAttributes.Level_1_EPM_ID__c = '98836';
        mmAttributes.Level_2_EPM_ID__c = '130101';
        mmAttributes.Level_3_EPM_ID__c = '130103';
        mmAttributes.Level_4_EPM_ID__c = '147261';
        mmAttributes.Level_5_EPM_ID__c = '130211';
        mmAttributes.MMID__c = '768221';
        mmAttributes.Unique_ID__c = '768221;130211;147261;130103;130101;98836';
        mmAttributes.iPaaS_Load_ID__c = '654890';
        mmAttributes.IsActive__c = true;
        mmList.add(mmAttributes);
        insert mmList;
        
        Test.startTest();    
        Database.executeBatch(new Product_MM_Attribute_MappingBatch('654890'));
        Test.stopTest(); 
        System.assertEquals('Sales',productRecord.Core_Product_Org__c);
    }
    
    @isTest
	static void TestMethod2(){
      List<Product2> productRecordsList1= new List<Product2>();
      Product2 productRecord2=new Product2();
        productRecord2.Core_iPaaS_Load_ID__c='654892';
        productRecord2.Core_Product_Org__c='Sales';
        productRecord2.Name='Intel® Cyclone® 10 LP FPGA Evaluation Kit EK-10CL025U256';	
        productRecord2.Core_Hierarchy_ID__c='43';
        productRecord2.Core_Hierarchy_Name__c='Valid Product Hierarchy';
        productRecord2.Core_Product_Type_EPM_ID__c='98836';
        productRecord2.Core_Product_Type__c='Intel® FPGAs';
        productRecord2.Core_Product_Status__c='AC';
        productRecord2.Core_Product_Name_EPM_ID__c='130211';
        productRecord2.Core_Unique_ID__c = '130211;147261;130103;130101;98836';
        productRecord2.IsActive=true;
        productRecordsList1.add(productRecord2);   
        insert productRecordsList1;
        
        List<Product_MM_Attribute_Mapping__c> mmList1 = new List<Product_MM_Attribute_Mapping__c>();
        Product_MM_Attribute_Mapping__c mmAttributes2 = new Product_MM_Attribute_Mapping__c();
		mmAttributes2.Level_1_EPM_ID__c = '86547';
        mmAttributes2.Level_2_EPM_ID__c = '67282';
        mmAttributes2.Level_3_EPM_ID__c = '65477';
        mmAttributes2.Level_4_EPM_ID__c = '65498';
        mmAttributes2.Level_5_EPM_ID__c = '62728';
        mmAttributes2.Name = '89292';
        mmAttributes2.Unique_ID__c = '89292;62728;65498;65477;67282;86547';
        mmAttributes2.iPaaS_Load_ID__c = '654892';
        mmAttributes2.IsActive__c = true;
        mmList1.add(mmAttributes2);
        insert mmList1;
        
         Test.startTest();    
        Database.executeBatch(new Product_MM_Attribute_MappingBatch('654892'));
        Test.stopTest(); 
        System.assertEquals('Sales',productRecord2.Core_Product_Org__c);
    }
    
	@isTest
	static void TestMethod3(){
      List<Product2> productRecordsList2= new List<Product2>();
        Product2 productRecord3=new Product2();
        productRecord3.Core_iPaaS_Load_ID__c='654891';
        productRecord3.Core_Product_Org__c='Sales';
        productRecord3.Name='Intel® Ethernet Controller I210-IT, Tray';	
        productRecord3.Core_Hierarchy_ID__c='43';
        productRecord3.Core_Hierarchy_Name__c='Valid Product Hierarchy';
        productRecord3.Core_Product_Type_EPM_ID__c='36773';
        productRecord3.Core_Product_Type__c='Ethernet Products';
        productRecord3.Core_Product_Status__c='AC';
        productRecord3.Core_Product_Name_EPM_ID__c='324251';
        productRecord3.Core_Unique_ID__c = '324251;627282;738992;728922;36773';
        productRecord3.IsActive=true;
        productRecordsList2.add(productRecord3);    
        insert productRecordsList2;
        
        List<Product_MM_Attribute_Mapping__c> mmList2 = new List<Product_MM_Attribute_Mapping__c>();
        Product_MM_Attribute_Mapping__c mmAttributes3 = new Product_MM_Attribute_Mapping__c();
		mmAttributes3.Level_1_EPM_ID__c = '873';
        mmAttributes3.Level_2_EPM_ID__c = '62829';
        mmAttributes3.Level_3_EPM_ID__c = '28282';
        mmAttributes3.Level_4_EPM_ID__c = '52627';
        mmAttributes3.Level_5_EPM_ID__c = '92020';
        mmAttributes3.Name = '52528';
        mmAttributes3.Unique_ID__c = '52528;92020;52627;28282;62829;873';
        mmAttributes3.iPaaS_Load_ID__c = '722892';
        mmAttributes3.IsActive__c = true;
        mmList2.add(mmAttributes3);
        
        Product_MM_Attribute_Mapping__c mmAttributes4 = new Product_MM_Attribute_Mapping__c();
		mmAttributes4.Level_1_EPM_ID__c = '36773';
        mmAttributes4.Level_2_EPM_ID__c = '728922';
        mmAttributes4.Level_3_EPM_ID__c = '738992';
        mmAttributes4.Level_4_EPM_ID__c = '627282';
        mmAttributes4.Level_5_EPM_ID__c = '324251';
        mmAttributes4.Name = '562621';
        mmAttributes4.Unique_ID__c = '562621;324251;627282;738992;728922;36773';
        mmAttributes4.iPaaS_Load_ID__c = '654891';
        mmAttributes4.IsActive__c = true;
        mmList2.add(mmAttributes4);
        insert mmList2;
        
       Test.startTest();    
       Database.executeBatch(new Product_MM_Attribute_MappingBatch('654891'));
       Test.stopTest(); 
       System.assertEquals('Valid Product Hierarchy',productRecord3.Core_Hierarchy_Name__c);
      }
}