global  virtual class  Core_SalesCRM_RestAPI_Response {
    public boolean isSuccess{get;set;}  
    public String code {get;set;}
    public List<Core_RestAPI_SuccessContent> successContent{get;set;}  
    public Core_SalesCRM_RestAPI_ErrorContent errorContent{get;set;} 
    public long totalRecords {set;get;}

    public Core_SalesCRM_RestAPI_Response(){
        this.isSuccess = true;
    }
   
}