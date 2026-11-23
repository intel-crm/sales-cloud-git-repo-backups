/****************************************************************************************************************************************
* Class Name  : Core_Rest_CaseList 
* Version     : 1.0 
* Created Date: 25 Sep 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         9/25/2017               REST API to retrieve Cases
*****************************************************************************************************************************************/
//Author - Sudhir Kathula

@RestResource(urlMapping='/v1/skpoc/cases')
global  class SKPOC_V1_Rest_GetCases  {   
    static DateTime entryTime = System.now();
   
    /*
    @HttpGet
    global static Core_RestApiResponse getCases(){
        String sql = ' SELECT Id,CaseNumber,Status,Subject,LastModifiedDate FROM case order by LastModifiedDate Desc LIMIT 3';
        System.debug(' \n ++++++++++++++ Returning the response '+RestContext.request);
        //Create handler instance
        SKPOC_V1_RestAPI_GetCasesHandler handler = new SKPOC_V1_RestAPI_GetCasesHandler(sql, entryTime);
        Core_RestApiResponse response = handler.getCases();
        handler.logTransaction();
        System.debug(' \n ++++++++++++++ Returning the response '+response);
        return response;
    }*/
    
    
    @HttpGet
    global static SKPOC_Response getCasesV2(){
        String sql = ' SELECT Id,CaseNumber,Status,Subject,LastModifiedDate FROM case order by LastModifiedDate Desc LIMIT 3';
       	SKPOC_Response response = new SKPOC_Response();
        response.err = new ErrorContent();
        return response;
    }
    
    
    @HttpPost
    global static void createCase(){
        //Core_Rest_CreateCasesHandler handler = new Core_Rest_CreateCasesHandler();
    }

    
    
    
   
    
}