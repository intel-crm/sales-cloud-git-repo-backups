/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveDeleteVideosQueueable 
* Version     : 1.0 
* Created Date: 18/05/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 18/05/2022                 This queueable class is used to delete bulk videos from brightcove and delete 
                                                               related records in salesforce, runs every 15 mins on Sunday only
*****************************************************************************************************************************************/
public with sharing class PMP_BrightCoveDeleteVideosQueueable implements Queueable,Database.AllowsCallouts{
    public static final string CLIENTID=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientID'));
    public static final string CLIENTSECRETE=String.valueOf(PMP_Utility.getValue('PMP_BrightCove_ClientSecret'));
    
/*************************************************************************************************************
* Method Name : generateAccesToken
* Description : this method returns brightcove access token
* Version     : 1.0 
* Created Date: 18/05/2022 
* Modification Log :
**************************************************************************************************************/
    public static String generateAccesToken(){
        //Getting the access token
        Blob headerValue = Blob.valueOf(CLIENTID + ':' + CLIENTSECRETE);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        system.debug('Encoder Value' + EncodingUtil.base64Encode(headerValue));
        String Access_Token;
        http http = new http();
        httpRequest request = new httpRequest();
        request.setMethod('POST');
        request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Access_Token_Endpoint_URL'))); //Remote site settings
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //request.setHeader(PMP_StaticConstants_Offering.Authorization, authorizationHeader);
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
        return Access_Token;
    }
    
/*************************************************************************************************************
* Method Name : searchBrightCoveVideos
* Description : this method is used to search videos in brightcove
* Version     : 1.0 
* Created Date: 18/05/2022 
* Modification Log :
**************************************************************************************************************/ 
    public static List<List<String>> searchBrightCoveVideos(){
        String Access_Token = generateAccesToken();
        Httprequest request = new HttpRequest();  
        request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos?query={name:SandboxCRM}');
        request.setMethod('GET');    
        request.setHeader('Content-Type','application/json');
        //request.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer+Access_Token);  
        HTTPResponse response = new HTTPResponse();
        try{
            Http http = new Http();
            response = http.send(request);
            List<String> videoIds = new  List<String>();
            Set<Id> resourceIds = new  Set<Id>();
           // Set<Id> workingOfferingIds = new  Set<Id>();
            List<List<String>> videoBatches = new List<List<String>>();
            // Parse the JSON response
            if(response.getStatusCode() == 200) {
                List<object> objList = (List<object>) JSON.deserializeUntyped(response.getBody());
                Integer noOfRecordsToProcessed;
                for(Object obj : objList)
                {
                    Map<String,Object> data = (Map<String,Object>)obj;
                    String referenceId = String.valueOf(data.get('reference_id'));
                    List<String> referenceIds = referenceId.split('_');
                    videoIds.add(String.valueOf(data.get('id')) + ':' + referenceIds[0] + ':' + referenceIds[1]);
                    resourceIds.add(referenceIds[0]);
                    //workingOfferingIds.add(referenceIds[1]);                 
                }
                if(videoIds!=null)
                {
                    if(videoIds.size()>10)
                    {
                        noOfRecordsToProcessed=10;
                    }
                    else if(videoIds.size()>0 && videoIds.size()<=10)
                    {
                        noOfRecordsToProcessed=videoIds.size();
                    }
                    Integer noOfPartitions = videoIds.size()/noOfRecordsToProcessed;
                    if(math.mod(videoIds.size(), noOfRecordsToProcessed) != 0){
                        noOfPartitions += 1;
                    }
                    System.debug('noOfPartitions'+ noOfPartitions);       
                    for(Integer i=0;i<noOfPartitions;i++)
                    {
                        List<String> batch = new List<String>();
                        for(Integer j=(i*noOfRecordsToProcessed);(j<(i*noOfRecordsToProcessed)+noOfRecordsToProcessed) && j<videoIds.size();j++){
                            batch.add(videoIds.get(j));
                        }
                        videoBatches.add(batch);
                    }      
                }
            }
            if(videoBatches!=null)
            {
                return videoBatches;
            }
            else
            {
                return null;
            }
        }
        catch(Exception e){
            String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
            PMP_Utility.logError(e,'PMP_BrightCoveDeleteVideosQueueable - searchBrightCoveVideos');
            return null;
        }
    }
/*************************************************************************************************************
* Method Name : deleteBrightcoveVideos
* Description : this method is used to delete videos from brightcove
* Version     : 1.0 
* Created Date: 18/05/2022 
* Modification Log :
**************************************************************************************************************/   
   // public static void deleteBrightcoveVideos(List<String> videoIdList,Set<Id> resourceIdList,Set<Id> workingOfferingIdList){
    public static void deleteBrightcoveVideos(List<String> videoIdList,Set<Id> resourceIdList){
           String Access_Token = generateAccesToken();
        String videoIds='';
        for(String videoId : videoIdList)
        {
            videoIds = videoIds+','+videoId;
        }
        videoIds=videoIds.substring(1, videoIds.length());  
        Httprequest request = new HttpRequest();  
        request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos/' +videoIds); //Remote site settings 
        request.setMethod('DELETE');    
        request.setHeader('Content-Type','application/json');
       // request.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer+Access_Token);  
        HTTPResponse response = new HTTPResponse();
        try
        { 
            Http http = new Http();
            response = http.send(request);          
        }
        catch(Exception e)
        {
            String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
            PMP_Utility.logError(e,'PMP_BrightCoveDeleteVideosQueueable - deleteBrightcoveVideos');
        }
    }
/*************************************************************************************************************
* Method Name : execute
* Description : this method executes automatically
* Version     : 1.0 
* Created Date: 18/05/2022 
* Modification Log :
**************************************************************************************************************/
    public void execute(QueueableContext context){
        List<List<String>> listOfListOfData= new   List<List<String>>();
        listOfListOfData = searchBrightCoveVideos();
        List<String> videoIds = new  List<String>();
        Set<Id> resourceIds = new  Set<Id>();
       // Set<Id> workingOfferingIds = new  Set<Id>();
        if(listOfListOfData!=null)
        {    
            for( List<String> dataList : listOfListOfData)
            {
                videoIds = new List<String>();
                for(String data : dataList)
                {
                    List<String> info = data.split(':');
                    videoIds.add(info[0]);
                    resourceIds.add(info[1]);
                    //workingOfferingIds.add(info[2]);  
                }
                //deleteBrightcoveVideos(videoIds,resourceIds,workingOfferingIds);  
            }
           // deleteRelatedRecords(resourceIds,workingOfferingIds);
        }
    }
/*************************************************************************************************************
* Method Name : deleteRelatedRecords
* Description : this method is used to delete related resources,offerings and content documents from salesforce
* Version     : 1.0 
* Created Date: 18/05/2022 
* Modification Log :
**************************************************************************************************************/
    //public static void deleteRelatedRecords(Set<Id> resourceIdList, Set<Id> workingOfferingIdList ){ 
    public static void deleteRelatedRecords(Set<Id> resourceIdList){ 
        Set<Id> contentDocumentIds = new  Set<Id>();
       // List<PMP_Partner_Offering__c> offeringList = [Select Id from PMP_Partner_Offering__c where Id in :workingOfferingIdList OR PMP_Working_Copy_Id__c in :workingOfferingIdList];
       // List<PMP_Partner_Offering_Resource__c> resourceList = [Select Id, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c where Id in :resourceIdList];
        // for(PMP_Partner_Offering_Resource__c offRes : resourceList)
        // {
        //     contentDocumentIds.add(offRes.PMP_Partner_Offering_Image__c);
        // }
        List<ContentDocument> contentDocumentList = [Select Id from ContentDocument where Id in :contentDocumentIds];
        
        // if(offeringList.size()>0)
        // {
        //     delete offeringList;
        // }
        if(contentDocumentList.size()>0)
        {
            delete contentDocumentList;
        }
    }
}