/****************************************************************************************************************************************
* Class Name  : PMP_Intel_Tech_Attribute_Chinese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing PMP_IntelTech_Attribute_Chinese Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Intel_Techn_Attribute_Chinese_Test {
    @isTest
    public static void testProcAttrMet()
    {
    
        PMP_Specification__c spec1 = PMP_TestDataUtility.getSpecs();
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP_IntelTechnologies';
        update spec1;
        
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_Intel_Technology_Attribute_Chinese chipAttrChn = new PMP_Intel_Technology_Attribute_Chinese();
        test.startTest();
        PMP_ParseIntelTechnologyJSON.strBaseKey = 'zh_CN';
        resultData = chipAttrChn.processData('Intel_Technology_Attribute_Chinese');
        system.assertNotEquals(resultData,null);
        test.stopTest();
    }
}