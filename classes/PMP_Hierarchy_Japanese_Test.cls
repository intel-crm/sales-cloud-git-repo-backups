/****************************************************************************************************************************************
* Class Name  : PMP_Category_Hierarchy_Japanese_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Category_Hierarchy_Chineses Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Hierarchy_Japanese_Test 
{
   @isTest
    public static void testCatHierMet(){
    
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        PMP_Hierarchy_Japanese catHierJap = new PMP_Hierarchy_Japanese();
        
        
        test.startTest();
        PMP_ParseCategoryJSON.languageCode = 'ja_JP';
        catHierJap.processData('PMP_Category_Hierarchy_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
        
        
    }
}