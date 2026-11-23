/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ContactsV1 
* Version     : 1.0 
* Created Date: 5 May 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         05/24/2017                Rest API class retrieves contacts
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/contacts') 
global with sharing  class Core_RestAPI_ContactsV1{
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_RestAPI_CasesV1.class.getName();
    
    @HttpGet
    global static Core_RestAPI_Response doGet(){
        System.debug(' request >> '+Json.serialize(RestContext.request));
        Core_RestAPI_ContactV1_Handler handler = new Core_RestAPI_ContactV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getContacts();
        return response;
    }
    
    }