/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_ErrorContent 
* Version     : 1.0 
* Created Date: 03 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         11/03/2020              To create structure of errors in the responses
*****************************************************************************************************************************************/
public  class Pricing_RestAPI_ErrorContent  {
    public String errorMessage {get;set;}
    public String traceId {get;set;}
    public Pricing_RestAPI_QuoteValidationErrors quoteValidationErrors {get;set;}
    
}