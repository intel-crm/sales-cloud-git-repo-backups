public class core_IPS_MySearchController_Coveo {

    class UserId{
        public String name {get; set;}
        public String provider {get; set;}
        public String type {get; set;}
        public String WWWid{get;set;}
        
        public void core_IPS_MySearchController_Coveo(){
            
        }
        public UserId(String name, String provider, String type){
            this.name = name;
            this.provider = provider;
            this.type = type;
            this.WWWid = '11962478';
        }
    }
    
    class TokenResponse {
        public String token;
    }
    
    public String getContext(){
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('https://YouRestApiUrl/rest/search/token');
        req.setEndpoint('https://platform.cloud.coveo.com/rest/search/token');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer xxddc56f94-ad0a-45bc-9f6e-f2a06f934db5');
        req.setHeader('Content-Type', 'application/json');
        
        List<UserId> userIds = new List<UserId>();
        list<User> loggedinUser = [Select id,Username,Core_WWID__c,FederationIdentifier from User where id=: UserInfo.getUserId()];
        String[] userGroup = new String[]{'11962478'};
       
        
        userIds.add(new UserId(loggedinUser[0].Username, 'Email Security Provider', 'User'));
        System.debug(JSON.serialize(userIds));
        
        Map<String,Object> body = new Map<String, Object>();
        body.put('licenseDefinitionKey', 'SFDC');
        body.put('salesforceOrganizationId', '00D3F0000000NmrUAE');
        body.put('userGroups', userGroup);
        body.put('userIds', userIds);
        body.put('usertype', 'Standard');
        
        //body.put('salesforceFallbackToAdmin', true);
        //body.put('salesforceUser', 'farooqx.ahmed@intel.com');
        System.debug(body);
        req.setBody(JSON.serialize(body));
        req.setTimeout(10000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
         Map<String,String> resBody = (Map<String,String>)JSON.deserialize(res.getBody(),Map<String,String>.class);
        
        String token = ((TokenResponse)JSON.deserialize(res.getBody(), TokenResponse.class)).token;
        
        CoveoV2.SearchContext context = new CoveoV2.SearchContext();
        context.put('token',token);
        return token;
    }
    
}