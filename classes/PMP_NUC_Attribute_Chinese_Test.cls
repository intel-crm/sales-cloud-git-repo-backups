/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_NUC_Attribute_Chinese_Test
* Version     : 1.0 
* Created Date: 13th Feb, 2019
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            02/13/2019               Test class for NUC_Attribute_Chinese.
******************************************************************************************************************************************************************************************************/
@isTest
public class PMP_NUC_Attribute_Chinese_Test {

    testMethod static void testNUCAttributeChinese(){       
    	PMP_NUC_Attribute_Chinese nucAttrChn = new PMP_NUC_Attribute_Chinese();
        nucAttrChn.processData('NUC_Attribute_Test');
    }
}