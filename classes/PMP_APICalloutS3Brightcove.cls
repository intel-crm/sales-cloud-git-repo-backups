public class PMP_APICalloutS3Brightcove {
 /*
    //This method inserts file information to Custom PMP_Company_Resource__c object
    @AuraEnabled
    public static void insertCompanyResourceRecord(String file_Name,String file_Type,String S3_Video_URL, String s3_VideoDownload_URL){
      
        PMP_Company_Resource__c companyResource = new PMP_Company_Resource__c();
        companyResource.PMP_Company_Id__c = 'a5S8A000000CvJr';
        companyResource.PMP_VideoName__c=file_Name;
        companyResource.Name=file_Name;
        companyResource.PMP_S3VideoURL__c=S3_Video_URL;
        companyResource.PMP_S3_VideoDownload_URL__c = s3_VideoDownload_URL;
        companyResource.PMP_Company_Resource_Type_Nm__c  = file_Type;
        companyResource.PMP_BrightCoveVideoAccountID__c = PMP_Utility.getValue('PMP_BrightCoveAccountID');
        insert companyResource;
    }
    
    //This method inserts file information to Custom PMP_Partner_Offering_Resource__c object
    @AuraEnabled
    public static void insertOfferingResourceRecord(String file_Name,String file_Type,String S3_Video_URL, String s3_VideoDownload_URL){
      
        PMP_Partner_Offering_Resource__c offResource = new PMP_Partner_Offering_Resource__c();
        offResource.PMP_Offering_Id__c = 'a5b8A000000EUla';
        offResource.PMP_VideoName__c=file_Name;
        offResource.Name=file_Name;
        offResource.PMP_S3VideoURL__c=S3_Video_URL;
        offResource.PMP_S3_VideoDownload_URL__c = s3_VideoDownload_URL;
        offResource.PMP_Resource_Type_Nm__c  = file_Type;
        offResource.PMP_BrightCoveVideoAccountID__c = PMP_Utility.getValue('PMP_BrightCoveAccountID');
        insert offResource;
    }
 
    public static void CreateVideoResponse(String resourceID,string parentId,string S3_Video_URL,String Access_Token,String object_type){
        //2.Create a new video in Account
        System.debug('Access_Token-62--->'+Access_Token);
      
        Httprequest request = new HttpRequest();  
        HttpResponse response;
        request.setEndpoint('https://cms.api.brightcove.com/v1/accounts/'+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos'); //Remote site settings 
        request.setMethod('POST');    
        request.setHeader('Content-Type','application/json');
        request.setHeader('Authorization','Bearer '+Access_Token);  
        try{
        request.setBody('{"cue_points":[{"name":"string","type":"AD","time":10.527,"metadata":"string","force_stop":false}],"description":"Laughing Gull","digital_master_id":null,"duration":null,"economics":"AD_SUPPORTED","geo":{"countries":["ca","fr","us"],"exclude_countries":true,"restricted":true},"link":null,"long_description":"Herring Gull near Fort Point Channel in Boston, MA, USA. 2019-04-25.","name":"A happy herring gull","original_filename":null,"projection":null,"published_at":null,"schedule":{"ends_at":null,"starts_at":"2019-05-20T20:41:07.689Z"},"sharing":null,"state":"ACTIVE","tags":["birds","sea"],"text_tracks":[],"updated_at":"2021-12-01T05:28:50.522Z","updated_by":{"type":"api_key","email":"nickolasx.dukes@intel.com"},"playback_rights_id":"primary"}');           
        Http http = new Http();
        response = http.send(request);                 
     // Parse the JSON response
        if(response.getStatusCode() == 201) {
             Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
             system.debug('Video Id:  '+results.get('id'));  
            
             Map<String,String> videoIdMap = new Map<String,String>();
             for(String str : results.keySet()){
                 if(str.contains('id')){
                    videoIdMap.put(resourceID,S3_Video_URL+'|'+results.get('id')); 
                 }
             }
            System.debug('****videoIdMap--->'+videoIdMap);    
            
            submitDynamicIngest(parentId,Access_Token,object_type,videoIdMap);
       
        } else if(response.getStatusCode() != 201 && response != null) {
             System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()); 
            if(object_type == 'Partner_Resource_Type'){
               performDMLWhenFailedInVideoID(resourceID,'Failed to Create Video Response - No Video ID returned','CreateVideoResponse');                 
            } else if (object_type == 'Offering_Resource_Type'){
                performDMLWhenFailedInVideoIDOffering(resourceID,'Failed to Create Video Response - No Video ID returned','CreateVideoResponse');  
            }            
       }
      }catch(Exception e){
         PMP_Utility.creatFailedCalloutLogEntryRecord(resourceID,'PMP_BrightCoveAPIVideoCallouts - CreateVideoResponse','PMP','PMP_Company_Resource__c','Failed',
                                                             response,parentId,'');     
          
      }
    }
    
  public static void submitDynamicIngest(String parentId,String Access_Token,String object_type,Map<String,String> videoIdMap){
    //3.Dynamic Ingest POST request to ingest the source file
      for(String str : videoIdMap.keySet()){
          List<String> strList = new List<String>();
          strList = videoIdMap.get(str).split('\\|');
          System.debug('*****strList-dynamicingest->'+strList);
          HttpRequest request = new HttpRequest();
          HttpResponse response;
        request.setEndpoint('https://ingest.api.brightcove.com/v1/accounts/'+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos/'+strList[1]+'/ingest-requests');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization','Bearer '+Access_Token); 
          try{
        request.setBody('{"master":{"url": ' +' "'+ strList[0] + '" '+ '},"profile":"multi-platform-standard-static","capture-images":true}');
        Http http = new Http();
         response = http.send(request);
                 if(response.getStatusCode() == 200) {
                   Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                     system.debug('Video_Job_ID:  '+ String.valueOf(results.get('id')));  
                  
                     for(String str1 : results.keySet()){
                         if(str1.contains('id')){
                           videoIdMap.put(str,videoIdMap.get(str)+'|'+results.get('id'));  
                         } 
                      }  
                     createVideoPlayer(parentId,Access_Token,object_type,videoIdMap);
                     
                 }else if(response.getStatusCode() != 200 && response != null){
                     if(object_type == 'Partner_Resource_Type'){
                       performDMLWhenFailedInCreateVideo(videoIdMap,'Failed at Dynamic Ingest - Couldnt upload video to Brightcove','submitDynamicIngest');         
                     }else if (object_type == 'Offering_Resource_Type'){
                         performDMLWhenFailedInCreateVideoOffering(videoIdMap,'Failed to do dynamic ingest','submitDynamicIngest'); 
                     }
              }
            }catch(Exception e){
                PMP_Utility.creatFailedCalloutLogEntryRecord(str,'PMP_BrightCoveAPIVideoCallouts - submitDynamicIngest','PMP','PMP_Company_Resource__c','Failed',
                                                             response,parentId,'');  
            }
        }
        
    }
    
      public static void createVideoPlayer(String parentId,String Access_Token,String object_type,Map<String,String> videoIdMap){
     //4.Get a list of players
     for(String str : videoIdMap.keySet()){
        List<String> strList = new List<String>();
          strList = videoIdMap.get(str).split('\\|');
          System.debug('*****strList-playerid->'+strList);
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       HttpResponse response;
       request.setEndpoint('https://players.api.brightcove.com/v2/accounts/'+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/players');
       request.setHeader('Content-Type','application/json');
       request.setHeader('Authorization','Bearer '+Access_Token); 
       request.setMethod('POST');
         try{
       request.setBody('{"name": "Test_Player_salesforce","description": "A test player for autoplay and video looping","configuration": {"autoplay": "any","loop": true,"video_cloud": {"video": ' +' "'+ strList[1] + '" '+ '}}}');
        response = http.send(request);
          system.debug('Player response--->'+response);
          system.debug('player response code--->'+response.getStatusCode());
       // If the request is successful, parse the JSON response.
       if(response.getStatusCode() == 201) {
          //system.debug(response.getBody());
       Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
       system.debug('id-player-->'+results.get('id'));
           
               for(String str1 : results.keySet()){
                   if(str1.contains('id')){
                       videoIdMap.put(str,videoIdMap.get(str)+'|'+results.get('id'));  
                    } 
                 }
                      
       getVideoPreviewURL(parentId,Access_Token,object_type,videoIdMap);
       }else if(response.getStatusCode() != 201 && response!=null){
           if(object_type == 'Partner_Resource_Type'){
             performDMLWhenFailedInCreateVideo(videoIdMap,'Failed to create a player','createVideoPlayer');  
           }else if (object_type == 'Offering_Resource_Type'){
             performDMLWhenFailedInCreateVideoOffering(videoIdMap,'Failed to create a player','createVideoPlayer');            
            }                   
       }
      }catch(Exception e){
          PMP_Utility.creatFailedCalloutLogEntryRecord(str,'PMP_BrightCoveAPIVideoCallouts - createVideoPlayer','PMP','PMP_Company_Resource__c','Failed',
                                                             response,parentId,'');
     }
  }
}
    
        public static void getVideoPreviewURL(String parentId,String Access_Token,String object_type,Map<String,String> videoIdMap){
     //5.Get a list of player
      for(String str : videoIdMap.keySet()){
       List<String> strList = new List<String>();
       strList = videoIdMap.get(str).split('\\|');
       System.debug('*****strList-previewURL->'+strList);
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       HttpResponse response;
       request.setEndpoint('https://players.api.brightcove.com/v2/accounts/'+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/players/'+strList[3]);
       request.setHeader('Content-Type','application/json');
       request.setHeader('Authorization','Bearer '+Access_Token); 
       request.setMethod('GET');
      try{
        response = http.send(request);
            System.debug('response--last--->'+response.getBody());
            
       // If the request is successful, parse the JSON response.
       if(response.getStatusCode() == 200) {
       Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

               for(String str1 : results.keySet()){
                   if(str1.contains('branches')){
                     map<String,Object> items = (map<String,Object>)results.get('branches');
                       for(String str2 : items.keySet()){
                           if(str2.contains('master')){
                               map<String,Object> items2 = (map<String,Object>)items.get('master');
                               for(String str3 : items2.keySet()){
                                   if(str3.contains('preview_url')){
                                      videoIdMap.put(str,videoIdMap.get(str)+'|'+items2.get('preview_url')); 
                                   }
                               }
                           }
                       }
                   }
                 }
           System.debug('*****videoIdMap--Last-->'+videoIdMap);
           //Insert all the video data based on object type
           if(object_type == 'Partner_Resource_Type'){
              performDML(videoIdMap);   
           }else if (object_type == 'Offering_Resource_Type'){
              performDMLOffering(videoIdMap);  
           }
       }else if(response.getStatusCode() != 200 && response!=null){
           if(object_type == 'Partner_Resource_Type'){
            performDMLWhenFailedInCreateVideo(videoIdMap,'Failed to get Preview URL','getVideoPreviewURL');
          }else if (object_type == 'Offering_Resource_Type'){
            performDMLWhenFailedInCreateVideoOffering(videoIdMap,'Failed to get Preview URL','getVideoPreviewURL');          
            }
       }
      }   catch(Exception e){
          PMP_Utility.creatFailedCalloutLogEntryRecord(str,'PMP_BrightCoveAPIVideoCallouts - getVideoPreviewURL','PMP','PMP_Company_Resource__c','Failed',
                                                             response,parentId,''); 
      }
     }
  }
    
    //perform DML when all callouts happen successfully - offering
    public static void performDMLOffering(Map<String,String> videoMap){
         List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
        System.debug('*****inside Finish-->');
        for(String str : videoMap.keySet()){
            PMP_Partner_Offering_Resource__c offeringresource = new PMP_Partner_Offering_Resource__c();
            offeringresource.id = str;
            offeringresource.PMP_BrightCoveVideoAccountID__c = String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
            List<String> strList = new List<String>();
            strList = videoMap.get(str).split('\\|');
            System.debug('*****strList-inbatch-->'+strList);
            
            offeringresource.PMP_BrightCoveVideoId__c = strList[1];
            offeringresource.PMP_BrightCoveVideoJobId__c = strList[2];
            offeringresource.PMP_BrightCovePlayerId__c = strList[3];
            offeringresource.PMP_Brightcove_VideoPreviewURL__c = strList[4];
            offeringresource.PMP_CalloutPayloadMessage__c = 'Success';  
            offeringResourceList.add(offeringresource); 
        }
        System.debug('offeringResourceList--->dynamic'+offeringResourceList);
        update offeringResourceList;     
    }
    
    
    public static void performDML(Map<String,String> videoMap){
         List<PMP_Company_Resource__c> companyResourceList = new List<PMP_Company_Resource__c>();
        System.debug('*****inside Finish-->');
        for(String str : videoMap.keySet()){
            PMP_Company_Resource__c cresource = new PMP_Company_Resource__c();
            cresource.id = str;
            List<String> strList = new List<String>();
            strList = videoMap.get(str).split('\\|');
            System.debug('*****strList-inbatch-->'+strList);
            System.debug('strList[1]---->'+strList[1]);
            System.debug('strList[2]---->'+strList[2]);
            System.debug('strList[3]---->'+strList[3]);
            System.debug('strList[4]---->'+strList[4]);
            cresource.PMP_BrightCoveVideoId__c = strList[1];
            cresource.PMP_BrightCoveVideoJobId__c = strList[2];
            cresource.PMP_BrightCovePlayerId__c = strList[3];
            cresource.PMP_Brightcove_VideoPreviewURL__c = strList[4];
            cresource.PMP_CalloutPayloadMessage__c = 'Success';  
            companyResourceList.add(cresource); 
        }
        System.debug('companyResourceList--->dynamic'+companyResourceList);
        update companyResourceList;     
    }
    
    public static void performDMLWhenFailedInCreateVideo(Map<String,String> videoIdMap,String failedMsg,String methodName){
        List<PMP_Company_Resource__c> companyResourceList = new List<PMP_Company_Resource__c>();
        if(videoIdMap !=null){
          for(String str : videoIdMap.keySet()){
              PMP_Company_Resource__c companyResource = new PMP_Company_Resource__c();
              companyResource.id = str;
              List<String> strList = new List<String>();
              strList = videoIdMap.get(str).split('\\|');
                       
              if(methodName == 'submitDynamicIngest'){
                  companyResource.PMP_CalloutPayloadMessage__c =  failedMsg;
                  companyResource.PMP_BrightCoveVideoId__c =  strList[1];
              }else if(methodName == 'createVideoPlayer'){
                   companyResource.PMP_CalloutPayloadMessage__c =  failedMsg;
                   companyResource.PMP_BrightCoveVideoId__c = strList[1];
                   companyResource.PMP_BrightCoveVideoJobId__c = strList[2];
              }else if(methodName == 'getVideoPreviewURL'){
                   companyResource.PMP_CalloutPayloadMessage__c =  failedMsg;
                   companyResource.PMP_BrightCoveVideoId__c = strList[1];
                   companyResource.PMP_BrightCoveVideoJobId__c = strList[2];
                   companyResource.PMP_BrightCovePlayerId__c = strList[3];
              }
              companyResourceList.add(companyResource); 
          }
             System.debug('companyResourceList--->failed1'+companyResourceList);
             update companyResourceList;
        }
    }
    
    public static void performDMLWhenFailedInVideoID(String resourceID, String failedMsg, String methodName){
        List<PMP_Company_Resource__c> companyResourceList = new List<PMP_Company_Resource__c>();
        if(methodName == 'CreateVideoResponse'){
            for(PMP_Company_Resource__c companyResource : [select id,Name,PMP_CalloutPayloadMessage__c from PMP_Company_Resource__c where id =:resourceID]){
                companyResource.PMP_CalloutPayloadMessage__c = failedMsg;
                companyResourceList.add(companyResource);
            }
             System.debug('companyResourceList--->failed2'+companyResourceList);
             update companyResourceList;
        } 
    }
    
    //perform DML when video Id callout failed - offering
    public static void performDMLWhenFailedInVideoIDOffering(String resourceID, String failedMsg, String methodName){
        List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
        if(methodName == 'CreateVideoResponse'){
            for(PMP_Partner_Offering_Resource__c offeringResource : [select id,Name,PMP_CalloutPayloadMessage__c from PMP_Partner_Offering_Resource__c where id =:resourceID]){
                offeringResource.PMP_CalloutPayloadMessage__c = failedMsg;
                offeringResource.PMP_BrightCoveVideoAccountID__c = String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
                offeringResourceList.add(offeringResource);
            }
             System.debug('offeringResourceList--->failed2'+offeringResourceList);
             update offeringResourceList;
        } 
    }
    
     //perform DML when video callout failed - Offering
    public static void performDMLWhenFailedInCreateVideoOffering(Map<String,String> videoIdMap,String failedMsg,String methodName){
        List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
        if(videoIdMap !=null){
          for(String str : videoIdMap.keySet()){
              PMP_Partner_Offering_Resource__c offeringResource = new PMP_Partner_Offering_Resource__c();
              offeringResource.id = str;
              offeringResource.PMP_BrightCoveVideoAccountID__c = String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
              List<String> strList = new List<String>();
              strList = videoIdMap.get(str).split('\\|');
         
              if(methodName == 'submitDynamicIngest'){
                  offeringResource.PMP_CalloutPayloadMessage__c =  failedMsg;
                  offeringResource.PMP_BrightCoveVideoId__c =  strList[1];
              }else if(methodName == 'createVideoPlayer'){
                   offeringResource.PMP_CalloutPayloadMessage__c =  failedMsg;
                   offeringResource.PMP_BrightCoveVideoId__c = strList[1];
                   offeringResource.PMP_BrightCoveVideoJobId__c = strList[2];
              }else if(methodName == 'getVideoPreviewURL'){
                   offeringResource.PMP_CalloutPayloadMessage__c =  failedMsg;
                   offeringResource.PMP_BrightCoveVideoId__c = strList[1];
                   offeringResource.PMP_BrightCoveVideoJobId__c = strList[2];
                   offeringResource.PMP_BrightCovePlayerId__c = strList[3];
              }
              offeringResourceList.add(offeringResource); 
          }
             System.debug('offeringResourceList-offering-->failed1'+offeringResourceList);
             update offeringResourceList;
        }
    }
    */
}