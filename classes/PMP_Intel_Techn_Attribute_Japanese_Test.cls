/****************************************************************************************************************************************
* Class Name  : PMP_Intel_Tech_Attribute_Japanese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing PMP_IntelTech_Attribute_Japanese Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Intel_Techn_Attribute_Japanese_Test {
   @isTest
    public static void testProcAttrMet()
    {   
    
        PMP_Specification__c spec1 = PMP_TestDataUtility.getSpecs();
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP_IntelTechnologies';
        update spec1;
        
        
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_Intel_Technology_Attribute_Japanese chipAttrChn = new PMP_Intel_Technology_Attribute_Japanese();
        test.startTest();
        PMP_ParseIntelTechnologyJSON.strBaseKey = 'ja_JP';
        resultData = chipAttrChn.processData('Intel_Technology_Attribute_English_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
    }
}