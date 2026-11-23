/**************************************************************************************
Apex Class Name : PMP_GenerateThumbnailImages
Version     : 1.0 
Created Date: 6th Sep, 2019
Description : Batch class to generate thumbnail images for uploaded images
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raj Yadav                 06/09/2019               Original Version
*************************************************************************************/
global without sharing class PMP_GenerateThumbnailImages implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    //start method
    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'select id, Name, PMP_Partner_Offering_Source_Id__c from PMP_Partner_Offering__c where PMP_Partner_Offering_Source_Id__c <> NULL';
        return Database.getQueryLocator(query);
    }
    
    //execute method
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering__c> offerings){
        //execute here
        for(PMP_Partner_Offering__c offering : offerings){
            generateThumbnails(offering.Id);
        }
    }
    
    //finish method
    global void finish(Database.BatchableContext bc){
        Id jobId = bc.getJobId();
        System.debug('JobId----->'+jobId);
    }
    
    //method to generate thumbnail images and to create content distribution for both images and thumbnails
    public void generateThumbnails(Id offeringId){
        
        try{
            List<Id> contentDocumentIds = new List<Id>();//variable to hold content document ids of current offering
            List<ContentDistribution> offeringContentDistributionData = new List<ContentDistribution>();
            Map<Id,Integer> imgSequenceByDocId = new Map<Id,Integer>();//**contains imageSequenceBycontentDocId
            Map<Id,Integer> imgSequenceByDistributionId = new Map<Id,Integer>();//**contains imageSequenceByContentDistributionId
            Map<Id,Id> resourceIdByDistributionId = new Map<Id,Id>();
             
            //query offering resources for the current offering and populate content document id's list
            for(PMP_Partner_Offering_Resource__c resource : [SELECT Id,PMP_Partner_Offering_Image__c,PMP_Resource_Sequence_Nbr__c FROM PMP_Partner_Offering_Resource__c
                                                             WHERE PMP_Offering_Id__c = :offeringId
                                                             AND PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.IMAGE]) {
                                                                 if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)) {
                                                                     contentDocumentIds.add(resource.PMP_Partner_Offering_Image__c);
                                                                     imgSequenceByDocId.put(Id.valueOf(resource.PMP_Partner_Offering_Image__c),Integer.valueOf(resource.PMP_Resource_Sequence_Nbr__c));
                                                                     resourceIdByDistributionId.put(resource.PMP_Partner_Offering_Image__c,resource.Id);
                                                                 }
                                                             }
            
            //contentDocumentIds list is not empty then query content distribution data using an utility method
            if(!contentDocumentIds.isEmpty()) {
                offeringContentDistributionData =  PMP_Utility.getContentDownloadUrlData(contentDocumentIds);
            }
            
            Map<Id,ContentDistribution> offeringContentDistributionDataById = new Map<Id,ContentDistribution>();
            Map<Id,Blob> thumbnailImageByContentId = new Map<Id,Blob>();
            HTTPResponse response = new HttpResponse();
            //iterate over content distribution data and make a call out to PIM to get auto resized url
            for(ContentDistribution content : offeringContentDistributionData) {
                //populating a map of content distribution by its ID
                offeringContentDistributionDataById.put(content.Id,content);
                imgSequenceByDistributionId.put(content.Id, imgSequenceByDocId.get(content.ContentDocumentId));//**populate imgSequenceByContentDistributionId
                response = PMP_CreateOfferingTab5Service.makeCalloutToPIM(content.ContentDownloadUrl,1);// make a call out to PIM
                
                //response is not null and 200 means its a success call , so create a thumbnail image
                if((response != null && response.getStatusCode() == 200)){
                    string responseValue = '';
                    responseValue = response.getBody();
                    //system.debug('Response Body for File: ' + responseValue);
                    
                    //get the response body as blob data
                    blob thumbNailImage = response.getBodyAsBlob();
                    thumbnailImageByContentId.put(content.Id,thumbNailImage);
                }else /*if(response == null)*/{ // if response is null means it failed 3 times in making callout
                    //create log entry record to retry again from batch process 
                    PMP_Utility.creatFailedCalloutLogEntryRecord(resourceIdByDistributionId.get(content.ContentDocumentId),'PMP_ImageResizeService','PMP','PMP_Partner_Offering_Resource__c');
                }
            }
            system.debug('###offeringContentDistributionDataById:->'+offeringContentDistributionDataById);
            system.debug('###thumbnailImageByContentId:->'+thumbnailImageByContentId);
            if(!thumbnailImageByContentId.keySet().isEmpty() || Test.isRunningTest()) {
                
                for(Id contentId : thumbnailImageByContentId.keySet()) {
                    system.debug('###contentId:->'+contentId);
                    if(offeringContentDistributionDataById != null && offeringContentDistributionDataById.containsKey(contentId)) {
                        ContentDistribution content = offeringContentDistributionDataById.get(contentId);
                        //insert a content version
                        ContentVersion newVersion = PMP_ImageResizeService.createContentVersion(content,thumbnailImageByContentId.get(contentId));
                        
                        //insert offering resource record with resource type as thumbnail
                        PMP_ImageResizeService.createThumbnailOfferingResource(newVersion,offeringId,imgSequenceByDistributionId.get(contentId));
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception while making PIM Resize callout:->'+ex);
            PMP_Utility.creatFailedCalloutLogEntryRecord(offeringId,'PMP_ImageResizeService','PMP','PMP_Partner_Offering__c');
        }
    }
}