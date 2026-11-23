global without sharing class PMP_SearchGenerateThumbnailImages implements Database.Batchable<sObject>, Database.AllowsCallouts {
    //start method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, name, CreatedDate, CreatedById from PMP_Company__c '+
                       ' Where CreatedById = \'' + System.Label.PMP_CreatedByIdFilter + '\''+
                       ' AND CreatedDate >= '+System.Label.PMP_CreatedDateFilter + 
                       ' AND CreatedDate <= '+System.Label.PMP_CreatedByDateEndFilter;
        system.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_Company__c> partners){
        for(PMP_Company__c partner : partners){
            generateThumbnails(partner.Id);
        }        
    }

    global void finish(Database.BatchableContext bc){
        Id jobId = bc.getJobId();
        System.debug('JobId----->'+jobId);
    } 

    public void generateThumbnails(Id sObjectId){
        
        try{
            List<Id> contentDocumentIds = new List<Id>();	//variable to hold content document ids of current offering
            List<ContentDistribution> ContentDistributionData = new List<ContentDistribution>();
            Map<Id,ContentDistribution> ContentDistributionDataById = new Map<Id,ContentDistribution>();
            Map<Id,Blob> thumbnailImageByContentId = new Map<Id,Blob>();
            List<PMP_Company_Resource__c> existingThumbnailPartnerResources = new List<PMP_Company_Resource__c>();
            HTTPResponse response;
            string object_type = sObjectId.getsobjecttype().getDescribe().getName();
            
			for(PMP_Company_Resource__c resource : [SELECT Id,PMP_Company_Image__c FROM PMP_Company_Resource__c WHERE PMP_Company_Id__c = :sObjectId AND PMP_Company_Resource_Type_Nm__c = :PMP_StaticConstants_Partner.THUMBNAIL_IMAGE]) {
                existingThumbnailPartnerResources.add(resource);
            }
            
            system.debug('existingThumbnailPartnerResources:->'+existingThumbnailPartnerResources);
			
            //query partner resources for the current partner and populate content document id's list
            for(PMP_Company_Resource__c resource : [SELECT Id,PMP_Company_Image__c FROM PMP_Company_Resource__c WHERE PMP_Company_Id__c = :sObjectId AND PMP_Company_Resource_Type_Nm__c = :PMP_StaticConstants_Partner.IMAGE]) {
                if(string.isNotBlank(resource.PMP_Company_Image__c)) {
                    contentDocumentIds.add(resource.PMP_Company_Image__c);
                }
            }            

            system.debug('contentDocumentIds => '+contentDocumentIds);	
            
            //contentDocumentIds list is not empty then query content distribution data using an utility method
            if(!contentDocumentIds.isEmpty()) {
                ContentDistributionData =  PMP_Utility.getContentDownloadUrlData(contentDocumentIds);
            }
            system.debug('ContentDistributionData => '+ContentDistributionData);
            
            //iterate over content distribution data and make a call out to PIM to get auto resized url
            for(ContentDistribution content : ContentDistributionData) {
                //populating a map of content distribution by its ID
                ContentDistributionDataById.put(content.Id,content);
                
                response = PMP_Image_Resizing.makeCalloutToPIM(content.ContentDownloadUrl,1);// make a call out to PIM
                
                if(response != null && response.getStatusCode() == 200){
                    string responseValue = '';
                    responseValue = response.getBody();
                    //system.debug('Response Body for File: ' + responseValue);
                    
                    //get the response body as blob data
                    blob thumbNailImage = response.getBodyAsBlob();
                    thumbnailImageByContentId.put(content.Id,thumbNailImage);
                }
            }
            system.debug('###ContentDistributionDataById:->'+ContentDistributionDataById);
            system.debug('###thumbnailImageByContentId:->'+thumbnailImageByContentId);
            
            List<ContentVersion> thumbnailContentVersions = new List<ContentVersion>();
            if(!thumbnailImageByContentId.keySet().isEmpty()) {
                for(Id contentId : thumbnailImageByContentId.keySet()) {
                    system.debug('###contentId:->'+contentId);
                    if(ContentDistributionDataById != null && ContentDistributionDataById.containsKey(contentId)) {
                        ContentDistribution content = ContentDistributionDataById.get(contentId);
                        //Create a content version instance
                        //ContentVersion newVersion = CreateContentVersionInstance(content,thumbnailImageByContentId.get(contentId));
                        ContentVersion newVersion = PMP_Image_Resizing.CreateContentVersionInstance(content,thumbnailImageByContentId.get(contentId));
                        system.debug('newVersion = '+newVersion);
                        thumbnailContentVersions.add(newVersion);
                        //insert company resource record with resource type as thumbnail
                        PMP_Image_Resizing.insertThumbnailCompanyResource(newVersion, sObjectId, object_type);
                    }
                }
            }
            //Delete existing offering records related to thumbnail , as we are inserting again those records above
            if(!existingThumbnailPartnerResources.isEmpty()){
            	delete existingThumbnailPartnerResources;
            }            
        }catch(Exception ex){
            system.debug('Exception while making PIM callout:->'+ex);
            throw ex;
        }
    }    
}