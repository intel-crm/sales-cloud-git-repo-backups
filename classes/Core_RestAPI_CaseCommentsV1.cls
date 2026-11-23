/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseCommentsV1 
* Version     : 1.0 
* Created Date: 12 Dec 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/12/2017               Rest API class retrieves case comments of particular case 
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/cases/*/comments') 
global with sharing  class Core_RestAPI_CaseCommentsV1 {

    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME= Core_RestAPI_CaseCommentsV1.class.getName();
    
    @HttpGet
    global static Core_RestAPI_Response doGet(){
    
        Core_RestAPI_CaseCommentV1_Handler handler = new Core_RestAPI_CaseCommentV1_Handler (ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getCaseComments();
        return response;
    }
    @HttpPost
    global static Core_RestAPI_Response doPost(Core_RestAPI_CC_CreateV1_Wrapper caseComments){
        Core_RestAPI_CC_CreateV1_Handler handler = new Core_RestAPI_CC_CreateV1_Handler(ENTRY_TIME, RESTAPI_NAME,caseComments);
        //Core_RestAPI_CC_CreateV2_Handler handler = new Core_RestAPI_CC_CreateV2_Handler(ENTRY_TIME, RESTAPI_NAME,caseComments);
        Core_RestAPI_Response response = handler.createCaseComments();
        return response;
        
    }
}