/**********************************************************************************************
* Class Name  :   PMP_ParseAllFilesJSONDeltaTest 
* Version     : 1.0 
* Created Date: 31/12/2021
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------
* Yashasvi Aggarwal        31/12/2021               Test class for PMP_ParseAllFilesJSONDelta
*************************************************************************************************/
@isTest
public class PMP_ParseAllFilesJSONDeltaTest {
    
    @isTest
    public static void parseAllFilesJSONTest(){
        Test.startTest();
        //Create Specification Values
        
        PMP_Specification_Value__c spec_value_Proc_Core = new PMP_Specification_Value__c();
        spec_value_Proc_Core.Name = 'IntelÂ® XeonÂ® Platinum 8380HL Processor (38.5M Cache, 2.90 GHz)';
        spec_value_Proc_Core.PMP_Active_Ind__c = true;
        spec_value_Proc_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Core.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Core.PMP_Product_Specification_Value_Cd__c = '205684';
        spec_value_Proc_Core.PMP_Product_Specification_Value_Key__c = '205684';
        spec_value_Proc_Core.PMP_Spec_Value_Type_Nm__c = 'Processor';
        spec_value_Proc_Core.PMP_Product_Status__c='Roadmap';
        spec_value_Proc_Core.PMP_Product_Restriction_Lvl__c='1';
        spec_value_Proc_Core.PMP_Specification_Value_Nm__c = 'IntelÂ® XeonÂ® Platinum 8380HL Processor (38.5M Cache, 2.90 GHz)';
        
        insert spec_value_Proc_Core;
        
        PMP_ParseAllFilesJSONDelta.parseAllFilesJSONDelta('PMP_Delta_IPA_Products_Test');
        Test.stopTest();          
    }
}