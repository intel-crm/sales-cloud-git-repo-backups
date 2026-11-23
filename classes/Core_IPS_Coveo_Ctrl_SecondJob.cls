public without sharing class Core_IPS_Coveo_Ctrl_SecondJob implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context){
        
        // List<String> userGroups  = getUserRole();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://platform.cloud.coveo.com/rest/search/v2/token?organizationId=intelcorporationnonproduction2ybdyblf7');
        req.setMethod('POST');
        String body = '{"pipeline":"IPSSBS","searchHub":"IPSSBS","validFor":3600000,"userGroups":["rdc","U:11735124","U:DerivedGroup:AllBlueBadge","U:DerivedGroup:AllEmployees","U:Public"],"userIds":[{"provider":"Email Security Provider","name":"anonymous","intel":{}}]}';
        // String body = '{"pipeline":"IPSSBS","searchHub":"IPSSBS","validFor":3600000,"userGroups":'+customList+',"userIds":[{"provider":"Email Security Provider","name":"anonymous","intel":{}}]}';
        req.setBody(body);
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        String authorizationHeader = 'Bearer xxd645a3c4-d795-40ee-b989-90b6a5a3a515';
        req.setHeader('Authorization', authorizationHeader);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        String resBody = res.getBody();
        Token accessToken = (Token) System.JSON.deserialize(resBody, Token.Class);
        System.debug(accessToken.token);
        // return accessToken.token;
        
        
    }
    public class Token{
        public String token;
    }
    
    
}