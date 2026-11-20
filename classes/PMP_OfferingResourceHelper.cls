@isTest
/****************************************************************************************************************************************
* Class Name  : PMP_OfferingResourceHelper
* Version     : 1.0 
* Created Date: 06-20-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Raj                   06-20-2019                    Created for Creating Offering resource records
****************************************************************************************************************************************************************/
public without sharing class PMP_OfferingResourceHelper extends PMP_SearchWrapperStore { 
    
//     /**
//     * Method added by raj to create OfferingResource records
//     * @description-create offering resource records 
//     * @param formData the data entered by user on create offering form
//     * @param offeringId the Id of the offering
//     * @return void
//     * Method Parameters - Intel_FormData
//     * Method Parameters - Id
//     */
//     public static void createOfferingResource(Intel_FormData formData, id offeringId){
        
//         List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();//list of offeringResources which are to be inserted
//         List<PMP_Partner_Offering_Resource__c> delOfferingResources = new List<PMP_Partner_Offering_Resource__c>();//list of offeringResources which are to be deleted
//         List<PMP_Partner_Offering_Resource__c> galleryResources = new List<PMP_Partner_Offering_Resource__c>();//list of offeringResources which are to be inserted
        
//         PMP_Partner_Offering_Resource__c offeringResource;
//         List<Id> linkIds = new List<Id>();
//         //List<ContentDocument> contentDoc= new List<ContentDocument>();
        
//         //List of non additional resource type values -For handling additonal resources we have seperate methods in this class
//         List<String> nonAdditionalResTypes =  PMP_Utility.getValue('Non_Additional_Offering_Reource_Types').split(';');
//         Integer imageOrder=0;
        
//         //Implement sequencing to the Product web page and Additional Resources :
//         Integer prodWebPageSequence = 0;
//         //get the list fo additional resource document ids into below list
//         List<Id> imageDocIdsAddedInAdditionalRes=new List<Id>();
             
        
//         //fetch the existing offering resources records
//         List<PMP_Partner_Offering_Resource__c> existingOfferingResources=PMP_CreateOfferingTab4Service.getOfferingResources(offeringId);
        
//         for(PMP_Partner_Offering_Resource__c res : existingOfferingResources){
//             //filtering and getting only the Image,Thumbnail Image and Web page records - additional resources are handled seperately
//             if(nonAdditionalResTypes.contains(res.PMP_Resource_Type_Nm__c)){
//                 delOfferingResources.add(res);
//             }  
//             else{ //list all additional resources document ids
//                imageDocIdsAddedInAdditionalRes.add(res.PMP_Partner_Offering_Image__c);
//             }
//         }
        
//         //setting the savepoint to protect the existing records in case of exception 
//         Savepoint sp = Database.setSavepoint();
        
//                   //for product web page related information
//                   if(formData.productWebPageData!=null && String.isNotBlank(formData.productWebPageData.Name) && String.isNotBlank(formData.productWebPageData.Url)) {
//                     //create offering resource record for type Product Web Page
//                     offeringResource = new PMP_Partner_Offering_Resource__c();
//                     offeringResource.PMP_Offering_Id__c = offeringId;
//                     offeringResource.Name = formData.productWebPageData.Name; 
//                     offeringResource.PMP_Partner_Offering_Resource_URL_Txt__c = formData.productWebPageData.Url;
//                     offeringResource.PMP_Resource_Type_Nm__c = 'URL'; // TODO : Need to move to custom labels if this text displays in UI
//                     offeringResource.PMP_Resource_Sequence_Nbr__c = prodWebPageSequence;
//                     addOfferingResources.add(offeringResource);
//                   }
//                   for(PMP_SearchWrapperStore.OfferingResourceWrapper orw:formData.galleryWrapperList){
//                       if(orw.Id != '' && orw.Id!=null){
//                         offeringResource = new PMP_Partner_Offering_Resource__c();
//                         offeringResource.Id = orw.Id;
//                         offeringResource.Name = orw.title;
//                         offeringResource.PMP_Alt_Text__c = orw.altText;
//                         offeringResource.PMP_Resource_Description_Txt__c = orw.description;
//                         galleryResources.add(offeringResource);
//                       }
//                   }
//                   update galleryResources;
//                   List<ContentDocumentLink> links;
//                   //Added by raj to add images to offering resources object for US357476
                  
//                   List<String> acceptableImageFormats = new List<String>{'PNG', 'GIF', 'JPG', 'JPEG'};//Adding so that only image can be considered to create at next
//                   links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink where  ContentDocument.FileType IN:acceptableImageFormats AND LinkedEntityId = :offeringId];//to fetch records related to the offering
                  
             
//                   if(!links.isEmpty()){
//                       for (ContentDocumentLink l : links) {//add contentDocumentId of the fetched record to a list
//                           //dont consider images added under additional resources for offering logo creation
//                           if(!imageDocIdsAddedInAdditionalRes.Contains(l.ContentDocumentId)){ //exclude additional resources image document ids
//                              linkIds.add(l.ContentDocumentId);
//                           }
//                       }
//                       //Added By Pranjal : TWC4497-41  start
//                        Map<String,String> conDocToAltTextMap = new Map<String,String>();
//                        for(MarketplaceImageUploader.ImageWrapper imgwrap:formData.imgWrapper){
//                         conDocToAltTextMap.put(imgwrap.Id,imgwrap.altText);
//                        }
//                        //Added By Pranjal : TWC4497-41 Ends
//                       //Content document with file type PDF should be filtered out as these documents are uploaded under additonal resources not Image resource type.
//                       for(ContentDocument cd:[SELECT Id, Title, CreatedDate,FileType FROM ContentDocument 
//                                               WHERE Id IN :linkIds AND FileType != :PMP_StaticConstants_Offering.PDF ORDER BY CreatedDate]){//fetch all contentdocument record for all the Ids in the list 
//                           //creating offering resources record for type image
//                                 offeringResource = new PMP_Partner_Offering_Resource__c();
//                                 offeringResource.PMP_Offering_Id__c = offeringId;                                                 
//                                 offeringResource.Name = cd.Title.length()>80 ? cd.Title.subString(0,80) : cd.Title;
//                                 offeringResource.PMP_Resource_Type_Nm__c ='Image';
//                                 offeringResource.PMP_Partner_Offering_Image__c=cd.Id;
//                                 offeringResource.PMP_Alt_Text__c = conDocToAltTextMap.get(cd.Id);//Added By Pranjal : TWC4497-41 
//                                 offeringResource.PMP_Resource_Sequence_Nbr__c=imageOrder;
//                                 addOfferingResources.add(offeringResource);
//                                 imageOrder++;
//                       }
//                   }    
//           /*----------------------------End US357476----------------------------------------*/
//             try{
                  
//                 if(!delOfferingResources.isEmpty()){//deleting already existing OfferingResource if any record exists
//                     delete delOfferingResources;
//                 }   
                
//                 if(!addOfferingResources.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable()) {//insert offeringResource records if present
//                     insert addOfferingResources;
//                 }
                
//             }
//             catch(Exception e){
//                   Database.rollback(sp);//rollback to the save point if there is any error while inserting or deleting
//                   //system.debug(e.getMessage()+e.getLineNumber());
//                   throw e;
//                 }
//       }
    
//     /**
//     * Method added by raj to fetch productwebpage data from offering resources records
//     * @description- fetch productwebpage data from offering resources record
//     * @param offeringId the Id of the offering
//     * @return Intel_ProductWebPageDataWrapper
//     * Method Parameters - Id
//     */
//     public static Intel_ProductWebPageDataWrapper getProductWebPageData(Id offeringId){
        
//         Intel_ProductWebPageDataWrapper webPageData = new Intel_ProductWebPageDataWrapper();
        
//         if(offeringId != null && string.isNotBlank(offeringId)){
//             List<PMP_Partner_Offering_Resource__c> offeringResources = PMP_CreateOfferingTab4Service.getOfferingResources(offeringId);
//             for(PMP_Partner_Offering_Resource__c resource : offeringResources){
//                 if(resource.PMP_Resource_Type_Nm__c == 'URL'){
//                    webPageData.Name =  resource.Name;
//                    webPageData.Url = resource.PMP_Partner_Offering_Resource_URL_Txt__c;
//                 }
//             }
//         }
//         return webPageData;
//     }
//     /**
//     * Method added by raj to fetch additional resources data from offering resources records
//     * @description- fetch additional resources data from offering resources record
//     * @param offeringId the Id of the offering
//     * @return List<PMP_Partner_Offering_Resource__c>
//     * Method Parameters - Id
//     */
//     public static List<PMP_Partner_Offering_Resource__c> getAdditionalResources(Id offeringId){
        
//         List<PMP_Partner_Offering_Resource__c> additionalResources = new List<PMP_Partner_Offering_Resource__c>();//additional resources list
        
//         if(offeringId != null && string.isNotBlank(offeringId)){
//             List<PMP_Partner_Offering_Resource__c> offeringResources = PMP_CreateOfferingTab4Service.getOfferingResources(offeringId);//fetch all the offering resources related to that offering
//             for(PMP_Partner_Offering_Resource__c resource : offeringResources){
//                 if(resource.PMP_Resource_Type_Nm__c != 'URL' && resource.PMP_Resource_Type_Nm__c != 'Image'//resource type other than Image,Thumbnail Image and Product Web Page are additional resources 
//                    && resource.PMP_Resource_Type_Nm__c != 'Thumbnail Image'){
//                     additionalResources.add(resource);
//                 }
//             }
//         }
//         return additionalResources;
//     }
    
    
//     //METHODS FOR NEW ADDITIONALS RESOURCES START
//     /**
//     * Method added by sooriya 
//     * @description-to get additional Offering Resource records in the form of wrapper to display in LWC component
//     * @param offeringId the Id of the offering
//     * @return List of OfferingResourceWrapper
//     * This method is used in ipaOfferingResourceService LWC component
//     */
     
//     @AuraEnabled
//     public static List<OfferingResourceWrapper> getResources(Id offeringId){
        
//         List<OfferingResourceWrapper> additionalResources = new List<OfferingResourceWrapper>();//offering resource wrapper list
//         List<Id> contentDocIds = New List<Id>();
//         Map<Id,ContentDocument> contentDocMap = New Map<Id,ContentDocument>();
//         List<PMP_Partner_Offering_Resource__c> offeringResources = New List<PMP_Partner_Offering_Resource__c>();
//         Map<String, String> resourceMap  = new Map<String, String>();

//         //List of non additional resource type values
//         List<String> nonAdditionalResTypes =  PMP_Utility.getValue('Non_Additional_Offering_Reource_Types').split(';');
        
//         //fetch base community URL
//         String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
            
//         //remove '/s' from baseCommunityUrl community URL
//         if(baseCommunityUrl.endsWith('/s')){
//             baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
//         }            
//         //fetch static text called "/file-asset" from metaData
//         String staticFileAsset = PMP_Utility.getValue('Community_File_Asset'); 
        
//         if(string.isNotBlank(offeringId)){
//             //getting only the additonal resource records
//             if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//                 offeringResources = [SELECT id,name,PMP_Resource_Type_Nm__c,PMP_File_Size_Txt__c,PMP_Video_Title_Txt__c,PMP_BrightCove_Video_Extension_Txt__c, PMP_External_Source_Id__c, PMP_Partner_Offering_Resource_URL_Txt__c,
//                                      PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c,PMP_Offering_Id__c,PMP_Alt_Text__c,PMP_BrightCoveVideoThumbnail_URL__c,LastModifiedDate,PMP_Offering_Gallery_Video_Ind__c,PMP_BrightCoveVideoAccountID__c,PMP_BrightCoveVideoId__c 
//                                      FROM PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c =: offeringId 
//                                      AND PMP_Offering_Gallery_Video_Ind__c = false AND PMP_Delete_BrightCove_Video_Ind__c=false
//                                      AND PMP_Resource_Type_Nm__c NOT IN :nonAdditionalResTypes];
//             }
            
//             //Iterating over the list of additonal resource records to get the content document Ids
//             for(PMP_Partner_Offering_Resource__c resource : offeringResources){
//                 if(String.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
//                     //storing the content document Ids in list
//                     contentDocIds.add(resource.PMP_Partner_Offering_Image__c);
//                 }
//             }
            
//             if(!contentDocIds.isEmpty()){
//                 //Fetch the content document details for the Ids in contentDocIds list to get file size, file type and title
//                 List<ContentDocument> cdList = getContentDocList(contentDocIds);
//                 for(ContentDocument cd : cdList){
//                     //populating a map with key as contentDoc Id and value as contentdocument
//                     contentDocMap.put(cd.Id, cd);
//                 }

//                 List<ContentAsset> ca = new List<ContentAsset>();
//                 ca = PMP_FetchAssetContent.getContentAsset(contentDocIds);
            
//                 if(!ca.isEmpty()){
//                     for (ContentAsset ca1 : ca){
//                         resourceMap.put(ca1.ContentDocumentId, ca1.DeveloperName);
//                     }
//                 }
//             }

            
            
            
            
            
//             //Iterating over the additional resources List to frame the return wrapper
//             for(PMP_Partner_Offering_Resource__c resource : offeringResources){
//                     //Framing the offering resource wrapper
//                     OfferingResourceWrapper resourceWrapper = New OfferingResourceWrapper();
//                     resourceWrapper.id = resource.Id;
//                     resourceWrapper.externalId = resource.PMP_External_Source_Id__c;
//                     resourceWrapper.title = resource.name;
//                     resourceWrapper.resourceType = resource.PMP_Resource_Type_Nm__c;
//                     resourceWrapper.url = String.IsNotBlank(resource.PMP_Partner_Offering_Resource_URL_Txt__c) ? resource.PMP_Partner_Offering_Resource_URL_Txt__c : '';
//                     resourceWrapper.description = String.IsNotBlank(resource.PMP_Resource_Description_Txt__c) ? resource.PMP_Resource_Description_Txt__c : '';
//                     resourceWrapper.publishDate = resource.LastModifiedDate.format('MMM dd, yyyy');
//                     resourceWrapper.altText = resource.PMP_Alt_Text__c;
//                     if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && resource.PMP_Offering_Gallery_Video_Ind__c==false){
//                         VideoTypeWrapper videoWrapper = new VideoTypeWrapper();
//                         videoWrapper.accountId = resource.PMP_BrightCoveVideoAccountID__c;
//                         videoWrapper.thumbnailUrl = String.IsNotBlank(resource.PMP_BrightCoveVideoThumbnail_URL__c)?resource.PMP_BrightCoveVideoThumbnail_URL__c:'' ;
//                         videoWrapper.videoId = resource.PMP_BrightCoveVideoId__c;
//                         videoWrapper.videoType =  PMP_StaticConstants_Offering.BRIGHTCOVE;
//                         resourceWrapper.videoThumbnail = String.IsNotBlank(resource.PMP_BrightCoveVideoThumbnail_URL__c)?resource.PMP_BrightCoveVideoThumbnail_URL__c:'' ;
//                         resourceWrapper.videoType = videoWrapper;
//                         resourceWrapper.fileSize = resource.PMP_File_Size_Txt__c;
//                         String filetype = resource.PMP_BrightCove_Video_Extension_Txt__c;
//                         if(filetype!=null && filetype.length()>0){
//                             filetype = filetype.substring(1);
//                             filetype = filetype.toUpperCase();
//                         }
//                         resourceWrapper.fileType = filetype;
//                         resourceWrapper.fileExt = resource.PMP_BrightCove_Video_Extension_Txt__c;
//                         resourceWrapper.uploadName = resource.PMP_Video_Title_Txt__c;
//                         resourceWrapper.uploadId = resource.PMP_Partner_Offering_Image__c;
//                     }
//                     if(String.isNotBlank(resource.PMP_Partner_Offering_Image__c) && contentDocMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
//                         resourceWrapper.uploadId = resource.PMP_Partner_Offering_Image__c;
//                         resourceWrapper.fileType = contentDocMap.get(resource.PMP_Partner_Offering_Image__c).FileType;
//                         //using the utility method to frame the filesize into KB,MB or GB as the filesize from content document record will be in bytes without suffix as bytes,KB,MB or GB
//                          resourceWrapper.fileSize = PMP_Utility.FileSizeToString(contentDocMap.get(resource.PMP_Partner_Offering_Image__c).ContentSize);
//                         //framing the download url with community url+'file-asset/'+contentasset developer name(resourceId_offeringId)
//                         if(resource.PMP_Resource_Type_Nm__c != PMP_StaticConstants_Offering.VIDEO){
//                             if(resourceMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
//                                 resourceWrapper.downloadUrl = baseCommunityUrl + staticFileAsset + resourceMap.get(resource.PMP_Partner_Offering_Image__c);    
//                             }else{
//                             resourceWrapper.downloadUrl = baseCommunityUrl + staticFileAsset + string.valueOf(resource.Id) +'_'+ string.valueOf(offeringId);
//                             }
//                         }
//                         resourceWrapper.uploadName = contentDocMap.get(resource.PMP_Partner_Offering_Image__c).Title;
//                     }
//                     additionalResources.add(resourceWrapper);
//             }
//         }
//         return additionalResources;
//     }
    
//     /**
//     * Method added by sooriya 
//     * @description-create/update offering additional resource records 
//     * @param resourceData- the data entered by user on manager resources pop up modal
//     * @param offeringId - the Id of the offering
//     * @return void
//     * This method is used in ipaOfferingResourceService LWC component
//     */
    
//     @AuraEnabled
//     public static void saveResources(Id offeringId, List<OfferingResourceWrapper> resourceData){
//         try{
//             //Sequence for additional resource should start with 1 as the web page record sequence will be 0
//             Integer additionalResSequence = 1;
//             List<PMP_Partner_Offering_Resource__c> updatedResourceList = New List<PMP_Partner_Offering_Resource__c>();
//             Set<String> setCondocId = new Set<String>();
//             for(OfferingResourceWrapper resData : resourceData){
//                 if(resData.resourceType==PMP_StaticConstants_Offering.VIDEO && (resData.url=='' || resData.url==null)){
//                     setCondocId.add(resData.uploadId);
//                 }
//             }
//             Map<Id,ContentDocument> mapContentDocument = new Map<Id,ContentDocument>([SELECT Id,ContentSize FROM ContentDocument WHERE Id IN: setCondocId]);
//             for(OfferingResourceWrapper resData : resourceData){
//                 PMP_Partner_Offering_Resource__c resource = New PMP_Partner_Offering_Resource__c();
//                 resource.name = resData.title;
//                 if(String.IsNotBlank(resData.id)){
//                     resource.id = resData.id;   //If existing resource record, then resource id is passed from input data
//                 }
//                 resource.PMP_Resource_Type_Nm__c = resData.resourceType;
//                 resource.PMP_Partner_Offering_Resource_URL_Txt__c = resData.url;
//                 resource.PMP_Resource_Sequence_Nbr__c = additionalResSequence;
//                 resource.PMP_Partner_Offering_Image__c = String.isNotBlank(resData.uploadId) ? resData.uploadId : '';
//                 resource.PMP_Resource_Description_Txt__c = String.isNotBlank(resData.description) ? resData.description : '';
//                 if(resource.PMP_Resource_Type_Nm__c==PMP_StaticConstants_Offering.VIDEO && (resData.url=='' || resData.url==null)){
//                     resource.PMP_BrightCove_Video_Extension_Txt__c = resData.fileExt;
//                     resource.PMP_BrightCoveVideoAccountID__c = '6298977448001';
//                     resource.PMP_File_Size_Txt__c = PMP_Utility.FileSizeToString(mapContentDocument.get(resData.uploadId).ContentSize);
//                 }
//                 if(String.IsBlank(resData.id)){
//                     resource.PMP_Offering_Id__c = offeringId; //If new resource record,then offering Id is passed
//                 }
//                 resource.PMP_Alt_Text__c = resData.altText;
//                 updatedResourceList.add(resource);
//                 //Incrementing the sequence number
//                 additionalResSequence ++;
//             }
            
//             //upsert is performed as the input resource data may contain new and updated records
//             if(!updatedResourceList.IsEmpty()){
//                 upsert updatedResourceList;
//             }
//         }
//         catch(Exception e){
//             PMP_Utility.logError(e,'PMP_OfferingResourceHelper');
//         }
//     }
    
//     /**
//     * Method added by sooriya 
//     * @description-delete offering resource records 
//     * @param deleteIds - List of resource Id's to be deleted
//     * @return void
//     * This method is used in ipaOfferingResourceService LWC component
//     */
    
//     @AuraEnabled
//     public static void deleteResources(List<String> deleteResourceIds){

//         List<PMP_Partner_Offering_Resource__c> offeringResList = New List<PMP_Partner_Offering_Resource__c>();
//         List<PMP_Partner_Offering_Resource__c> toDeleteList = New List<PMP_Partner_Offering_Resource__c>();
//         List<PMP_Partner_Offering_Resource__c> toUpdateList = New List<PMP_Partner_Offering_Resource__c>();
//         //getting the list of resource records which needs to be deleted by filtering using the input Ids
//         if(!deleteResourceIds.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//             offeringResList = [select id,PMP_Resource_Type_Nm__c,PMP_Partner_Offering_Resource_URL_Txt__c,PMP_Delete_BrightCove_Video_Ind__c,PMP_Partner_Offering_Image__c,PMP_Offering_Id__c from PMP_Partner_Offering_Resource__c where Id IN : deleteResourceIds];
//         }
//         for(PMP_Partner_Offering_Resource__c resData: offeringResList){
//             if(resData.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && (resData.PMP_Partner_Offering_Resource_URL_Txt__c=='' || resData.PMP_Partner_Offering_Resource_URL_Txt__c==null)){
//                 resData.PMP_Delete_BrightCove_Video_Ind__c = true;
//                 toUpdateList.add(resData);
//             }
//             else{
//                 toDeleteList.add(resData);
//             }
//         }
       
//         if(!toDeleteList.IsEmpty()){
//             delete toDeleteList;
//         }
//         if(!toUpdateList.IsEmpty()){
//             update toUpdateList;
//         }
//     }
    
//     /**
//     * Method added by sooriya 
//     * @description-delete uploaded content documents 
//     * @param deleteFileIds - List of content document Id's to be deleted
//     * @return void
//     * This method is used in ipaOfferingResourceService LWC component
//     */
    
//     @AuraEnabled
//     public static Void deleteResourcesFiles(List<String> deleteFileIds, List<Map<String,String>> idToUploadsId){
//         List<PMP_Partner_Offering_Resource__c> checkResource = new List<PMP_Partner_Offering_Resource__c>();
//         List<PMP_Partner_Offering_Resource__c> toDeletePORList = new List<PMP_Partner_Offering_Resource__c>();
//         List<ContentDocument> toDeleteList = New List<ContentDocument>();
//         List<ContentDocumentLink> cdlListToDelete = New List<ContentDocumentLink>();
//         Map<String, String> mapIdstoUploadIds = new Map<String, String>();
//         for(map<string,String> idToUploadId : idToUploadsId) {
//             mapIdstoUploadIds.put(idToUploadId.get('value'), idToUploadId.get('key'));
//         }

//         Set<String> deleteFileIds2  = new Set<String>();
//         Set<String> deleteFileldIdNew  = new Set<String>();
//         Set<String> offeringIds  = new Set<String>();

//         deleteFileIds2.addAll(deleteFileIds);
        
//         if(!deleteFileIds2.IsEmpty()){
//             checkResource = [ Select id,PMP_Partner_Offering_Image__c,PMP_Resource_Type_Nm__c,PMP_Partner_Offering_Resource_URL_Txt__c,PMP_Delete_BrightCove_Video_Ind__c,PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,
//                                                 PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c,PMP_Offering_Id__c from PMP_Partner_Offering_Resource__c 
//                                                 where PMP_Partner_Offering_Image__c =: deleteFileIds2 ];
                                                
//             if(!checkResource.ISEmpty()){
//                 for(PMP_Partner_Offering_Resource__c offRes : checkResource){
//                     offeringIds.add(offRes.PMP_Offering_Id__c);
//                 }
//                 List <ContentDocumentLink> cdlList = [SELECT id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:offeringIds];
//                 Map<string,String> cdTocdlMap = new Map<string,String>();
//                 for(ContentDocumentLink cdl : cdlList){
//                     cdTocdlMap.put(cdl.ContentDocumentId,cdl.id);
//                 }
//                 Map<string,List<PMP_Partner_Offering_Resource__c>> cdtoPORMap = new Map<string,List<PMP_Partner_Offering_Resource__c>>();
//                 for(PMP_Partner_Offering_Resource__c por : checkResource){
//                     if(cdtoPORMap.get(por.PMP_Partner_Offering_Image__c)==null){
//                         cdtoPORMap.put(por.PMP_Partner_Offering_Image__c,new List<PMP_Partner_Offering_Resource__c>{por});
//                     }
//                     else{
//                         List<PMP_Partner_Offering_Resource__c> oldList = cdtoPORMap.get(por.PMP_Partner_Offering_Image__c);
//                         oldList.add(por);
//                         cdtoPORMap.put(por.PMP_Partner_Offering_Image__c,oldList);
//                     }
//                 }
//                 for(PMP_Partner_Offering_Resource__c offRes : checkResource){
//                     if(offRes.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && offRes.id == mapIdstoUploadIds.get(offRes.PMP_Partner_Offering_Image__c) && offRes.PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c != 'Published'  && (offRes.PMP_Partner_Offering_Resource_URL_Txt__c=='' || offRes.PMP_Partner_Offering_Resource_URL_Txt__c==null)){
//                         offRes.PMP_Delete_BrightCove_Video_Ind__c=true;
//                             toDeletePORList.add(offRes);
//                     }
//                     if(cdtoPORMap.get(offRes.PMP_Partner_Offering_Image__c).size()>2 && offRes.PMP_Partner_Offering_Image__c!=''&&  offRes.id == mapIdstoUploadIds.get(offRes.PMP_Partner_Offering_Image__c) && (offRes.PMP_Partner_Offering_Resource_URL_Txt__c=='' || offRes.PMP_Partner_Offering_Resource_URL_Txt__c==null)){
//                         //if(offRes.PMP_Partner_Offering_Image__c!=''&&  offRes.id == mapIdstoUploadIds.get(offRes.PMP_Partner_Offering_Image__c) && (offRes.PMP_Partner_Offering_Resource_URL_Txt__c=='' || offRes.PMP_Partner_Offering_Resource_URL_Txt__c==null)){
//                             cdlListToDelete.add(new ContentDocumentLink(Id = cdTocdlMap.get(offRes.PMP_Partner_Offering_Image__c)));
//                         //}
//                     }
//                 }
//                 update toDeletePORList;
//                 if(!cdlListToDelete.IsEmpty()){
//                     delete cdlListToDelete;
//                 }
//                 for (PMP_Partner_Offering_Resource__c offRes : checkResource){
//                     if ((offRes.PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c == false && 
//                         offRes.PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Published')){
//                             deleteFileldIdNew.add(String.valueOf(offRes.PMP_Partner_Offering_Image__c));    
//                     }  
//                 }
//                 deleteFileIds2.removeAll(deleteFileldIdNew);
//                 if(!deleteFileIds2.IsEmpty()){     
//                     List<String> newIdList = new List<String>(deleteFileIds2);
//                     deleteFileldIdNew  = new Set<String>();

//                     for (integer i = 0; i < newIdList.size(); i++ ){
//                         integer workingCpyCount = 0;
                        
//                         for (PMP_Partner_Offering_Resource__c offRes : checkResource){
//                             if(offRes.PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c != 'Published' &&  offRes.PMP_Partner_Offering_Image__c == newIdList[i]){
//                                 workingCpyCount++;
//                             }

//                             if(workingCpyCount>=1){
//                                 deleteFileldIdNew.add(String.valueOf(offRes.PMP_Partner_Offering_Image__c)); 
//                             }
//                         }
//                     }

//                     deleteFileIds2.removeAll(deleteFileldIdNew);
//                 }
//             } 
//             //getting the list of content documents which needs to be deleted by filtering using the input Ids
//             toDeleteList = [select id from ContentDocument where Id IN : deleteFileIds2];
//         }
        
//         if(!toDeleteList.IsEmpty()){
//             delete toDeleteList;
//         }
//     }
    
//     /**
//     * Method added by sooriya 
//     * @description - get the additional resource types picklist options
//     * @return - List of OfferingResourceType wrapper which holds the label and values of resource types
//     * This method is used in ipaOfferingResourceService LWC component
//     */
    
//     @AuraEnabled
//     public static List<OfferingResourceType> getAdditionalResourceTypes(){
//         List<OfferingResourceType> resourceTypesList = New List<OfferingResourceType>();
//         //List of picklist values which are restricted in additonal resource section picklist dropdown
//         List<String> restrictedValues =  PMP_Utility.getValue('Restricted_Additional_Resource_Types').split(';');
        
//         Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('PMP_Partner_Offering_Resource__c').getDescribe().fields.getMap().get('PMP_Resource_Type_Nm__c').getDescribe();
//         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
//         for (Schema.PicklistEntry pickListVal : ple){
//           //filtering out the restricted picklist values
//           if(!restrictedValues.contains(pickListVal.getValue()) ){ 
//               OfferingResourceType resType = New OfferingResourceType();
//               resType.label = pickListVal.getLabel();
//               resType.value = pickListVal.getValue();
//               resourceTypesList.add(resType);
//           }
//         }
//         return resourceTypesList;
//     }
    
//    /**
//     * Method added by sooriya 
//     * @description - to get the list of content document records using the content document Ids
//     * @return - List of ContentDocument records
//     * This method is used as Utility method in this class and PMP_OfferingDetailsController
//     */ 
//    public static List<ContentDocument> getContentDocList(List<Id> contentDocIds){
//         List<ContentDocument> cdList = New List<ContentDocument>();
//         cdList = [select id,FileType, ContentSize,Title from ContentDocument  where Id in :contentDocIds];
        
//         return cdList;
//     }
    
//     //METHODS FOR NEW ADDITIONALS RESOURCES END
//       @AuraEnabled
//     public static Integer getContentDocSize(Id contentDocId){
//         Map<Id,ContentDocument> contentDocMap = New Map<Id,ContentDocument>();
//         List<String> contentDocIds = new List<String>();
//         contentDocIds.add(contentDocId);
//         List<ContentDocument> cdList = getContentDocList(contentDocIds);
//         for(ContentDocument cd : cdList){
//             contentDocMap.put(cd.Id, cd);
//         }
//         return contentDocMap.get(contentDocId).ContentSize/1024;
//     }
//       /**
//     * Method added by Pranjal 
//     * @description-Validation of Video
//     * @param contentDocId- Id of content document
//     * @param offeringId - the Id of the offering
//     * @return Map
//     * This method is used in ipaOfferinguploadVideo LWC component
//     */
//     @AuraEnabled
//     public static Map<String,String> validateVideo(Id offeringId, Id contentDocId){
//         try{
//             Map<String,String> output = new Map<String,String>();
//             output.put('contentDocSize',String.valueOf(getContentDocSize(contentDocId)));
//             output.put('imageCount',String.valueOf(getGalleryImagesCount(offeringId)));
//            return output;
//         }
//         catch(Exception e){
//             PMP_Utility.logError(e,'PMP_OfferingResourceHelper');
//             return null;
//         }
//     }
//       /**
//     * Method added by Pranjal 
//     * @description-create/update Video
//     * @param GalleryVideo- the data entered by user on manager resources pop up modal
//     * @param offeringId - the Id of the offering
//     * @return void
//     * This method is used in ipaOfferinguploadVideo LWC component
//     */
    
//     @AuraEnabled
//     public static String saveGalleryVideo(Id offeringId, OfferingResourceWrapper galleryVideo){
//         try{
//             list<aggregateResult> aggResults = [Select max(PMP_Resource_Sequence_Nbr__c) maxseq FROM PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c =: offeringId];
//             Integer additionalResSequence =  Integer.valueOf(aggResults[0].get('maxseq'));
//             PMP_Partner_Offering_Resource__c resource = New PMP_Partner_Offering_Resource__c();
//             resource.name = galleryVideo.title;
//             resource.PMP_Resource_Type_Nm__c = PMP_StaticConstants_Offering.VIDEO;
//             resource.PMP_BrightCoveVideoAccountID__c = '6298977448001';
//             resource.PMP_Resource_Sequence_Nbr__c = additionalResSequence;
//             resource.PMP_Partner_Offering_Image__c = String.isNotBlank(galleryVideo.uploadId) ? galleryVideo.uploadId : '';
//             resource.PMP_Resource_Description_Txt__c = String.isNotBlank(galleryVideo.description) ? galleryVideo.description : '';
//             resource.PMP_Offering_Id__c = offeringId; //If new resource record,then offering Id is passed
//             resource.PMP_Alt_Text__c = galleryVideo.altText;
//             resource.PMP_Offering_Gallery_Video_Ind__c = true;
//             resource.PMP_BrightCove_Video_Extension_Txt__c = galleryVideo.fileExt;
//             resource.PMP_File_Size_Txt__c = galleryVideo.fileSize;
//             resource.PMP_Video_Title_Txt__c = galleryVideo.uploadName;
//             insert resource;   
//             return resource.id;
//         }
//         catch(Exception e){
//             PMP_Utility.logError(e,'PMP_OfferingResourceHelper');
//             return null;
//         }
//     } 
//     /**
//     * Method added by Pranjal 
//     * @description-to get Gallery Offering Resource records in the form of wrapper to display in LWC component
//     * @param offeringId the Id of the offering
//     * This method is used in ipaVideo LWC component
//     */
     
//     @AuraEnabled
//     public static List<OfferingResourceWrapper> getGalleryVideos(Id offeringId){
        
//        List<OfferingResourceWrapper> galleryResources = new List<OfferingResourceWrapper>();//offering resource wrapper list
//        List<PMP_Partner_Offering_Resource__c> offeringResources = New List<PMP_Partner_Offering_Resource__c>();
//        //List<Id> contentDocIds = New List<Id>();
//        //Map<Id,ContentDocument> contentDocMap = New Map<Id,ContentDocument>();
//         if(string.isNotBlank(offeringId)){
//             //getting only the additonal resource records
//             if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//                 offeringResources = [SELECT id,name,PMP_Video_Title_Txt__c,PMP_Resource_Type_Nm__c, PMP_Partner_Offering_Resource_URL_Txt__c,
//                                      PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c,PMP_Offering_Id__c ,PMP_Alt_Text__c,PMP_BrightCoveVideoThumbnail_URL__c,LastModifiedDate,PMP_Offering_Gallery_Video_Ind__c,PMP_BrightCoveVideoAccountID__c,PMP_External_Source_Id__c,PMP_BrightCoveVideoId__c
//                                      FROM PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c =: offeringId
//                                      AND PMP_Offering_Gallery_Video_Ind__c = true AND PMP_Delete_BrightCove_Video_Ind__c=false
//                                      AND PMP_Resource_Type_Nm__c =:PMP_StaticConstants_Offering.VIDEO];
//             }
            
//             //Iterating over the additional resources List to frame the return wrapper
//             for(PMP_Partner_Offering_Resource__c resource : offeringResources){
//                     //Framing the offering resource wrapper
                    
//                     OfferingResourceWrapper resourceWrapper = New OfferingResourceWrapper();
//                     resourceWrapper.Id = resource.Id;
//                     resourceWrapper.title = resource.name;
//                     resourceWrapper.description = String.IsNotBlank(resource.PMP_Resource_Description_Txt__c) ? resource.PMP_Resource_Description_Txt__c : '';
//                     resourceWrapper.altText = resource.PMP_Alt_Text__c;
//                     resourceWrapper.uploadId = resource.PMP_Partner_Offering_Image__c;
//                     if(resource.PMP_Resource_Type_Nm__c ==PMP_StaticConstants_Offering.VIDEO && resource.PMP_Offering_Gallery_Video_Ind__c==true){
//                         VideoTypeWrapper videoWrapper = new VideoTypeWrapper();
//                         videoWrapper.accountId = resource.PMP_BrightCoveVideoAccountID__c;
//                         videoWrapper.thumbnailUrl = String.IsNotBlank(resource.PMP_BrightCoveVideoThumbnail_URL__c)?resource.PMP_BrightCoveVideoThumbnail_URL__c:'' ;
//                         videoWrapper.videoId = resource.PMP_BrightCoveVideoId__c;
//                         if(String.IsNotBlank(resource.PMP_BrightCoveVideoThumbnail_URL__c) && (videoWrapper.videoId!=null || videoWrapper.videoId!='')){
//                             videoWrapper.videoType = PMP_StaticConstants_Offering.BRIGHTCOVE;
//                         }
//                         resourceWrapper.videoType = videoWrapper;
//                         resourceWrapper.videoThumbnail = String.IsNotBlank(resource.PMP_BrightCoveVideoThumbnail_URL__c)?resource.PMP_BrightCoveVideoThumbnail_URL__c:'' ;
//                        resourceWrapper.uploadName = (resource.PMP_Video_Title_Txt__c==null || resource.PMP_Video_Title_Txt__c=='')?resource.name:resource.PMP_Video_Title_Txt__c;
//                     }
//                     galleryResources.add(resourceWrapper);
//             }
//         }
//         return galleryResources;
//     }
//     /**
//     * Method added by Pranjal 
//     * @description-to delete GalleryVideo update teh field
//     * @param offeringId the Id of the offering
//     * This method is used in ipaVideo LWC component
//     */
     
//     @AuraEnabled
//     public static Boolean updateGalleryVideo(String offeringResId,String uploadId){
//             List<PMP_Partner_Offering_Resource__c> offeringResourceToUpdate = new List<PMP_Partner_Offering_Resource__c>();
//             //getting only the additonal resource records
//             if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//                 offeringResourceToUpdate = [SELECT id,name,PMP_Delete_BrightCove_Video_Ind__c,PMP_Offering_Id__c
//                                       FROM PMP_Partner_Offering_Resource__c WHERE Id =: offeringResId];
//             }
//             if(offeringResourceToUpdate.size()>0){
//                 offeringResourceToUpdate[0].PMP_Delete_BrightCove_Video_Ind__c=true;
//                 update offeringResourceToUpdate;
//             }
//             List <ContentDocumentLink> cdlList = [SELECT id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =:uploadId];
//             List <ContentDocumentLink> newCDLList = new List <ContentDocumentLink>();
//             if(cdlList.size()>2){
//                 for(ContentDocumentLink cdl:cdlList){
//                     String cdId = cdl.LinkedEntityId;
//                     if(!cdId.contains('005') && offeringResourceToUpdate[0].PMP_Offering_Id__c == cdId ){
//                         newCDLList.add(cdl);
//                     }
//                 }
//                 delete newCDLList;
//             } else {
//                 List<ContentDocument> cd= [SELECT id FROM ContentDocument WHERE Id =: uploadId];
//                 if(cd.size()>0){
//                     delete cd;
//                 }
//             }
//             return true;
//     }

//     /**
//     * Method added by Pranjal 
//     * @description-to get the images count
//     * @param offeringId the Id of the offering
//     * This method is used in ipaVideo LWC component
//     */
//     @AuraEnabled
//     public static Integer getGalleryImagesCount(Id offeringId){
//         List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE ContentDocument.FileType IN ('PNG', 'GIF', 'JPG', 'JPEG') AND LinkedEntityId =: offeringId];
//         Integer galleryImagesLength =cdlList.size();
//         return galleryImagesLength;
//     }
}