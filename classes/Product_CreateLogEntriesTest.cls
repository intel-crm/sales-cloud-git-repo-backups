@isTest
public class Product_CreateLogEntriesTest {
@isTest

    public static void testBatchLogEntry(){
        // Create test data for Core_Products_Staging__c records
        List<Core_Products_Staging__c> stagingRecords = new List<Core_Products_Staging__c>();        
        Core_Products_Staging__c stagingRecord1 = new Core_Products_Staging__c();
        stagingRecord1.iPaaS_Load_ID__c = '1687154732679';
        stagingRecord1.Core_Unique_ID__c = '128267';
        stagingRecord1.Core_Product_Org__c = 'Sales';
        stagingRecord1.core_Logging_Type__c = 'OPN_Deactivation';
        stagingRecord1.Core_Hierarchy_ID__c = '43';
        stagingRecords.add(stagingRecord1);
        
        Core_Products_Staging__c stagingRecord2 = new Core_Products_Staging__c();
        //stagingRecord2.iPaaS_Load_ID__c = '1687154732779';
        stagingRecord2.Core_Unique_ID__c = '128267';
        stagingRecord2.Core_Product_Org__c = 'Sales';
        stagingRecord2.core_Logging_Type__c = 'OPN_Deactivation';
        stagingRecord1.Core_Hierarchy_ID__c = '59';
        stagingRecords.add(stagingRecord2);
		insert stagingRecords; 
        
        //populate ipaas Load Id
        List<Product_Inbound_Staging__c> inbList = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<10;i++)
        {
            inbList.add(new Product_Inbound_Staging__c(iPaaS_Load_ID__c='1689681866468',level_1_epm_id__c = '77353',level_1_epm_name__c='Server Products', level_2_epm_id__c = '123'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='128751'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', level_4_epm_id__c='128749'+i, level_4_epm_name__c='Intel® Nervana™ Cloud', level_5_epm_id__c='1287499'+i, Core_Hierarchy_ID__c='43', Core_Hierarchy_Name__c='Valid Product Hierarchy'));
        }
        insert inbList;
        
        //insert Product Log Entry
        List<Product_Log_Entry__c> prodLogEntryList = new List<Product_Log_Entry__c>();
      	Product_Log_Entry__c prdLogEntryRec = new Product_Log_Entry__c();
        prdLogEntryRec.EPM_Id__c ='65900';
            prdLogEntryRec.Ipaas_LoadId__c='1689681866468';
            prdLogEntryRec.Logging_Type__c='OPN_Deactivation';
            prdLogEntryRec.Message__c = '65900_Load_Id_Deactivation';
            prdLogEntryRec.Method_Name__c='OPNDeactivation';
            prdLogEntryRec.Class_Name__c='Product_CreateLogEntriesBatch';
        prodLogEntryList.add(prdLogEntryRec);
        Product_Log_Entry__c prdLogEntryRec1 = new Product_Log_Entry__c();
         prdLogEntryRec1.EPM_Id__c ='65900';
            prdLogEntryRec1.Ipaas_LoadId__c='1689681866468';
            prdLogEntryRec1.Logging_Type__c='OPN_Deactivation';
            prdLogEntryRec1.Message__c = '65900_Load_Id_Deactivation';
            prdLogEntryRec1.Method_Name__c='OPNDeactivation';
            prdLogEntryRec1.Class_Name__c='Product_CreateLogEntriesBatch';
        prodLogEntryList.add(prdLogEntryRec1);
        insert prodLogEntryList;
        
        Test.startTest();
         Product_CreateLogEntriesBatch obj = new Product_CreateLogEntriesBatch();
         DataBase.executeBatch(obj); 
        Test.stopTest();
        
    }
    
}