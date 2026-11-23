/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_ChangeHistory 
* Version     : 2.0 
* Created Date: 01 Jun 2023
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         06/01/2023              Rest API to send all quotelines not created by current user as response to the calling system

Sample API call:- /services/apexrest/v2.0/quoterequest/changehistory?id=&status=&quotelinetype=&endDate=&approvedorrejecteddate=&operator=&limit=&offset=
The above call sends the records of Quote object as response
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v2.0/quoterequest/changehistory')
global without sharing class Pricing_RestAPI_ChangeHistory {
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_GetAllQuotesV2.class.getName();
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet() {
        //Pricing_RestAPI_GetAllQuotesV2  getAllQuotes = new Pricing_RestAPI_GetAllQuotesV2();
        //Pricing_RestAPI_GetAllQuotesV2.isChangeHistory= true;
        //response = Pricing_RestAPI_GetAllQuotesV2.doGet();
        return response;
    }  
}