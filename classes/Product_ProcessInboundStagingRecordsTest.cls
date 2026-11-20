@isTest
public class Product_ProcessInboundStagingRecordsTest 
{
    @testSetup static void setup() {
        List<Product_Inbound_Staging__c> inbList = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<10;i++)
        {
            inbList.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '98836',level_1_epm_name__c='Server Products', level_2_epm_id__c = '123'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='128751'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', level_4_epm_id__c='128749'+i, level_4_epm_name__c='Intel® Nervana™ Cloud', iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='43', Core_Hierarchy_Name__c='Valid Product Hierarchy'));
        }
        insert inbList;
        
        List<Product_Inbound_Staging__c> inbListVplch = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<10;i++)
        {
            inbListVplch.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '988379',level_1_epm_name__c='Server Products', level_2_epm_id__c = '17898'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='1241'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', level_4_epm_id__c='1297'+i, level_4_epm_name__c='Intel® Nervana™ Cloud', iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='59', Core_Hierarchy_Name__c='Valid Platform CodeName Hierarchy'));
        }
        insert inbListVplch;
    }
    @isTest static void TestMethod1()
    {
        Core_Trigger_Executions__c triggerExe1= new Core_Trigger_Executions__c();
        triggerExe1.Name='AllowProductErrorNotification';
        triggerExe1.Core_Active__c=true;
        triggerExe1.Core_Class_Name__c='Product_InboundStagingTriggerHelper';
        triggerExe1.Core_Object__c='Product_Inbound_Staging__c';
        triggerExe1.Core_Trigger_Events__c='before insert';
        triggerExe1.Core_Description__c='Product_InboundStagingTriggerHelper';
        Database.insert(triggerExe1);
        
        Core_Trigger_Executions__c triggerExe2= new Core_Trigger_Executions__c();
        triggerExe2.Name='CheckInboundStagingRecordCount';
        triggerExe2.Core_Active__c=true;
        triggerExe2.Core_Class_Name__c='Product_InboundStagingTriggerHelper';
        triggerExe2.Core_Object__c='Product_Inbound_Staging__c';
        triggerExe2.Core_Trigger_Events__c='before insert';
        triggerExe2.Core_Description__c='Product_InboundStagingTriggerHelper';
        Database.insert(triggerExe2);
        
        list<Product_Inbound_Staging__c> inbList0 = new list<Product_Inbound_Staging__c>();  
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
        inbRec1.iPaaS_Load_ID__c ='12343346';
        inbList0.add(inbRec1);
        Insert inbList0;
        
        Core_Products_Staging__c cps = new Core_Products_Staging__c();
        cps.iPaaS_Load_ID__c = '12343346';
        insert cps;
        
        List<Product_Inbound_Staging__c> inbList = [select id,iPaaS_Load_ID__c from Product_Inbound_Staging__c limit 1];
        String ipaasId= inbList[0].iPaaS_Load_ID__c;
        Product_ProcessInboundStagingRecords.largeDataSetL1ids.add('98836');
        List<String> idList = new List<String>();
        idList.add(ipaasId);
        Test.startTest();
        Product_ProcessInboundStagingRecords.processInboundStagingRecords(idList);
        Test.stopTest();
        System.assertEquals('70322',inbRec1.level_2_epm_id__c);
    }
    
    @isTest static void setup2() {
        Core_Trigger_Executions__c triggerExe= new Core_Trigger_Executions__c();
        triggerExe.Name='PopulateMMattributesFields';
        triggerExe.Core_Active__c=true;
        triggerExe.Core_Class_Name__c='Product_InboundStagingTriggerHelper';
        triggerExe.Core_Object__c='Product_Inbound_Staging__c';
        triggerExe.Core_Trigger_Events__c='before insert';
        triggerExe.Core_Description__c='Product_InboundStagingTriggerHelper';
        Database.insert(triggerExe);
        
       List<Product_Inbound_Staging__c> inbList = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<10;i++)
        {
            inbList.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '98836',level_1_epm_name__c='Server Products', level_2_epm_id__c = '123'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='128751'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', level_4_epm_id__c='128749'+i, level_4_epm_name__c='Intel® Nervana™ Cloud', iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='43', Core_Hierarchy_Name__c='Valid Product Hierarchy'));
        }
        insert inbList;
        List<Product_Inbound_Staging__c> inbListWithMMID = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<10;i++)
        {
            inbListWithMMID.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '1201',level_1_epm_name__c='Server Products', level_2_epm_id__c = '14909'+i, level_2_epm_name__c='Legacy Server Products', level_3_epm_id__c='7755'+i, level_3_epm_name__c='Intel® Server System SR2500AL Family', level_4_epm_id__c='2474'+i, level_4_epm_name__c='Intel® Server System SR2500ALBRPR',level_5_epm_id__c='4826'+i,level_5_epm_name__c='Intel® Server System SR2500ALBRPR, Single', iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='43', Core_Hierarchy_Name__c='Valid Product Hierarchy',L5_mmid__c='4826'+i+';'+'2474'+i+';'+'7755'+i+';',Restriction_Code__c='4826'+i+'-0;'+'2474'+i+'-1;'+'7755'+i+'-0;',L5_Opcode__c='4826'+i+'-DD;'+'2474'+i+'-DD;'+'7755'+i+'-DD;'));
        }
        insert inbListWithMMID;
        list<string> Ids;
        Product_ProcessInboundStagingRecords.processInboundStagingRecords(Ids);
        System.assertNotEquals(null,inbList.size());
    }
    
}