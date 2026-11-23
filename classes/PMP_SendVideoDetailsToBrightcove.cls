public class PMP_SendVideoDetailsToBrightcove {
   /* public static HTTPResponse makeCalloutToBrightCove(String contentURL){
        // create http request instance
        HttpRequest request = new HttpRequest();
        String endPointURL = '';   	
        request.setEndpoint('');
    	request.setMethod('POST'); // set the http method as 'POST'
        request.setBody('{"File Name":"King"}');
        Http h = new Http();//http instance variable to make http callout

        HTTPResponse response = new  HTTPResponse(); // variable to store http response

        system.debug('###request:->'+request);

        // sending the request using http instance
        response = h.send(request);
    	system.debug('response::'+response);
        return response;
    }*/
    
    public static String getToken(){
        HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setEndpoint('https://oauth.brightcove.com/v4/access_token');
            String CLIENT_ID = '9e49e693-d4c1-42ac-8f35-0386c86eb538';
            String CLIENT_SECRET = 'GVHb9ZGJ8g9d_CsnzLB2MiWH7gFCfFmFx_vziHFGCeUK4IJ-DwpD3Lixuj1JGB4LaE8nRBnN0ORBXw9mFcsSBg';
            req.setBody('grant_type=client_credentials' + '&client_id='+CLIENT_ID + '&client_secret='+CLIENT_SECRET + '&scope=USER');
            Http http = new Http();
            HTTPResponse response = http.send(req);
            System.debug('Body ' + response.getBody());
            System.debug('Status ' + response.getStatus());
            System.debug('Status code ' + response.getStatusCode());
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        String token = '';
        //String refreshtoken = '';
        //if(response.getStatusCode() == 200){
         token = (String)results.get('access_token');
            system.debug('*****token from class******'+token);
         //refreshtoken = (String)results.get('refresh_token');
            return token;
        //}
        //else{throw new CalloutException('FAILED TO GET TOKEN');}
    }
}