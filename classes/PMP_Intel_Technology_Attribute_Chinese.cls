/****************************************************************************************************************************************
* Class Name  : PMP_Intel_Technology_Attribute_Chinese
* Version     : 1.0 
* Created Date: 06-06-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      06/06/2019                    Class for Processing Intel_Technology_Attribute_Chinese Static Resource
* ****************************************************************************************************************************************/
public class PMP_Intel_Technology_Attribute_Chinese implements PMP_ProcessTaxonomyJSON {
    public List<Database.UpsertResult> processData(String fileName)
    {
        return PMP_ParseIntelTechnologyJSON.ParseIntelTechJSON(fileName);
    }

}