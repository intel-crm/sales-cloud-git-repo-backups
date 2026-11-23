/****************************************************************************************************************************************
* Class Name  : PMP_Category_Hierarchy_Chinese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Category_Hierarchy_Chineses Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Hierarchy_Chinese_Test 
{
   @isTest
    public static void testCatHierMet(){
    
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_Hierarchy_Chinese catHierChn = new PMP_Hierarchy_Chinese();
        
        test.startTest();
        PMP_ParseCategoryJSON.strBaseKey = 'zh_CN';
        catHierChn.processData('PMP_Category_Hierarchy_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
        
    }
}