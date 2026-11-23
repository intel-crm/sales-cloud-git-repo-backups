public class Jira_Client {
    private static final String JIRA_INSTANCE_URL = 'https://jira.devtools.intel.com';
    private static final String API_PATH = '/rest/api/latest/issue/';
    private static final String BEARER_TOKEN = 'NTI0NjE2ODEwNjQyOvL8mX6LGNKvlnUmV5QpoR/nnEGs';
	
     @InvocableMethod(label='Get Jira Issue' description='Returns the list of account names corresponding to the specified account IDs.' category='Jira')
    public static void getIssueDetails(List<String> issueKey) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(JIRA_INSTANCE_URL + API_PATH + issueKey[0]);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + BEARER_TOKEN);
        req.setHeader('Host', 'jira.devtools.intel.com');
        req.setHeader('Content-Type', 'application/json');
		req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            // Parse the JSON response
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('Issue details: ' + results);
        } else {
            System.debug('Issue details: ' + res.getStatus());
        }
    }
}