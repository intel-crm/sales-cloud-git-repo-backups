public class PMP_RetryBatch_VideoCalloutsOffering{} /*global class PMP_RetryBatch_VideoCalloutsOffering implements Database.Batchable<sObject>,Database.AllowsCallouts{
    Map<String,String> videoMap = new Map<String,String>();
    global static final string CLIENTID=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientID'));
    global static final string CLIENTSECRETE=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientSecret'));
    global static String Access_Token;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String Failed = '%Failed%';
        String videoType = 'Video/mp4';
        String query = 'select id,Name,PMP_Offering_Id__c,PMP_BrightCoveVideoId__c,PMP_BrightCovePlayerId__c,PMP_Brightcove_VideoPreviewURL__c,PMP_BrightCoveVideoJobId__c,PMP_Resource_Type_Nm__c,PMP_S3VideoURL__c,PMP_CalloutPayloadMessage__c,PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c WHERE PMP_Resource_Type_Nm__c=:videoType AND PMP_CalloutPayloadMessage__c like:Failed';
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
                if(cResource.PMP_BrightCoveVideoId__c == null && (!cResource.PMP_CalloutPayloadMessage__c.contains('Success'))){
                   PMP_BrightCoveAPIFirstVideoCallouts.createVideoResponse(cResource.id,cResource.PMP_Offering_Id__c,cResource.Name,Access_Token,cResource.PMP_Partner_Offering_Image__c,'Offering_Resource_Type');  
                }
                else if(cResource.PMP_BrightCoveVideoId__c != null && cResource.PMP_S3VideoURL__c ==null && (!cResource.PMP_CalloutPayloadMessage__c.contains('Success'))){
                     videoMap.put(cResource.id,cResource.Name+'|'+cResource.PMP_BrightCoveVideoId__c);
                     PMP_BrightCoveAPIFirstVideoCallouts.getS3UploadURLs(cResource.PMP_Offering_Id__c,Access_Token,'Offering_Resource_Type',cResource.PMP_Partner_Offering_Image__c,videoMap);
                }
                else if (cResource.PMP_BrightCoveVideoId__c != null && cResource.PMP_S3VideoURL__c !=null && cResource.PMP_BrightCoveVideoJobId__c == null && (!cResource.PMP_CalloutPayloadMessage__c.contains('Success'))){
                    videoMap.put(cResource.id,cResource.Name+'|'+cResource.PMP_BrightCoveVideoId__c + '|'+ cResource.PMP_S3VideoURL__c);
                    //PMP_BrightCoveAPIFirstVideoCallouts.sendS3InfoToMulesoft(cResource.PMP_Offering_Id__c,Access_Token,'Offering_Resource_Type',videoMap);
                }
               
                 else if (cResource.PMP_BrightCoveVideoId__c != null && cResource.PMP_S3VideoURL__c !=null && cResource.PMP_BrightCoveVideoJobId__c != null && cResource.PMP_BrightCoveVideoThumbnail_URL__c ==null && (!cResource.PMP_CalloutPayloadMessage__c.contains('Success'))){
                    videoMap.put(cResource.id,cResource.Name+'|'+cResource.PMP_BrightCoveVideoId__c+'|'+cResource.PMP_S3VideoURL__c+'|'+cResource.PMP_BrightCoveVideoJobId__c);
                    PMP_BrightCoveAPISecondVideoCallouts.getVideoThumnailURL(cResource.PMP_Offering_Id__c,Access_Token,'Offering_Resource_Type',videoMap);
                }  
            }         
      }   
 }
    
     global void finish(Database.BatchableContext bc){
           PMP_SecondBatch_BrightCoveVideoOffering batchRetry = new PMP_SecondBatch_BrightCoveVideoOffering();
           Database.executeBatch(batchRetry, 1);  
    }

}*/