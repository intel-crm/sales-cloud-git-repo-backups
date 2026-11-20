/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_InterestedPartiesV1
* Version     : 1.0 
* Created Date: 12 Dec 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/11/2017               Rest API class retrieves interseted parties for the given caseNumber 
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/cases/*/interestedparties') 
global with sharing  class Core_RestAPI_InterestedPartiesV1 {
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME= Core_RestApi_InterestedPartiesV1.class.getName();
    
    @HttpGet
    global static Core_RestAPI_Response doGet(){
        Core_RestApi_InterestedPartyV1_Handler handler = new Core_RestApi_InterestedPartyV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getInterestedParties();
        return response;
    }
    
    /*@HttpPost   api is on ONHOLD - sudhir 
    global static Core_RestAPI_Response doPost(Core_RestApi_IP_CreateV1_Wrapper interestedParty){
        System.debug('Core_RestAPI_InterestedPartiesV1 doPost Invoked ' +interestedParty);
        Core_RestApi_IP_CreateV1_Handler handler = new Core_RestApi_IP_CreateV1_Handler(ENTRY_TIME, RESTAPI_NAME, null); 
        Core_RestAPI_Response response = handler.createInterestedParties();
        return response;
    }*/
}

//