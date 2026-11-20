/****************************************************************************************************************************************
* Class Name  : PMP_ProcessTaxonomyJSON 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Interface for Processing different Taxonomy files
* ****************************************************************************************************************************************/

public interface PMP_ProcessTaxonomyJSON 
{
     List<Database.UpsertResult> processData(String fileName);
     
}