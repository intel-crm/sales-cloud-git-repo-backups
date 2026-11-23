public class PMP_Batch_DynamicIngestVideoFlowOffering{}
/*global class PMP_Batch_DynamicIngestVideoFlowOffering implements Database.Batchable<sObject>,Database.AllowsCallouts {
    Map<String,String> videoMap = new Map<String,String>();
    global static final string CLIENTID=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientID'));
    global static final string CLIENTSECRETE=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientSecret'));
    global static String Access_Token;
    
     global Database.QueryLocator start(Database.BatchableContext bc) {
        String videoType = 'Video/mp4';
         String Success = 'Success';
         String query = 'select id,Name,PMP_Offering_Id__c,PMP_Resource_Type_Nm__c,PMP_BrightCoveVideoId__c,PMP_S3VideoURL__c from PMP_Partner_Offering_Resource__c WHERE Name !=null AND PMP_Resource_Type_Nm__c =:videoType AND PMP_BrightCoveVideoId__c != null AND PMP_VideoUploadToS3__c:=Success AND PMP_BrightCoveVideoJobId__c = null AND PMP_Brightcove_VideoPreviewURL__c = null';
         return Database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering_Resource__c> scope){
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
            for(PMP_Partner_Offering_Resource__c cResource : scope){
                 if (cResource.PMP_BrightCoveVideoId__c != null && cResource.PMP_S3VideoURL__c !=null && cResource.PMP_BrightCoveVideoJobId__c == null && cResource.PMP_VideoUploadToS3__c == 'Success'){
                    videoMap.put(cResource.id,cResource.Name+'|'+cResource.PMP_BrightCoveVideoId__c + '|'+ cResource.PMP_S3VideoURL__c);
                    PMP_BrightCoveAPIVideoCallouts.submitDynamicIngest(cResource.id,Access_Token,'Offering_Resource_Type',videoMap); 
                }
            }         
      }   
    }
    
    global void finish(Database.BatchableContext bc){
        PMP_RetryBatch_VideoCalloutsOffering batchRetry = new PMP_RetryBatch_VideoCalloutsOffering();
        Database.executeBatch(batchRetry, 1);          
    }

}*/