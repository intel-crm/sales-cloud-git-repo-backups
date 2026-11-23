/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_PickList 
* Version     : 1.0 
* Created Date: 06 Oct 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/06/2020              Rest API to send Piklist field values as response to the calling system

Sample API call:- /v1.0/quoterequest/picklistutility/Application

in above call "Application" is the picklist field name that the API needs to return the values of.
This field's API name and Object name are configured in "Pricing Picklist Field Names Mapping" custom metadata.
If the requested field name ia available in the custom metadata, then the API returns the picklist values, otherwise returns error response.
*****************************************************************************************************************************************/
@RestResource(urlMapping='/*/quoterequest/picklistutility/*')
global  class Pricing_RestAPI_PickList {
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_PickList.class.getName();
   
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
 
        //RestResponse response = RestContext.Response;
        Pricing_RestAPI_PicklistHandler handler = new Pricing_RestAPI_PicklistHandler(ENTRY_TIME, RESTAPI_NAME);    
        return handler.getPicklistValues();
        //return handler.getPicklistValuesMetadata();
    }//End of doGet
    
}