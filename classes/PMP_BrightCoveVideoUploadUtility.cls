/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveVideoUploadUtility 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022                This class is called from PMP_BrightCoveOfferingVideoUploadBatch and used to perform
                                                              1 callout (Create Video Response) and perform DML on offering resource
*****************************************************************************************************************************************/
@isTest
public with sharing class PMP_BrightCoveVideoUploadUtility {
    
/*************************************************************************************************************
* Method Name : createVideoResponse
* Description : this method is used to create video id in brightcove
* Version     : 1.0 
* Created Date: 06/04/2022
* Modification Log :
**************************************************************************************************************/
//     public static void createVideoResponse(String resourceID,String parentId,string fileName,String Access_Token,String contentDocumentId,String object_type,String description,String title){
//         //2.Create a new video in Account
//         // System.debug('fileName--->'+fileName);
//         String shortDescription;
//         String referenceId = resourceID +'_'+ parentId;
//         Organization org = [SELECT IsSandbox FROM Organization Limit 1];   
//         if(org.IsSandbox)
//         {
//             title= '[SandboxCRM] ' + title;
//         }
//         if(description!=null)
//         {
//             description= description.replaceAll('\\s+',' ');
//             if(description.length() > 250 )
//             {
//                 shortDescription = description.substring(0, 250);
//             }
//             else
//             {
//                 shortDescription = description;
//             }
//         }
//         else
//         {
//             shortDescription = description;
//         }
        
//         String body='{"name":' +' "'+ title + '" '+
//                             ',"description":' +' "'+ shortDescription + '" '+
//                             ',"long_description":' +' "'+ description + '" '+
//                             ',"reference_id":' +' "'+ referenceId + '" '+
//                             '}';
//         //System.debug('body1-->' + body);
//         Httprequest request = new HttpRequest();  
//         request.setEndpoint(String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos'); //Remote site settings 
//         request.setMethod('POST');    
//         request.setHeader('Content-Type','application/json');
//         request.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer+Access_Token);  
//         HTTPResponse response = new HTTPResponse();
//         try{
//             request.setBody(body);  
//             Http http = new Http();
//             response = http.send(request); 
            
//             // Parse the JSON response
//             if(response.getStatusCode() == 201) {
//                 Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
//                 Map<String,String> videoIdMap = new Map<String,String>();
//                 for(String str : results.keySet()){
//                     if(str.contains('id')){
//                         videoIdMap.put(resourceID,fileName+'|'+results.get('id')); 
//                     }
//                 }
//                 performDMLOffering(videoIdMap);
                
//             } else if(response.getStatusCode() != 201 && response != null) {
//                 //System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()); 
//                 if(object_type == 'Offering_Resource_Type'){
//                     performDMLWhenFailedInVideoIDOffering(resourceID,'Failed to Create Video Response - No Video ID returned','createVideoResponse');                 
//                 }            
//             }
//         }catch(Exception e){
//             String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
//             performDMLWhenFailedInVideoIDOffering(resourceID,error,'createVideoResponse');
//             PMP_Utility.logError(e,'PMP_BrightCoveVideoUploadUtility - createVideoResponse');
//         }
//     }
    
// /*************************************************************************************************************
// * Method Name : performDMLOffering
// * Description : this method is used to perform DML on offering resource when all callouts happen successfully
// * Version     : 1.0 
// * Created Date: 06/04/2022
// * Modification Log :
// **************************************************************************************************************/
//     public static void performDMLOffering(Map<String,String> videoMap){
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
//                 offeringresource.PMP_BrightCoveVideoId__c = strList[1];
//                 offeringresource.PMP_Integration_Status_Nm__c='Pending';
//                 offeringResource.PMP_Integration_Status_Reason_Txt__c='Video Id is created sucessfully in BrightCove';
//                 offeringResourceList.add(offeringresource); 
//             }
//             update offeringResourceList;     
//         }
//     }
    
// /*************************************************************************************************************
// * Method Name : performDMLWhenFailedInVideoIDOffering
// * Description : this method is used to perform DML when video Id callout failed on offering resource
// * Version     : 1.0 
// * Created Date: 06/04/2022
// * Modification Log :
// **************************************************************************************************************/
//    public static void performDMLWhenFailedInVideoIDOffering(String resourceID, String failedMsg, String methodName){
//         List<PMP_Partner_Offering_Resource__c> offResourceList = [Select Id,PMP_Integration_Status_Nm__c,PMP_Integration_Status_Reason_Txt__c from PMP_Partner_Offering_Resource__c where Id=:resourceID Limit 1];
//         if(offResourceList.size()>0)
//         {
//             List<PMP_Partner_Offering_Resource__c> offeringResourceList = new List<PMP_Partner_Offering_Resource__c>();
//             if(methodName == 'createVideoResponse'){
//                 for(PMP_Partner_Offering_Resource__c offeringResource : offResourceList){
//                     offeringResource.PMP_Integration_Status_Nm__c='Aborted';
//                     offeringResource.PMP_Integration_Status_Reason_Txt__c=failedMsg;
//                     offeringResourceList.add(offeringResource);
//                 }
//                 update offeringResourceList;
//             } 
//         }
//     }
}