/******************************************************************************************************************************************
Class Name  : SWS_UnrivalService
Version     : 1.0 
Function    : Unrival Service call for Account 360 Tab
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Shijas KM        04/15/2025   Original version
*****************************************************************************************************************************************/


public with sharing class SWS_UnrivalService implements SWS_DynamicMethodInterface {
    
     public Object execute(List<Object> params) {  
        // Implement the logic for the method you want to call 
        String account_ID = (String) params[0];
        String service_URL = (String) params[1];
        String service_Key = (String) params[2];
        String service_Secret = (String) params[3];
         // this is for replacing the accountID string from the URL Configured
        service_URL = service_URL.replace('accountID', account_ID); 
         //  system.debug(service_URL);
        return callUnrivalService(service_URL,service_Key,service_Secret);
    }
   private static string callUnrivalService (string serviceURL, string serviceKey, string serviceSecret){
       List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
       String EmbedURL;
        try{
       		Http httpUnrival = new Http();
            HttpRequest reqUnrival = new HttpRequest();	 
            reqUnrival.setEndpoint(serviceURL);  
            reqUnrival.setMethod('GET');
			reqUnrival.setHeader('Content-Type', 'application/json');
			reqUnrival.setHeader(serviceKey, serviceSecret); 
            HttpResponse resUnrival = httpUnrival.send(reqUnrival);
          if (resUnrival.getStatusCode() == 200) {
            String strUnrivalResponse = resUnrival.getBody();
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(strUnrivalResponse);
        	EmbedURL = (String) jsonMap.get('KS_Embed_Preview') +'&uid='+ UserInfo.getUserId();
          
          }           
           
        }
       catch(Exception ex){
          // return 'Error: ' + ex.getMessage();
         
        }
		
   return EmbedURL;
   }    
    
    public static string GetUnrivalServiceData (){   
       List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
       String salesforceId;
       Custom_URL_Embed__mdt  urlConfig;
        try{ 
            
          urlConfig  = [select id,URL__c, Dynamic_filter__c, Dynamic_Filter_and_Value_txt__c, Object__c, Static_filter__c, Static_Filter_and_Value_txt__c, Security_enforced__c,Security_Query_txt__c, No_Access_Error_txt__c, User_Info__c,User_Filter_and_Value_txt__c ,Core_Add_User_SessionID__c,Core_Session_Parameter__c,DeveloperName,Core_Auto_SSO_Enabled__c,Core_Access_Level__c,Core_Client_ID__c,Core_Client_Secret__c,Core_Tenant_Id__c , Embed_URL_Class__c  from Custom_URL_Embed__mdt where DeveloperName ='Unrival_Service_Companies'];
       		Http httpUnrival = new Http();
            HttpRequest reqUnrival = new HttpRequest();			
            reqUnrival.setEndpoint(urlConfig.URL__c);  
            reqUnrival.setMethod('GET');
			reqUnrival.setHeader('Content-Type', 'application/json');
			reqUnrival.setHeader(urlConfig.Core_Client_ID__c, urlConfig.Core_Client_Secret__c); 
            HttpResponse resUnrival = httpUnrival.send(reqUnrival);
            
          if (resUnrival.getStatusCode() == 200) {
            // Deserialize the JSON string into a generic Map
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(resUnrival.getBody());            
            // Access the list of companies
            List<Object> companies = (List<Object>) jsonMap.get('companies');            
            // Access the first company in the list
            if (companies != null && !companies.isEmpty()) {
                Map<String, Object> firstCompany = (Map<String, Object>) companies[0];                
                // Extract the salesforce_id
                 salesforceId = (String) firstCompany.get('salesforce_id');
            
            } 
            }
        }
       catch(Exception ex){
          // PMP_Utility.logError(ex, 'SWS_UnrivalService.GetUnrivalServiceData');
         
        }      
   
   return salesforceId;
   }
}