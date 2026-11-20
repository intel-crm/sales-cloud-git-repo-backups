/*********************************************
* Name : Core_IPS_APIGEE_Utility 
* Author : Chandrashekar Pallikonda
* Date Created : 21/05/2021
* Description : This class is used as a utility for token generation for MyIntel Integration.
*   
************************************************/
public class Core_IPS_APIGEE_Utility {
    public static String accessToken = '';
    public static String generateAccessToken(String integrationName){
        try{
            Core_IPS_APIGEE_Custom_Settings__c integrationSetting = Core_IPS_APIGEE_Custom_Settings__c.getValues(integrationName);
            String accessTokenURL = integrationSetting?.MyIntel_Token_Endpoint_URL__c;
            String clientId = integrationSetting?.MyIntel_Client_Id__c;
            String clientSecret = integrationSetting?.MyIntel_Client_Secret__c;
            String grantType = integrationSetting?.MyIntel_GrantType__c;
            
            HttpRequest accessTokenRequest = new HttpRequest();
            accessTokenRequest.setEndpoint(accessTokenURL);
            accessTokenRequest.setMethod('POST');
            accessTokenRequest.setBody('grant_type='+grantType+'&client_id='+clientId+'&client_secret='+clientSecret);
            accessTokenRequest.setTimeout(12000);
            Http tokenCallout = new Http(); 
            HTTPResponse tokenResponse = tokenCallout.send(accessTokenRequest);
            
            if(tokenResponse.getStatusCode() == 200){
              
                Map<string,Object> resultMap = (Map<string,Object>)JSON.deserializeUntyped(tokenResponse.getBody());
                accessToken = (String) resultMap.get('access_token');
                
                return accessToken;
            } else {
                
                String strDetails=  'Call out Service Name : '+'Core_IPS_MyIntel_Utility'+'\n Trace Information : '+'STATUS:'+ tokenResponse.getStatus() + '\nSTATUS_CODE:' + tokenResponse.getStatusCode() + '\n Message:' + tokenResponse.toString();
                Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'error','IPS MyIntel Integration issue',strDetails,null,'Case',null);
                return null;
            }
        } catch(Exception e){ String strDetails=  'Exception Occured.';
            Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Case',null);
            return null;
        }
    }
   
    // This method is used to generate access token for backend system HSD,IPS JIRA,RTC 
    public static String generateAccessToken1(String integrationName){
        try{
            
            Core_IPS_System_Credentails_Apigee__c integrationSetting = Core_IPS_System_Credentails_Apigee__c.getValues(integrationName);
            String accessTokenURL = integrationSetting?.Core_IPS_Authorization_URL__c;
            String clientId = integrationSetting?.Core_IPS_Client_Id__c;
            String clientSecret = integrationSetting?.Core_IPS_Client_Secret__c;
            String grantType = integrationSetting?.Core_IPS_GrantType__c;
            
            HttpRequest accessTokenRequest = new HttpRequest();
            accessTokenRequest.setEndpoint(accessTokenURL);
            accessTokenRequest.setMethod('POST');
            accessTokenRequest.setBody('grant_type='+grantType+'&client_id='+clientId+'&client_secret='+clientSecret);
            accessTokenRequest.setTimeout(12000);
            Http tokenCallout = new Http(); 
            HTTPResponse tokenResponse = tokenCallout.send(accessTokenRequest);
            
            
            if(tokenResponse.getStatusCode() == 200){
                
                Map<string,Object> resultMap = (Map<string,Object>)JSON.deserializeUntyped(tokenResponse.getBody());
                accessToken = (String) resultMap.get('access_token');
                return accessToken;
            } else {
                
                String strDetails=  'Call out Service Name : '+'IPS_APIGEE_Case_Backend_System'+'\n Trace Information : '+'STATUS:'+ tokenResponse.getStatus() + '\nSTATUS_CODE:' + tokenResponse.getStatusCode() + '\n Message:' + tokenResponse.toString();
                Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'error','IPS Backend Integration issue',strDetails,null,'Case',null);
                return null;
            }

        } catch(Exception e){ String strDetails=  'Exception Occured.';
            Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS Backend Integration issue',strDetails,null,'Case',null);
            return null;
        }   
    }
}