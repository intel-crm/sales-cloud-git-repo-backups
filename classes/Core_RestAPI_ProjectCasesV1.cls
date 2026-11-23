/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProjectCasesV1 
* Version     : 1.0 
* Created Date: 11 Dec 2017 
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/11/2017               Rest API class retrieves the specific Project's Cases 
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/projects/*/cases')
global with sharing class Core_RestAPI_ProjectCasesV1 {
 private static final DateTime ENTRY_TIME = System.now(); 
    private static final String RESTAPI_NAME = Core_RestAPI_ProjectCasesV1.class.getName();
    
    //Get method to retrieve all the Cases of a single Project
    @HttpGet 
    global static Core_RestAPI_Response doGet()
    {
        Core_RestAPI_ProjectCaseV1_Handler handler = new Core_RestAPI_ProjectCaseV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getProjectCases();//For fetching all Cases of a single Project
        system.debug('response'+response);
        return response;  
       
    }
}