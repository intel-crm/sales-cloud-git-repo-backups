@isTest
public class Product_stageQueueableTest {
    @isTest
    static void TestMethod2(){
        List<Product_Inbound_Staging__c> inbList_1 = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<1;i++)
        {
            inbList_1.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '77355',level_1_epm_name__c='Server Products', level_2_epm_id__c = '123'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='128751'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions',  Core_Hierarchy_ID__c='43', Core_Hierarchy_Name__c='Valid Product Hierarchy'));
        }
        insert inbList_1;
        List<Product_Inbound_Staging__c> inbListFP = new List <Product_Inbound_Staging__c>();          
        for(Integer i=0;i<1;i++)
        {
            inbListFP.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '98836',level_1_epm_name__c='Server Products', level_2_epm_id__c = '123'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='128751'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', level_4_epm_id__c='128749'+i, level_4_epm_name__c='Intel® Nervana™ Cloud', level_5_epm_id__c='1287499'+i, level_5_epm_name__c='Intel® Nervana™ Cloud',iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='43', Core_Hierarchy_Name__c='Valid Product Hierarchy'));
        }
        insert inbListFP;
        List<Product_Inbound_Staging__c> inbListVplch = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<2;i++)
        {
            inbListVplch.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '988379',level_1_epm_name__c='Server Products', level_2_epm_id__c = '17898'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='1241'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', level_4_epm_id__c='1297'+i, level_4_epm_name__c='Intel® Nervana™ Cloud', level_5_epm_id__c='1287478'+i, level_5_epm_name__c='Intel® Nervana™ Cloud',iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='59', Core_Hierarchy_Name__c='Valid Platform CodeName Hierarchy'));
        }
        insert inbListVplch;
        List<Product_Inbound_Staging__c> inbListVplchFP = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<1;i++)
        {
            inbListVplchFP.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '98839'+i,level_1_epm_name__c='Intel® FPGA', level_2_epm_id__c = '17876'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='98836', level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', level_4_epm_id__c='1297'+i, level_4_epm_name__c='Intel® Nervana™ Cloud', level_5_epm_id__c='1287478'+i, level_5_epm_name__c='Intel® Nervana™ Cloud',iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='59', Core_Hierarchy_Name__c='Valid Platform CodeName Hierarchy'));
        }
        insert inbListVplchFP;
        List<Product_Inbound_Staging__c> inbListVplchblank = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<1;i++)
        {
            inbListVplchblank.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '988365',level_1_epm_name__c='Server Products', level_2_epm_id__c = '17865'+i,level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='1247'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='59', Core_Hierarchy_Name__c='Valid Platform CodeName Hierarchy'));
        }
        insert inbListVplchblank;
        List<Product_Inbound_Staging__c> inbListVplchblank_1 = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<1;i++)
        {
            inbListVplchblank_1.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '98876',level_1_epm_name__c='Server Products', level_2_epm_id__c = '17867'+i, level_2_epm_name__c='Intel® Nervana™ Products', level_3_epm_id__c='1246'+i, level_3_epm_name__c='Intel® Nervana™ Cloud based Solutions', level_4_epm_id__c='12979'+i, level_4_epm_name__c='Intel® Nervana™ Cloud',iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='59', Core_Hierarchy_Name__c='Valid Platform CodeName Hierarchy'));
        }
        insert inbListVplchblank_1;
        List<Product_Inbound_Staging__c> inbListVplchblank_2 = new List <Product_Inbound_Staging__c>();         
        for(Integer i=0;i<1;i++)
        {
            inbListVplchblank_2.add(new Product_Inbound_Staging__c(level_1_epm_id__c = '98871',level_1_epm_name__c='Server Products', level_2_epm_id__c = '17861'+i, level_2_epm_name__c='Intel® Nervana™ Products',iPaaS_Load_ID__c ='1687256736366', Core_Hierarchy_ID__c='59', Core_Hierarchy_Name__c='Valid Platform CodeName Hierarchy'));
        }
        insert inbListVplchblank_2;
        System.assertEquals('98836',inbListFP[0].level_1_epm_id__c);
    }
    
    @isTest
    static void TestMethod1(){
        //test data 
        list<Product_Inbound_Staging__c> inbList0 = new list<Product_Inbound_Staging__c>();  
        Product_Inbound_Staging__c inbRec1 = new Product_Inbound_Staging__c();        
        inbRec1.Core_Hierarchy_ID__c='43';
        inbRec1.level_1_epm_id__c='69130';
        inbRec1.iPaaS_Load_ID__c='1687256736366';
        inbRec1.level_1_epm_name__c='Smart and Connected Home';
        inbRec1.level_2_epm_id__c='70322';
        inbRec1.level_2_epm_name__c='Telecommunication and Gateways';
        inbRec1.level_3_epm_id__c='98836';
        inbRec1.level_3_epm_name__c='Intel® FPGAs';
        inbRec1.level_4_epm_id__c='75920';
        inbRec1.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbRec1.level_5_epm_id__c='190400';
        inbRec1.level_5_epm_name__c='Intel Atom® Processor CE5328 (512K Cache, 1.20 GHz) FC-BGA11E, Tray';
        inbList0.add(inbRec1);
        Insert inbList0;
        
        List<Product_Inbound_Staging__c> inbList = [select id,iPaaS_Load_ID__c from Product_Inbound_Staging__c limit 1];
        String ipaasId= inbList[0].iPaaS_Load_ID__c;
        TestMethod2();
        Map<integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<integer,Product_ProcessInboundStagingRecords.InputWrapper>();
        Product_ProcessInboundStagingRecords.InputWrapper input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '77353';
        inputWrapperMap.put(1,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '98836';
        inputWrapperMap.put(2,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '77355';
        inputWrapperMap.put(3,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        Test.startTest();
        
        System.enqueueJob(new Product_stageQueueable(1,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        System.enqueueJob(new Product_stageQueueable(2,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        System.enqueueJob(new Product_stageQueueable(3,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        Test.stopTest();  
        System.assertEquals('43',inbRec1.Core_Hierarchy_ID__c);
    } 
    
    @isTest
    static void TestMethod3(){
        list<Product_Inbound_Staging__c> inbList = new list<Product_Inbound_Staging__c>();  
        Product_Inbound_Staging__c inbRec1 = new Product_Inbound_Staging__c();        
        inbRec1.Core_Hierarchy_ID__c='43';
        inbRec1.level_1_epm_id__c='69132';
        inbRec1.iPaaS_Load_ID__c='1687256736366';
        inbRec1.level_1_epm_name__c='Server Products';
        inbRec1.level_2_epm_id__c='70323';
        inbRec1.level_2_epm_name__c='Telecommunication and Gateways';
        inbRec1.level_3_epm_id__c='98836';
        inbRec1.level_3_epm_name__c='Intel® FPGAs';
        inbRec1.level_4_epm_id__c='95920';
        inbRec1.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbList.add(inbRec1);
        
        Product_Inbound_Staging__c inbRec2 = new Product_Inbound_Staging__c();        
        inbRec2.Core_Hierarchy_ID__c='43';
        inbRec2.level_1_epm_id__c='69134';
        inbRec2.iPaaS_Load_ID__c='1687256736366';
        inbRec2.level_1_epm_name__c='Server Products';
        inbRec2.level_2_epm_id__c='70325';
        inbRec2.level_2_epm_name__c='Intel® Nervana™ Products';
        inbRec2.level_3_epm_id__c='98836';
        inbRec2.level_3_epm_name__c='Intel® FPGAs';
        inbList.add(inbRec2);
        insert inbList;
        
        List<Product_Inbound_Staging__c> inbList1 = [select id,iPaaS_Load_ID__c from Product_Inbound_Staging__c limit 1];
        String ipaasId= inbList1[0].iPaaS_Load_ID__c;
        Map<integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<integer,Product_ProcessInboundStagingRecords.InputWrapper>();
        Product_ProcessInboundStagingRecords.InputWrapper input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '69132';
        inputWrapperMap.put(1,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '69134';
        inputWrapperMap.put(2,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        
        Test.startTest();
        System.enqueueJob(new Product_stageQueueable(1,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        System.enqueueJob(new Product_stageQueueable(2,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        Test.stopTest(); 
        System.assertEquals('69134',inbRec2.level_1_epm_id__c);
    }
    
    
    @isTest
    static void TestMethod4(){
        list<Product_Inbound_Staging__c> inbList2 = new list<Product_Inbound_Staging__c>();  
        Product_Inbound_Staging__c inbRec3 = new Product_Inbound_Staging__c();        
        inbRec3.Core_Hierarchy_ID__c='43';
        inbRec3.level_1_epm_id__c='69124';
        inbRec3.iPaaS_Load_ID__c='1687256736366';
        inbRec3.level_1_epm_name__c='Server Products';
        inbRec3.level_2_epm_id__c='70325';
        inbRec3.level_2_epm_name__c='Telecommunication and Gateways';
        inbList2.add(inbRec3);
        
        Product_Inbound_Staging__c inbRec4 = new Product_Inbound_Staging__c();        
        inbRec4.Core_Hierarchy_ID__c='43';
        inbRec4.level_1_epm_id__c='59124';
        inbRec4.iPaaS_Load_ID__c='1687256736366';
        inbRec4.level_1_epm_name__c='Server Products';
        inbList2.add(inbRec4);
        
        Product_Inbound_Staging__c inbRec7 = new Product_Inbound_Staging__c();        
        inbRec7.Core_Hierarchy_ID__c='43';
        inbRec7.level_1_epm_id__c='69124';
        inbRec7.iPaaS_Load_ID__c='1687256736366';
        inbRec7.level_1_epm_name__c='Smart and Connected Home';
        inbRec7.level_2_epm_id__c='70325';
        inbRec7.level_2_epm_name__c='Intel® Nervana™ Products';
        inbList2.add(inbRec7);
        insert inbList2;
        
        
        List<Product_Inbound_Staging__c> inbList1 = [select id,iPaaS_Load_ID__c from Product_Inbound_Staging__c limit 1];
        String ipaasId= inbList1[0].iPaaS_Load_ID__c;
        Map<integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<integer,Product_ProcessInboundStagingRecords.InputWrapper>();
        Product_ProcessInboundStagingRecords.InputWrapper input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '69124';
        inputWrapperMap.put(3,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '59124';
        inputWrapperMap.put(4,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '69124';
        inputWrapperMap.put(7,input);
        
        Test.startTest();
        System.enqueueJob(new Product_stageQueueable(3,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        System.enqueueJob(new Product_stageQueueable(4,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        System.enqueueJob(new Product_stageQueueable(7,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        Test.stopTest();
        System.assertEquals('Intel® Nervana™ Products',inbRec7.level_2_epm_name__c);
    }
    
    
    @isTest
    static void TestMethod5(){
        list<Product_Inbound_Staging__c> inbList3 = new list<Product_Inbound_Staging__c>(); 
        Product_Inbound_Staging__c inbRec5 = new Product_Inbound_Staging__c();        
        inbRec5.Core_Hierarchy_ID__c='43';
        inbRec5.level_1_epm_id__c='69232';
        inbRec5.iPaaS_Load_ID__c='1687256736366';
        inbRec5.level_1_epm_name__c='Server Products';
        inbRec5.level_2_epm_id__c='70324';
        inbRec5.level_2_epm_name__c='Intel® Nervana™ Products';
        inbRec5.level_3_epm_id__c='98836';
        inbRec5.level_3_epm_name__c='Intel® FPGAs';
        inbRec5.level_4_epm_id__c='95921';
        inbRec5.level_4_epm_name__c='Intel Atom® Processor CE5300';
        inbList3.add(inbRec5);
        
        Product_Inbound_Staging__c inbRec6 = new Product_Inbound_Staging__c();        
        inbRec6.Core_Hierarchy_ID__c='43';
        inbRec6.level_1_epm_id__c='48134';
        inbRec6.iPaaS_Load_ID__c='1687256736366';
        inbRec6.level_1_epm_name__c='Server Products';
        inbRec6.level_2_epm_id__c='70325';
        inbRec6.level_2_epm_name__c='Telecommunication and Gateways';
        inbRec6.level_3_epm_id__c='98836';
        inbRec6.level_3_epm_name__c='Intel® FPGAs';
        inbList3.add(inbRec6);
        insert inbList3;
        
        List<Product_Inbound_Staging__c> inbList1 = [select id,iPaaS_Load_ID__c from Product_Inbound_Staging__c limit 1];
        String ipaasId= inbList1[0].iPaaS_Load_ID__c;
        Map<integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<integer,Product_ProcessInboundStagingRecords.InputWrapper>();
        Product_ProcessInboundStagingRecords.InputWrapper input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '69232';
        inputWrapperMap.put(5,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = false;
        input.vplchInd = false ;
        input.level1EPMId = '48134';
        inputWrapperMap.put(6,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        
        Test.startTest();
        System.enqueueJob(new Product_stageQueueable(5,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        System.enqueueJob(new Product_stageQueueable(6,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>()));
        Test.stopTest(); 
        System.assertEquals('98836',inbRec6.level_3_epm_id__c);
        
    }
    
    
    @isTest
    static void TestMethod6(){
        Product_Inbound_Staging__c inbRec1 = new Product_Inbound_Staging__c();        
        inbRec1.level_1_epm_id__c='69130';
        inbRec1.iPaaS_Load_ID__c='1687256736366';
        insert inbRec1;
        
        TestMethod2();
        List<Product_Inbound_Staging__c> inbList1 = [select id,iPaaS_Load_ID__c from Product_Inbound_Staging__c limit 1];
        String ipaasId= inbList1[0].iPaaS_Load_ID__c;
        Map<integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<integer,Product_ProcessInboundStagingRecords.InputWrapper>();
        Product_ProcessInboundStagingRecords.InputWrapper input = new Product_ProcessInboundStagingRecords.InputWrapper();
        input.atLevel2 = true;
        input.vplchInd = false ;
        input.level1EPMId = '77353';
        Set<String> l2Ids = new Set<String> ();
        l2Ids.add('1230');
        input.level2EPMIds = l2Ids;
        inputWrapperMap.put(4,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        Set<String> vplchIds = new Set<String> ();
        vplchIds.add('988379');
        input.vplchInd = true;
        input.level1VplchEPMIds = vplchIds;
        inputWrapperMap.put(5,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        vplchIds = new Set<String> ();
        vplchIds.add('988390');
        input.vplchInd = true;
        input.level1VplchEPMIds = vplchIds;
        inputWrapperMap.put(6,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        vplchIds = new Set<String> ();
        vplchIds.add('988365');
        input.vplchInd = true;
        input.level1VplchEPMIds = vplchIds;
        inputWrapperMap.put(7,input);
        input = new Product_ProcessInboundStagingRecords.InputWrapper();
        vplchIds = new Set<String> ();
        vplchIds.add('98876');
        vplchIds.add('98871');
        input.vplchInd = true;
        input.level1VplchEPMIds = vplchIds;
        inputWrapperMap.put(8,input);
        
        Test.startTest();
        System.enqueueJob(new Product_stageQueueable(4,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>())); 
        System.enqueueJob(new Product_stageQueueable(5,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>())); 
        System.enqueueJob(new Product_stageQueueable(6,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>())); 
        System.enqueueJob(new Product_stageQueueable(7,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>())); 
        System.enqueueJob(new Product_stageQueueable(8,new  list<Core_Products_Staging__c>(),inputWrapperMap,false, ipaasId,new Set<String>())); 
        Test.stopTest();  
        System.assertEquals('69130',inbRec1.level_1_epm_id__c);
    } 
}