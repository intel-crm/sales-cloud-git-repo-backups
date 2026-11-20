/****************************************************************************************************************************************
* Class Name  : PMP_Attributes_English_Proc 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Class for Processing Attributes_English Static Resource
* ****************************************************************************************************************************************/

public class PMP_Attributes_English implements PMP_ProcessTaxonomyJSON {
    
    public List<Database.UpsertResult> processData(String fileName)
    {
        List<Database.UpsertResult> totalRecords = new List<Database.UpsertResult>();
        List<Database.UpsertResult> totalRecordsJunc = new List<Database.UpsertResult>();
        List<Database.UpsertResult> totalResults = new List<Database.UpsertResult>();
        
        totalRecords = PMP_ParseSpecificationJSON.ParseSpecificationJSON(fileName);
        totalRecordsJunc = PMP_CreateJunctionData.createJunctionObjData();
        
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