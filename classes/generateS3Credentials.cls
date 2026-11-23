public class generateS3Credentials 
{
    public static final string CLIENTID=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientID'));
    public static final string CLIENTSECRETE=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientSecret'));
    public static String Access_Token;
    
      public static void getS3UploadURLs(){
                  Blob headerValue = Blob.valueOf(CLIENTID + ':' + CLIENTSECRETE);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            system.debug('Encoder Value' + EncodingUtil.base64Encode(headerValue));
            http http = new http();
            httpRequest request = new httpRequest();
            request.setMethod('POST');
            request.setEndpoint('https://oauth.brightcove.com/v4/access_token'); //Remote site settings
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody('grant_type=client_credentials');
            httpResponse response = http.send(request);
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    Access_Token = parser.getText();
                    system.debug('access token--->'+Access_Token);
                }
            }
            
            HttpRequest request1 = new HttpRequest();
            request1.setEndpoint('https://ingest.api.brightcove.com/v1/accounts/6298977448001/videos/6303060396001/upload-urls/Sample_Video_Upload.mp4');
            request1.setHeader('Content-Type','application/json');
            request1.setHeader('Authorization','Bearer '+Access_Token); 
            request1.setMethod('GET');
            HTTPResponse response1 = new HTTPResponse();
                response1 = http.send(request1);
                System.debug('responsestatus--->'+response.getStatusCode());
                System.debug('responsebody--->'+response.getBody());
                // If the request is successful, parse the JSON response.
                if(response1.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response1.getBody());
                    String objApiName;
                    system.debug('bucket:  '+results.get('bucket'));
                    system.debug('object_key: '+results.get('object_key'));
                    system.debug('access_key_id: '+results.get('access_key_id'));
                    system.debug('secret_access_key: '+results.get('secret_access_key'));
                    system.debug('session_token: '+results.get('session_token'));
                    system.debug('signed_url: '+results.get('signed_url')); 
                    system.debug('api_request_url: '+results.get('api_request_url'));
              } 
              
        }
        
  }