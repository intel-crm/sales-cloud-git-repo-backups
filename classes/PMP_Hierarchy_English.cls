/****************************************************************************************************************************************
* Class Name  : PMP_Category_Hierarchy_English 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Class for Processing Category_Hierarchy_English Static Resource
* ****************************************************************************************************************************************/

public class PMP_Hierarchy_English implements PMP_ProcessTaxonomyJSON 
{
   public List<Database.UpsertResult> processData(String fileName)
   {
       return PMP_ParseCategoryJSON.parseCategoryJSON(fileName);
   }

}