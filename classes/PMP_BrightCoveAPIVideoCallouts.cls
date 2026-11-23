/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveVideoUploadUtility 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022                This class is called from PMP_BrightCoveOfferingVideoUploadBatch and used to perform
                                                              3 callouts(Create Video Response,Generate S3 URLS,Send Info to Mulesoft) and 
                                                              perform DML on offering resource
*****************************************************************************************************************************************/
public class PMP_BrightCoveAPIVideoCallouts {
    
/*************************************************************************************************************
* Method Name : createVideoResponse
* Description : this method is used to create video id in brightcove
* Version     : 1.0 
* Created Date: 06/04/2022
* Modification Log :
**************************************************************************************************************/
    public static void createVideoResponse(String resourceID,String parentId,string fileName,String Access_Token,String contentDocumentId,String object_type,String description){
        //2.Create a new video in Account
        System.debug('Access_Token-62--->'+Access_Token);
        System.debug('resourceID--->'+ resourceID);
        System.debug('parentId--->'+parentId);
        System.debug('fileName--->'+fileName);
        System.debug('object_type--->'+object_type);
        
        String referenceId = resourceID +'_'+ parentId;
        DateTime currentDateTime = system.now();
        DateTime currentDateTimePlus10Years = currentDateTime.addYears(10);
        // DateTime Format - YYYY-MM-DDTHH:mm:ss.sssZ
        String startDate = String.valueOf(currentDateTime.year())+'-'+String.valueOf(currentDateTime.month())+'-'+String.valueOf(currentDateTime.day())+'T';
        String startDateTime = startDate+String.valueOf(currentDateTime.hour())+':'+String.valueOf(currentDateTime.minute())+':'+String.valueOf(currentDateTime.second())+'.'+String.valueOf(currentDateTime.millisecond())+'Z';
        
        String endDate = String.valueOf(currentDateTimePlus10Years.year())+'-'+String.valueOf(currentDateTimePlus10Years.month())+'-'+String.valueOf(currentDateTimePlus10Years.day())+'T';
        String endDateTime = endDate+String.valueOf(currentDateTimePlus10Years.hour())+':'+String.valueOf(currentDateTimePlus10Years.minute())+':'+String.valueOf(currentDateTimePlus10Years.second())+'.'+String.valueOf(currentDateTimePlus10Years.millisecond())+'Z';
        
        String body='{"name":' +' "'+ fileName + '" '+
                            ',"description":' +' "'+ description + '" '+
                            ',"long_description":' +' "'+ description + '" '+
                             ',"schedule":{"ends_at":' +' "'+ endDateTime + '" '+
                             ',"starts_at":' +' "'+ startDateTime + '"}'+
                            ',"reference_id":' +' "'+ referenceId + '" '+
                            '}';
        System.debug('body1-->' + body);
        Httprequest request = new HttpRequest();  
        request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos'); //Remote site settings 
        request.setMethod('POST');    
        request.setHeader('Content-Type','application/json');
        request.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer+Access_Token);  
        HTTPResponse response = new HTTPResponse();
        try{
            request.setBody(body);  
            Http http = new Http();
            response = http.send(request); 
            
            // Parse the JSON response
            if(response.getStatusCode() == 201) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String,String> videoIdMap = new Map<String,String>();
                for(String str : results.keySet()){
                    if(str.contains('id')){
                        videoIdMap.put(resourceID,fileName+'|'+results.get('id')); 
                    }
                }
                String awS3Code=PMP_BrightCoveVideoUploadAWS3.uploadVideoToAWS3(fileName,object_type,contentDocumentId,videoIdMap); 
                if(awS3Code=='200')
                {
                    submitDynamicIngest(Access_Token,object_type,videoIdMap);
                }
                
            } else if(response.getStatusCode() != 201 && response != null) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()); 
                if(object_type == 'Offering_Resource_Type'){
                    performDMLWhenFailedInVideoIDOffering(resourceID,'Failed to Create Video Response - No Video ID returned','createVideoResponse');                 
                }            
            }
        }catch(Exception e){
            String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
            performDMLWhenFailedInVideoIDOffering(resourceID,error,'createVideoResponse');
            //PMP_Utility.logError(e,'PMP_BrightCoveVideoUploadUtility - createVideoResponse');
        }
    }

/*************************************************************************************************************
* Method Name : submitDynamicIngest
* Description : this method is used to upload video from AWS3 to BrightCove
* Version     : 1.0 
* Created Date: 06/04/2022
* Modification Log :
**************************************************************************************************************/
    public static void submitDynamicIngest(String Access_Token,String object_type,Map<String,String> videoIdMap){
    //4.Dynamic Ingest POST request to ingest the source file
        for(String str : videoIdMap.keySet()){
            List<String> strList = new List<String>();
            strList = videoIdMap.get(str).split('\\|');
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_S3_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos/'+strList[1]+'/ingest-requests');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer+Access_Token);  
            try{
                request.setBody('{"master":{"url": ' +' "'+ strList[2] + '" '+ '},"profile":"multi-platform-standard-static","capture-images":true}');
                Http http = new Http();
                response = http.send(request);
                if(response.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    for(String str1 : results.keySet()){
                        if(str1.contains('id')){
                            videoIdMap.put(str,videoIdMap.get(str)+'|'+results.get('id'));  
                        } 
                    }
                   performDMLOffering(videoIdMap); 
                }else if(response.getStatusCode() != 200 && response != null){
                    if (object_type == 'Offering_Resource_Type'){
                        performDMLWhenFailedInCreateVideoOffering(videoIdMap,'Failed at Dynamic Ingest - Couldnot upload video to Brightcove','submitDynamicIngest');
                    }
                }
            }catch(Exception e){
                String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
                performDMLWhenFailedInCreateVideoOffering(videoIdMap,error,'submitDynamicIngest');
               // PMP_Utility.logError(e,'PMP_BrightCoveVideoUploadUtility - submitDynamicIngest');
            }
        }
        
    }
    
/*************************************************************************************************************
* Method Name : performDMLOffering
* Description : this method is used to perform DML on offering resource when all callouts happen successfully
* Version     : 1.0 
* Created Date: 06/04/2022
* Modification Log :
**************************************************************************************************************/
    public static void performDMLOffering(Map<String,String> videoMap){
        List<PMP_Partner_Offering_Resource__c> offResourceList = [Select Id from PMP_Partner_Offering_Resource__c where Id in :videoMap.keySet()];
        if(offResourceList.size()>0)
        {
            List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
            for(String str : videoMap.keySet()){
                PMP_Partner_Offering_Resource__c offeringresource = new PMP_Partner_Offering_Resource__c();
                offeringresource.id = str;
                offeringresource.PMP_BrightCoveVideoAccountID__c = String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
                List<String> strList = new List<String>();
                strList = videoMap.get(str).split('\\|');
                System.debug('strList[1]---->'+strList[1]);
                System.debug('strList[2]---->'+strList[2]);
                offeringresource.PMP_BrightCoveVideoId__c = strList[1];
                offeringresource.PMP_BrightCoveVideoJobId__c = strList[2];
                offeringresource.PMP_Integration_Status_Nm__c='Success';
                offeringResource.PMP_Integration_Status_Reason_Txt__c='Video is successfully uploaded in BrightCove';
                offeringResourceList.add(offeringresource); 
            }
            update offeringResourceList;     
        }
    }
    
/*************************************************************************************************************
* Method Name : performDMLWhenFailedInVideoIDOffering
* Description : this method is used to perform DML when video Id callout failed on offering resource
* Version     : 1.0 
* Created Date: 06/04/2022
* Modification Log :
**************************************************************************************************************/
    public static void performDMLWhenFailedInVideoIDOffering(String resourceID, String failedMsg, String methodName){
        List<PMP_Partner_Offering_Resource__c> offResourceList = [Select Id from PMP_Partner_Offering_Resource__c where Id=:resourceID Limit 1];
        if(offResourceList.size()>0)
        {
            List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
            if(methodName == 'createVideoResponse'){
                for(PMP_Partner_Offering_Resource__c offeringResource : [select id,Name from PMP_Partner_Offering_Resource__c where id =:resourceID]){
                    offeringResource.PMP_BrightCoveVideoAccountID__c = String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
                    offeringResource.PMP_Integration_Status_Nm__c='Failed';
                    offeringResource.PMP_Integration_Status_Reason_Txt__c=failedMsg;
                    offeringResourceList.add(offeringResource);
                }
                update offeringResourceList;
            } 
        }
    }
    
/*************************************************************************************************************
* Method Name : performDMLWhenFailedInCreateVideoOffering
* Description : this method is used to perform DML when video callout getS3UploadURLs/sendS3InfoToMulesoft failed on offering resource
* Version     : 1.0 
* Created Date: 06/04/2022
* Modification Log :
**************************************************************************************************************/
    public static void performDMLWhenFailedInCreateVideoOffering(Map<String,String> videoIdMap,String failedMsg,String methodName){
        List<PMP_Partner_Offering_Resource__c> offResourceList = [Select Id from PMP_Partner_Offering_Resource__c where Id in :videoIdMap.keySet()];
        if(offResourceList.size()>0)
        {
            List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
            if(videoIdMap !=null){
                for(String str : videoIdMap.keySet()){
                    PMP_Partner_Offering_Resource__c offeringResource = new PMP_Partner_Offering_Resource__c();
                    offeringResource.id = str;
                    offeringResource.PMP_BrightCoveVideoAccountID__c = String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
                    List<String> strList = new List<String>();
                    strList = videoIdMap.get(str).split('\\|');
                    
                    if(methodName == 'uploadVideoToAWS3' || methodName == 'submitDynamicIngest'){
                        System.debug('strList[1]---->'+strList[1]);
                        offeringResource.PMP_BrightCoveVideoId__c =  strList[1];
                        offeringResource.PMP_Integration_Status_Nm__c='Failed';
                        offeringResource.PMP_Integration_Status_Reason_Txt__c=failedMsg;
                    }
                    offeringResourceList.add(offeringResource); 
                }
                update offeringResourceList;
            }
        }
    }
}