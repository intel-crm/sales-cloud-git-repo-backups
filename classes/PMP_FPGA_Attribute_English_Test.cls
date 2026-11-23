/****************************************************************************************************************************************
* Class Name  : PMP_FPGA_Attribute_English_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing FPGA_Attributes_English Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_FPGA_Attribute_English_Test {
    
    @isTest
    public static void testProcAttrMet()
    {
        PMP_FPGA_Attribute_English procAttrEng = new PMP_FPGA_Attribute_English();
        PMP_FPGA_CreateJunctionData_Test.fpgaCreateJunctionDataTestMet();
        PMP_ParseFPGAJSON.strBaseKey = 'en_US';
        procAttrEng.processData('PMP_FPGA_Attribute_Test');
    }

}