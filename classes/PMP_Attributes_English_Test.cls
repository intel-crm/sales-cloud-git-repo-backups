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
public class PMP_Attributes_English_Test {
    
    @isTest
    public static void testAttrMet()
    {
    
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_Attributes_English AttrEng = new PMP_Attributes_English();
        
        
        test.startTest();
        PMP_ParseSpecificationJSON.strBaseKey = 'en_US';
        AttrEng.processData('PMP_Attributes_English_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
    }

}