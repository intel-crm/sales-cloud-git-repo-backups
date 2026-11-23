/****************************************************************************************************************************************
* Class Name  : PMP_Attributes_English_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Attributes_English Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Processors_Attribute_English_Test {
    
    @isTest
    public static void testProcAttrMet()
    {
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        
        PMP_Processors_Attribute_English procAttrEng = new PMP_Processors_Attribute_English();
      
        
        PMP_Processor_CreateJunctionData_Test.PMP_Processor_CreateJunctionData_Test_Met();
        PMP_ParseProcessorJSON.strBaseKey = 'en_US';
        resultData = procAttrEng.processData('PMP_Processors_Attribute_Test');
        system.assertNotEquals(resultData,null);
        
    }

}