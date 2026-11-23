/****************************************************************************************************************************************
* Class Name  : PMP_Processors_Attribute_English_Process 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Class for Processing Processors_Attribute_English Static Resource
* ****************************************************************************************************************************************/

public class PMP_Processors_Attribute_English implements PMP_ProcessTaxonomyJSON {
    
    public List<Database.UpsertResult> processData(String fileName)
    {
        List<Database.UpsertResult> totalRecords = new List<Database.UpsertResult>();
        List<Database.UpsertResult> totalRecordsJunc = new List<Database.UpsertResult>();
        List<Database.UpsertResult> totalResults = new List<Database.UpsertResult>();
        
        totalRecords = PMP_ParseProcessorJSON.ParseProcessorJSON(fileName);
        totalRecordsJunc = PMP_Processor_CreateJunctionData.PMP_Processor_CreateJunctionDataMet();
        
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