@isTest
public class CSF_Product_UtilityTest {
    @isTest static void IsProductDeactivatedTestMethod(){
        String ProdStatus = 'OB;RP;RT;NO';
        system.assertEquals(true, Product_Utility.IsProductDeactivated(true, prodStatus));
        system.assertEquals(false, Product_Utility.IsProductDeactivated(false, prodStatus));
    }
    
    @isTest static void concatenateEpmIdsTestMethod(){
        String uniqueId;
        Core_Products_Staging__c stgRecVPH = new Core_Products_Staging__c();
        stgRecVPH.Core_Product_Name_EPM_ID__c='5';
        stgRecVPH.Core_Product_Group_EPM_ID__c='4';
        stgRecVPH.Core_Product_Series_EPM_ID__c='3';
        stgRecVPH.Core_Product_Family_EPM_ID__c='2';
        stgRecVPH.Core_Product_Type_EPM_ID__c='1';
        stgRecVPH.Core_Hierarchy_ID__c = '43';
        Core_Products_Staging__c stgRecVPLCH = new Core_Products_Staging__c();
        stgRecVPLCH.Core_Product_Name_EPM_ID__c='5';
        stgRecVPLCH.Core_Code_Name_EPM_ID__c='4';
        stgRecVPLCH.Core_Product_Type_EPM_ID__c='3';
        stgRecVPLCH.Core_Platform_Config_EPM_ID__c='2';
        stgRecVPLCH.Core_Platform_EPM_ID__c='1';
        stgRecVPLCH.Core_Hierarchy_ID__c = '59';
        system.assertEquals('5;4;3;2;1', Product_Utility.concatenateEpmIds(stgRecVPH));
        system.assertEquals('5;4;3;2;1', Product_Utility.concatenateEpmIds(stgRecVPLCH));
    }
    @isTest static void getObjectFieldsTestMethod(){
        String objName = 'Core_Products_Staging__c';
        List<String> fieldsList = new List<String>();
        fieldsList = Product_Utility.getObjectFields(objName);
        System.assertNotEquals(null, fieldsList.size());
    }
    @isTest static void getOPNTestMethod(){
        String value='MAVinci SIRIUS™ PRO* UAS SRSMV101190';
        String value2 = '';
        System.assertEquals('SRSMV101190',product_utility.getOPN(value));
        System.assertEquals('',product_utility.getOPN(null));
    }
    
    @isTest static void concatenateEpmIdsFPHTestMethod(){
        String uniqueId;     
        Core_Products_Staging__c stgRec = new Core_Products_Staging__c();
        stgRec.Core_L5_EPM_ID__c='5';
        stgRec.Core_L4_EPM_ID__c='4';
        stgRec.Core_L3_EPM_ID__c='3';
        stgRec.Core_L2_EPM_ID__c='2';
        stgRec.Core_L1_EPM_ID__c='1';
        Test.startTest();        
        System.assertEquals('5;4;3;2;1',product_utility.concatenateEpmIdsFPH(stgRec));
        Test.stopTest();
    }
    @isTest static void processInbStgngMapngTestMethod(){
        Map<String,Product_fields_mapping__mdt> salesConfigMap = new  Map<String,Product_fields_mapping__mdt>();
        salesConfigMap = product_utility.getSalesConfigurationMap();        
        //vph record
        Product_Inbound_Staging__c inbRecordVPH = new Product_Inbound_Staging__c();        
        inbRecordVPH.Core_Hierarchy_ID__c='43';
        inbRecordVPH.Core_Hierarchy_Name__c='Valid Product Hierarchy';
        inbRecordVPH.iPaaS_Load_ID__c='8778788887';
        inbRecordVPH.L4_CoreCount__c='2';
        inbRecordVPH.L5_Division_withBracket__c='MMId101-130314';
        inbRecordVPH.L5_Group_withBracket__c='MMId101-120165';
        inbRecordVPH.L5_MaterialStatusCode__c='MMId101-RT';
        inbRecordVPH.L5_Opcode__c='MMId101-CY';
        inbRecordVPH.level_1_epm_id__c='98836';
        inbRecordVPH.level_1_epm_name__c='Intel® FPGAs';
        inbRecordVPH.level_2_epm_id__c='70322';
        inbRecordVPH.level_2_epm_name__c='Telecommunication and Gateways';
        inbRecordVPH.level_3_epm_id__c='47338';
        inbRecordVPH.level_3_epm_name__c='Intel® CE Media Processors';
        inbRecordVPH.level_4_epm_id__c='75920';
        inbRecordVPH.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbRecordVPH.level_5_epm_id__c='190400';
        inbRecordVPH.level_5_epm_name__c='Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray';        
        //vplch record
        Product_Inbound_Staging__c inbRecordVPLCH = new Product_Inbound_Staging__c();        
        inbRecordVPLCH.Core_Hierarchy_ID__c='59';
        inbRecordVPLCH.Core_Hierarchy_Name__c='Valid Product CodeName Hierarchy';
        inbRecordVPLCH.iPaaS_Load_ID__c='8778788887';
        inbRecordVPLCH.L4_CoreCount__c='2';
        inbRecordVPLCH.L4_MaxTDP__c='10 W';
        inbRecordVPLCH.L5_Division_withBracket__c='MMId102-130314';
        inbRecordVPLCH.L5_Group_withBracket__c='MMId102-120165';
        inbRecordVPLCH.L5_MaterialStatusCode__c='MMId102-RT';
        inbRecordVPLCH.L5_Opcode__c='MMId102-CY';
        inbRecordVPLCH.level_1_epm_id__c='69130';
        inbRecordVPLCH.level_1_epm_name__c='Smart and Connected Home';
        inbRecordVPLCH.level_2_epm_id__c='70322';
        inbRecordVPLCH.level_2_epm_name__c='Telecommunication and Gateways';
        inbRecordVPLCH.level_3_epm_id__c='98836';
        inbRecordVPLCH.level_3_epm_name__c='Intel® FPGAs';
        inbRecordVPLCH.level_4_epm_id__c='75920';
        inbRecordVPLCH.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbRecordVPLCH.level_5_epm_id__c='190400';
        inbRecordVPLCH.level_5_epm_name__c='Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray';    
        Core_Products_Staging__c stagingRecVPH = new Core_Products_Staging__c(); 
        stagingRecVPH = product_utility.processInbStgngMapng(inbRecordVPH, salesConfigMap.get('4'));        
        Core_Products_Staging__c stagingRecVPLCH = new Core_Products_Staging__c();
        stagingRecVPLCH = product_utility.processInbStgngMapng(inbRecordVPLCH, salesConfigMap.get('4'));
        Test.startTest();  
        system.assertEquals(stagingRecVPH, product_utility.processInbStgngMapng(inbRecordVPH, salesConfigMap.get('4')));
        Test.stopTest();
    }
    @isTest static void processInbStngFPHRecordsTestMethod(){  
        //vph when four levels available        
        Product_Inbound_Staging__c inbRecordVPH = new Product_Inbound_Staging__c();        
        inbRecordVPH.Core_Hierarchy_ID__c='43';
        inbRecordVPH.Core_Hierarchy_Name__c='Valid Product Hierarchy';
        inbRecordVPH.iPaaS_Load_ID__c='8778788887';
        inbRecordVPH.level_1_epm_id__c='69130';
        inbRecordVPH.level_1_epm_name__c='Smart and Connected Home';
        inbRecordVPH.level_2_epm_id__c='70322';
        inbRecordVPH.level_2_epm_name__c='Telecommunication and Gateways';
        inbRecordVPH.level_3_epm_id__c='47338';
        inbRecordVPH.level_3_epm_name__c='Intel® CE Media Processors';
        inbRecordVPH.level_4_epm_id__c='75920';
        inbRecordVPH.level_4_epm_name__c='Intel Atom® Processor CE5300';     
        //vplch only one level available
        Product_Inbound_Staging__c inbRecordVPLCHL1 = new Product_Inbound_Staging__c();        
        inbRecordVPLCHL1.Core_Hierarchy_ID__c='59';
        inbRecordVPLCHL1.Core_Hierarchy_Name__c='Valid Product CodeName Hierarchy';
        inbRecordVPLCHL1.iPaaS_Load_ID__c='8778788887';
        inbRecordVPLCHL1.level_1_epm_id__c='98836';
        inbRecordVPLCHL1.level_1_epm_name__c='Intel® FPGAs';        
        //vplch when two levels available
        Product_Inbound_Staging__c inbRecordVPLCHL2 = new Product_Inbound_Staging__c();        
        inbRecordVPLCHL2.Core_Hierarchy_ID__c='59';
        inbRecordVPLCHL2.Core_Hierarchy_Name__c='Valid Product CodeName Hierarchy';
        inbRecordVPLCHL2.iPaaS_Load_ID__c='8778788887';
        inbRecordVPLCHL2.level_1_epm_id__c='69130';
        inbRecordVPLCHL2.level_1_epm_name__c='Smart and Connected Home';
        inbRecordVPLCHL2.level_2_epm_id__c='70322';
        inbRecordVPLCHL2.level_2_epm_name__c='Telecommunication and Gateways';        
        //vplch when three levels available
        Product_Inbound_Staging__c inbRecordVPLCHL3 = new Product_Inbound_Staging__c();        
        inbRecordVPLCHL3.Core_Hierarchy_ID__c='59';
        inbRecordVPLCHL3.Core_Hierarchy_Name__c='Valid Product CodeName Hierarchy';
        inbRecordVPLCHL3.iPaaS_Load_ID__c='8778788887';        
        inbRecordVPLCHL3.level_1_epm_id__c='69130';
        inbRecordVPLCHL3.level_1_epm_name__c='Smart and Connected Home';
        inbRecordVPLCHL3.level_2_epm_id__c='70322';
        inbRecordVPLCHL3.level_2_epm_name__c='Telecommunication and Gateways';
        inbRecordVPLCHL3.level_3_epm_id__c='47338';
        inbRecordVPLCHL3.level_3_epm_name__c='Intel® CE Media Processors';           
        Core_Products_Staging__c stagingRecVPH_FPH = new Core_Products_Staging__c();
        stagingRecVPH_FPH = product_utility.processInbStngFPHRecords(inbRecordVPH);        
        Core_Products_Staging__c stagingRecVPLCHL1_FPH = new Core_Products_Staging__c();
        stagingRecVPLCHL1_FPH = product_utility.processInbStngFPHRecords(inbRecordVPLCHL1);
        Core_Products_Staging__c stagingRecVPLCHL2_FPH = new Core_Products_Staging__c();
        stagingRecVPLCHL2_FPH = product_utility.processInbStngFPHRecords(inbRecordVPLCHL2);
        Core_Products_Staging__c stagingRecVPLCHL3_FPH = new Core_Products_Staging__c();
        stagingRecVPLCHL3_FPH = product_utility.processInbStngFPHRecords(inbRecordVPLCHL3);
        Test.startTest();        
        system.assertEquals(stagingRecVPLCHL1_FPH, product_utility.processInbStngFPHRecords(inbRecordVPLCHL1));
        system.assertEquals(stagingRecVPLCHL2_FPH, product_utility.processInbStngFPHRecords(inbRecordVPLCHL2));
        Test.stopTest();
    }
    @isTest static void processInbStngIPSRecordsTestMethod(){
        Map<String,Product_fields_mapping__mdt> ipsConfigMap = new  Map<String,Product_fields_mapping__mdt>();
        ipsConfigMap = product_utility.getIPSConfigurationMap();
        //vph record
        Product_Inbound_Staging__c inbRecordVPH = new Product_Inbound_Staging__c();        
        inbRecordVPH.Core_Hierarchy_ID__c='43';
        inbRecordVPH.Core_Hierarchy_Name__c='Valid Product Hierarchy';
        inbRecordVPH.iPaaS_Load_ID__c='8778788887';
        inbRecordVPH.L5_Division_withBracket__c='130314';
        inbRecordVPH.L5_Division_withoutBracket__c='Leg 2 Div';
        inbRecordVPH.L5_MaterialStatusCode__c='RT';
        inbRecordVPH.L5_Opcode__c='CY';
        inbRecordVPH.level_1_epm_id__c='98836';
        inbRecordVPH.level_1_epm_name__c='Intel® FPGAs';
        inbRecordVPH.level_2_epm_id__c='70322';
        inbRecordVPH.level_2_epm_name__c='Telecommunication and Gateways';
        inbRecordVPH.level_3_epm_id__c='47338';
        inbRecordVPH.level_3_epm_name__c='Intel® CE Media Processors';
        inbRecordVPH.level_4_epm_id__c='75920';
        inbRecordVPH.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbRecordVPH.level_5_epm_id__c='190400';
        inbRecordVPH.level_5_epm_name__c='Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray';
        //vplch record
        Product_Inbound_Staging__c inbRecordVPLCH = new Product_Inbound_Staging__c();        
        inbRecordVPLCH.Core_Hierarchy_ID__c='59';
        inbRecordVPLCH.Core_Hierarchy_Name__c='Valid Product CodeName Hierarchy';
        inbRecordVPLCH.iPaaS_Load_ID__c='8778788887';
        inbRecordVPLCH.L5_MaterialStatusCode__c='RT';
        inbRecordVPLCH.L5_Opcode__c='CY';
        inbRecordVPLCH.level_1_epm_id__c='69130';
        inbRecordVPLCH.level_1_epm_name__c='Smart and Connected Home';
        inbRecordVPLCH.level_2_epm_id__c='70322';
        inbRecordVPLCH.level_2_epm_name__c='Telecommunication and Gateways';
        inbRecordVPLCH.level_3_epm_id__c='98836';
        inbRecordVPLCH.level_3_epm_name__c='Intel® FPGAs';
        inbRecordVPLCH.level_4_epm_id__c='75920';
        inbRecordVPLCH.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbRecordVPLCH.level_5_epm_id__c='190400';
        inbRecordVPLCH.level_5_epm_name__c='Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray';
        Core_Products_Staging__c stagingRecVPH1 = new Core_Products_Staging__c();
        stagingRecVPH1 = product_utility.processInbStngIPSRecords(inbRecordVPH,1,ipsConfigMap);
        Core_Products_Staging__c stagingRecVPHLCH1 = new Core_Products_Staging__c();
        stagingRecVPHLCH1 = product_utility.processInbStngIPSRecords(inbRecordVPLCH,1,ipsConfigMap);
        Test.startTest();
        system.assertEquals(stagingRecVPHLCH1, product_utility.processInbStngIPSRecords(inbRecordVPLCH,1,ipsConfigMap));
        Test.stopTest();
    }
    @isTest static void createLevelDatawithRollupIPSTestMethod(){
        Map<String,List<Core_Products_Staging__c>> levelDataMap = new Map<String,List<Core_Products_Staging__c>>();
        Integer level;
        String hierarchyId;
        Map<String,Product_fields_mapping__mdt> ipsConfigMap = new Map<String,Product_fields_mapping__mdt>();
        ipsConfigMap = product_utility.getIPSConfigurationMap();
        
        List<Core_Products_Staging__c> tempList = new List<Core_Products_Staging__c>();
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
        stageIPSRecord1 = Product_Utility.processInbStngIPSRecords(inbRec1,5,ipsConfigMap);
        stageIPSRecord2 = Product_Utility.processInbStngIPSRecords(inbRec2,5,ipsConfigMap);
        tempList.add(stageIPSRecord1);
        tempList.add(stageIPSRecord2);
        levelDataMap.put('98836',tempList);        
        Test.startTest();
        product_utility.createLevelDatawithRollupIPS(levelDataMap,3,'43',ipsConfigMap);
        Test.stopTest();
        system.assertEquals(stageIPSRecord1, product_utility.processInbStngIPSRecords(inbRec1,5,ipsConfigMap));
        
    }
    @isTest static void removeDuplicateEntriesTestMethod(){
        String str = 'Telecommunication and Gateways Connected Home';
        system.assertEquals('Telecommunication and Gateways Connected Home',product_utility.removeDuplicateEntries(str));
    }
    @isTest static void createLevelDatawithRollupSalesTestMethod(){
        Map<String,List<Product_Inbound_Staging__c>> levelDataMap = new Map<String,List<Product_Inbound_Staging__c>>();
        List<Product_Inbound_Staging__c> l4WoL5List = new List<Product_Inbound_Staging__c>();
        List<Product_Inbound_Staging__c> inboundList = new List<Product_Inbound_Staging__c>();
        Map<String,Product_fields_mapping__mdt> salesConfigMap = new Map<String,Product_fields_mapping__mdt>();
        salesConfigMap = product_utility.getSalesConfigurationMap();
        List<Core_Products_Staging__c> tempList = new List<Core_Products_Staging__c>();
        
        //test data
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
        Product_Inbound_Staging__c inbRec5 = new Product_Inbound_Staging__c();        
        inbRec5.Core_Hierarchy_ID__c='43';
        inbRec5.level_1_epm_id__c='69134';
        inbRec5.level_1_epm_name__c='Smart and Connected Home';
        inbRec5.level_2_epm_id__c='70326';
        inbRec5.level_2_epm_name__c='Telecommunication and Gateways';
        inbRec5.level_3_epm_id__c='98836';
        inbRec5.level_3_epm_name__c='Intel® FPGAs';
        inbRec5.level_4_epm_id__c='75920';
        inbRec5.level_4_epm_name__c='Intel Atom® Processor CE5300';        
        Core_Products_Staging__c stageIPSRecord1 = new Core_Products_Staging__c();
        stageIPSRecord1 = Product_Utility.processInbStgngMapng(inbRec1,salesConfigMap.get('4'));
        tempList.add(stageIPSRecord1);
        inboundList.add(inbRec1);
        l4WoL5List.add(inbRec5);
        levelDataMap.put('98836',inboundList);
        Test.startTest();
        Product_utility.createLevelDatawithRollupSales(levelDataMap,'Core_Product_Group_EPM_ID__c','43',l4WoL5List,salesConfigMap.get('4'));
        Test.stopTest();
        System.assertEquals(stageIPSRecord1, Product_Utility.processInbStgngMapng(inbRec1,salesConfigMap.get('4')));
        System.assertEquals('Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray', inbRec1.level_5_epm_name__c);
    }
    
    @isTest static void createLogEntryAndNotifyUserTest(){
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = new  Map<String,Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c testTrg= new Core_Trigger_Executions__c();
        testTrg.Core_Active__c = true;
        testTrg.Name =  'AllowProductErrorNotification';
        testTrg.Core_Class_Name__c ='product_utility';
        testTrg.Core_Description__c ='test';
        testTrg.Core_Object__c='test';
        testTrg.Core_Trigger_Events__c = 'test';        
        insert testTrg;
        mapFunctionalityNameTriggerExecution.put('AllowProductErrorNotification',testTrg);          
        Test.startTest();
        Product_utility.createLogEntryAndNotifyUser('Attempt to de-reference a null object','36589','Product_utility',12,'STRATIX 80 GX F43I2LG');
        Test.stopTest();
        System.assertEquals('AllowProductErrorNotification',testTrg.Name);
        
    }
    
    
    @isTest static void processInbStngIPSVplchRecordsTest(){
        Map<String,Product_fields_mapping__mdt> ipsConfigMap = new  Map<String,Product_fields_mapping__mdt>();
        ipsConfigMap = product_utility.getIPSConfigurationMap();
        Product_Inbound_Staging__c inbRecordVPLCH = new Product_Inbound_Staging__c();        
        inbRecordVPLCH.Core_Hierarchy_ID__c='59';
        inbRecordVPLCH.Core_Hierarchy_Name__c='Valid Product CodeName Hierarchy';
        inbRecordVPLCH.iPaaS_Load_ID__c='87765';
        inbRecordVPLCH.L4_CoreCount__c='2';
        inbRecordVPLCH.L4_MaxTDP__c='10 W';
        inbRecordVPLCH.L5_CustomIndicator__c='N';
        inbRecordVPLCH.L5_Division_withBracket__c='130314';
        inbRecordVPLCH.L5_Division_withoutBracket__c='Leg 2 Div';
        inbRecordVPLCH.L5_FamilyName__c='MEDIA';
        inbRecordVPLCH.L5_Group_withBracket__c='120165';
        inbRecordVPLCH.L5_Group_withoutBracket__c='CCG P&L';
        inbRecordVPLCH.L5_MaterialStatusCode__c='RT';
        inbRecordVPLCH.L5_Opcode__c='CY';
        inbRecordVPLCH.level_1_epm_id__c='69130';
        inbRecordVPLCH.level_1_epm_name__c='Smart and Connected Home';
        inbRecordVPLCH.level_2_epm_id__c='70322';
        inbRecordVPLCH.level_2_epm_name__c='Telecommunication and Gateways';
        inbRecordVPLCH.level_3_epm_id__c='98836';
        inbRecordVPLCH.level_3_epm_name__c='Intel® FPGAs';
        inbRecordVPLCH.level_4_epm_id__c='75920';
        inbRecordVPLCH.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbRecordVPLCH.level_5_epm_id__c='190400';
        inbRecordVPLCH.level_5_epm_name__c='Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray';
        insert inbRecordVPLCH;
        
        Test.startTest();
        Map<String,Product_Inbound_Staging__c> ipsPreProcessMap=new Map<String,Product_Inbound_Staging__c>();
        ipsPreProcessMap.put('69130;1',inbRecordVPLCH);
        Product_utility.processInbStngIPSVplchRecords(ipsPreProcessMap,ipsConfigMap);
        Test.stopTest();
        System.assertEquals('Valid Product CodeName Hierarchy',inbRecordVPLCH.Core_Hierarchy_Name__c);
        
    }
}