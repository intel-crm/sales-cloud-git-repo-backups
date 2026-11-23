/**********************************************************************************************
* Class Name  :   PMP_ParseProcessorJSON_Test 
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------
* Sangeetha                 09/01/2019               Test class for Core_PMP_ParseProcessorJSON
*************************************************************************************************/
@isTest
public class PMP_ParseProcessorJSON_Test {
    
    @isTest
    public static void parseEnglishProcessorJSONTest(){
        Test.startTest();
        
        //Create test Specifications:
        
        PMP_Specification__c spec_Main = new PMP_Specification__c();
        spec_Main.Name = 'Processors';
        spec_Main.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors';
        spec_Main.PMP_Specification_Type_Nm__c = 'Other';
        spec_Main.PMP_Active_Ind__c = true;
        spec_Main.PMP_Display_Type_Nm__c = 'Label';
        spec_Main.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        spec_Main.PMP_Partner_Product_Display_Sequence_Nbr__c = 510;
        spec_Main.PMP_Specification_Chinese_Nm__c = '处理器';
        spec_Main.PMP_Specification_Japanese_Nm__c = 'プロセッサー';
        spec_Main.PMP_Partner_Product_Specification_Key__c = 'npp_processors';
        insert spec_Main; 
        
        PMP_Specification__c spec_Test = new PMP_Specification__c();
        spec_Test.Name = 'Test';
        spec_Test.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        spec_Test.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Test.PMP_Active_Ind__c = true;
        spec_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Test.PMP_Partner_Product_Specification_Key__c = 'npp_test';
        spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Test.PMP_Specification_Chinese_Nm__c = '处理';
        spec_Test.PMP_Specification_Japanese_Nm__c = 'プロセッサ';
        spec_Test.PMP_Parent_Specification_Id__c = spec_Main.id;
        spec_Test.PMP_Product_Parent_Specification_Id__c = 'npp_processors';
        insert spec_Test;     
        
        PMP_Specification__c spec_Core = new PMP_Specification__c();
        spec_Core.Name = 'Intel® Core™ Processors';
        spec_Core.PMP_Partner_Product_Specification_Id__c= '122139';
        spec_Core.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core.PMP_Active_Ind__c = true;
        spec_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core.PMP_Partner_Product_Specification_Key__c = '122139';
        spec_Core.PMP_Partner_Product_Display_Sequence_Nbr__c = 110;
        //spec_Core.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ 处理器';
        //spec_Core.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ プロセッサー・ファミリー';
        spec_Core.PMP_Parent_Specification_Id__c = spec_Main.id;
        spec_Core.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        insert spec_Core;
        
        PMP_Specification__c spec_Core_X = new PMP_Specification__c();
        spec_Core_X.Name = 'Intel® Core™ X-series Processors';
        spec_Core_X.PMP_Partner_Product_Specification_Id__c= '123588';
        spec_Core_X.PMP_Product_Parent_Specification_Id__c = '122139';    
        spec_Core_X.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core_X.PMP_Active_Ind__c = true;
        spec_Core_X.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core_X.PMP_Partner_Product_Specification_Key__c = '123588';
        spec_Core_X.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        //spec_Core_X.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ X 系列处理器';
        //spec_Core_X.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ X シリーズ・プロセッサー・ファミリー';
        spec_Core_X.PMP_Parent_Specification_Id__c = spec_Core.id;  
        insert spec_Core_X;
        
        
        PMP_Specification__c spec_Core_P = new PMP_Specification__c();
        spec_Core_P.Name = 'Intel® Pentium® Processor';
        spec_Core_P.PMP_Partner_Product_Specification_Id__c= '29862';
        spec_Core_P.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        spec_Core_P.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core_P.PMP_Active_Ind__c = true;
        spec_Core_P.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core_P.PMP_Partner_Product_Specification_Key__c = '29862';
        spec_Core_P.PMP_Partner_Product_Display_Sequence_Nbr__c = 111;
        //spec_Core_P.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ X 系列处理器';
        //spec_Core_P.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ X シリーズ・プロセッサー・ファミリー';
        spec_Core_P.PMP_Parent_Specification_Id__c = spec_Main.id;  
        insert spec_Core_P;
        
        //Create Specification Values
        
        PMP_Specification_Value__c spec_value_Proc_Core = new PMP_Specification_Value__c();
        spec_value_Proc_Core.Name = 'Intel® Core™ i7-7740X X-series Processor (8M Cache, up to 4.50 GHz)';
        spec_value_Proc_Core.PMP_Active_Ind__c = true;
        spec_value_Proc_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Core.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Core.PMP_Product_Specification_Value_Cd__c = '121499';
        spec_value_Proc_Core.PMP_Product_Specification_Value_Key__c = '121499';
        spec_value_Proc_Core.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //spec_value_Proc_Core.PMP_Specification_Value_Chinese_Cd__c = '英特尔® 酷睿™ i7-7740X X 系列处理器（8M 高速缓存，高达 4.50 GHz';
        //spec_value_Proc_Core.PMP_Specification_Value_Japanese_Cd__c = 'インテル® Core™ i7-7740X X シリーズ・プロセッサー (8M キャッシュ、最大 4.50 GHz)';
        spec_value_Proc_Core.PMP_Specification_Value_Nm__c = 'Intel® Core™ i7-7740X X-series Processor (8M Cache, up to 4.50 GHz)';
        
        insert spec_value_Proc_Core;
        
        PMP_Specification_Value__c spec_value_Proc_Test = new PMP_Specification_Value__c();
        spec_value_Proc_Test.Name = 'Test';
        spec_value_Proc_Test.PMP_Active_Ind__c = true;
        spec_value_Proc_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Product_Specification_Value_Key__c = 'test';
        spec_value_Proc_Test.PMP_Spec_Value_Type_Nm__c = 'Processor';
        spec_value_Proc_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_Proc_Test;
        
        PMP_Specification_Value__c spec_value_Proc_CoreX = new PMP_Specification_Value__c();
        spec_value_Proc_CoreX.Name = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        spec_value_Proc_CoreX.PMP_Active_Ind__c = true;
        spec_value_Proc_CoreX.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_CoreX.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_CoreX.PMP_Product_Specification_Value_Cd__c = '121500';
        spec_value_Proc_CoreX.PMP_Product_Specification_Value_Key__c = '121500';
        spec_value_Proc_CoreX.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //spec_value_Proc_CoreX.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        //spec_value_Proc_CoreX.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        spec_value_Proc_CoreX.PMP_Specification_Value_Nm__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        
        insert spec_value_Proc_CoreX;
        system.assertNotEquals(spec_value_Proc_CoreX.Id,null);
        PMP_ParseProcessorJSON.strBaseKey = 'en_US';
        PMP_ParseProcessorJSON.ParseProcessorJSON('Processors_Attribute_Test');
        Test.stopTest();          
    }
    
    @isTest
    public static void parseChineseProcessorJSONTest(){
        Test.startTest();
        
        //Create test Specifications:
        
        PMP_Specification__c spec_Main = new PMP_Specification__c();
        spec_Main.Name = 'Processors';
        spec_Main.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors';
        spec_Main.PMP_Specification_Type_Nm__c = 'Other';
        spec_Main.PMP_Active_Ind__c = true;
        spec_Main.PMP_Display_Type_Nm__c = 'Label';
        spec_Main.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        spec_Main.PMP_Partner_Product_Display_Sequence_Nbr__c = 510;
        spec_Main.PMP_Specification_Chinese_Nm__c = '处理器';
        spec_Main.PMP_Specification_Japanese_Nm__c = 'プロセッサー';
        spec_Main.PMP_Partner_Product_Specification_Key__c = 'npp_processors';
        insert spec_Main; 
        
        PMP_Specification__c spec_Test = new PMP_Specification__c();
        spec_Test.Name = 'Test';
        spec_Test.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        spec_Test.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Test.PMP_Active_Ind__c = true;
        spec_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Test.PMP_Partner_Product_Specification_Key__c = 'npp_test';
        spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Test.PMP_Specification_Chinese_Nm__c = '处理';
        spec_Test.PMP_Specification_Japanese_Nm__c = 'プロセッサ';
        spec_Test.PMP_Parent_Specification_Id__c = spec_Main.id;
        spec_Test.PMP_Product_Parent_Specification_Id__c = 'npp_processors';
        insert spec_Test;     
        
        PMP_Specification__c spec_Core = new PMP_Specification__c();
        spec_Core.Name = 'Intel® Core™ Processors';
        spec_Core.PMP_Partner_Product_Specification_Id__c= '122139';
        spec_Core.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core.PMP_Active_Ind__c = true;
        spec_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core.PMP_Partner_Product_Specification_Key__c = '122139';
        spec_Core.PMP_Partner_Product_Display_Sequence_Nbr__c = 110;
        //spec_Core.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ 处理器';
        //spec_Core.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ プロセッサー・ファミリー';
        spec_Core.PMP_Parent_Specification_Id__c = spec_Main.id;
        spec_Core.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        insert spec_Core;
        
        PMP_Specification__c spec_Core_X = new PMP_Specification__c();
        spec_Core_X.Name = 'Intel® Core™ X-series Processors';
        spec_Core_X.PMP_Partner_Product_Specification_Id__c= '123588';
        spec_Core_X.PMP_Product_Parent_Specification_Id__c = '122139';    
        spec_Core_X.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core_X.PMP_Active_Ind__c = true;
        spec_Core_X.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core_X.PMP_Partner_Product_Specification_Key__c = '123588';
        spec_Core_X.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        //spec_Core_X.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ X 系列处理器';
        //spec_Core_X.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ X シリーズ・プロセッサー・ファミリー';
        spec_Core_X.PMP_Parent_Specification_Id__c = spec_Core.id;  
        insert spec_Core_X;
        
        
        PMP_Specification__c spec_Core_P = new PMP_Specification__c();
        spec_Core_P.Name = 'Intel® Pentium® Processor';
        spec_Core_P.PMP_Partner_Product_Specification_Id__c= '29862';
        spec_Core_P.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        spec_Core_P.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core_P.PMP_Active_Ind__c = true;
        spec_Core_P.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core_P.PMP_Partner_Product_Specification_Key__c = '29862';
        spec_Core_P.PMP_Partner_Product_Display_Sequence_Nbr__c = 111;
        //spec_Core_P.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ X 系列处理器';
        //spec_Core_P.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ X シリーズ・プロセッサー・ファミリー';
        spec_Core_P.PMP_Parent_Specification_Id__c = spec_Main.id;  
        insert spec_Core_P;
        
        //Create Specification Values
        
        PMP_Specification_Value__c spec_value_Proc_Core = new PMP_Specification_Value__c();
        spec_value_Proc_Core.Name = 'Intel® Core™ i7-7740X X-series Processor (8M Cache, up to 4.50 GHz)';
        spec_value_Proc_Core.PMP_Active_Ind__c = true;
        spec_value_Proc_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Core.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Core.PMP_Product_Specification_Value_Cd__c = '121499';
        spec_value_Proc_Core.PMP_Product_Specification_Value_Key__c = '121499';
        spec_value_Proc_Core.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //spec_value_Proc_Core.PMP_Specification_Value_Chinese_Cd__c = '英特尔® 酷睿™ i7-7740X X 系列处理器（8M 高速缓存，高达 4.50 GHz';
        //spec_value_Proc_Core.PMP_Specification_Value_Japanese_Cd__c = 'インテル® Core™ i7-7740X X シリーズ・プロセッサー (8M キャッシュ、最大 4.50 GHz)';
        spec_value_Proc_Core.PMP_Specification_Value_Nm__c = 'Intel® Core™ i7-7740X X-series Processor (8M Cache, up to 4.50 GHz)';
        
        insert spec_value_Proc_Core;
        
        PMP_Specification_Value__c spec_value_Proc_Test = new PMP_Specification_Value__c();
        spec_value_Proc_Test.Name = 'Test';
        spec_value_Proc_Test.PMP_Active_Ind__c = true;
        spec_value_Proc_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Product_Specification_Value_Key__c = 'test';
        spec_value_Proc_Test.PMP_Spec_Value_Type_Nm__c = 'Processor';
        spec_value_Proc_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_Proc_Test;
        
        PMP_Specification_Value__c spec_value_Proc_CoreX = new PMP_Specification_Value__c();
        spec_value_Proc_CoreX.Name = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        spec_value_Proc_CoreX.PMP_Active_Ind__c = true;
        spec_value_Proc_CoreX.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_CoreX.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_CoreX.PMP_Product_Specification_Value_Cd__c = '121500';
        spec_value_Proc_CoreX.PMP_Product_Specification_Value_Key__c = '121500';
        spec_value_Proc_CoreX.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //spec_value_Proc_CoreX.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        //spec_value_Proc_CoreX.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        spec_value_Proc_CoreX.PMP_Specification_Value_Nm__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        
        insert spec_value_Proc_CoreX;
        system.assertNotEquals(spec_value_Proc_CoreX.Id,null);
        PMP_ParseProcessorJSON.strBaseKey = 'zh_CN';
        PMP_ParseProcessorJSON.ParseProcessorJSON('Processors_Attribute_Test');
        Test.stopTest();          
    }
    
    @isTest
    public static void parseJapaneseProcessorJSONTest(){
        Test.startTest();
        
        //Create test Specifications:
        
        PMP_Specification__c spec_Main = new PMP_Specification__c();
        spec_Main.Name = 'Processors';
        spec_Main.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors';
        spec_Main.PMP_Specification_Type_Nm__c = 'Other';
        spec_Main.PMP_Active_Ind__c = true;
        spec_Main.PMP_Display_Type_Nm__c = 'Label';
        spec_Main.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        spec_Main.PMP_Partner_Product_Display_Sequence_Nbr__c = 510;
        spec_Main.PMP_Specification_Chinese_Nm__c = '处理器';
        spec_Main.PMP_Specification_Japanese_Nm__c = 'プロセッサー';
        spec_Main.PMP_Partner_Product_Specification_Key__c = 'npp_processors';
        insert spec_Main; 
        
        PMP_Specification__c spec_Test = new PMP_Specification__c();
        spec_Test.Name = 'Test';
        spec_Test.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        spec_Test.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Test.PMP_Active_Ind__c = true;
        spec_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Test.PMP_Partner_Product_Specification_Key__c = 'npp_test';
        spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Test.PMP_Specification_Chinese_Nm__c = '处理';
        spec_Test.PMP_Specification_Japanese_Nm__c = 'プロセッサ';
        spec_Test.PMP_Parent_Specification_Id__c = spec_Main.id;
        spec_Test.PMP_Product_Parent_Specification_Id__c = 'npp_processors';
        insert spec_Test;     
        
        PMP_Specification__c spec_Core = new PMP_Specification__c();
        spec_Core.Name = 'Intel® Core™ Processors';
        spec_Core.PMP_Partner_Product_Specification_Id__c= '122139';
        spec_Core.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core.PMP_Active_Ind__c = true;
        spec_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core.PMP_Partner_Product_Specification_Key__c = '122139';
        spec_Core.PMP_Partner_Product_Display_Sequence_Nbr__c = 110;
        //spec_Core.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ 处理器';
        //spec_Core.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ プロセッサー・ファミリー';
        spec_Core.PMP_Parent_Specification_Id__c = spec_Main.id;
        spec_Core.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        insert spec_Core;
        
        PMP_Specification__c spec_Core_X = new PMP_Specification__c();
        spec_Core_X.Name = 'Intel® Core™ X-series Processors';
        spec_Core_X.PMP_Partner_Product_Specification_Id__c= '123588';
        spec_Core_X.PMP_Product_Parent_Specification_Id__c = '122139';    
        spec_Core_X.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core_X.PMP_Active_Ind__c = true;
        spec_Core_X.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core_X.PMP_Partner_Product_Specification_Key__c = '123588';
        spec_Core_X.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        //spec_Core_X.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ X 系列处理器';
        //spec_Core_X.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ X シリーズ・プロセッサー・ファミリー';
        spec_Core_X.PMP_Parent_Specification_Id__c = spec_Core.id;  
        insert spec_Core_X;
        
        
        PMP_Specification__c spec_Core_P = new PMP_Specification__c();
        spec_Core_P.Name = 'Intel® Pentium® Processor';
        spec_Core_P.PMP_Partner_Product_Specification_Id__c= '29862';
        spec_Core_P.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        spec_Core_P.PMP_Specification_Type_Nm__c = 'Processor';
        spec_Core_P.PMP_Active_Ind__c = true;
        spec_Core_P.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core_P.PMP_Partner_Product_Specification_Key__c = '29862';
        spec_Core_P.PMP_Partner_Product_Display_Sequence_Nbr__c = 111;
        //spec_Core_P.PMP_Specification_Chinese_Nm__c = '英特尔® 酷睿™ X 系列处理器';
        //spec_Core_P.PMP_Specification_Japanese_Nm__c = 'インテル® Core™ X シリーズ・プロセッサー・ファミリー';
        spec_Core_P.PMP_Parent_Specification_Id__c = spec_Main.id;  
        insert spec_Core_P;
        
        //Create Specification Values
        
        PMP_Specification_Value__c spec_value_Proc_Core = new PMP_Specification_Value__c();
        spec_value_Proc_Core.Name = 'Intel® Core™ i7-7740X X-series Processor (8M Cache, up to 4.50 GHz)';
        spec_value_Proc_Core.PMP_Active_Ind__c = true;
        spec_value_Proc_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Core.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Core.PMP_Product_Specification_Value_Cd__c = '121499';
        spec_value_Proc_Core.PMP_Product_Specification_Value_Key__c = '121499';
        spec_value_Proc_Core.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //spec_value_Proc_Core.PMP_Specification_Value_Chinese_Cd__c = '英特尔® 酷睿™ i7-7740X X 系列处理器（8M 高速缓存，高达 4.50 GHz';
        //spec_value_Proc_Core.PMP_Specification_Value_Japanese_Cd__c = 'インテル® Core™ i7-7740X X シリーズ・プロセッサー (8M キャッシュ、最大 4.50 GHz)';
        spec_value_Proc_Core.PMP_Specification_Value_Nm__c = 'Intel® Core™ i7-7740X X-series Processor (8M Cache, up to 4.50 GHz)';
        
        insert spec_value_Proc_Core;
        
        PMP_Specification_Value__c spec_value_Proc_Test = new PMP_Specification_Value__c();
        spec_value_Proc_Test.Name = 'Test';
        spec_value_Proc_Test.PMP_Active_Ind__c = true;
        spec_value_Proc_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Product_Specification_Value_Key__c = 'test';
        spec_value_Proc_Test.PMP_Spec_Value_Type_Nm__c = 'Processor';
        spec_value_Proc_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_Proc_Test;
        
        PMP_Specification_Value__c spec_value_Proc_CoreX = new PMP_Specification_Value__c();
        spec_value_Proc_CoreX.Name = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        spec_value_Proc_CoreX.PMP_Active_Ind__c = true;
        spec_value_Proc_CoreX.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_CoreX.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_CoreX.PMP_Product_Specification_Value_Cd__c = '121500';
        spec_value_Proc_CoreX.PMP_Product_Specification_Value_Key__c = '121500';
        spec_value_Proc_CoreX.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //spec_value_Proc_CoreX.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        //spec_value_Proc_CoreX.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        spec_value_Proc_CoreX.PMP_Specification_Value_Nm__c = 'Intel® Core™ i5-7640X X-series Processor (6M Cache, up to 4.20 GHz)';
        
        insert spec_value_Proc_CoreX;
        system.assertNotEquals(spec_value_Proc_CoreX.Id,null);
        PMP_ParseProcessorJSON.strBaseKey = 'ja_JP';
        PMP_ParseProcessorJSON.ParseProcessorJSON('Processors_Attribute_Test');
        Test.stopTest();          
    }
}