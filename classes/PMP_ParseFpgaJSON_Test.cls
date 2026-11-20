/**********************************************************************************************
* Class Name  :   PMP_ParseFpgaJSON_Test
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------
* Sangeetha                 09/01/2019               Test class for Core_PMP_ParseFpgaJSON
*************************************************************************************************/

@isTest
public class PMP_ParseFpgaJSON_Test {
//IPA 2.0- US-TWC729-7980
    /*@isTest
    public static void parseEnglishFpgaJSONTest(){
    Test.startTest();
     
        PMP_Specification__c FPGA_Spec_Main = new PMP_Specification__c();
        FPGA_Spec_Main.Name = 'FPGA';
        FPGA_Spec_Main.PMP_Partner_Product_Specification_Id__c= 'NPP_FPGA';
        FPGA_Spec_Main.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Main.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Main;
        
        PMP_Specification__c FPGA_Spec_Test = new PMP_Specification__c();
        FPGA_Spec_Test.Name = 'Test';
        FPGA_Spec_Test.PMP_Partner_Product_Specification_Id__c= '194690';
        FPGA_Spec_Test.PMP_Partner_Product_Specification_Key__c= '194690';
        FPGA_Spec_Test.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Test.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Test;
        
        PMP_Specification__c FPGA_Spec_Test2 = new PMP_Specification__c();
        FPGA_Spec_Test2.Name = 'Test2';
        FPGA_Spec_Test2.PMP_Partner_Product_Specification_Id__c= '193644';
        FPGA_Spec_Test2.PMP_Partner_Product_Specification_Key__c= '193644';
        FPGA_Spec_Test2.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Test2.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Test2;
        
        PMP_Specification__c FPGA_Spec1 = new PMP_Specification__c();
        FPGA_Spec1.Name = 'Test';
        FPGA_Spec1.PMP_Active_Ind__c = true;
        FPGA_Spec1.PMP_Parent_Specification_Id__c = FPGA_Spec_Main.Id;
        FPGA_Spec1.PMP_Specification_Type_Nm__c = 'FPGA';
        insert FPGA_Spec1;
        
        PMP_Specification_Value__c spec_value_FPGA = new PMP_Specification_Value__c();
        spec_value_FPGA.Name = 'Intel® Z370 FPGA';
        spec_value_FPGA.PMP_Active_Ind__c = true;
        spec_value_FPGA.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA.PMP_Product_Specification_Value_Cd__c = '125903';
        spec_value_FPGA.PMP_Product_Specification_Value_Key__c = '125903';
        spec_value_FPGA.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        //spec_value_Chip.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Z370 Chipset';
        //spec_value_Chip.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Z370 Chipset';
        spec_value_FPGA.PMP_Specification_Value_Nm__c = 'Intel® Z370 FPGA';
        insert spec_value_FPGA;
        
        PMP_Specification_Value__c spec_value_FPGA_Test = new PMP_Specification_Value__c();
        spec_value_FPGA_Test.Name = 'Test';
        spec_value_FPGA_Test.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Product_Specification_Value_Key__c = 'test';
        spec_value_FPGA_Test.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_FPGA_Test;
        
        PMP_Specification_Value__c spec_value_FPGA_Test2 = new PMP_Specification_Value__c();
        spec_value_FPGA_Test2.Name = 'Test2';
        spec_value_FPGA_Test2.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test2.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test2.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test2.PMP_Product_Specification_Value_Cd__c = '194277';
        spec_value_FPGA_Test2.PMP_Product_Specification_Value_Key__c = '194277';
        spec_value_FPGA_Test2.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test2.PMP_Specification_Value_Chinese_Cd__c = 'Test2';
        spec_value_FPGA_Test2.PMP_Specification_Value_Japanese_Cd__c = 'Test2';
        spec_value_FPGA_Test2.PMP_Specification_Value_Nm__c = 'Test2';
        
        insert spec_value_FPGA_Test2;
        
        PMP_Specification_Value__c spec_value_FPGA_Test3 = new PMP_Specification_Value__c();
        spec_value_FPGA_Test3.Name = 'Test3';
        spec_value_FPGA_Test3.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test3.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test3.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test3.PMP_Product_Specification_Value_Cd__c = '194429';
        spec_value_FPGA_Test3.PMP_Product_Specification_Value_Key__c = '194429';
        spec_value_FPGA_Test3.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test3.PMP_Specification_Value_Chinese_Cd__c = 'Test3';
        spec_value_FPGA_Test3.PMP_Specification_Value_Japanese_Cd__c = 'Test3';
        spec_value_FPGA_Test3.PMP_Specification_Value_Nm__c = 'Test2';
        
        insert spec_value_FPGA_Test3;
        
        system.assertNotEquals(spec_value_FPGA_Test3.Id,null);
        PMP_ParseFPGAJSON.languageCode = 'en_US';
        PMP_ParseFPGAJSON.parseFpgaJSON('PMP_FPGA_Attribute_Test');
        
     Test.stopTest();
    }
    
     @isTest
    public static void parseChineseFpgaJSONTest(){
    Test.startTest();
     
        PMP_Specification__c FPGA_Spec_Main = new PMP_Specification__c();
        FPGA_Spec_Main.Name = 'FPGA';
        FPGA_Spec_Main.PMP_Partner_Product_Specification_Id__c= 'NPP_FPGA';
        FPGA_Spec_Main.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Main.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Main;
        
        PMP_Specification__c FPGA_Spec_Test = new PMP_Specification__c();
        FPGA_Spec_Test.Name = 'Test';
        FPGA_Spec_Test.PMP_Partner_Product_Specification_Id__c= '194690';
        FPGA_Spec_Test.PMP_Partner_Product_Specification_Key__c= '194690';
        FPGA_Spec_Test.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Test.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Test;
        
        PMP_Specification__c FPGA_Spec_Test2 = new PMP_Specification__c();
        FPGA_Spec_Test2.Name = 'Test2';
        FPGA_Spec_Test2.PMP_Partner_Product_Specification_Id__c= '193644';
        FPGA_Spec_Test2.PMP_Partner_Product_Specification_Key__c= '193644';
        FPGA_Spec_Test2.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Test2.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Test2;
        
        PMP_Specification__c FPGA_Spec1 = new PMP_Specification__c();
        FPGA_Spec1.Name = 'Test';
        FPGA_Spec1.PMP_Active_Ind__c = true;
        FPGA_Spec1.PMP_Parent_Specification_Id__c = FPGA_Spec_Main.Id;
        FPGA_Spec1.PMP_Specification_Type_Nm__c = 'FPGA';
        insert FPGA_Spec1;
        
        PMP_Specification_Value__c spec_value_FPGA = new PMP_Specification_Value__c();
        spec_value_FPGA.Name = 'Intel® Z370 FPGA';
        spec_value_FPGA.PMP_Active_Ind__c = true;
        spec_value_FPGA.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA.PMP_Product_Specification_Value_Cd__c = '125903';
        spec_value_FPGA.PMP_Product_Specification_Value_Key__c = '125903';
        spec_value_FPGA.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        //spec_value_Chip.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Z370 Chipset';
        //spec_value_Chip.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Z370 Chipset';
        spec_value_FPGA.PMP_Specification_Value_Nm__c = 'Intel® Z370 FPGA';
        insert spec_value_FPGA;
        
        PMP_Specification_Value__c spec_value_FPGA_Test = new PMP_Specification_Value__c();
        spec_value_FPGA_Test.Name = 'Test';
        spec_value_FPGA_Test.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Product_Specification_Value_Key__c = 'test';
        spec_value_FPGA_Test.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_FPGA_Test;
        
        PMP_Specification_Value__c spec_value_FPGA_Test2 = new PMP_Specification_Value__c();
        spec_value_FPGA_Test2.Name = 'Test2';
        spec_value_FPGA_Test2.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test2.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test2.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test2.PMP_Product_Specification_Value_Cd__c = '194277';
        spec_value_FPGA_Test2.PMP_Product_Specification_Value_Key__c = '194277';
        spec_value_FPGA_Test2.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test2.PMP_Specification_Value_Chinese_Cd__c = 'Test2';
        spec_value_FPGA_Test2.PMP_Specification_Value_Japanese_Cd__c = 'Test2';
        spec_value_FPGA_Test2.PMP_Specification_Value_Nm__c = 'Test2';
        
        insert spec_value_FPGA_Test2;
        
        PMP_Specification_Value__c spec_value_FPGA_Test3 = new PMP_Specification_Value__c();
        spec_value_FPGA_Test3.Name = 'Test3';
        spec_value_FPGA_Test3.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test3.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test3.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test3.PMP_Product_Specification_Value_Cd__c = '194429';
        spec_value_FPGA_Test3.PMP_Product_Specification_Value_Key__c = '194429';
        spec_value_FPGA_Test3.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test3.PMP_Specification_Value_Chinese_Cd__c = 'Test3';
        spec_value_FPGA_Test3.PMP_Specification_Value_Japanese_Cd__c = 'Test3';
        spec_value_FPGA_Test3.PMP_Specification_Value_Nm__c = 'Test2';
        
        insert spec_value_FPGA_Test3;
        
        system.assertNotEquals(spec_value_FPGA_Test3.Id,null);
        PMP_ParseFPGAJSON.languageCode = 'zh_CN';
        PMP_ParseFPGAJSON.parseFpgaJSON('PMP_FPGA_Attribute_Test');
        
     Test.stopTest();
    }
    
     @isTest
    public static void parseJapaneseFpgaJSONTest(){
    Test.startTest();
     
        PMP_Specification__c FPGA_Spec_Main = new PMP_Specification__c();
        FPGA_Spec_Main.Name = 'FPGA';
        FPGA_Spec_Main.PMP_Partner_Product_Specification_Id__c= 'NPP_FPGA';
        FPGA_Spec_Main.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Main.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Main;
        
        PMP_Specification__c FPGA_Spec_Test = new PMP_Specification__c();
        FPGA_Spec_Test.Name = 'Test';
        FPGA_Spec_Test.PMP_Partner_Product_Specification_Id__c= '194690';
        FPGA_Spec_Test.PMP_Partner_Product_Specification_Key__c= '194690';
        FPGA_Spec_Test.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Test.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Test;
        
        PMP_Specification__c FPGA_Spec_Test2 = new PMP_Specification__c();
        FPGA_Spec_Test2.Name = 'Test2';
        FPGA_Spec_Test2.PMP_Partner_Product_Specification_Id__c= '193644';
        FPGA_Spec_Test2.PMP_Partner_Product_Specification_Key__c= '193644';
        FPGA_Spec_Test2.PMP_Specification_Type_Nm__c = 'Other';
        FPGA_Spec_Test2.PMP_Active_Ind__c = true;
        
        insert FPGA_Spec_Test2;
        
        PMP_Specification__c FPGA_Spec1 = new PMP_Specification__c();
        FPGA_Spec1.Name = 'Test';
        FPGA_Spec1.PMP_Active_Ind__c = true;
        FPGA_Spec1.PMP_Parent_Specification_Id__c = FPGA_Spec_Main.Id;
        FPGA_Spec1.PMP_Specification_Type_Nm__c = 'FPGA';
        insert FPGA_Spec1;
        
        PMP_Specification_Value__c spec_value_FPGA = new PMP_Specification_Value__c();
        spec_value_FPGA.Name = 'Intel® Z370 FPGA';
        spec_value_FPGA.PMP_Active_Ind__c = true;
        spec_value_FPGA.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA.PMP_Product_Specification_Value_Cd__c = '125903';
        spec_value_FPGA.PMP_Product_Specification_Value_Key__c = '125903';
        spec_value_FPGA.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        //spec_value_Chip.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Z370 Chipset';
        //spec_value_Chip.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Z370 Chipset';
        spec_value_FPGA.PMP_Specification_Value_Nm__c = 'Intel® Z370 FPGA';
        insert spec_value_FPGA;
        
        PMP_Specification_Value__c spec_value_FPGA_Test = new PMP_Specification_Value__c();
        spec_value_FPGA_Test.Name = 'Test';
        spec_value_FPGA_Test.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Product_Specification_Value_Key__c = 'test';
        spec_value_FPGA_Test.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_FPGA_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_FPGA_Test;
        
        PMP_Specification_Value__c spec_value_FPGA_Test2 = new PMP_Specification_Value__c();
        spec_value_FPGA_Test2.Name = 'Test2';
        spec_value_FPGA_Test2.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test2.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test2.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test2.PMP_Product_Specification_Value_Cd__c = '194277';
        spec_value_FPGA_Test2.PMP_Product_Specification_Value_Key__c = '194277';
        spec_value_FPGA_Test2.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test2.PMP_Specification_Value_Chinese_Cd__c = 'Test2';
        spec_value_FPGA_Test2.PMP_Specification_Value_Japanese_Cd__c = 'Test2';
        spec_value_FPGA_Test2.PMP_Specification_Value_Nm__c = 'Test2';
        
        insert spec_value_FPGA_Test2;
        
        PMP_Specification_Value__c spec_value_FPGA_Test3 = new PMP_Specification_Value__c();
        spec_value_FPGA_Test3.Name = 'Test3';
        spec_value_FPGA_Test3.PMP_Active_Ind__c = true;
        spec_value_FPGA_Test3.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_FPGA_Test3.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_FPGA_Test3.PMP_Product_Specification_Value_Cd__c = '194429';
        spec_value_FPGA_Test3.PMP_Product_Specification_Value_Key__c = '194429';
        spec_value_FPGA_Test3.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        spec_value_FPGA_Test3.PMP_Specification_Value_Chinese_Cd__c = 'Test3';
        spec_value_FPGA_Test3.PMP_Specification_Value_Japanese_Cd__c = 'Test3';
        spec_value_FPGA_Test3.PMP_Specification_Value_Nm__c = 'Test2';
        
        insert spec_value_FPGA_Test3;
        
        system.assertNotEquals(spec_value_FPGA_Test3.Id,null);
        PMP_ParseFPGAJSON.languageCode = 'ja_JP';
        PMP_ParseFPGAJSON.parseFpgaJSON('PMP_FPGA_Attribute_Test');
        
     Test.stopTest();
    }*/
}