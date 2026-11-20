/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProductCategoriesV1
* Version     : 1.0 
* Created Date: 17 Nov 2017
* Modification Log :
* Developer        Farha Amreen        Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/17/2017               Rest API class to retrieve Product's categories and Sub categories
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/products/*/categories')
global with sharing class Core_RestAPI_ProductCategoriesV1{

    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME= Core_RestAPI_ProductCategoriesV1.class.getName();
    
    //Get method to retrieve all the Categories and Sub-Categories of a single Product
    @HttpGet
    global static Core_RestAPI_Response doGet(){
        Core_RestAPI_ProductCategoryV1_Handler handler = new Core_RestAPI_ProductCategoryV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getCategoriesandSubCategories();
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