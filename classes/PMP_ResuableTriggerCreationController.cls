public class PMP_ResuableTriggerCreationController {
    final String endpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v56.0/tooling/sobjects';
    
    // used receive response by sending a http request
    private String getResponse(HttpRequest req)
    {
        try
        {
            Http httpreq = new Http();
            HttpResponse res = httpreq.send(req);
            String reqresponse = res.getBody();
            return reqresponse;
        }
        catch (Exception e)
        {
            return 'Error:' +e.getMessage();
        }
    }
    
    // create a http request with required endpoint and request method
    private HttpRequest createHttpRequest(String endpoint, String method)
    {
        HttpRequest req = new HttpRequest();
        endpoint += '';
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        return req;
    }
    
     // create a new Apex Trigger
    public void createApexTrigger()
    {
        // create a Http request with post method
        HttpRequest req = createHttpRequest(endpoint+'/ApexTrigger','POST');
        String body ='{"Name":"OFFTR3","TableEnumOrId":"PMP_Partner_Offering__c","Body":"trigger OFFTR3 on PMP_Partner_Offering__c (before insert) {}"}';
        req.setBody(body);
        // send request and receive response
        String response = getResponse(req);
    }
    
    // create a new Apex Class
    public void createApexClass()
    {
        // create a Http request with post method
        HttpRequest req = createHttpRequest(endpoint+'/ApexClass','POST');
        req.setBody( '{"Name":"NewApexClass1","Body":"public class NewApexClass1 {}"}');
        // send request and receive response
        String response = getResponse(req);
    }
    
    // create new Custom MetaData
    public void createCustomMetaData()
    {
        // create a Http request with post method
        HttpRequest req = createHttpRequest(endpoint+'/ApexClass','POST');
        req.setBody( '{"Name":"NewApexClass1","Body":"public class NewApexClass1 {}"}');
        // send request and receive response
        String response = getResponse(req);
    }
}