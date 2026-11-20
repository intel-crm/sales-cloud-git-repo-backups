/****************************************************************************************************************************************
* Class Name  : PMP_Category_Hierarchy_English_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Test Class for Processing Category_Hierarchy_English Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Hierarchy_English_Test 
{
   @isTest
    public static void testCatHierMet(){
        test.startTest();
        PMP_Hierarchy_English catHierEng = new PMP_Hierarchy_English();
        PMP_ParseCategoryJSON.languageCode = 'en_US';
        List<Database.UpsertResult> response = catHierEng.processData('PMP_Category_Hierarchy_Test');
        test.stopTest();
        system.assertNotEquals(response,null);
    }
}