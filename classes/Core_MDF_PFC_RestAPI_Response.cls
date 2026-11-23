/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : Core_MDF_PFC_RestAPI_Response
 * Author          : <YourName>
 * Created Date    : May 25, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 25, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 25, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

global  virtual class  Core_MDF_PFC_RestAPI_Response {
    public boolean isSuccess{get;set;}  
    public String code {get;set;}
    public List<Object> successContent{get;set;}  
    public Object errorContent{get;set;} 
    public long totalRecords {set;get;}
    //public long executionTime {get;set;}
    
    public Core_MDF_PFC_RestAPI_Response(){
        this.isSuccess = true;
    }
   
}