/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Response 
* Version     : 1.0 
* Created Date: 03 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         03/11/2020              To create structure of all the responses
*****************************************************************************************************************************************/
global virtual class  Pricing_RestAPI_Response {
    public boolean isSuccess{get;set;}  
    public String code {get;set;}
    public List<Pricing_RestAPI_SuccessContent> successContent{get;set;}  
    public Pricing_RestAPI_ErrorContent errorContent{get;set;} 
    public long totalRecords {set;get;}
    //public long executionTime {get;set;}
    
    public Pricing_RestAPI_Response(){
        this.isSuccess = true;
    }
   
}