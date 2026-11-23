/****************************************************************************************************************************************
* Class Name  : PMP_Processors_Attribute_Japanese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Processors_Attribute_Japanese Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Processors_Attribute_Japanese_Test {

    @isTest
    public static void testProcMethod(){
    
        PMP_Specification__c spec1 = PMP_TestDataUtility.getSpecs();
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP_Processors';
        update spec1;
        
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        
        PMP_Processors_Attribute_Japanese testProcessor = new PMP_Processors_Attribute_Japanese();
        test.startTest();
        PMP_ParseProcessorJSON.strBaseKey = 'ja_JP';
        resultData = testProcessor.processData('PMP_Processors_Attribute_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
    }
}