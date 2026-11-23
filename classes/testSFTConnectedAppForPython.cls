public class testSFTConnectedAppForPython {
	public static String getAccessToken() {
        // Define the endpoint and parameters
        String tokenEndpoint = 'https://test.salesforce.com/services/oauth2/token';
        String clientId = '3MVG9ysJNY7CaIHnXtkJBm9UdfINPMY9eEn7nzf09Toxfi7uhu0kDiMA4O2vUAzLs99_ovOmkF3ALp7981gJW';
        String clientSecret = '161B4962732C0876C6CC9BF06477C3AC282A98DE0BEF37C051A995534544C792';
        String username = '12002644@intel.com.crm.crmdevint3';
        String password = 'Amey009@';

        // Prepare HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        // Set body parameters
        String body = 'grant_type=password' +
                      '&client_id=' + clientId +
                      '&client_secret=' + clientSecret +
                      '&username=' + username +
                      '&password=' + password;
        req.setBody(body);

        // Send HTTP request and get the response
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Parse the JSON response to get the access token
        if (res.getStatusCode() == 200) {
            Map<String, Object> authResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) authResponse.get('access_token');
        } else {
            throw new CalloutException('Error obtaining access token: ' + res.getBody());
        }
    }
    public void queryAccounts() {
        String accessToken = getAccessToken();
        String instanceUrl = 'https://intel--crmdevint3.sandbox.my.salesforce.com'; // e.g., https://yourInstance.salesforce.com

        // Define the query
        String query = 'SELECT Id FROM PartnerFundClaim LIMIT 10';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        String queryEndpoint = instanceUrl + '/services/data/v52.0/query?q=' + encodedQuery;

        // Prepare HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(queryEndpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        // Send HTTP request and get the response
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Handle the response
        if (res.getStatusCode() == 200) {
            System.debug('Query response: ' + res.getBody());
        } else {
            System.debug('Error querying data: ' + res.getBody());
        }
    }
}