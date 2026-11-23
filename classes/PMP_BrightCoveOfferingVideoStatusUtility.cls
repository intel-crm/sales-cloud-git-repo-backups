/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveOfferingVideoStatusUtility 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022                This class is called from PMP_BrightCoveOfferingVideoStatusBatch and used to perform
                                                              4 callouts(Check Video Status,Generate Thumbnail URLS and Delete Video from brightcove and AWS3)
                                                              and perform DML on offering resource
*****************************************************************************************************************************************/
@isTest
public with sharing class PMP_BrightCoveOfferingVideoStatusUtility {
    
    /*************************************************************************************************************
    * Method Name : checkVideoJobIdStatus
    * Description : this method is used to check video job id status in brightcove
    * Version     : 1.0 
    * Created Date: 06/04/2022
    * Modification Log :
    **************************************************************************************************************/
    //      public static void checkVideoJobIdStatus(String resourceID,String parentId,String fileName,String videoId, String videoJobId,String Access_Token,String object_type){
    //         //4.Check status of Video Job Id
    //         Map<String,String> videoIdMap = new Map<String,String>();
    //         videoIdMap.put(resourceID,fileName+'|'+videoId);
    //         Httprequest request = new HttpRequest();  
    //         request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos/'+videoId+'/ingest_jobs/'+videoJobId); //Remote site settings 
    //         request.setMethod('GET');    
    //         request.setHeader('Content-Type','application/json');
    //         request.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer+Access_Token);  
    //         HTTPResponse response = new HTTPResponse();
    //         try{        
    //             Http http = new Http();
    //             response = http.send(request); 
    //             // Parse the JSON response
    //             if(response.getStatusCode() == 200) {
    //                 Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    //                 for(String str : results.keySet()){
    //                     if(str.contains('state')){
    //                         videoIdMap.put(resourceID,+videoIdMap.get(resourceID)+'|'+results.get('state')); 
    //                     }
    //                 }
    //                 if(results.get('state')=='finished')
    //                 {
    //                     getVideoThumnailURL(parentId,Access_Token,object_type,videoIdMap);
    //                 }  
    //                 else if(results.get('state')=='processing')
    //                 {
    //                     performDMLWhenFailedInVideoJobIdOffering(videoIdMap,'Video Upload is "In Progress" in BrightCove','checkVideoJobIdStatus');  
    //                 }
    //                 else
    //                 {
    //                     String error= String.ValueOf(results.get('error_message')).substring(0,String.ValueOf(results.get('error_message')).length()>250 ? 250 : String.ValueOf(results.get('error_message')).length() - 1);
    //                     performDMLWhenFailedInVideoJobIdOffering(videoIdMap,error,'checkVideoJobIdStatus');                 
    //                 }
    //             } else if(response.getStatusCode() != 201 && response != null) {
    //                 //System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()); 
    //                 if(object_type == 'Offering_Resource_Type'){
    //                     performDMLWhenFailedInVideoJobIdOffering(videoIdMap,'Failed to get finished status of video job id  - No Finished Status returned','checkVideoJobIdStatus');                 
    //                 }            
    //             }
    //         }catch(Exception e){
    //             String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
    //             performDMLWhenFailedInVideoJobIdOffering(videoIdMap,error,'checkVideoJobIdStatus');
    //             PMP_Utility.logError(e,'PMP_BrightCoveOfferingVideoStatusUtility - checkVideoJobIdStatus');  
    //         }
    //     }
    
    // /*************************************************************************************************************
    // * Method Name : getVideoThumnailURL
    // * Description : this method is used to generate thumbnail url from brightcove
    // * Version     : 1.0 
    // * Created Date: 06/04/2022
    // * Modification Log :
    // **************************************************************************************************************/
    //     public static void getVideoThumnailURL(String parentId,String Access_Token,String object_type,Map<String,String> videoIdMap){
    //          //5. Get the video thumbnail images url
    //         for(String str : videoIdMap.keySet()){
    //             List<String> strList = new List<String>();
    //           strList = videoIdMap.get(str).split('\\|');
    //           //System.debug('*****strList-videothumnail->'+strList);
    //                Http http = new Http();
    //                HTTPResponse response = new HTTPResponse();
    //                HttpRequest request = new HttpRequest();
    //                request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos/'+strList[1]+'/images');
    //                request.setHeader('Content-Type','application/json');
    //                request.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer+Access_Token); 
    //                request.setMethod('GET');
                   
    //             try{
    //                  response = http.send(request);
    //                 // If the request is successful, parse the JSON response.
    //                 if(response.getStatusCode() == 200) {
    //                      Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    //                     for(String str1 : results.keySet()){
    //                         if(str1.contains('thumbnail')){
    //                             map<String,Object> items1 = (map<String,Object>)results.get('thumbnail');
    //                                 for(String str2 : items1.keySet()){
    //                                     if(str2.contains('src')){
    //                                       videoIdMap.put(str,videoIdMap.get(str)+'|'+items1.get('src')); 
    //                                    }
    //                                 }
    //                          } 
    //                     } 
    //                     //Insert all the video data based on object type
    //                        if (object_type == 'Offering_Resource_Type'){
    //                            performDMLOffering(videoIdMap,'getVideoThumnailURL');  
    //                        }
    //                 }else if(response.getStatusCode() != 200 && response != null) {
    //                        if (object_type == 'Offering_Resource_Type'){
    //                                performDMLWhenFailedInVideoJobIdOffering(videoIdMap,'Failed to get video thumbnail URL','getVideoThumnailURL');      
    //                         }
    //                 }
                    
    //             }catch(Exception e){
    //                 String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
    //                 performDMLWhenFailedInVideoJobIdOffering(videoIdMap,error,'getVideoThumnailURL');
    //                 PMP_Utility.logError(e,'PMP_BrightCoveOfferingVideoStatusUtility - getVideoThumnailURL');
    //             }
    //         }
    //     }
    
    // /*************************************************************************************************************
    // * Method Name : deleteBrightCoveVideo
    // * Description : this method is used to delete video from brightcove
    // * Version     : 1.0 
    // * Created Date: 06/04/2022
    // * Modification Log :
    // **************************************************************************************************************/    
    //       public static void deleteBrightCoveVideo(String resourceID,String parentId,String fileName,String videoId,String Access_Token,String object_type){
    //          //6. delete the video from brightcove
    //           Map<String,String> videoIdMap = new Map<String,String>();
    //           videoIdMap.put(resourceID,fileName+'|'+videoId);     
    //           Http http = new Http();
    //           HTTPResponse response = new HTTPResponse();
    //           HttpRequest request = new HttpRequest();
    //           request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos/'+videoId);
    //           request.setHeader('Content-Type','application/json');
    //           request.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer+Access_Token); 
    //           request.setMethod('DELETE');
              
    //           try{
    //               response = http.send(request);
    //               // If the request is successful, parse the JSON response.
    //               if(response.getStatusCode()==204) {  
    //                   //Insert all the video data based on object type
    //                   if (object_type == 'Offering_Resource_Type'){
    //                       performDMLOffering(videoIdMap,'deleteBrightCoveVideo');
    //                   }
    //               }else if(response.getStatusCode() != 204 && response != null) {
    //                   if (object_type == 'Offering_Resource_Type'){
    //                       performDMLWhenFailedInVideoJobIdOffering(videoIdMap,'Failed to delete video from BrightCove','deleteBrightCoveVideo');      
    //                   }
    //               }
                  
    //           }catch(Exception e){
    //               String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
    //               performDMLWhenFailedInVideoJobIdOffering(videoIdMap,error,'deleteBrightCoveVideo');
    //               PMP_Utility.logError(e,'PMP_BrightCoveOfferingVideoStatusUtility - deleteBrightCoveVideo');
    //           }
    //     }
    
    // /*************************************************************************************************************
    // * Method Name : performDMLOffering
    // * Description : this method is used to perform DML on offering resource when all callouts happen successfully
    // * Version     : 1.0 
    // * Created Date: 06/04/2022
    // * Modification Log :
    // **************************************************************************************************************/  
    //     public static void performDMLOffering(Map<String,String> videoMap,String methodName){
           
    //         List<PMP_Partner_Offering_Resource__c> offResourceList = [Select Id from PMP_Partner_Offering_Resource__c where Id in :videoMap.keySet()];
    //         if(offResourceList.size()>0)
    //         {
    //             List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
    //             for(String str : videoMap.keySet()){
    //                 PMP_Partner_Offering_Resource__c offeringresource = new PMP_Partner_Offering_Resource__c();
    //                 offeringresource.id = str;
    //                 offeringresource.PMP_BrightCoveVideoAccountID__c = String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
    //                 List<String> strList = new List<String>();
    //                 strList = videoMap.get(str).split('\\|');
    //                 if(methodName == 'deleteBrightCoveVideo')
    //                 {
    //                     offeringResource.PMP_Integration_Status_Nm__c='Success';
    //                 }
    //                 else
    //                 {
    //                     offeringresource.PMP_BrightCoveVideoThumbnail_URL__c = strList[3];
    //                     offeringResource.PMP_Integration_Status_Nm__c='Success';
    //                     offeringResource.PMP_Integration_Status_Reason_Txt__c='';            
    //                 }
                    
    //                 offeringResourceList.add(offeringresource); 
    //             }
    //             update offeringResourceList;     
    //         }
    //     } 
    // /*************************************************************************************************************
    // * Method Name : performDMLWhenFailedInVideoJobIdOffering
    // * Description : this method is used to perform DML when video job id/getVideoThumnailURL/deleteBrightCoveVideo callout failed on offering resource 
    // * Version     : 1.0 
    // * Created Date: 06/04/2022
    // * Modification Log :
    // **************************************************************************************************************/
    //     public static void performDMLWhenFailedInVideoJobIdOffering(Map<String,String> videoIdMap,String failedMsg,String methodName){
    //         List<PMP_Partner_Offering_Resource__c> offResourceList = [Select Id from PMP_Partner_Offering_Resource__c where Id in :videoIdMap.keySet()];
    //         if(offResourceList.size()>0)
    //         {
    //             List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
    //             if(videoIdMap !=null){
    //                 for(String str : videoIdMap.keySet()){
    //                     PMP_Partner_Offering_Resource__c offeringResource = new PMP_Partner_Offering_Resource__c();
    //                     offeringResource.id = str;
    //                     offeringResource.PMP_BrightCoveVideoAccountID__c = String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
    //                     List<String> strList = new List<String>();
    //                     strList = videoIdMap.get(str).split('\\|');
    //                     if(methodName == 'checkVideoJobIdStatus' || methodName == 'getVideoThumnailURL' || methodName == 'deleteBrightCoveVideo'){
    //                         offeringResource.PMP_Integration_Status_Nm__c='Aborted';
    //                         offeringResource.PMP_Integration_Status_Reason_Txt__c=failedMsg;
    //                     }
    //                     offeringResourceList.add(offeringResource); 
    //                 }
    //                 update offeringResourceList;
    //             }
    //         }
    //     }
    }