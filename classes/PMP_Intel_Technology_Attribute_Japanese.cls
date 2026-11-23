/****************************************************************************************************************************************
* Class Name  : PMP_Intel_Technology_Attribute_Japanese
* Version     : 1.0 
* Created Date: 06-06-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      06/06/2019                    Class for Processing Intel_Technology_Attribute_Japanese Static Resource
* ****************************************************************************************************************************************/
public class PMP_Intel_Technology_Attribute_Japanese implements PMP_ProcessTaxonomyJSON {
    public List<Database.UpsertResult> processData(String fileName)
    {
        return PMP_ParseIntelTechnologyJSON.ParseIntelTechJSON(fileName);
    } 

}