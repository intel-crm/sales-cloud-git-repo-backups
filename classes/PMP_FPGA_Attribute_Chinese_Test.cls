/****************************************************************************************************************************************
* Class Name  : PMP_FPGA_Attribute_Chinese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing FPGA_Attributes_Chinese Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_FPGA_Attribute_Chinese_Test {
    
    @isTest
    public static void testProcAttrMet()
    {

        PMP_Specification__c spec1 = PMP_TestDataUtility.getSpecs();
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP_FPGA';
        update spec1;
        
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_FPGA_Attribute_Chinese procAttrEng = new PMP_FPGA_Attribute_Chinese();
        
        
        test.startTest();
        PMP_ParseFPGAJSON.strBaseKey = 'zh_CN';
        resultData = procAttrEng.processData('PMP_FPGA_Attribute_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
        
        
    }

}