public class SimpleApiClient {

    public class ApiResponse {
        public Integer statusCode;
        public String body;
        public Map<String, String> headers;
    }
    public static String getAccessToken(String clientId, String clientSecret, String tokenUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        // The request body to send in order to get the access token
        String body = 'grant_type=client_credentials' +
                      '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
                      '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        // Check if the callout was successful
        if (res.getStatusCode() == 200) {
            // Parse the response body to extract the access token
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String accessToken = (String) jsonResponse.get('access_token');
            System.debug('Access Token: ' + accessToken);
            return accessToken;
        } else {
            // If error occurs, log the response for troubleshooting
            System.debug('Error: ' + res.getBody());
            return null;
        }
    }

    // Method to send a GET request
    public static ApiResponse sendGetRequest(String url, String token) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(60000); // Optional: Set timeout for 60 seconds

        // Add the Authorization header if a token is provided
        if (String.isNotBlank(token)) {
            req.setHeader('Authorization', 'Bearer ' + token);  // For Bearer Token
        }

        req.setHeader('Content-Type', 'application/json'); // Set content type to JSON

        Http http = new Http();
        HttpResponse res;
        ApiResponse apiRes = new ApiResponse();

        try {
            res = http.send(req); // Sending the request
            apiRes.statusCode = res.getStatusCode(); // Getting status code
            apiRes.body = res.getBody(); // Getting response body
            System.debug('apiResboby:inside try ');

            // Capture headers (Optional)
            apiRes.headers = new Map<String, String>();
            for (String key : res.getHeaderKeys()) {
                apiRes.headers.put(key, res.getHeader(key));
            }
        } catch (Exception ex) {
            apiRes.statusCode = 0; // Indicating an error
            apiRes.body = 'Callout error: ' + ex.getMessage();
            System.debug('apiResboby:inside catch ');
        }
        System.debug('apiResstatusCode: ' + apiRes.statusCode);
        System.debug('apiResboby: ' + apiRes.body);
        return apiRes;
    }
}