/****************************************************************************************************************************************
* Class Name  : PMP_Attributes_Chinese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Attributes_Chinese Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Attributes_Chinese_Test {
    
    @isTest
    public static void testAttrMet()
    {
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_Attributes_Chinese AttrChn = new PMP_Attributes_Chinese();
        
        
        test.startTest();
        PMP_ParseSpecificationJSON.strBaseKey = 'zh_CN';
        AttrChn.processData('PMP_Attributes_Chinese_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
    }

}