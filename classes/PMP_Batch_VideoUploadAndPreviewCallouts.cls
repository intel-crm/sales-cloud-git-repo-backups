global class PMP_Batch_VideoUploadAndPreviewCallouts implements Database.Batchable<sObject>,Database.AllowsCallouts {
  
    global static final string CLIENTID='9e49e693-d4c1-42ac-8f35-0386c86eb538';
    global static final string CLIENTSECRETE='GVHb9ZGJ8g9d_CsnzLB2MiWH7gFCfFmFx_vziHFGCeUK4IJ-DwpD3Lixuj1JGB4LaE8nRBnN0ORBXw9mFcsSBg';
    global static String Access_Token;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select id,Name,PMP_Company_Resource_Type_Nm__c,PMP_BrightCoveVideoId__c,PMP_Company_Id__c,PMP_S3VideoURL__c from PMP_Company_Resource__c WHERE PMP_S3VideoURL__c !=null AND PMP_VideoName__c !=null AND PMP_BrightCoveVideoId__c = null AND PMP_BrightCoveVideoJobId__c = null AND PMP_BrightCovePlayerId__c = null AND PMP_Brightcove_VideoPreviewURL__c = null';
        return Database.getQueryLocator(query);    
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_Company_Resource__c> scope){
         system.debug('Scope ---> '+scope);
         system.debug('scope size ---> '+scope.size());
        if(scope !=null){
             
        //1. Getting the access token
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
        system.debug('body:'+response.getBody());
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
            parser.nextToken();
            Access_Token = parser.getText();
            system.debug('access token--->'+Access_Token);
            }
        }
            for(PMP_Company_Resource__c cResource : scope){
                 PMP_APICalloutS3Brightcove.CreateVideoResponse(cResource.id,cResource.PMP_Company_Id__c,cResource.PMP_S3VideoURL__c,Access_Token,'Partner_Resource_Type'); 
            }         
      }   
   }
    
    global void finish(Database.BatchableContext bc){
        PMP_RetryBatch_VideoCallouts batchRetry = new PMP_RetryBatch_VideoCallouts();
        Database.executeBatch(batchRetry, 1);          
    }

}