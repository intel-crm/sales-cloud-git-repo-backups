global class powerBiReportEmbedEali {

    @AuraEnabled(cacheable=true)
    public static Map<boolean,string> getURL(string configName, string recordId) {
        Map<boolean,string> result=new Map<boolean,string>();
        Map<string,string> filterToField = new Map<string,string>();
        Map<string,string> filterToValue = new Map<string,string>();
        List<string> fieldsToBeQueriedL = new List<string>();
        string filterConditions = '';
        boolean hasAccess = true;
        string url = '';
        
        //Testing - Should not be migrated
        configName= 'RLS_Test';
        
        try {
            //Query to get the URL Configs
            Custom_URL_Embed__mdt urlConfig = [select id,URL__c, Dynamic_filter__c, Dynamic_Filter_and_Value_txt__c, Object__c,
                                                      Static_filter__c,Static_Filter_and_Value_txt__c , 
                                                      Security_enforced__c,Security_Query_txt__c, No_Access_Error_txt__c,
                                                      User_Info__c, User_Filter_and_Value_txt__c,Core_Add_User_SessionID__c,Core_Session_Parameter__c,DeveloperName
                                                      from Custom_URL_Embed__mdt where DeveloperName = :configName];
            
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
            if(urlConfig.DeveloperName == 'Account_AI_Insights') {
            String req_id = (Math.random()+' ').substring(2,10)+(Math.random()+' ').substring(2,10);
                if(url.contains('&')){
		            url += '&req_id='+req_id;
                }else{
					url+= 'req_id='+req_id;	                    
                }
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
            result.put(hasAccess,url);
            system.debug('result: '+result);
        }
        catch(exception ex) {
            hasAccess = false;
            string error = 'Error :'+ ex.getMessage();
            result.put(hasAccess,error);
            system.debug('result2: '+result);
        }
        
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
            
            system.debug('sO: '+sO);
            fP.sO = sO;
            fP.delimiter = 'and';
            //url += '&filter=';
            url+=buildFilter(fP);
            system.debug('url: '+url);  
        }
        catch(exception ex) {
            system.debug('error: '+ ex.getLineNumber() + ex.getMessage());
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
            system.debug('error: '+ ex.getLineNumber() + ex.getMessage()); 
        }
        return url; 
    }
    
    //User Info logic
    public static string getUserInfo(Custom_URL_Embed__mdt config){
        string urlAddn;    
        string filterConditions = '';
        
        try{
            FilterAndValueParams fP = splitTheFilters(config.User_Filter_and_Value_txt__c);
            system.debug('fieldsToBeQueried: '+fP.fieldsToBeQueriedL);
            string fieldsToBeQueried = String.join(new List <String> (fP.fieldsToBeQueriedL), ',');
            string userId = UserInfo.getUserId();
            string dynamicQuery = 'Select '+ String.escapeSingleQuotes(fieldsToBeQueried) + ' from User where id=:userId';
            User userRec=Database.query(dynamicQuery);
            
            system.debug('userRec: '+userRec);
            
            urlAddn = '&';
            fP.sO = userRec;
            fP.delimiter='&';
            
            urlAddn+=buildFilter(fP);
            system.debug('url: '+urlAddn);
            
        }
        
        catch(exception ex) {
            system.debug('error: '+ ex.getLineNumber() + ex.getMessage());
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
            system.debug('hasAccess: '+ hasAccess);
        }
        catch(exception ex) {
            system.debug('error: '+ ex.getLineNumber() + ex.getMessage());
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
            
            system.debug('fP: '+fP);
        }
        
        catch(exception ex) {
            system.debug('error: '+ ex.getLineNumber() + ex.getMessage());
        }
        return fP;
    }
    
    //Build the filter-value pair based on the query
    public static string buildFilter(FilterAndValueParams fP){
        string filterConditions = '';
        try {
            for(string fV: fP.filterToField.keyset()) {
                string value = fP.filterToValue.get(fV).replace(fP.filterToField.get(fV),String.valueOf(fP.sO.get(fP.filterToField.get(fV))));
                system.debug('value'+value);
                filterConditions += fV + value;
                if(fP.filterToField.size()>1) {
                    filterConditions += fP.delimiter; 
                }
            }
            filterConditions = filterConditions.removeend(fP.delimiter);
            system.debug('filterConditions: '+filterConditions);   
        }
        catch(exception ex) {
            system.debug('error: '+ ex.getLineNumber() + ex.getMessage());   
        }
        return filterConditions;
    }
    
    //Wrapper class to store the Filter-Value parameters
    public class FilterAndValueParams {
        public List<string> fieldsToBeQueriedL {get; set;} 
        public Map<string,string> filterToValue { get; set;}
        public Map<string,string> filterToField { get; set;} 
        public sObject sO {get; set;}
        public string delimiter{get; set;}
    }
    
    public static String getPowerBiAccessToken() {
        
        // get auth settings from Custom Metadata Type reconrd
        /*Power_BI_Auth_Setting__mdt authSetting = Power_BI_Auth_Setting__mdt.getInstance('Power_Bi_App_Creds');*/
        string TenantId = '46c98d88-e344-4ed4-8496-4ed7712e255d';// authSetting.TenantId__c;    
       // &ctid=46c98d88-e344-4ed4-8496-4ed7712e255d
        string ClientId ='b2dbf413-0e2b-483d-ba84-7a2dde7ba9d0';// authSetting.ClientId__c;    
        string ClientSecret ='Mxf8Q~nVnAdbySZ4IpKsB8~lFx4o4txP6RSF2aKK';// authSetting.ClientSecret__c;        
        
        // construct URL for client credentials flow
        String aadTokenEndpoint = 'https://login.microsoftonline.com/' + TenantId + '/oauth2/v2.0/token';
        
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
        postData.scope = 'https://analysis.windows.net/powerbi/api/.default';
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
        system.debug('access_token: '+access_token);
        return access_token;
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
    
    @remoteaction
    global static PowerBiReportData getEmbeddingDataForReport1() {
        System.debug('m here!!');
        return powerBiReportEmbedEali.getEmbeddingDataForReport('1f0210e2-2cb4-432a-99c0-28d3f4d5e58a','a9c961d0-738f-4e13-b8fa-f8997472ecd7');
       
    }
    
    public static PowerBiReportData getEmbeddingDataForReport(String WorkspaceId, String ReportId) {
        
        // get access token for Authorization header
        String access_token = getPowerBiAccessToken();        
        
        // Call to Power BI Service API to get report data for embedding        
        HttpRequest reqGetReport = new HttpRequest();
        reqGetReport.setMethod('GET');
        String urlGetReport = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId;
        //String urlGetReport = 'https://api.powerbi.com/groups/' + WorkspaceId + '/reports/' + ReportId;
        //String urlGetReport = 'https://app.powerbi.com/reportEmbed?reportId=a9c961d0-738f-4e13-b8fa-f8997472ecd7';
        reqGetReport.setEndpoint(urlGetReport);
        reqGetReport.setHeader('Authorization', 'Bearer ' + access_token);
        
        Http http = new Http();    
        //system.debug('reqGetReport: '+reqGetReport.getHeader(key));
        HttpResponse response = http.send(reqGetReport);
        
        // check response for success
        if(response.getStatusCode()!=200){
            System.debug('ERROR --- Getting Report Data --- ERROR');
            System.debug('Status Code: ' + response.getStatusCode());
            System.debug('Status Code: ' + response.getBody());
            PowerBiReportData getReportError = new PowerBiReportData();
            getReportError.error = 'Get Report Error: ' + response.getStatus();
            return getReportError;            
        }            
        
        // extract Power BI report data from JSON response
        String responseJson = response.getBody();
        PowerBiReport powerBiReport = (PowerBiReport)JSON.deserialize(responseJson, PowerBiReport.class);
        
        // send report info to debug window
        System.debug('id: ' + powerBiReport.id);        
        System.debug('reportType: ' + powerBiReport.reportType);        
        System.debug('name: ' + powerBiReport.name);  
        System.debug('webUrl: ' + powerBiReport.webUrl);      
        System.debug('embedUrl: ' + powerBiReport.embedUrl);        
        System.debug('isFromPbix: ' + powerBiReport.isFromPbix);        
        System.debug('isOwnedByMe: ' + powerBiReport.isOwnedByMe);        
        System.debug('datasetId: ' + powerBiReport.datasetId);        
        
        // Call to Power BI Service API to get embed token for report        
        HttpRequest reqGetEmbedToken = new HttpRequest();
        reqGetEmbedToken.setMethod('POST');
        String urlGetEmbedToken = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId + '/GenerateToken';
        
        //credential = new ClientCredential(Secrets.ClientID, Secrets.ClientSecret);
        
        //var rls = new EffectiveIdentity(username: "<ENTER USERNAME>", new List<string> { datasetId.ToString() });
        
		//String urlGetEmbedToken = 'https://app.powerbi.com/groups/1f0210e2-2cb4-432a-99c0-28d3f4d5e58a/reports/a9c961d0-738f-4e13-b8fa-f8997472ecd7' +   '/GenerateToken';     
    	reqGetEmbedToken.setEndpoint(urlGetEmbedToken);
        reqGetEmbedToken.setHeader('Authorization', 'Bearer ' + access_token);
        String strBody = '{"accessLevel": "View","identities": [{"username": "lakshman.k.bachu@intel.com","roles": ["read"],"datasets": ["'+ powerBiReport.datasetId +'"]}]}';
        //String strBody = '{"accessLevel": "View","identities": [{"username": "Account Cisco"}]}';
		System.debug(strBody);   
        reqGetEmbedToken.setHeader('Content-Type','application/json');
		reqGetEmbedToken.setBody(strBody);
        System.debug('datasetId: ' + powerBiReport.datasetId);  
        HttpResponse responseEmbedToken = http.send(reqGetEmbedToken);
        
        // check response for success
        if(responseEmbedToken.getStatusCode()!=200){
            System.debug('ERROR --- Getting Embed Token --- ERROR');
            System.debug('Status Code: ' + responseEmbedToken.getStatusCode() + responseEmbedToken.getBody());            
            PowerBiReportData getEmbedTokenError = new PowerBiReportData();
            getEmbedTokenError.error = 'Get Embed Token Error: ' + response.getStatus();
            return getEmbedTokenError;            
        }            
        
        // extract Power BI embed token and expiration
        PowerBiEmbedToken embedToken = (PowerBiEmbedToken)JSON.deserialize(responseEmbedToken.getBody(), PowerBiEmbedToken.class);
        
        // send report info to debug window
        System.debug('EmbedToken: ' + embedToken.token);        
        System.debug('EmbedToken ID: ' + embedToken.tokenId);        
        System.debug('expiration: ' + embedToken.expiration);
        
        // create custom remote-able object to return to caller in browser 
        PowerBiReportData powerBiReportData = new PowerBiReportData();        
        powerBiReportData.workspaceId = WorkspaceId;
        powerBiReportData.reportId = ReportId;
        powerBiReportData.name = powerBiReport.name;
        powerBiReportData.embedUrl = powerBiReport.embedUrl;
        powerBiReportData.embedToken = embedToken.token;
        powerBiReportData.embedTokenExpires = embedToken.expiration;
        
        system.debug('powerBiReportData: '+powerBiReportData.embedUrl);
        
        return powerBiReportData;            
        
    }
    global class PowerBiReportData    {
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
}