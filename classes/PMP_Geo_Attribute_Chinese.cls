/****************************************************************************************************************************************
* Class Name  : PMP_Geo_Attribute_Chinese 
* Version     : 1.0 
* Created Date: 10-22-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      10/22/2019                    Class for Processing PMP_Geo_Attribute_Chinese Static Resource
* ****************************************************************************************************************************************/
public class PMP_Geo_Attribute_Chinese implements PMP_ProcessTaxonomyJSON{

    public List<Database.UpsertResult> processData(String fileName)
    {
        return PMP_ParseGeoRegionsJSON.parseGeoRegionsJSON(fileName);
    }
}