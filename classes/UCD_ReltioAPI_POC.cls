public with sharing class UCD_ReltioAPI_POC {

    static String endPoint = 'https://apim.workato.com/cenvb9o3/search-before-request-vv0-1/sbr_wrapper';
    static String requestpayload = '{ "BusinessOrganizationName": "Spain National Intelligence Center", "CustomerAggregationTypeCd": "Unified Intermediate Customer", "WebsiteURL": "https://www.cni.es/", "Address": "", "CustomerProcessEngagement": "Direct Price Exception" }';

    static String authToken = 'Bearer b8ceae45b0bf0279493806d734e79f5a38fb3044273e13b3fa3d4496d64039bb';
    static String apiToken = 'b8ceae45b0bf0279493806d734e79f5a38fb3044273e13b3fa3d4496d64039bb';

    static String clientId = 'dec09bb9a4037a1fdf09213c1326ba020963e0f1e7e2acff1bf2cef0d126f76a';
    static String clientSecret = '56f14b4a8b4bf216fc3bf6f9fd5f0a819363756940ff3a68b15232c954d41785';

    public static void callAPI(){

        //String headerKey = '';


        String auth = getauthToken();

        accessToken restResponseJson = (accessToken) JSON.deserialize(auth, accessToken.class);

        System.debug('auth==>'+auth);

        Map < String , String > mapofHader = new Map < String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => restResponseJson.access_token,
            'API_Token' =>    apiToken   };

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndPoint(endPoint);
        
        for(String headerKey : mapofHader.keySet()){
            request.setHeader(headerKey, mapofHader.get(headerKey));
        }

        request.setBody(requestpayload);

        System.debug('request==>'+request);
        Http httpInstance = new Http();
        HttpResponse response = new HttpResponse();
        response = httpInstance.send(request);
    
        System.debug('response==>'+response.getBody());
    }


    public static String getauthToken(){
        String payloadString = 'client_id='+ clientId + '&client_secret=' + clientSecret + '&grant_type=client_credentials'   ;


            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndPoint('https://apim.workato.com/oauth2/token');
            
    
            request.setBody(payloadString);
    
            System.debug('request2==>'+request);
            Http httpInstance = new Http();
            HttpResponse response = new HttpResponse();
            response = httpInstance.send(request);
        
            System.debug('response2==>'+response);

            return response.getBody();
    }

    public class accessToken{
        public String access_token;
    }
}