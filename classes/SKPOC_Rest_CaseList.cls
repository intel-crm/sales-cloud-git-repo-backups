/****************************************************************************************************************************************
* Class Name  : Core_Rest_CaseList 
* Version     : 1.0 
* Created Date: 25 Sep 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         9/25/2017               REST API to retrieve Cases
*****************************************************************************************************************************************/
//Sudhir Kathula - POC
@RestResource(urlMapping='/skpoc/cases')
global  class SKPOC_Rest_CaseList  {   
    
    private static Exception excpObj;
    //Main Wrapper class for User cases.
    global class JsonWithWrapper  {
        public List<WrapperInterface> Cases;      
    }
    public static JsonWithWrapper finalJson = new JsonWithWrapper();
    
    
    //Child Wrapper class for User cases.
    public class CaseWrapper implements WrapperInterface{
        Public String CaseNumber;
        Public String Status;
        Public String Subject;
        Public String CaseURL;
        Public DateTime LastModifiedDate;
    }
    
    
    @HttpGet
    //Main Method to retrieve User Cases
    global static JsonWithWrapper getCases(){
        
        RestRequest req = RestContext.request;
        String uri = '';//req.requestURI;
        System.debug(' Request URI '+uri.contains('v3'));
        System.debug(' Request URI '+req);
        uri = Json.serialize(req);
        System.debug(' Request URI '+uri);
        Core_Log_Entry.core_Log_Entry('B2B','B2B', 'B2B', 'Info', 'B2BRequest', uri, 'strObjectID', 'strObjectType', 'strTags', null);
        List<WrapperInterface> recordsList = new List<CaseWrapper>();
        try{
            for(Case caseRec: [SELECT Id,CaseNumber,Status,Subject,LastModifiedDate
                               FROM case order by LastModifiedDate Desc LIMIT 2])
            {
                CaseWrapper cw = new CaseWrapper();
                cw.CaseNumber = caseRec.CaseNumber;
                cw.Status= caseRec.Status;
                if(uri.contains('v3')){
                    cw.CaseURL = Label.Core_IPS_Portal_URL+caseRec.id;
                    cw.LastModifiedDate = caseRec.LastModifiedDate;
                }
                cw.Subject = caseRec.Subject;
                recordsList.add(cw);
            }
            finalJson.Cases = recordsList;
            System.debug(' Serialize type '+JSON.serialize(finalJson.Cases));
        }
        catch(Exception ex){
            system.debug('Exception Occured '+ ex);
            excpObj = ex;
            throw ex;
        }
        finally{
            System.debug(' In FINAL Method '+finalJson);
            Core_Log_Entry.core_Log_Entry('B2B','B2B', 'B2B', 'Info', 'B2BRequest', 'Finally', 'strObjectID', 'strObjectType', 'strTags', excpObj);
        }
        return finalJson;
    }
    
}


//Core_IPS_ExceptionHandling
//