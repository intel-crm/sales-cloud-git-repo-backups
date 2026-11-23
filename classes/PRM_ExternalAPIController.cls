public without sharing class PRM_ExternalAPIController {
    
    // Wrapper class to hold report details
    
    public class ReportWrapper {
        @AuraEnabled public String reportId { get; set; }
        @AuraEnabled public String developerName { get; set; }
        @AuraEnabled public String workspaceId { get; set; }
        @AuraEnabled public String tableName { get; set; }
        @AuraEnabled public String columnName { get; set; }
    }
    
    // Method to retrieve report details from Custom Metadata Type
    @AuraEnabled
    public Static ReportWrapper getReportDetails(String pageName) {
        ReportWrapper wrap = new ReportWrapper();
        // Query Custom Metadata Type to fetch report details
        for (Power_Bi_Auth_Setting__mdt mdt : [SELECT ReportId__c, DeveloperName,Table_Name__c, Column_Name__c, WorkspaceId__c FROM Power_Bi_Auth_Setting__mdt WHERE label=:pageName LIMIT 1]) {
            wrap.reportId = mdt.ReportId__c;
            wrap.developerName = mdt.DeveloperName;
            wrap.workspaceId = mdt.WorkspaceId__c;
            wrap.tableName = mdt.Table_Name__c;
            wrap.columnName = mdt.Column_Name__c;
        }
       
        return wrap;
    }
    
    // Method to get the Account ID of the current user
    @AuraEnabled
    public static String getAccountId(String pageName) {
        try {
            // Query the User object to retrieve the Account ID associated with the current user
            Id accountId = [SELECT Contact.AccountId, Id FROM User WHERE Id = :UserInfo.getUserId()].Contact.AccountId;
            // Check if the account ID exists in the partner consent distributor table
            List<PRM_Partner_Consent_Distributor__c> pcd = [SELECT Id FROM PRM_Partner_Consent_Distributor__c WHERE PRM_Account_Id__c = :accountId];
            if(pageName == 'partner-assist' || pageName == 'emea-distributors')
            {
                return pcd.size() > 0 ? accountId : null;
            }
            else {
                return accountId;
            }
              
        } 
        catch (Exception ex) {return 'Error: Unable to process the request. Please try again later or contact support. Error message: ' + ex.getMessage();
        }
    }
    
    // Method to check if the current user has access
    @AuraEnabled
    public static boolean checkAccess() {
        List<Core_Contact_Entitlement__c> entitlements = new List<Core_Contact_Entitlement__c>();
        // Query the User object to retrieve the contact record and its partner role
        User contactRecord = [SELECT ContactId, Contact.Core_IPA_PartnerRole__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if (contactRecord != null && contactRecord.Contact.Core_IPA_PartnerRole__c == 'Distributor') {
            // Query the Core_Contact_Entitlement__c object to check for entitlements
            entitlements = [SELECT Id FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c = :contactRecord.ContactId AND Core_Selected__c = true AND Core_Status__c = 'Complete' AND (Core_Entitlement_Id__r.Name = :System.Label.PRM_Partner_Admin OR Core_Entitlement_Id__r.Name = :System.Label.PRM_Partner_Admin_delegate)];
        }
        
        return entitlements.size() > 0 ? true : false;
    }
    
    // Helper class for client credential POST data
  /*  public class ClientCredentialPostData {
        public String client_id;
        public String client_info;
        public String client_secret;
        public String scope;
        public String grant_type;
        
        // Method to format POST data as a string
        public String getPostData() {
            return 'client_id=' + this.client_id + '&client_info=' + this.client_info + '&client_secret=' + this.client_secret + '&scope=' + this.scope + '&grant_type=' + grant_type;
        }
    }*/
    
    // Helper class for client credential response
    public class ClientCredentialResponse {
        public String access_token;
        public String expires_in;
        public String ext_expires_in;
        public String token_type;
    }
    
    // Helper class for Power BI report
    public class PowerBiReport {
      //  public String id { get; set; }
      //  public String reportType { get; set; }
        public String name { get; set; }
      //  public String webUrl { get; set; }
        public String embedUrl { get; set; }
       // public boolean isFromPbix { get; set; }
      //  public boolean isOwnedByMe { get; set; }
        public String datasetId { get; set; }
    }
    
    // Helper class for Power BI embed token
    public class PowerBiEmbedToken {
        public String token { get; set; }
      //  public String tokenId { get; set; }
        public DateTime expiration { get; set; }
    }
    
    // Helper class for Power BI report data
    public class PowerBiReportData {
        @AuraEnabled
        public String workspaceId { get; set; }
        @AuraEnabled
        public String reportId { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String embedUrl { get; set; }
        @AuraEnabled
        public String embedToken { get; set; }
        @AuraEnabled
        public DateTime embedTokenExpires { get; set; }
        @AuraEnabled
       public String error { get; set; }
    }
    
    // Method to retrieve the Power BI access token
    /*public static String getPowerBiAccessToken(String pageName) {
        // Get authentication settings from Custom Metadata Type record
        Power_BI_Auth_Setting__mdt authSetting = [SELECT TenantId__c, ClientId__c, ClientSecret__c FROM Power_Bi_Auth_Setting__mdt WHERE label=:pageName LIMIT 1];
        String TenantId = authSetting.TenantId__c;
        String ClientId = authSetting.ClientId__c;
        String ClientSecret = authSetting.ClientSecret__c;
        
        // Construct URL for client credentials flow
        String aadTokenEndpoint = 'https://login.microsoftonline.com/' + TenantId + '/oauth2/v2.0/token';
        
        // Prepare HTTP request
        HttpRequest reqClientCredentialsFlow = new HttpRequest();
        reqClientCredentialsFlow.setMethod('POST');
        reqClientCredentialsFlow.setEndpoint(aadTokenEndpoint);
        reqClientCredentialsFlow.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // Compose data for POST body
        ClientCredentialPostData postData = new ClientCredentialPostData();
        postData.client_id = ClientId;
        postData.client_info = '1';
        postData.client_secret = ClientSecret;
        postData.scope = 'https://analysis.windows.net/powerbi/api/.default';
        postData.grant_type = 'client_credentials';
        String postBody = postData.getPostData();
        reqClientCredentialsFlow.setBody(postBody);
        
        // Send HTTP POST to execute client credentials flow
        Http http = new Http();
        HttpResponse response = http.send(reqClientCredentialsFlow);
        
        // Extract and return app-only access token for service principal
        String responseJson = response.getBody();
        ClientCredentialResponse responseData = (ClientCredentialResponse)JSON.deserialize(responseJson, ClientCredentialResponse.class);
        String access_token = responseData.access_token;
        return access_token;
    }
*/
    
    // Method to retrieve embedding data for a Power BI report
    @AuraEnabled(cacheable=true)
    public static PowerBiReportData getEmbeddingDataForReport(String WorkspaceId, String ReportId, String pageName) {
        // Get access token for Authorization header
        //String access_token = getPowerBiAccessToken(pageName);
        
        // Call Power BI Service API to get report data for embedding
        HttpRequest reqGetReport = new HttpRequest();
        reqGetReport.setMethod('GET');
        //String urlGetReport = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId;
        String urlGetReport = 'callout:PowerBI/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId;
        reqGetReport.setEndpoint(urlGetReport);
       // reqGetReport.setHeader('Authorization', 'Bearer ' + access_token);
        
        Http http = new Http();
        HttpResponse response = http.send(reqGetReport);
        
        // Check response for success
        if (response.getStatusCode() != 200) { PowerBiReportData getReportError = new PowerBiReportData();
            getReportError.error = 'Get Report Error: ' + response.getStatus();
            return getReportError;
        }
        
        // Extract Power BI report data from JSON response
        String responseJson = response.getBody();
        PowerBiReport powerBiReport = (PowerBiReport)JSON.deserialize(responseJson, PowerBiReport.class);
        
        // Send report info to debug window
        system.debug('here'+powerBiReport);
        system.debug('here'+responseJson);
        // Call Power BI Service API to get embed token for report
        HttpRequest reqGetEmbedToken = new HttpRequest();
        reqGetEmbedToken.setMethod('POST');
      //  String urlGetEmbedToken = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId + '/GenerateToken';
        String urlGetEmbedToken = 'callout:PowerBI/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId + '/GenerateToken';
        reqGetEmbedToken.setEndpoint(urlGetEmbedToken);
       // reqGetEmbedToken.setHeader('Authorization', 'Bearer ' + access_token);
       reqGetEmbedToken.setHeader('Content-Type', 'application/json');
        reqGetEmbedToken.setBody('{"accessLevel": "View", "datasetId": "' + powerBiReport.datasetId + '"}');
     
	   
        HttpResponse responseEmbedToken = http.send(reqGetEmbedToken);
        
        // Check response for success
        if (responseEmbedToken.getStatusCode() != 200) {
           
            PowerBiReportData getEmbedTokenError = new PowerBiReportData();
            getEmbedTokenError.error = 'Get Embed Token Error: '+powerBiReport.datasetId+' ' + response.getStatus();
              System.debug('here'+response.getBody());
            return getEmbedTokenError;
        }
       System.debug('here'+response.getBody());
        // Extract Power BI embed token and expiration
        PowerBiEmbedToken embedToken = (PowerBiEmbedToken)JSON.deserialize(responseEmbedToken.getBody(), PowerBiEmbedToken.class);
                      
        // Create custom remote-able object to return to caller
        PowerBiReportData reportData = new PowerBiReportData();
        reportData.workspaceId = WorkspaceId;
        reportData.reportId = ReportId;
        reportData.name = powerBiReport.name;
        reportData.embedUrl = powerBiReport.embedUrl;
        reportData.embedToken = embedToken.token;
        reportData.embedTokenExpires = embedToken.expiration;
        
        return reportData;
    }
}