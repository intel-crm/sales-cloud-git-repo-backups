/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//NP - 2023
//Class that will dynamically embed URLs in Lightning Record Pages
//Maintain URL details in Custom Metatdata - Custom_URL_Embed__mdt
//TWC3123-5759 Added without sharing keyword to fix code scan issue
//TWC5945-1988 Call Unrival URL and Display Insights on Account 360 Page
public without sharing class Custom_URL_Embed { 
    
    public static Custom_URL_Embed__mdt urlConfig;
    
    public static void loadMetadataRecord(String configName){
        urlConfig = [select id,URL__c, Dynamic_filter__c, Dynamic_Filter_and_Value_txt__c, Object__c,
                     Static_filter__c, Static_Filter_and_Value_txt__c, 
                     Security_enforced__c,Security_Query_txt__c, No_Access_Error_txt__c,
                     User_Info__c,User_Filter_and_Value_txt__c ,Core_Add_User_SessionID__c,Core_Session_Parameter__c,DeveloperName,
                     Core_Auto_SSO_Enabled__c,Core_Access_Level__c,Core_Client_ID__c,Core_Client_Secret__c,Core_Tenant_Id__c
                     ,Embed_URL_Class__c
                     from Custom_URL_Embed__mdt where DeveloperName = :configName];
        
    }


    @AuraEnabled(cacheable=true)
    public static GetURLWrapperClass getURL(string configName, string recordId) {
        GetURLWrapperClass result=new GetURLWrapperClass();
        Map<string,string> filterToField = new Map<string,string>();
        Map<string,string> filterToValue = new Map<string,string>();
        List<string> fieldsToBeQueriedL = new List<string>();
        string filterConditions = '';
        boolean hasAccess = true;
        string url = '';
        
        try {
            
            //Query to get the URL Configs
            loadMetadataRecord(configName);
            system.debug('urlConfig.Embed_URL_Class__c' + urlConfig.Embed_URL_Class__c);
            if (urlConfig.Embed_URL_Class__c != null)
            {
                List<Object> methodParams= new  List<Object>();
                methodParams.add(recordId);
                methodParams.add(urlConfig.URL__c);
                methodParams.add(urlConfig.Core_Client_ID__c);
                methodParams.add(urlConfig.Core_Client_Secret__c);
                system.debug('URL EMBED METHOD PARAMS:'+methodParams);
                // Call the respective service and get the URL Dynamically                 
                Object obj =  SWS_DynamicMethodCaller.callMethod(urlConfig.Embed_URL_Class__c, methodParams);  
                if (obj != null)
                {
                result.reportURL=  (String) obj;            
                result.hasAccess=true;
                result.autoSSOEnabled=false;
                }       
            }
            else
            {
            
            url += urlConfig.URL__c;
            
            //If URL has Dynamic Filters
            if(urlConfig.Dynamic_filter__c) {
                url += dynamicFilters(urlConfig, recordId);
            }
            
            //If URL has Static filters
            if(urlConfig.Static_filter__c) {
                url += staticFilters(urlConfig);
            }
            
            //If User info is required in URL
            if(urlConfig.User_Info__c){
                url+= getUserInfo(urlConfig);
            }
            //TWC3123-3650-check for user session.
            if(urlConfig.Core_Add_User_SessionID__c){
                PageReference newPage = Page.GetSessionIdPage;
                String content = newPage.getContent().toString();              
                String sid = content.substringBetween('<SessionId>', '</SessionId>');     
                if(url.contains('&')){
                    url+= '&'+ urlConfig.Core_Session_Parameter__c +'='+ sid;
                }else{
                    url+= urlConfig.Core_Session_Parameter__c +'='+ sid;
                }
            }
            //Check for Request ID.
            if(Core_CRM_Utility.getCRMLabel('External_URL_s_Name').contains(urlConfig.DeveloperName)) {
                String req_id = (Math.random()+' ').substring(2,10)+(Math.random()+' ').substring(2,10);
                if(url.contains('&')){url += '&req_id='+req_id;}else{url+= 'req_id='+req_id;}
            }
            //TWC3123-3650 - End
            
            //If access of component needs to be controlled
            if(urlConfig.Security_enforced__c){
                hasAccess = securityFilters(urlConfig,recordId);
                if(!hasAccess){
                    url = '';
                    url = urlConfig.No_Access_Error_txt__c;
                }
            }
            
            if(urlConfig.Core_Auto_SSO_Enabled__c) {
                result.hasAccess=hasAccess;
                result.autoSSOEnabled=true;
                result.reportURL=url;
            }
            else{
                result.hasAccess=hasAccess;
                result.autoSSOEnabled=false;
                result.reportURL=url;
            }
            }
            system.debug('URL EMBED RESULT:'+result);
        }
        catch(exception ex) {
             system.debug(ex);
            hasAccess = false;string error = 'Error :'+ ex.getMessage();result.hasAccess=hasAccess;result.autoSSOEnabled=false;result.reportURL=error;}
        
        return result;  
    }



    
    
    //Dynamic Filter logic
    public static string dynamicFilters(Custom_URL_Embed__mdt config, string recordId){
        string url = '';
        string filterConditions = '';
        
        try {
            FilterAndValueParams fP = splitTheFilters(config.Dynamic_Filter_and_Value_txt__c);
            string fieldsToBeQueried = String.join(new List <String> (fP.fieldsToBeQueriedL), ',');
            string dynamicQuery = 'Select '+ String.escapeSingleQuotes(fieldsToBeQueried) + ' from '+ config.Object__c + ' where id=:recordId';
            sObject sO=Database.query(dynamicQuery);
            fP.sO = sO;
            fP.delimiter = 'and';
            url+=buildFilter(fP);  
        }
        catch(exception ex) {
            PMP_Utility.logError(ex, 'Custom_URL_Embed.dynamicFilters');
        }
        if(config.URL__c.containsIgnoreCase('powerbi')){
            url = EncodingUtil.urlEncode(url, 'UTF-8');
        }
        return url;
    }
    
    //Static Filter logic
    public static string staticFilters(Custom_URL_Embed__mdt config){
        string url = '';
        
        try {
            if(config.Dynamic_filter__c) {
                url+='&' + config.Static_Filter_and_Value_txt__c;
            }
            else {
                url+= config.Static_Filter_and_Value_txt__c;
            }
        }
        catch(exception ex) {
            PMP_Utility.logError(ex, 'Custom_URL_Embed.staticFilters'); 
        }
        return url; 
    }
    
    //User Info logic
    public static string getUserInfo(Custom_URL_Embed__mdt config){
        string urlAddn;    
        string filterConditions = '';
        
        try{
            FilterAndValueParams fP = splitTheFilters(config.User_Filter_and_Value_txt__c);
            string fieldsToBeQueried = String.join(new List <String> (fP.fieldsToBeQueriedL), ',');
            string userId = UserInfo.getUserId();
            string dynamicQuery = 'Select '+ String.escapeSingleQuotes(fieldsToBeQueried) + ' from User where id=:userId';
            User userRec=Database.query(dynamicQuery);
            
            urlAddn = '&';
            fP.sO = userRec;
            fP.delimiter='&';
            
            urlAddn+=buildFilter(fP);
            
        }
        
        catch(exception ex) {
            PMP_Utility.logError(ex, 'Custom_URL_Embed.getUserInfo');
        }
        
        return urlAddn;
        
    }
    
    //Component Visibilty Logic
    public static boolean securityFilters(Custom_URL_Embed__mdt config, string recordId){
        boolean hasAccess = true;
        
        try {
            string query = config.Security_Query_txt__c + ' WITH SECURITY_ENFORCED';
            sObject[] securitySo =Database.query(query);
            hasAccess = securitySo.size()>0 ? true:false; 
        }
        catch(exception ex) {
            PMP_Utility.logError(ex, 'Custom_URL_Embed.securityFilters');
        }
        return hasAccess; 
    }
    
    //Generic methods
    //Split the text based on the filter condition and value
    public static FilterAndValueParams splitTheFilters(string filterValue){
        FilterAndValueParams fP = new FilterAndValueParams();
        Map<string,string> filterToField = new Map<string,string>();
        Map<string,string> filterToValue = new Map<string,string>();
        List<string> fieldsToBeQueriedL = new List<string>();
        
        try{
            List<string> filterVal = filterValue.contains(';')?filterValue.split(';'):new List<string>{filterValue};
                for(string filter:filterVal) {
                    list<string> innerList = filter.split(':');
                    string apiNames = innerList[1].replaceAll('\'','');
                    fieldsToBeQueriedL.add(apiNames);
                    filterToField.put(innerList[0],apiNames);
                    filterToValue.put(innerList[0],innerList[1]);
                }
            fP.filterToField = filterToField;
            fP.filterToValue = filterToValue;
            fP.fieldsToBeQueriedL = fieldsToBeQueriedL;
        }
        
        catch(exception ex) {
            PMP_Utility.logError(ex, 'Custom_URL_Embed.splitTheFilters');
        }
        return fP;
    }
    
    //Build the filter-value pair based on the query
    public static string buildFilter(FilterAndValueParams fP){
        string filterConditions = '';
        try {
            for(string fV: fP.filterToField.keyset()) {
                //TWC3123-4663
                String filterv;
                if(String.valueOf(fP.sO.get(fP.filterToField.get(fv)))==Null){
                    filterv = '%27%27';
                }else{
                    filterv = String.valueOf(fP.sO.get(fP.filterToField.get(fv)));
                } //TWC3123-4663-End
                string value = fP.filterToValue.get(fV).replace(fP.filterToField.get(fV),filterv);
                filterConditions += fV + value;
                if(fP.filterToField.size()>1) {
                    filterConditions += fP.delimiter; 
                }
            }
            filterConditions = filterConditions.removeend(fP.delimiter);  
        }
        catch(exception ex) {
            PMP_Utility.logError(ex, 'Custom_URL_Embed.buildFilter'); 
        }
        return filterConditions;
    }
    
    
    public static String getPowerBiAccessToken(String configName) {
        
        // get auth settings from Custom Metadata Type reconrd
        if(urlConfig == null){loadMetadataRecord(configName);}
        string TenantId = urlConfig.Core_Tenant_Id__c;// authSetting.TenantId__c;    
        
        string ClientId =urlConfig.Core_Client_ID__c;// authSetting.ClientId__c;    
        string ClientSecret =urlConfig.Core_Client_Secret__c;// authSetting.ClientSecret__c;        
        
        // construct URL for client credentials flow
        String aadTokenEndpoint = Core_CRM_Utility.getCRMLabel('Core_MicrosoftConnectionURLForPBI') + TenantId + '/oauth2/v2.0/token';
        
        // prepare HTTP request 
        HttpRequest reqClientCredentialsFlow = new HttpRequest();
        reqClientCredentialsFlow.setMethod('POST');
        reqClientCredentialsFlow.setEndpoint(aadTokenEndpoint);        
        reqClientCredentialsFlow.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // compose data for POST body
        ClientCredentialPostData postData = new ClientCredentialPostData();
        postData.client_id = ClientId;
        postData.client_info = '1';
        postData.client_secret = ClientSecret;
        postData.scope = Core_CRM_Utility.getCRMLabel('Core_PBIReportScope');
        postData.grant_type = 'client_credentials';        
        String postBody = postData.getPostData();
        reqClientCredentialsFlow.setBody(postBody);
        // send HTTP POST to execute client credentials flow
        Http http = new Http();        
        HttpResponse response = http.send(reqClientCredentialsFlow);
        
        // extract and return app-only access token for service principal
        String responseJson = response.getBody();
        ClientCredentialResponse responseData = (ClientCredentialResponse)JSON.deserialize(responseJson, ClientCredentialResponse.class);
        String access_token = responseData.access_token;   
        if(access_token != null){
            debugUntruncated(access_token);
        }
        return access_token;
    }
    
    public static void debugUntruncated(String msg) {
        for (Integer i = 0; i < msg.length(); i=i+300) {
            Integer effectiveEnd = (i+300 > (msg.length()) ? msg.length()-1 : i+300);
        }
    }    
    
    @AuraEnabled(cacheable=true)
    public static PowerBiReportData getEmbeddingDataForReport(String configName, String WorkspaceId, String ReportId, String roles) {
        system.debug('POWER BI DETAILS:'+WorkspaceId+':'+ReportId+':'+roles);
        // get access token for Authorization header
        String access_token = getPowerBiAccessToken(configName); 
        // Call to Power BI Service API to get report data for embedding        
        HttpRequest reqGetReport = new HttpRequest();
        reqGetReport.setMethod('GET');
        String urlGetReport = urlConfig.URL__c + WorkspaceId + '/reports/' + ReportId;
        system.debug('POWER BI URL:'+urlGetReport);
        reqGetReport.setEndpoint(urlGetReport);
        reqGetReport.setHeader('Authorization', 'Bearer ' + access_token);
        
        Http http = new Http();
        HttpResponse response = http.send(reqGetReport);
        
        // check response for success
        if(response.getStatusCode()!=200){
            PowerBiReportData getReportError = new PowerBiReportData();
            getReportError.error = 'Get Report Error: ' + response.getStatus();
            return getReportError;            
        }            
        system.debug('POWER BI RESULT:'+response.getStatusCode()+' '+response.getBody());
        // extract Power BI report data from JSON response
        String responseJson = response.getBody();
        PowerBiReport powerBiReport = (PowerBiReport)JSON.deserialize(responseJson, PowerBiReport.class);
        
        // Call to Power BI Service API to get embed token for report
        
        HttpRequest reqGetEmbedToken = new HttpRequest();
        reqGetEmbedToken.setMethod('POST');
        String urlGetEmbedToken = urlConfig.URL__c + WorkspaceId + '/reports/' + ReportId +'/GenerateToken';
        
        reqGetEmbedToken.setEndpoint(urlGetEmbedToken);
        
        reqGetEmbedToken.setHeader('Authorization', 'Bearer ' + access_token);
        reqGetEmbedToken.setHeader('Content-Type', 'application/json');
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        
        String strBody = '{"accessLevel": "' + urlConfig.Core_Access_Level__c + '","identities": [{"username": "' + activeUser.Email + '","roles": ["' + roles + '"],"datasets": ["' + powerBiReport.datasetId + '"]}]}';  
        //reqGetEmbedToken.setHeader('Content-Type','application/json');
        reqGetEmbedToken.setBody(strBody); 
        HttpResponse responseEmbedToken = http.send(reqGetEmbedToken);
        
        // check response for success
        if(responseEmbedToken.getStatusCode()!=200){
            PowerBiReportData getEmbedTokenError = new PowerBiReportData();
            getEmbedTokenError.error = 'Get Embed Token Error: ' + responseEmbedToken.getStatus();
            return getEmbedTokenError;            
        }            
        
        // extract Power BI embed token and expiration
        PowerBiEmbedToken embedToken = (PowerBiEmbedToken)JSON.deserialize(responseEmbedToken.getBody(), PowerBiEmbedToken.class);
        
        // create custom remote-able object to return to caller in browser 
        PowerBiReportData powerBiReportData = new PowerBiReportData();        
        powerBiReportData.workspaceId = WorkspaceId;
        powerBiReportData.reportId = ReportId;
        powerBiReportData.name = 'test';
        powerBiReportData.embedUrl = powerBiReport.embedUrl;
        powerBiReportData.embedToken = embedToken.token;
        powerBiReportData.embedTokenExpires = embedToken.expiration;
        
        return powerBiReportData;            
        
    }
    
    public class GetURLWrapperClass    { 
        @AuraEnabled
        public boolean autoSSOEnabled { get; set; }
        @AuraEnabled 
        public boolean hasAccess { get; set; } 
        @AuraEnabled
        public String reportURL { get; set; } 
    }
    
    public class ClientCredentialPostData {
        public String client_id;
        public String client_info;
        public string client_secret;
        public String scope;
        public string grant_type;
        public String getPostData(){
            return 'client_id=' + this.client_id + 
                '&client_info=' + this.client_info +
                '&client_secret=' + this.client_secret +
                '&scope=' + this.scope +
                '&grant_type=' + grant_type;
        }
    }
    public class ClientCredentialResponse {
        public String access_token;
        public String expires_in;
        public String ext_expires_in;
        public String token_type;
    }
    
    public class PowerBiReportData    {
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
    public class PowerBiReport    {
        public String id { get; set; } 
        public String reportType { get; set; } 
        public String name { get; set; } 
        public String webUrl { get; set; } 
        public String embedUrl { get; set; } 
        public boolean isFromPbix { get; set; } 
        public boolean isOwnedByMe { get; set; } 
        public String datasetId { get; set; } 
    }
    
    public class PowerBiEmbedToken    {
        public string token { get; set; } 
        public string tokenId { get; set; } 
        public DateTime expiration { get; set; } 
    }
    
    //Wrapper class to store the Filter-Value parameters
    public class FilterAndValueParams {
        public List<string> fieldsToBeQueriedL {get; set;} 
        public Map<string,string> filterToValue { get; set;}
        public Map<string,string> filterToField { get; set;} 
        public sObject sO {get; set;}
        public string delimiter{get; set;}
    }
   
}