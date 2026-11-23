/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveOfferingVideoUploadBatch 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022                 This batch class is used to upload videos in brightcove and perform 2 callouts
                                                               (Access Token Generation,Create Video Response) and batch size should be always 1
*****************************************************************************************************************************************/
// IPA2.0 - As part of TWC729-7977 commented the entire class & added dummy syntax to override error
global with sharing class PMP_BrightCoveOfferingVideoUploadBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // added dummy syntax to override error
       return null;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        // added dummy syntax to override error
    }

    global void finish(Database.BatchableContext bc) {
        // added dummy syntax to override error
    }
/*
    global static final string CLIENTID=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientID'));
    global static final string CLIENTSECRETE=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientSecret')); 
    global static String Access_Token;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String videoType = 'Video';
        String query =   'Select id,Name,PMP_Offering_Id__c,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c,PMP_BrightCove_Video_Extension_Txt__c from PMP_Partner_Offering_Resource__c WHERE PMP_Resource_Type_Nm__c =:videoType' +
            ' AND PMP_BrightCoveVideoAccountID__c!=null AND PMP_BrightCoveVideoId__c=null AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'Admin Review\' AND PMP_Partner_Offering_Image__c!=null AND PMP_Delete_BrightCove_Video_Ind__c=false AND PMP_BrightCove_Video_Extension_Txt__c!=null';
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering_Resource__c> scope){
        if(scope !=null && scope.size()==1){
            
            //1. Getting the access token
            Blob headerValue = Blob.valueOf(CLIENTID + ':' + CLIENTSECRETE);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //system.debug('Encoder Value' + EncodingUtil.base64Encode(headerValue));
            http http = new http();
            httpRequest request = new httpRequest();
            request.setMethod('POST');
            request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Access_Token_Endpoint_URL'))); //Remote site settings
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader(PMP_StaticConstants_Offering.Authorization, authorizationHeader);
            request.setBody('grant_type=client_credentials');
            httpResponse response = http.send(request);
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    Access_Token = parser.getText();
                    //system.debug('access token--->'+Access_Token);
                }
            }
            for(PMP_Partner_Offering_Resource__c cResource : scope){
                // call PMP_BrightCoveVideoUploadUtility apex class to create the video in brightcove
                PMP_BrightCoveVideoUploadUtility.createVideoResponse(cResource.id,cResource.PMP_Offering_Id__c,cResource.id + '_' + cResource.PMP_Offering_Id__c + cResource.PMP_BrightCove_Video_Extension_Txt__c,Access_Token,cResource.PMP_Partner_Offering_Image__c,'Offering_Resource_Type',cResource.PMP_Resource_Description_Txt__c,cResource.Name); 
            }       
        }   
    }
    
    global void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest()){
            // call the PMP_BrightCoveOfferingVideoRetryBatch batch class to perform retry mechanism for video integration
            Database.executeBatch(new PMP_BrightCoveOfferingVideoRetryBatch(null), 1);
        }
    }   
*/
}