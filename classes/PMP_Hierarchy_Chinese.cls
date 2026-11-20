/****************************************************************************************************************************************
* Class Name  : PMP_Category_Hierarchy_Chinese 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Class for Processing PMP_Category_Hierarchy_Chinese Static Resource
* ****************************************************************************************************************************************/

public class PMP_Hierarchy_Chinese implements PMP_ProcessTaxonomyJSON {
    
    public List<Database.UpsertResult> processData(String fileName)
   {
       return PMP_ParseCategoryJSON.parseCategoryJSON(fileName);
   }
}