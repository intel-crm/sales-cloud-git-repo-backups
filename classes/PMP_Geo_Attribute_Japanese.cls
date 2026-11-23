/****************************************************************************************************************************************
* Class Name  : PMP_Geo_Attribute_Japanese 
* Version     : 1.0 
* Created Date: 10-22-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      10/22/2019                    Class for Processing PMP_Geo_Attribute_Japanese Static Resource
* ****************************************************************************************************************************************/
public class PMP_Geo_Attribute_Japanese implements PMP_ProcessTaxonomyJSON{

    public List<Database.UpsertResult> processData(String fileName)
    {
        return PMP_ParseGeoRegionsJSON.ParseGeoRegionsJSON(fileName);
    }
    
}