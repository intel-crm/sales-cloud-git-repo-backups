/****************************************************************************************************************************************
* Class Name  : PMP_Intel_Technology_Attribute_English
* Version     : 1.0 
* Created Date: 06-06-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      06/06/2019                    Class for Processing Intel_Technology_Attribute_English Static Resource
* ****************************************************************************************************************************************/
public class PMP_Intel_Technology_Attribute_English implements PMP_ProcessTaxonomyJSON {
    public List<Database.UpsertResult> processData(String fileName)
    {
        List<Database.UpsertResult> totalRecords = new List<Database.UpsertResult>();
        List<Database.UpsertResult> totalRecordsJunc = new List<Database.UpsertResult>();
        List<Database.UpsertResult> totalResults = new List<Database.UpsertResult>();
        
        totalRecords = PMP_ParseIntelTechnologyJSON.ParseIntelTechJSON(fileName);
        totalRecordsJunc = PMP_IntelTech_CreateJunctionData.PMP_Inteltech_CreateJunctionDataMet();
        
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