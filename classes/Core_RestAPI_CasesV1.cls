/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CasesV1 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/6/2017  (Created)              Rest API class retrieves cases 
* Team: PopcornApps         01/18/2018 (Modified)             Added Post method for creating cases
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/cases') 
global with sharing  class Core_RestAPI_CasesV1 {
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_RestAPI_CasesV1.class.getName();
    
    @HttpGet
    global static Core_RestAPI_Response doGet(){
        Core_RestAPI_CaseV1_Handler handler = new Core_RestAPI_CaseV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getCases();
        return response;
    }
    
    //INFO: Use Post for Creating records
    //@HttpPost
    @HttpPost
    global static Core_RestAPI_Response doPost(Core_RestAPI_Case_CreateV1_Wrapper caseDetail){
     Core_RestAPI_Response  resp = null;
        Core_RestApi_Case_CreateV1_Handler handler = new Core_RestApi_Case_CreateV1_Handler(RESTAPI_NAME, ENTRY_TIME, caseDetail);
        return handler.createCase();
    }
    
        
    //INFO: Use put for updating records
    //@HttpPut
    //global static void doPut(){
        //Core_RestAPI_UpdateCasesHandler handler = new Core_RestAPI_UpdateCasesHandler();
        //handler.updateCases();
    //}
}