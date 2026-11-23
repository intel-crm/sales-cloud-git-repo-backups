/****************************************************************************************************************************************
* Class Name  : PMP_Geo_Attribute_English 
* Version     : 1.0 
* Created Date: 05-22-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/22/2019                    Class for Processing Geo_Attribute_English Static Resource
* ****************************************************************************************************************************************/
public class PMP_Geo_Attribute_English implements PMP_ProcessTaxonomyJSON{

    public List<Database.UpsertResult> processData(String fileName)
    {
        List<Database.UpsertResult> totalRecords = new List<Database.UpsertResult>();
        List<Database.UpsertResult> totalRecordsJunc = new List<Database.UpsertResult>();
        List<Database.UpsertResult> totalResults = new List<Database.UpsertResult>();
        
        totalRecords = PMP_ParseGeoRegionsJSON.ParseGeoRegionsJSON(fileName);
        totalRecordsJunc = PMP_GeoRegion_CreateJunctionData.PMP_GeoRegion_CreateJunctionDataMet();
        
        if(totalRecords.size()>0)
        {
            for(Database.UpsertResult res : totalRecords)
            {
                totalResults.add(res); 
            } 
        }
        
        if(totalRecordsJunc.size()>0)
        {
            for(Database.UpsertResult res : totalRecordsJunc)
            {
                totalResults.add(res);
            }  
        }
        
        
        return totalResults;
    } 
}