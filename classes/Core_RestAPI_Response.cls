/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Response 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/6/2017               Response wrapper class for all rest API's
*****************************************************************************************************************************************/
global virtual class  Core_RestAPI_Response {
    public boolean isSuccess{get;set;}  
    public String code {get;set;}
    public List<Core_RestAPI_SuccessContent> successContent{get;set;}  
    public Core_RestAPI_ErrorContent errorContent{get;set;} 
    
    public Core_RestAPI_Response(){
        this.isSuccess = true;
    }
    
    //public Core_RestAPI_Response(boolean flag){
    //    this.isSuccess = flag;
    //}
}