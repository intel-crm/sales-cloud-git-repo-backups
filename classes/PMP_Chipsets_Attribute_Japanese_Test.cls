/****************************************************************************************************************************************
* Class Name  : PMP_Chipsets_Attribute_Japanese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Chipsets_Attribute_Japanese Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Chipsets_Attribute_Japanese_Test {
    
    @isTest
    public static void testProcAttrMet()
    {
    
        PMP_Specification__c spec1 = PMP_TestDataUtility.getSpecs();
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP_Chipsets';
        update spec1;
        
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_Chipsets_Attribute_Japanese procAttrEng = new PMP_Chipsets_Attribute_Japanese();
        
        
        test.startTest();
        PMP_ParseChipSet_JSON.strBaseKey = 'ja_JP';
        resultData = procAttrEng.processData('PMP_Chipsets_Attribute_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
        
        
    }

}