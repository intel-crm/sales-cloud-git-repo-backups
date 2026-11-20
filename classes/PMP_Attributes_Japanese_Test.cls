/****************************************************************************************************************************************
* Class Name  : PMP_Attributes_Japanese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Attributes_Japanese Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Attributes_Japanese_Test {

    @isTest
    public static void testAttrJap(){
        
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_Attributes_Japanese AttrJap = new PMP_Attributes_Japanese();
        
        
        test.startTest();
        PMP_ParseSpecificationJSON.strBaseKey = 'ja_JP';
        AttrJap.processData('PMP_Attributes_Japanese_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
        
        
    }
}