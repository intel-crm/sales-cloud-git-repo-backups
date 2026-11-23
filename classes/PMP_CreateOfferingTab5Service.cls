/**************************************************************************************
Apex Class Name : PMP_CreateOfferingTab5Service
Version     : 1.0 
Created Date: 07-01-2019
Modification Date : 29-11-2019
Description : Generate ThumbnailImages through Content Asset by replacing Content Distribution
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Prakash           07-01-2019        Created for processing/displaying tab5 elements in 'Create Offering'
* Sandhya           29/11/2019        Replaced Content Distribution logic with Content Asset.
*************************************************************************************/
@isTest
public without sharing class PMP_CreateOfferingTab5Service {
    
    //US982076-synchronous call
//     public static void generateThumbnailImagesSynchronously(Id offeringId) {
       
//         try{            
//             List<String> contentAssets = new List<String>();
//             Map<String,Integer> imgSequenceByContentAsset = new Map<String,Integer>();//**contains imageSequenceByAsset
//             //Variable to capture existing offering resource records related to thumbnail images
//             List<PMP_Partner_Offering_Resource__c> existingThumbnailOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
//             Map<Id,String> offeringResourceNameById = new Map<Id,String>();
//             String questionMarkSymbol = '?';           
//             String offeringName = '';
//             Id resourceId = null;
//             //List<PMP_Partner_Offering_Resource__c> partnerOffResourceList = new List<PMP_Partner_Offering_Resource__c>();
//             if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//                 List<PMP_Partner_Offering_Resource__c> partnerOffResourceList = [SELECT Id,PMP_Partner_Offering_Image__c,PMP_Offering_Id__c FROM PMP_Partner_Offering_Resource__c
//                                                                 WHERE PMP_Offering_Id__c = :offeringId
//                                                                 AND PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.THUMBNAIL_IMAGE];
                
            
//                 for(PMP_Partner_Offering_Resource__c resource : partnerOffResourceList) {
//                     existingThumbnailOfferingResources.add(resource);
//                 }

                 
//                 Map<String, String> resourceMap  = new Map<String, String>(); 
//                 List<ContentAsset> ca = new List<ContentAsset>();

//             //query offering resources for the current offering and add it to Map
//             for(PMP_Partner_Offering_Resource__c resource : [SELECT Id,Name,PMP_Partner_Offering_Image__c,PMP_Resource_Sequence_Nbr__c ,PMP_Offering_Id__r.Name
//                                                              FROM PMP_Partner_Offering_Resource__c
//                                                                WHERE PMP_Offering_Id__c = :offeringId
//                                                                 AND PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.IMAGE AND PMP_Resource_Sequence_Nbr__c =0]) {                                                                 
//               if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)) {
                
//                 ca = PMP_FetchAssetContent.getContentAsset(resource.PMP_Partner_Offering_Image__c);
//                 if(!ca.isEmpty()){
//                     for (ContentAsset ca1 : ca){
//                         resourceMap.put(ca1.ContentDocumentId, ca1.DeveloperName);
//                     }
//                 }  
                 
//                 offeringResourceNameById.put(resource.Id,resource.Name);

//                 String contentAssetName = '';
//                 if(resourceMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
//                     contentAssetName= resourceMap.get(resource.PMP_Partner_Offering_Image__c); 
//                 }else{
//                    contentAssetName = string.valueOf(resource.Id) +'_'+ string.valueOf(offeringId);
//                 }       
                
//                 offeringName = resource.PMP_Offering_Id__r.Name;
//                 resourceId = resource.Id;
//                 imgSequenceByContentAsset.put(contentAssetName,Integer.valueOf(resource.PMP_Resource_Sequence_Nbr__c));
//                 contentAssets.add(contentAssetName);
                  
//                 }
//             }

            
           
                     
//             Map<String,Blob> thumbnailImageByContentAsset = new Map<String,Blob>();
//             HTTPResponse response;
            
//             //fetch base community URL
//             String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
            
//             //remove '/s' from baseCommunityUrl community URL
//             if(baseCommunityUrl.endsWith('/s')){
//                 baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
//             }            
//             //fetch static text called "/file-asset" from metaData
//             String staticFileAsset = PMP_Utility.getValue('Community_File_Asset');            
            
//             //iterate over content asset data and make a call out to PIM to get auto resized url
//             for(String contentAsset : contentAssets) {
//                 //Send the string to PIM in the form of : communityURL/file-asset/AssetName? 
//                 String contentUrl = baseCommunityUrl+staticFileAsset+contentAsset+questionMarkSymbol;
//                 response = PMP_ImageResizeService.makeCalloutToPIM(contentUrl);// make a call out to PIM
//                 //response is not null and 200 means its a success call , so create a thumbnail image
//                 if(response != null && response.getStatusCode() == 200){
//                   //get the response body as blob data
//                     blob thumbNailImage = response.getBodyAsBlob();
//                     thumbnailImageByContentAsset.put(contentAsset,thumbNailImage);
//                 }else if(response != null && response.getStatusCode() == 400) { 
//                     //create log entry record to track the failed callouts 
//                     PMP_Utility.creatFailedCalloutLogEntryRecord(resourceId,'PMP_ImageResizeService','PMP','PMP_Partner_Offering_Resource__c','Failed',
//                                                                  response,offeringId,offeringName);
//                 }
//                 else if(response != null){
//                      //create log entry record to retry from batch 
//                     PMP_Utility.creatFailedCalloutLogEntryRecord(resourceId,'PMP_ImageResizeService','PMP','PMP_Partner_Offering_Resource__c','Investigating',
//                                                                  response,offeringId,offeringName);
//                 }
                
//             }          
            
//             if(!thumbnailImageByContentAsset.keySet().isEmpty()) {

//                 for(String contentAssetRec : thumbnailImageByContentAsset.keySet()) {
//                     // system.debug('###contentAssetRec:->'+contentAssetRec);
//                     //Split the asset id to get only the resourceImageId                   
//                     ContentVersion newVersion = PMP_ImageResizeService.createContentAssetVersion(offeringResourceNameById.get(resourceId),thumbnailImageByContentAsset.get(contentAssetRec));                   
//                     //insert offering resource record with resource type as thumbnail
//                     PMP_ImageResizeService.createThumbnailOfferingResource(newVersion,offeringId,imgSequenceByContentAsset.get(contentAssetRec));
                    
//                     //US982076-insert published offering thumbnail resource record if execution is not a batch context
//                     if(!System.isBatch()){
//                         createPublishedThumbnailOfferingResource(newVersion,offeringId);
//                     }
//                 }
//             }
            
//             //Delete existing offering records related to thumbnail , as we are inserting again those records above
//             if(!existingThumbnailOfferingResources.isEmpty()){
//                 delete existingThumbnailOfferingResources;
//             }
//             }
    
//         }catch(Exception ex){
//             //system.debug('Exception while making PIM Resize callout:->'+ex);
//             PMP_Utility.logError(ex,'PMP_Offering');
//         }
//     }

    
//     @future(callout=true)
//     public static void generateThumbnailImages(Id offeringId) {
//       generateThumbnailImagesSynchronously(offeringId);
//     }


 
// /**
//     * @description create offering resource with thumbnail image data in published copy[US982076]
//     * @param content - content version object information from working copy
//     * @param offeringId - offering id under which the offering resources to be created
//     * @return void
//     * Method Parameters -  ContentVersion, Id
//     */
//     public static void createPublishedThumbnailOfferingResource(ContentVersion content, Id offeringId){

//         List<PMP_Partner_Offering__c> publishedOffering = new List<PMP_Partner_Offering__c>();

//         //To fetch the Published offering Id using working Copy Id
//         if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
//             publishedOffering =[select Id, PMP_Working_Copy_Id__c from PMP_Partner_Offering__c 
//                                 where PMP_Working_Copy_Id__c =: offeringId];
//         }
//         if(publishedOffering.size() > 0){
        
//             //Creating new content version 
//             ContentVersion cv = new ContentVersion();
//             cv.Title  = content.Title;
//             cv.PathOnClient  = content.PathOnClient;
//             cv.VersionData = content.VersionData;
//             cv.NetworkId = content.NetworkId;  
//             cv.Origin = content.Origin;
//             insert cv;
        
//             //To get the content document Id
//             ContentVersion cvDetails = [Select Id ,ContentDocumentId,Title from ContentVersion where Id=:cv.Id Limit 1];
                            
//             //Creating new Thumbnail Resource Record for Published offering
//             PMP_Partner_Offering_Resource__c offeringResource = new PMP_Partner_Offering_Resource__c(); // offering resource instance
//             offeringResource.Name = content.Title.length()>80 ? content.Title.subString(0,80) : content.Title; // populating offering resource name
//             offeringResource.PMP_Resource_Type_Nm__c = PMP_StaticConstants_Offering.THUMBNAIL_IMAGE; // populating resource type
//             offeringResource.PMP_Offering_Id__c= publishedOffering[0].Id; // associating offering Id
//             offeringResource.PMP_Partner_Offering_Image__c = cvDetails.ContentDocumentId; // associating content document id
//             offeringResource.PMP_Resource_Sequence_Nbr__c = 0; // only 0 sequence image will have thumbnail resource record
            
//             if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable()){
//                 insert offeringResource; // insert offering resource
//             }              
//         }
//     }

}