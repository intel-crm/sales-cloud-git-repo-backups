/****************************************************************************************************************************************
* Class Name  : PMP_Chipsets_Attribute_English_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Chipsets_Attribute_English Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Chipsets_Attribute_English_Test {
    
    @isTest
    public static void testProcAttrMet()
    {
        PMP_Chipsets_Attribute_English procAttrEng = new PMP_Chipsets_Attribute_English();
        PMP_ChipSet_CreateJunctionData_Test.chipSetCreateJunctionDataTestMet();
        PMP_ParseChipSet_JSON.strBaseKey = 'en_US';
        procAttrEng.processData('PMP_Chipsets_Attribute_Test');
    }

}