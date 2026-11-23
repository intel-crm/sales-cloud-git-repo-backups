global virtual class ICS_ILM_RestAPI_Response {
    public boolean isSuccess{get;set;}  
    public String code {get;set;}
    public List<Core_RestAPI_SuccessContent> successContent{get;set;}  
    public Core_RestAPI_ErrorContent errorContent{get;set;} 
    
    public ICS_ILM_RestAPI_Response(){
        this.isSuccess = true;
    }
}