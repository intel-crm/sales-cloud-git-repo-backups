/**********************************************************************************************
* Class Name  :   PMP_ParseChipSet_JSON_Test
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Manasa                  02/01/2019               Test class for Core_PMP_ParseChipSet_JSON.apxc
* Infosys - Sangeetha     09/01/2019               Updated test class
*************************************************************************************************/

@isTest
public class PMP_ParseChipSet_JSON_Test {
    
    @isTest
    public static void parseEnglishChipSetJSONTest(){
        
        //Create test Specifications:
        Test.startTest();
        
        PMP_Specification__c specMain = new PMP_Specification__c();
        specMain.Name = 'Chipsets';
        specMain.PMP_Partner_Product_Specification_Id__c= 'NPP_Chipsets';
        specMain.PMP_Specification_Type_Nm__c = 'Other';
        specMain.PMP_Active_Ind__c = true;
        specMain.PMP_Display_Type_Nm__c = 'Label';
        specMain.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        specMain.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        specMain.PMP_Specification_Chinese_Nm__c = '芯片组';
        specMain.PMP_Specification_Japanese_Nm__c = 'チップセット';
        specMain.PMP_Partner_Product_Specification_Key__c = 'npp_chipsets';
        insert specMain; 
        
        PMP_Specification__c specTest = new PMP_Specification__c();
        specTest.Name = 'Test';
        specTest.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        specTest.PMP_Specification_Type_Nm__c = 'Chipset';
        specTest.PMP_Active_Ind__c = true;
        specTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specTest.PMP_Partner_Product_Specification_Key__c = 'npp_test';
        specTest.PMP_Partner_Product_Display_Sequence_Nbr__c = 530;
        specTest.PMP_Specification_Chinese_Nm__c = '芯片';
        specTest.PMP_Specification_Japanese_Nm__c = 'チップセッ';
        specTest.PMP_Parent_Specification_Id__c = specMain.id;
        specTest.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';
        insert specTest;     
        
        PMP_Specification__c specCon = new PMP_Specification__c();
        specCon.Name = 'Consumer Chipsets';
        specCon.PMP_Partner_Product_Specification_Id__c= '98455';
        specCon.PMP_Specification_Type_Nm__c = 'Chipset';
        specCon.PMP_Active_Ind__c = true;
        specCon.PMP_Display_Type_Nm__c = 'Checkbox';
        specCon.PMP_Partner_Product_Specification_Key__c = '98455';
        specCon.PMP_Partner_Product_Display_Sequence_Nbr__c = 160;
        //specCon.PMP_Specification_Chinese_Nm__c = '消费级芯片组';
        //specCon.PMP_Specification_Japanese_Nm__c = 'コンシューマー・チップセット';
        specCon.PMP_Parent_Specification_Id__c = specMain.id;
        specCon.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';    
        insert specCon;
        
        PMP_Specification__c specSer = new PMP_Specification__c();
        specSer.Name = 'Server Chipsets';
        specSer.PMP_Partner_Product_Specification_Id__c= '46652';    
        specSer.PMP_Specification_Type_Nm__c = 'Chipset';
        specSer.PMP_Active_Ind__c = true;
        specSer.PMP_Display_Type_Nm__c = 'Checkbox';
        specSer.PMP_Partner_Product_Specification_Key__c = '46652';
        specSer.PMP_Partner_Product_Display_Sequence_Nbr__c = 161;
        //specSer.PMP_Specification_Chinese_Nm__c = '服务器芯片组';
        //specSer.PMP_Specification_Japanese_Nm__c = 'サーバー向けチップセット';
        specSer.PMP_Parent_Specification_Id__c = specMain.id; 
        specSer.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';
        insert specSer;
        
        
        PMP_Specification__c spec300Series = new PMP_Specification__c();
        spec300Series.Name = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Partner_Product_Specification_Id__c= '126380';
        spec300Series.PMP_Product_Parent_Specification_Id__c = '98455';    
        spec300Series.PMP_Specification_Type_Nm__c = 'Chipset';
        spec300Series.PMP_Active_Ind__c = true;
        spec300Series.PMP_Display_Type_Nm__c = 'Checkbox';
        spec300Series.PMP_Partner_Product_Specification_Key__c = '126380';
        spec300Series.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        //spec300Series.PMP_Specification_Chinese_Nm__c = 'Intel® 300 Series Chipsets';
        //spec300Series.PMP_Specification_Japanese_Nm__c = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Parent_Specification_Id__c = specCon.id;  
        insert spec300Series;
        
        //Create Specification Values
        
        PMP_Specification_Value__c specValueChip = new PMP_Specification_Value__c();
        specValueChip.Name = 'Intel® Z370 Chipset';
        specValueChip.PMP_Active_Ind__c = true;
        specValueChip.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueChip.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueChip.PMP_Product_Specification_Value_Cd__c = '125903';
        specValueChip.PMP_Product_Specification_Value_Key__c = '125903';
        specValueChip.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //specValueChip.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Z370 Chipset';
        //specValueChip.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Z370 Chipset';
        specValueChip.PMP_Specification_Value_Nm__c = 'Intel® Z370 Chipset';
        insert specValueChip;
        
        PMP_Specification_Value__c specValueChipTest = new PMP_Specification_Value__c();
        specValueChipTest.Name = 'Test';
        specValueChipTest.PMP_Active_Ind__c = true;
        specValueChipTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueChipTest.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueChipTest.PMP_Product_Specification_Value_Cd__c = 'Test';
        specValueChipTest.PMP_Product_Specification_Value_Key__c = 'test';
        specValueChipTest.PMP_Spec_Value_Type_Nm__c = 'Chipset';
        specValueChipTest.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        specValueChipTest.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        specValueChipTest.PMP_Specification_Value_Nm__c = 'Test';
        
        insert specValueChipTest;
        PMP_ParseChipSet_JSON.strBaseKey = 'en_US';
        PMP_ParseChipSet_JSON.parseChipSetJSON('Chipsets_Attribute_Test');
        System.assertEquals(specValueChip.PMP_Specification_Value_Nm__c, 'Intel® Z370 Chipset');
        
        Test.stopTest();     
    }
    
    @isTest
    public static void parseChineseChipSetJSONTest(){
        
        //Create test Specifications:
        Test.startTest();
        
        PMP_Specification__c specMain = new PMP_Specification__c();
        specMain.Name = 'Chipsets';
        specMain.PMP_Partner_Product_Specification_Id__c= 'NPP_Chipsets';
        specMain.PMP_Specification_Type_Nm__c = 'Other';
        specMain.PMP_Active_Ind__c = true;
        specMain.PMP_Display_Type_Nm__c = 'Label';
        specMain.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        specMain.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        specMain.PMP_Specification_Chinese_Nm__c = '芯片组';
        specMain.PMP_Specification_Japanese_Nm__c = 'チップセット';
        specMain.PMP_Partner_Product_Specification_Key__c = 'npp_chipsets';
        insert specMain; 
        
        PMP_Specification__c specTest = new PMP_Specification__c();
        specTest.Name = 'Test';
        specTest.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        specTest.PMP_Specification_Type_Nm__c = 'Chipset';
        specTest.PMP_Active_Ind__c = true;
        specTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specTest.PMP_Partner_Product_Specification_Key__c = 'npp_test';
        specTest.PMP_Partner_Product_Display_Sequence_Nbr__c = 530;
        specTest.PMP_Specification_Chinese_Nm__c = '芯片';
        specTest.PMP_Specification_Japanese_Nm__c = 'チップセッ';
        specTest.PMP_Parent_Specification_Id__c = specMain.id;
        specTest.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';
        insert specTest;     
        
        PMP_Specification__c specCon = new PMP_Specification__c();
        specCon.Name = 'Consumer Chipsets';
        specCon.PMP_Partner_Product_Specification_Id__c= '98455';
        specCon.PMP_Specification_Type_Nm__c = 'Chipset';
        specCon.PMP_Active_Ind__c = true;
        specCon.PMP_Display_Type_Nm__c = 'Checkbox';
        specCon.PMP_Partner_Product_Specification_Key__c = '98455';
        specCon.PMP_Partner_Product_Display_Sequence_Nbr__c = 160;
        //specCon.PMP_Specification_Chinese_Nm__c = '消费级芯片组';
        //specCon.PMP_Specification_Japanese_Nm__c = 'コンシューマー・チップセット';
        specCon.PMP_Parent_Specification_Id__c = specMain.id;
        specCon.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';    
        insert specCon;
        
        PMP_Specification__c specSer = new PMP_Specification__c();
        specSer.Name = 'Server Chipsets';
        specSer.PMP_Partner_Product_Specification_Id__c= '46652';    
        specSer.PMP_Specification_Type_Nm__c = 'Chipset';
        specSer.PMP_Active_Ind__c = true;
        specSer.PMP_Display_Type_Nm__c = 'Checkbox';
        specSer.PMP_Partner_Product_Specification_Key__c = '46652';
        specSer.PMP_Partner_Product_Display_Sequence_Nbr__c = 161;
        //specSer.PMP_Specification_Chinese_Nm__c = '服务器芯片组';
        //specSer.PMP_Specification_Japanese_Nm__c = 'サーバー向けチップセット';
        specSer.PMP_Parent_Specification_Id__c = specMain.id; 
        specSer.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';
        insert specSer;
        
        
        PMP_Specification__c spec300Series = new PMP_Specification__c();
        spec300Series.Name = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Partner_Product_Specification_Id__c= '126380';
        spec300Series.PMP_Product_Parent_Specification_Id__c = '98455';    
        spec300Series.PMP_Specification_Type_Nm__c = 'Chipset';
        spec300Series.PMP_Active_Ind__c = true;
        spec300Series.PMP_Display_Type_Nm__c = 'Checkbox';
        spec300Series.PMP_Partner_Product_Specification_Key__c = '126380';
        spec300Series.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        //spec300Series.PMP_Specification_Chinese_Nm__c = 'Intel® 300 Series Chipsets';
        //spec300Series.PMP_Specification_Japanese_Nm__c = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Parent_Specification_Id__c = specCon.id;  
        insert spec300Series;
        
        //Create Specification Values
        
        PMP_Specification_Value__c specValueChip = new PMP_Specification_Value__c();
        specValueChip.Name = 'Intel® Z370 Chipset';
        specValueChip.PMP_Active_Ind__c = true;
        specValueChip.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueChip.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueChip.PMP_Product_Specification_Value_Cd__c = '125903';
        specValueChip.PMP_Product_Specification_Value_Key__c = '125903';
        specValueChip.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //specValueChip.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Z370 Chipset';
        //specValueChip.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Z370 Chipset';
        specValueChip.PMP_Specification_Value_Nm__c = 'Intel® Z370 Chipset';
        insert specValueChip;
        
        PMP_Specification_Value__c specValueChipTest = new PMP_Specification_Value__c();
        specValueChipTest.Name = 'Test';
        specValueChipTest.PMP_Active_Ind__c = true;
        specValueChipTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueChipTest.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueChipTest.PMP_Product_Specification_Value_Cd__c = 'Test';
        specValueChipTest.PMP_Product_Specification_Value_Key__c = 'test';
        specValueChipTest.PMP_Spec_Value_Type_Nm__c = 'Chipset';
        specValueChipTest.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        specValueChipTest.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        specValueChipTest.PMP_Specification_Value_Nm__c = 'Test';
        
        insert specValueChipTest;
        PMP_ParseChipSet_JSON.strBaseKey = 'zh_CN';
        PMP_ParseChipSet_JSON.parseChipSetJSON('Chipsets_Attribute_Test');
        System.assertEquals(specValueChip.PMP_Specification_Value_Nm__c, 'Intel® Z370 Chipset');
        
        Test.stopTest();     
    }
    
    @isTest
    public static void parseJapaneseChipSetJSONTest(){
        
        //Create test Specifications:
        Test.startTest();
        
        PMP_Specification__c specMain = new PMP_Specification__c();
        specMain.Name = 'Chipsets';
        specMain.PMP_Partner_Product_Specification_Id__c= 'NPP_Chipsets';
        specMain.PMP_Specification_Type_Nm__c = 'Other';
        specMain.PMP_Active_Ind__c = true;
        specMain.PMP_Display_Type_Nm__c = 'Label';
        specMain.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        specMain.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        specMain.PMP_Specification_Chinese_Nm__c = '芯片组';
        specMain.PMP_Specification_Japanese_Nm__c = 'チップセット';
        specMain.PMP_Partner_Product_Specification_Key__c = 'npp_chipsets';
        insert specMain; 
        
        PMP_Specification__c specTest = new PMP_Specification__c();
        specTest.Name = 'Test';
        specTest.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        specTest.PMP_Specification_Type_Nm__c = 'Chipset';
        specTest.PMP_Active_Ind__c = true;
        specTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specTest.PMP_Partner_Product_Specification_Key__c = 'npp_test';
        specTest.PMP_Partner_Product_Display_Sequence_Nbr__c = 530;
        specTest.PMP_Specification_Chinese_Nm__c = '芯片';
        specTest.PMP_Specification_Japanese_Nm__c = 'チップセッ';
        specTest.PMP_Parent_Specification_Id__c = specMain.id;
        specTest.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';
        insert specTest;     
        
        PMP_Specification__c specCon = new PMP_Specification__c();
        specCon.Name = 'Consumer Chipsets';
        specCon.PMP_Partner_Product_Specification_Id__c= '98455';
        specCon.PMP_Specification_Type_Nm__c = 'Chipset';
        specCon.PMP_Active_Ind__c = true;
        specCon.PMP_Display_Type_Nm__c = 'Checkbox';
        specCon.PMP_Partner_Product_Specification_Key__c = '98455';
        specCon.PMP_Partner_Product_Display_Sequence_Nbr__c = 160;
        //specCon.PMP_Specification_Chinese_Nm__c = '消费级芯片组';
        //specCon.PMP_Specification_Japanese_Nm__c = 'コンシューマー・チップセット';
        specCon.PMP_Parent_Specification_Id__c = specMain.id;
        specCon.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';    
        insert specCon;
        
        PMP_Specification__c specSer = new PMP_Specification__c();
        specSer.Name = 'Server Chipsets';
        specSer.PMP_Partner_Product_Specification_Id__c= '46652';    
        specSer.PMP_Specification_Type_Nm__c = 'Chipset';
        specSer.PMP_Active_Ind__c = true;
        specSer.PMP_Display_Type_Nm__c = 'Checkbox';
        specSer.PMP_Partner_Product_Specification_Key__c = '46652';
        specSer.PMP_Partner_Product_Display_Sequence_Nbr__c = 161;
        //specSer.PMP_Specification_Chinese_Nm__c = '服务器芯片组';
        //specSer.PMP_Specification_Japanese_Nm__c = 'サーバー向けチップセット';
        specSer.PMP_Parent_Specification_Id__c = specMain.id; 
        specSer.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';
        insert specSer;
        
        
        PMP_Specification__c spec300Series = new PMP_Specification__c();
        spec300Series.Name = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Partner_Product_Specification_Id__c= '126380';
        spec300Series.PMP_Product_Parent_Specification_Id__c = '98455';    
        spec300Series.PMP_Specification_Type_Nm__c = 'Chipset';
        spec300Series.PMP_Active_Ind__c = true;
        spec300Series.PMP_Display_Type_Nm__c = 'Checkbox';
        spec300Series.PMP_Partner_Product_Specification_Key__c = '126380';
        spec300Series.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        //spec300Series.PMP_Specification_Chinese_Nm__c = 'Intel® 300 Series Chipsets';
        //spec300Series.PMP_Specification_Japanese_Nm__c = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Parent_Specification_Id__c = specCon.id;  
        insert spec300Series;
        
        //Create Specification Values
        
        PMP_Specification_Value__c specValueChip = new PMP_Specification_Value__c();
        specValueChip.Name = 'Intel® Z370 Chipset';
        specValueChip.PMP_Active_Ind__c = true;
        specValueChip.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueChip.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueChip.PMP_Product_Specification_Value_Cd__c = '125903';
        specValueChip.PMP_Product_Specification_Value_Key__c = '125903';
        specValueChip.PMP_Spec_Value_Type_Nm__c = 'Processor';
        //specValueChip.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Z370 Chipset';
        //specValueChip.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Z370 Chipset';
        specValueChip.PMP_Specification_Value_Nm__c = 'Intel® Z370 Chipset';
        insert specValueChip;
        
        PMP_Specification_Value__c specValueChipTest = new PMP_Specification_Value__c();
        specValueChipTest.Name = 'Test';
        specValueChipTest.PMP_Active_Ind__c = true;
        specValueChipTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueChipTest.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueChipTest.PMP_Product_Specification_Value_Cd__c = 'Test';
        specValueChipTest.PMP_Product_Specification_Value_Key__c = 'test';
        specValueChipTest.PMP_Spec_Value_Type_Nm__c = 'Chipset';
        specValueChipTest.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        specValueChipTest.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        specValueChipTest.PMP_Specification_Value_Nm__c = 'Test';
        
        insert specValueChipTest;
        PMP_ParseChipSet_JSON.strBaseKey = 'ja_JP';
        PMP_ParseChipSet_JSON.parseChipSetJSON('Chipsets_Attribute_Test');
        System.assertEquals(specValueChip.PMP_Specification_Value_Nm__c, 'Intel® Z370 Chipset');
        
        Test.stopTest();     
    }
}