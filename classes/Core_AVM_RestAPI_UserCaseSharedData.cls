/****************************************************************************************************************************************
* Class Name  : Core_AVM_RestAPI_UserCaseSharedData
* Version     : 1.0 
* Created Date: 21 DEC 2021
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/21/2021               Rest API class sent users case share detail 
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/userCaseShares/*') 
global without sharing class Core_AVM_RestAPI_UserCaseSharedData {
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_AVM_RestAPI_UserCaseSharedData.class.getName();
    
    //Retieves the specific case
    @HttpGet	
    global static Core_RestAPI_Response doGet(){
        Core_AVM_UserCaseSharedData_Handler handler = new Core_AVM_UserCaseSharedData_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getCaseDetail();
        return response;
    }
    
}