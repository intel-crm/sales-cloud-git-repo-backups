/**************************************************************************************
Apex Class Name:  Core_IQR_ProductUtility
Version     : 1.0 
Created Date: 02 Nov 2021
Function    : To get the access token from APIGEE for IQR Product Functionality
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya Dayananda           02/11/2021             Original Version
*************************************************************************************/
public class Core_IQR_ProductUtility {
    public static String accessToken = '';
    public static List<Core_Log_Entry__c> Logentries= new List<Core_Log_Entry__c> ();
    /*
    * Method name  : generateAccessToken
    * Description  : This Method is used to generate the Accesstoken for AGS Integration
    * Return Type  : None
    * Parameter    : Name of the Custom Setting record where we stored the AGS integration information
    */
    public static String generateAccessToken(String integrationSettingname){
        Core_Apigee_Cred_Contact_GEC__c integrationSetting = Core_Apigee_Cred_Contact_GEC__c.getValues(integrationSettingname);
        String accessTokenURL = integrationSetting?.Core_Token_EndPoint_URL__c;
        String clientId = integrationSetting?.Core_Client_Id__c;
        String clientSecret = integrationSetting?.Core_Client_Secret__c;
        String grantType = integrationSetting?.Core_Grant_Type__c;
      //  AGSEndpointURL=integrationSetting?.Core_EndPoint_Url__c;
        
        HttpRequest accessTokenRequest = new HttpRequest();
        accessTokenRequest.setEndpoint(accessTokenURL);
        system.debug('TokenUrl'+accessTokenURL);
        accessTokenRequest.setMethod('GET');
        accessTokenRequest.setBody('grant_type='+grantType+'&client_id='+clientId+'&client_secret='+clientSecret);
        accessTokenRequest.setTimeout(12000);
        Http tokenCallout = new Http(); 
        HTTPResponse tokenResponse = tokenCallout.send(accessTokenRequest);
        system.debug('***tokenbody'+tokenResponse.getBody());
        
        //  return accessToken;
        if(tokenResponse.getStatusCode() == 200){
            Map<string,Object> resultMap = (Map<string,Object>)JSON.deserializeUntyped(tokenResponse.getBody());
            accessToken = (String) resultMap.get('access_token');
            return accessToken;
        } else {
            String strDetails=  'Call out Service Name : '+'Core_IQR_ProductUtility'+'\n Trace Information : '+'STATUS:'+ tokenResponse.getStatus() + '\nSTATUS_CODE:' + tokenResponse.getStatusCode() + '\n Message:' + tokenResponse.toString();
            
            logEntries.add(new Core_Log_Entry__c(Core_Message__c =strDetails , Core_Origin__c='Core_IQR_ProductUtility.generateAccessToken', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            
            return null;
        }
        
        
    }


}