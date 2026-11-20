/**********************************************************************************************************************************************************
* Class Name  : Core_RestAPI_SPEnvDetailsV1
* Version     : 1.0  
* Created Date: 28 Dec 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/28/2017             Rest API class retrieves the specific Supported Product's Environment Details 
**********************************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/products/*/environmentdetails')
global with sharing class Core_RestAPI_SPEnvDetailsV1{
 private static final DateTime ENTRY_TIME = System.now(); 
    private static final String RESTAPI_NAME = Core_RestAPI_SPEnvDetailsV1.class.getName();
    
    //Get method to retrieve all the Env details of Supported Product
    @HttpGet 
    global static Core_RestAPI_Response doGet()
    {
        Core_RestAPI_SPEnvDetailV1_Handler handler = new Core_RestAPI_SPEnvDetailV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getEnvironmentDetails();//For fetching all list of Environment Details a single Supported Product
        return response;  
       
    }

}