/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProjectsV1 
* Version     : 1.0 
* Created Date: 20 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/20/2017               Rest API class retrieves list of projects 
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/projects')
global with sharing class Core_RestAPI_ProjectsV1 {
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_RestAPI_ProjectsV1.class.getName();
    
    //Use get method to retrieve list of projects
    @HttpGet
    global static Core_RestAPI_Response doGet()
    {
        Core_RestAPI_ProjectV1_Handler projecthandler = new Core_RestAPI_ProjectV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = projecthandler.getProjects();//For fetching Projects 
        return response;  
    }
}