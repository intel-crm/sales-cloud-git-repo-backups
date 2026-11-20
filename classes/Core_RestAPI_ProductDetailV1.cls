/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProductDetailV1
* Version     : 1.0 
* Created Date: 12/13/2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps     12/13/2017                 Rest API class retrieves specific Intel Product
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/products/*') 
global with sharing  class Core_RestAPI_ProductDetailV1{
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_RestAPI_ProductDetailV1.class.getName();
    
    //Use get method to retrieve the list of Products
    @HttpGet
    global static Core_RestAPI_Response doGet(){
        
        Core_RestAPI_ProductDetailV1_Handler handler = new Core_RestAPI_ProductDetailV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getProducts();
        return response;
    }
    
    
}