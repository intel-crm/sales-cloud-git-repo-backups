/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_NUC_Attribute_Japanese_Test
* Version     : 1.0 
* Created Date: 13th Feb, 2019
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            02/13/2019               Test class for NUC_Attribute_Japanese.
******************************************************************************************************************************************************************************************************/
@isTest
public class PMP_NUC_Attribute_Japanese_Test {
	
    testMethod static void testNUCAttributeJapanese(){       
    	PMP_NUC_Attribute_Japanese nucAttrJap = new PMP_NUC_Attribute_Japanese();
        nucAttrJap.processData('NUC_Attribute_Test'); 
    }
}