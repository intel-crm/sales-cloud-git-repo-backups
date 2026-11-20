@isTest
public class Product_insStgngRcrdsBatchTest {
    @isTest static void insStgngRcrdsBatchTestMethod(){
        Map<String,Product_fields_mapping__mdt> salesConfigMap = new  Map<String,Product_fields_mapping__mdt>();
        salesConfigMap = product_utility.getSalesConfigurationMap();        
        
        Integer count = 1;
        Map<Integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<Integer,Product_ProcessInboundStagingRecords.InputWrapper>();
        Boolean vplchInd = false;
        string ipaasId = '2323232';
        Set<String> opnLst = new Set<String>();
        List<Core_Products_Staging__c> stgList = new List<Core_Products_Staging__c>();
        Product_Inbound_Staging__c inbRec1 = new Product_Inbound_Staging__c();        
        inbRec1.Core_Hierarchy_ID__c='43';
        inbRec1.level_1_epm_id__c='69130';
        inbRec1.level_1_epm_name__c='Smart and Connected Home';
        inbRec1.level_2_epm_id__c='70322';
        inbRec1.level_2_epm_name__c='Telecommunication and Gateways';
        inbRec1.level_3_epm_id__c='98836';
        inbRec1.level_3_epm_name__c='Intel® FPGAs';
        inbRec1.level_4_epm_id__c='75920';
        inbRec1.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbRec1.level_5_epm_id__c='190400';
        inbRec1.level_5_epm_name__c='Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray';
        Product_Inbound_Staging__c inbRec2 = new Product_Inbound_Staging__c();        
        inbRec2.Core_Hierarchy_ID__c='59';
        inbRec2.level_1_epm_id__c='69131';
        inbRec2.level_1_epm_name__c='Smart and Connected Home';
        inbRec2.level_2_epm_id__c='70323';
        inbRec2.level_2_epm_name__c='Telecommunication and Gateways';
        inbRec2.level_3_epm_id__c='98836';
        inbRec2.level_3_epm_name__c='Intel® FPGAs';
        inbRec2.level_4_epm_id__c='75920';
        inbRec2.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbRec2.level_5_epm_id__c='190400';
        inbRec2.level_5_epm_name__c='Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray';
        Core_Products_Staging__c stageIPSRecord1 = new Core_Products_Staging__c();
        Core_Products_Staging__c stageIPSRecord2 = new Core_Products_Staging__c();
        stageIPSRecord1 = Product_Utility.processInbStngIPSRecords(inbRec1,5,salesConfigMap);
        stageIPSRecord2 = Product_Utility.processInbStngIPSRecords(inbRec2,5,salesConfigMap);
        stgList.add(stageIPSRecord1);
        stgList.add(stageIPSRecord2);
		Test.startTest();
        Database.executeBatch(new Product_insStgngRcrdsBatch(count,stgList,inputWrapperMap,vplchInd,ipaasId,opnLst),1000); 
        Test.stopTest();
        System.assertEquals('Smart and Connected Home',inbRec1.level_1_epm_name__c);

    }    

}