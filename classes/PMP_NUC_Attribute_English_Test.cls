/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_NUC_Attribute_English_Test
* Version     : 1.0 
* Created Date: 13th Feb, 2019
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            02/13/2019               Test class for NUC_Attribute_English.
******************************************************************************************************************************************************************************************************/
@isTest
public class PMP_NUC_Attribute_English_Test {
    
    testMethod static void testNUCAttributeEnglish(){
        PMP_NUC_Attribute_English nucAttrEng = new PMP_NUC_Attribute_English();
        PMP_NUC_CreateJunctionData_Test.createNUCJunctionDataMetTest();
        nucAttrEng.processData('NUC_Attribute_Test');
    }

}