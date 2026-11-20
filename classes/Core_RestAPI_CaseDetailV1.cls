/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Case_DetailV1 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/16/2017               Rest API class retrieves case detail 
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/cases/*') 
global with sharing class Core_RestAPI_CaseDetailV1 {
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_RestAPI_CaseDetailV1.class.getName();
    
    //Retieves the specific case
    @HttpGet
    global static Core_RestAPI_Response doGet(){
        Core_RestAPI_CaseDetailV1_Handler handler = new Core_RestAPI_CaseDetailV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getCaseDetail();
        return response;
    }
    
    //Update the specific case
    @HttpPatch
    global static Core_RestAPI_Response  doPatch(Core_RestAPI_Case_UpdateV1_Wrapper caseDetail){
        Core_RestAPI_Response  resp = null;
        Core_RestAPI_Case_UpdateV1_Handler handler = new Core_RestAPI_Case_UpdateV1_Handler(RESTAPI_NAME, ENTRY_TIME, caseDetail);
        Core_RestAPI_Response response = handler.updateCase();
        return response;
    }
    
}