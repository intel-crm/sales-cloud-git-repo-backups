/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveOfferingVideoStatusBatch 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022                 This batch class is used to generate thumbnail URLS from brightcove and perform 4 callouts
                                                               (Access Token Generation,Check Video Status,Generate Thumbnail URLS and Delete Video from brightcove)
                                                               and batch size should be always 1
*****************************************************************************************************************************************/
@isTest
global with sharing class PMP_BrightCoveOfferingVideoStatusBatch{ /* implements Database.Batchable<sObject>,Database.AllowsCallouts{
    // global static final string CLIENTID=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientID'));
    // global static final string CLIENTSECRETE=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientSecret'));
    // global static String Access_Token;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // String videoType = 'Video';
        // String query =   'Select id,Name,PMP_Offering_Id__c,PMP_Resource_Type_Nm__c,PMP_BrightCoveVideoId__c,PMP_BrightCoveVideoJobId__c,PMP_Delete_BrightCove_Video_Ind__c,PMP_Partner_Offering_Image__c,PMP_BrightCove_Video_Extension_Txt__c,PMP_BrightCoveVideoThumbnail_URL__c,PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Integration_Status_Reason_Txt__c from PMP_Partner_Offering_Resource__c' +
        //                  ' WHERE PMP_BrightCoveVideoAccountID__c!=null AND PMP_Resource_Type_Nm__c =:videoType AND PMP_BrightCoveVideoId__c != null' +
        //                  ' AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c!=\'Published\' AND PMP_Partner_Offering_Image__c!=null' +
        //                  ' AND (PMP_BrightCoveVideoJobId__c != null OR PMP_Delete_BrightCove_Video_Ind__c=true)';
        String query=null;
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering_Resource__c> scope){
        // if(scope !=null && scope.size()==1){
            
        //     //4. Getting the access token
        //     Blob headerValue = Blob.valueOf(CLIENTID + ':' + CLIENTSECRETE);
        //     String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        //     //system.debug('Encoder Value' + EncodingUtil.base64Encode(headerValue));
        //     http http = new http();
        //     httpRequest request = new httpRequest();
        //     request.setMethod('POST');
        //     request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Access_Token_Endpoint_URL'))); //Remote site settings
        //     request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //     request.setHeader(PMP_StaticConstants_Offering.Authorization, authorizationHeader);
        //     request.setBody('grant_type=client_credentials');
        //     request.setTimeout(120000);
        //     httpResponse response = http.send(request);
        //     JSONParser parser = JSON.createParser(response.getBody());
        //     while (parser.nextToken() != null) {
        //         if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
        //             parser.nextToken();
        //             Access_Token = parser.getText();
        //             //system.debug('access token--->'+Access_Token);
        //         }
        //     }
        //     for(PMP_Partner_Offering_Resource__c cResource : scope){
        //         if(cResource.PMP_Delete_BrightCove_Video_Ind__c && cResource.PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c=='Approved'
        //            && cResource.PMP_Integration_Status_Reason_Txt__c==system.label.PMP_Integration_Delete_Video_Msg)
        //         {
        //             // call deleteBrightCoveVideo method to delete the video in brightcove
        //             PMP_BrightCoveOfferingVideoStatusUtility.deleteBrightCoveVideo(cResource.id,cResource.PMP_Offering_Id__c,cResource.id + '_' + cResource.PMP_Offering_Id__c + cResource.PMP_BrightCove_Video_Extension_Txt__c,cResource.PMP_BrightCoveVideoId__c,Access_Token,'Offering_Resource_Type'); 
        //         }
        //         else
        //         {
        //             if(cResource.PMP_BrightCoveVideoThumbnail_URL__c==null || cResource.PMP_BrightCoveVideoThumbnail_URL__c=='')
        //             {
        //                 // call checkVideoJobIdStatus method to check video job id status
        //                 PMP_BrightCoveOfferingVideoStatusUtility.checkVideoJobIdStatus(cResource.id,cResource.PMP_Offering_Id__c,cResource.id + '_' + cResource.PMP_Offering_Id__c + cResource.PMP_BrightCove_Video_Extension_Txt__c,cResource.PMP_BrightCoveVideoId__c,cResource.PMP_BrightCoveVideoJobId__c,Access_Token,'Offering_Resource_Type'); 
        //             }
        //         } 
        //     }       
        // }   
    }
    
    global void finish(Database.BatchableContext bc){
      // Delete the offering resource record and video files from salesforce
    //     List<PMP_Partner_Offering_Resource__c> deleteOfferingResourceList = [SELECT Id,Name,PMP_Partner_Offering_Image__c,PMP_BrightCoveVideoId__c,PMP_Offering_Id__c,PMP_Resource_Description_Txt__c,PMP_Delete_BrightCove_Video_Ind__c,PMP_Offering_Id__r.PMP_Published_Copy_Id_Txt__c FROM PMP_Partner_Offering_Resource__c 
    //                                                                          WHERE PMP_BrightCoveVideoAccountID__c!=null AND PMP_Delete_BrightCove_Video_Ind__c=true AND ( PMP_BrightCoveVideoId__c=null OR (PMP_BrightCoveVideoId__c!=null AND PMP_Integration_Status_Reason_Txt__c=:system.label.PMP_Integration_Delete_Video_Msg))
    //                                                                          AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Approved'
    //                                                                          Limit 2000];
        
    //     List<PMP_Partner_Offering_Resource__c> deletePublishedOfferingResourceList = [SELECT Id,Name,PMP_Partner_Offering_Image__c,PMP_BrightCoveVideoId__c,PMP_Offering_Id__c,PMP_Resource_Description_Txt__c,PMP_Delete_BrightCove_Video_Ind__c,PMP_Offering_Id__r.PMP_Published_Copy_Id_Txt__c FROM PMP_Partner_Offering_Resource__c 
    //                                                                                   WHERE PMP_BrightCoveVideoAccountID__c!=null AND PMP_Delete_BrightCove_Video_Ind__c=true
    //                                                                                   AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published'
    //                                                                                   Limit 2000];
    //     Map<String,String> offResVideoIdResourceIdMap = new Map<String,String>();
    //     Set<Id> deleteOffResIdSet = new Set<Id>();
    //     Set<Id> contentDocumentIds = new Set<Id>();
    //     List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
        
    //     for(PMP_Partner_Offering_Resource__c publishOffRes : deletePublishedOfferingResourceList)
    //     {
    //         offResVideoIdResourceIdMap.put(publishOffRes.PMP_BrightCoveVideoId__c+publishOffRes.PMP_Offering_Id__r.PMP_Published_Copy_Id_Txt__c,publishOffRes.id);
    //     }
        
    //     for(PMP_Partner_Offering_Resource__c offRes : deleteOfferingResourceList)
    //     {
    //         deleteOffResIdSet.add(offRes.Id);
    //         if(offResVideoIdResourceIdMap.containsKey(offRes.PMP_BrightCoveVideoId__c+offRes.PMP_Offering_Id__r.PMP_Published_Copy_Id_Txt__c))
    //         {
    //             deleteOffResIdSet.add(offResVideoIdResourceIdMap.get(offRes.PMP_BrightCoveVideoId__c+offRes.PMP_Offering_Id__r.PMP_Published_Copy_Id_Txt__c));
    //         }
    //         contentDocumentIds.add(offRes.PMP_Partner_Offering_Image__c);
    //         Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
    //         String body='{"resource_name":' +' "'+ offRes.Name + '" '+
    //             ',"document_id":' +' "'+ offRes.PMP_Partner_Offering_Image__c + '" '+
    //             ',"video_id":' +' "'+ offRes.PMP_BrightCoveVideoId__c + '" '+
    //             ',"offering_id":' +' "'+ offRes.PMP_Offering_Id__c + '" '+
    //             ',"description":' +' "'+ offRes.PMP_Resource_Description_Txt__c + '" '+
    //             ',"delete_video":' +' "'+ offRes.PMP_Delete_BrightCove_Video_Ind__c + '" '+
    //             '}';
    //         logEntry.Core_Details__c=body;
    //         logEntry.Core_sObjectType__c='PMP_Partner_Offering__c';
    //         logEntry.Core_Origin__c='PMP_BrightCoveOfferingVideoStatusBatch';
    //         logEntry.Core_Severity__c='Low';
    //         logEntry.Core_When__c= system.today();
    //         logEntry.Core_Message__c = 'Video Deleted';
    //         logEntry.Core_Project__c = 'Marketplace';
    //         logEntry.Core_Scope__c = 'Offering Video';
    //         logEntry.Core_sObjectId__c=offRes.PMP_Offering_Id__c;
    //         logEntryList.add(logEntry);
    //     }
    //     List<ContentDocument> contentDocumentList = [Select Id from ContentDocument where Id in :contentDocumentIds Limit 2000];
    //     List<PMP_Partner_Offering_Resource__c> finalDeleteOfferingResourceList= [Select Id from PMP_Partner_Offering_Resource__c where Id in : deleteOffResIdSet Limit 2000];
    //     if(logEntryList.size()>0)
    //     {
    //         insert logEntryList;
    //     }
    //     if(contentDocumentList.size()>0)
    //     {
    //         delete contentDocumentList;
    //     }
    //     if(deleteOfferingResourceList.size()>0)
    //     {
    //         delete finalDeleteOfferingResourceList;
    //     }
     }  */ 
}