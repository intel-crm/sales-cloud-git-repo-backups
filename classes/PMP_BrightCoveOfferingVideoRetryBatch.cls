/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveOfferingVideoRetryBatch 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022                 This batch class is used to perform retry mechanism for brightcove video
                                                               integration and batch size should be always 1
*****************************************************************************************************************************************/
//IPA2.0 - As part of TWC729-7977 commented the entire class & added dummy syntax to override error
global with sharing class PMP_BrightCoveOfferingVideoRetryBatch{
	public static Boolean isWorking() {
        return true;
    }
	
 /*implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    /*
    Map<String,String> videoMap = new Map<String,String>();
    global static final string CLIENTID=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientID'));
    global static final string CLIENTSECRETE=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientSecret'));
    global static String Access_Token;
    global String resourceID;
    
    global PMP_BrightCoveOfferingVideoRetryBatch(String resourceID)
    {
        this.resourceID=resourceID;
        //System.debug('resourceID'+resourceID);
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String videoType = 'Video';
        String blank='';
        String query;
        if(resourceID!=null)
        {
            query = 'Select id,Name,PMP_Offering_Id__c,PMP_BrightCoveVideoId__c,PMP_BrightCoveVideoJobId__c,PMP_Resource_Type_Nm__c,PMP_Integration_Status_Nm__c,PMP_Partner_Offering_Image__c,PMP_Delete_BrightCove_Video_Ind__c,PMP_Resource_Description_Txt__c,PMP_BrightCoveVideoThumbnail_URL__c,PMP_BrightCove_Video_Extension_Txt__c,PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Integration_Status_Reason_Txt__c from PMP_Partner_Offering_Resource__c' +
                    ' WHERE PMP_BrightCoveVideoAccountID__c!=null AND PMP_Resource_Type_Nm__c=:videoType AND (PMP_Integration_Status_Nm__c =\'Aborted\' OR PMP_Integration_Status_Reason_Txt__c!=:blank)' +
                    ' AND PMP_BrightCove_Video_Extension_Txt__c!=null AND id=:resourceID';
        }
        else
        {
            query = 'Select id,Name,PMP_Offering_Id__c,PMP_BrightCoveVideoId__c,PMP_BrightCoveVideoJobId__c,PMP_Resource_Type_Nm__c,PMP_Integration_Status_Nm__c,PMP_Partner_Offering_Image__c,PMP_Delete_BrightCove_Video_Ind__c,PMP_Resource_Description_Txt__c,PMP_BrightCoveVideoThumbnail_URL__c,PMP_BrightCove_Video_Extension_Txt__c,PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Integration_Status_Reason_Txt__c from PMP_Partner_Offering_Resource__c' +
                    ' WHERE PMP_BrightCoveVideoAccountID__c!=null AND PMP_BrightCove_Video_Extension_Txt__c!=null AND PMP_Resource_Type_Nm__c=:videoType AND (PMP_Integration_Status_Nm__c =\'Aborted\' OR PMP_Integration_Status_Reason_Txt__c!=:blank)';
        }    
        return Database.getQueryLocator(query);    
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering_Resource__c> scope){
        if(scope !=null && scope.size()==1){
             
        //Getting the access token
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
        request.setTimeout(120000);
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
                // if video id is null
                if(cResource.PMP_BrightCoveVideoId__c == null && (!cResource.PMP_Integration_Status_Nm__c.contains('Success'))){
                   PMP_BrightCoveVideoUploadUtility.createVideoResponse(cResource.id,cResource.PMP_Offering_Id__c,cResource.id + '_' + cResource.PMP_Offering_Id__c + cResource.PMP_BrightCove_Video_Extension_Txt__c,Access_Token,cResource.PMP_Partner_Offering_Image__c,'Offering_Resource_Type',cResource.PMP_Resource_Description_Txt__c,cResource.Name);  
                }
                // if video id is not null,video job id is not null but thumbnail url is null
                else if (cResource.PMP_BrightCoveVideoId__c != null && cResource.PMP_BrightCoveVideoJobId__c != null && cResource.PMP_BrightCoveVideoThumbnail_URL__c ==null && (!cResource.PMP_Integration_Status_Nm__c.contains('Success'))){
                    PMP_BrightCoveOfferingVideoStatusUtility.checkVideoJobIdStatus(cResource.id,cResource.PMP_Offering_Id__c,cResource.id + '_' + cResource.PMP_Offering_Id__c + cResource.PMP_BrightCove_Video_Extension_Txt__c,cResource.PMP_BrightCoveVideoId__c,cResource.PMP_BrightCoveVideoJobId__c,Access_Token,'Offering_Resource_Type');
                }
                // if PMP_Delete_BrightCove_Video_Ind__c flag is true
                else if (cResource.PMP_BrightCoveVideoId__c != null && cResource.PMP_BrightCoveVideoJobId__c != null && cResource.PMP_BrightCoveVideoThumbnail_URL__c !=null && cResource.PMP_Delete_BrightCove_Video_Ind__c==true && (!cResource.PMP_Integration_Status_Nm__c.contains('Success'))
                         && cResource.PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c=='Approved'
                         && cResource.PMP_Integration_Status_Reason_Txt__c==system.label.PMP_Integration_Delete_Video_Msg)
                {
                    PMP_BrightCoveOfferingVideoStatusUtility.deleteBrightCoveVideo(cResource.id,cResource.PMP_Offering_Id__c,cResource.id + '_' + cResource.PMP_Offering_Id__c + cResource.PMP_BrightCove_Video_Extension_Txt__c,cResource.PMP_BrightCoveVideoId__c,Access_Token,'Offering_Resource_Type'); 
                }  
            }         
      }   
 }
    
     global void finish(Database.BatchableContext bc){
         if(!Test.isRunningTest()){
           // call the PMP_BrightCoveOfferingVideoStatusBatch batch class to generate thumbnail urls
           Database.executeBatch(new PMP_BrightCoveOfferingVideoStatusBatch(), 1);  
         }
    }
*/
}