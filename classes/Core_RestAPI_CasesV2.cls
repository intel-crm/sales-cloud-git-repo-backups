/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CasesV2 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/21/2017               Rest API class retrieves cases, contains additional information like count of status
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v2.0/cases') 
global with sharing  class Core_RestAPI_CasesV2 {
    
    private static DateTime entryTime = System.now();
    private static final String RESTAPI_NAME= Core_RestAPI_CasesV2.class.getName();
    
    @HttpGet
    global static Core_RestAPI_Response  doGet(){
        
        Core_RestAPI_CaseV2_Handler handler = new Core_RestAPI_CaseV2_Handler(entryTime, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getCases();
        return response; 
    }
    
    //INFO: Use Post for Creating records
    //@HttpPost
    //global static void doPost(){
        //Core_Rest_CreateCasesHandler handler = new Core_Rest_CreateCasesHandler();
        //handler.createCases();
    //}
    
    //INFO: Use put for updating records
    //@HttpPut
    //global static void doPut(){
        //Core_RestAPI_UpdateCasesHandler handler = new Core_RestAPI_UpdateCasesHandler();
        //handler.updateCases();
    //}
}