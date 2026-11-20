/**********************************************************************************************************************************************************
* Class Name  : Core_RestAPI_SubEnvDetailsV1
* Version     : 1.0  
* Created Date: 28 Dec 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/28/2017             Rest API class retrieves the specific Supported Product's Subcategories Environment Details 
**********************************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/products/categories/*/environmentdetails')
global with sharing class Core_RestAPI_SubEnvDetailsV1{
 private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_RestAPI_SubEnvDetailsV1.class.getName();
    
      //Get method to retrieve all the Env details of Supported Product's Subcategories
    @HttpGet 
    global static Core_RestAPI_Response doGet()
    {
        Core_RestAPI_SubEnvDetailV1_Handler handler = new Core_RestAPI_SubEnvDetailV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getEnvironmentDetails();
        return response; 
       
    }

}