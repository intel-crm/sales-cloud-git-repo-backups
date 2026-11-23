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
    global Database.QueryLocator start(Database.BatchableContext bc) {
      //  string query = 'select id, Name, PMP_Partner_Offering_Source_Id__c from PMP_Partner_Offering__c where PMP_Partner_Offering_Source_Id__c <> NULL';
     // string query = 'select id, Name, PMP_Partner_Offering_Source_Id__c from PMP_Partner_Offering__c where '+ PMP_Utility.getValue('Batch_Class_Offering_Thumbnail');
        String query=null;
        return Database.getQueryLocator(query);
    }
    
    //execute method
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering__c> offerings) {
        // //execute here
        // for(PMP_Partner_Offering__c offering : offerings){
        //      generateThumbnailImages(offering.Id);          
        // }
        
    }
    
    //finish method
    global void finish(Database.BatchableContext bc) {
        // Id jobId = bc.getJobId();
        // System.debug('JobId----->'+jobId);
    }
     
    //new method to generate thumbnail images and to create content asset and versions for the thumbnails
    public void generateThumbnailImages(Id offeringId) {
        // try {
        //     List<PMP_Partner_Offering_Resource__c> offeringResources = queryOfferingResources(offeringId);
        //     if (!offeringResources.isEmpty()) {
        //         processOfferingResource(offeringResources[0]);
        //     }
        // } catch (Exception ex) {
        //     handleException(ex);
        // }
    }

    private List<PMP_Partner_Offering_Resource__c> queryOfferingResources(Id offeringId) {
        // return [SELECT Id, PMP_Partner_Offering_Image__c, PMP_Offering_Id__c, PMP_Resource_Sequence_Nbr__c, PMP_Offering_Id__r.Name
        //         FROM PMP_Partner_Offering_Resource__c 
        //         WHERE PMP_Offering_Id__c = :offeringId
        //         AND PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.IMAGE
        //         LIMIT 1];
          return [SELECT Id FROM PMP_Partner_Offering_Resource__c LIMIT 1];
    }

    private void processOfferingResource(PMP_Partner_Offering_Resource__c offeringResource) {
        // if (String.isNotBlank(offeringResource.PMP_Partner_Offering_Image__c)) {
        //     String contentAssetName = fetchContentAssetName(offeringResource);
        //     HTTPResponse response = makeCalloutToPIM(contentAssetName);
        //     handleCalloutResponse(response, offeringResource);
        // }
    }

    private String fetchContentAssetName(PMP_Partner_Offering_Resource__c offeringResource) {
        // Map<String, String> resourceMap = new Map<String, String>();
        // List<ContentAsset> ca = PMP_FetchAssetContent.getContentAsset(offeringResource.PMP_Partner_Offering_Image__c);
        // if (!ca.isEmpty()) {
        //     for (ContentAsset ca1 : ca) {
        //         resourceMap.put(ca1.ContentDocumentId, ca1.DeveloperName);
        //     }
        // }
        // return resourceMap.containsKey(offeringResource.PMP_Partner_Offering_Image__c) 
        //     ? resourceMap.get(offeringResource.PMP_Partner_Offering_Image__c)
        //     : offeringResource.Id + '_' + offeringResource.PMP_Offering_Id__c;
        
               return 'SELECT Id FROM User LIMIT 1';

    }

    private HTTPResponse makeCalloutToPIM(String contentAssetName) {
        // String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
        // String staticFileAsset = PMP_Utility.getValue('Community_File_Asset');
        // String contentAssetURL = baseCommunityUrl + staticFileAsset + contentAssetName + '?';
        // return PMP_ImageResizeService.makeCalloutToPIM(contentAssetURL);
        return null;
    }

    private void handleCalloutResponse(HTTPResponse response, PMP_Partner_Offering_Resource__c offeringResource) {
        // if (response != null) {
        //     String offeringName = offeringResource.PMP_Offering_Id__r.Name;
        //     Id resourceId = offeringResource.Id;
        //     if (response.getStatusCode() == 200) {
        //         Blob thumbNailImage = response.getBodyAsBlob();
        //         ContentVersion newVersion = PMP_ImageResizeService.createContentAssetVersion(offeringResource.PMP_Partner_Offering_Image__c, thumbNailImage);
        //         PMP_ImageResizeService.createThumbnailOfferingResource(newVersion, offeringResource.PMP_Offering_Id__c, Integer.valueOf(offeringResource.PMP_Resource_Sequence_Nbr__c));
        //     } else {
        //         String logType = response.getStatusCode() == 400 ? 'Failed' : 'Investigating';
        //         PMP_Utility.creatFailedCalloutLogEntryRecord(resourceId, 'PMP_ImageResizeService', 'PMP', 'PMP_Partner_Offering_Resource__c', logType, response, offeringResource.PMP_Offering_Id__c, offeringName);
        //     }
        // }
    }

    private void handleException(Exception ex) {
        // System.debug('Exception while making PIM Resize callout:->' + ex);
        // PMP_Utility.logError(ex, 'PMP_Offering_Thumbnail');
    }

}