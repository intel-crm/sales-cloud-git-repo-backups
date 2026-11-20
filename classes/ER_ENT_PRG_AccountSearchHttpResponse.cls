@isTest
public class ER_ENT_PRG_AccountSearchHttpResponse {
 // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String str='{               "SearchAccount": {                              "AccountName": "Apple UK",                              "AccountAddress": {                                             "CountryCode2": "USA"                              },                              "EmailAddress": alleniheavshadvbha@lenovo.com,                              "SearchLimit": "10",                              "MinimumSearchScore": "10",                              "EntitlementName": "Resource & Design Center for Secure Content"               }}';
            res.setBody(str);
            res.setStatuscode(200);           
        return res; 
    }
}