/******************************************************************************************************************************************************************
* Class Name  : MarketplaceProductDetailsController 
* Version     : 1.0 
* Created Date: 06-10-2019
* Modification Log :
*
* Developer                           Date                          Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Raj                   06/10/2019                    Method 'getOfferingDetails' to display offering details on create offering wizard's product card
******************************************************************************************************************************************************************/
public with sharing class MarketplaceProductDetailsController extends PMP_SearchWrapperStore {
    public static Boolean isWorking() {
        return true;
    }
    
    /**
    * method added by raj to get offering details for US374590
    * @description-fetch offering and it's related object details
    * @param offeringId the Id of the offering
    * @return Map<String,Object>
    * Method Parameters - Id
    */
   /* @AuraEnabled(cacheable = true)
    public static String getOfferingDetails(Id offeringId){
        
        Map<String,Object> detailsByType = new Map<String,Object>();//It will contain details of the offering and it's related object
        String language = userinfo.getLanguage();//getting the logged in user's language
        String localeCatNmField;
        String localeSpecNmField;
        String localeSpecValNmField;
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeFields = new List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();
        List<OffCatWrapper> categoriesData = new List<OffCatWrapper>();
        List<OffSpecWrapper> specificationsData = new List<OffSpecWrapper>();
        List<PMP_Partner_Offering_Resource__c> offeringResources = new List<PMP_Partner_Offering_Resource__c>();
        List<Id> contentDocIds = New List<Id>();
        List<OfferingResourceWrapper> resourceWrapperList = New List<OfferingResourceWrapper>();
        Map<String,ContentDocument> contentDocMap = New Map<String,ContentDocument>();			
        Map<string, contentAssetWrapper> contentAssetWrapperMap = New Map<string, contentAssetWrapper>();
        List<media> mediaWrapperList = New List<media>();	
        //fetch static text called "/file-asset" from metaData
        String staticFileAsset = PMP_Utility.getValue('Community_File_Asset'); 
        //fetch base community URL
        String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
        Map<String, String> resourceMap  = new Map<String, String>();
        Set<id> imageIds = new Set<id>();
        if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
        for(PMP_Partner_Offering_Resource__c resource1 : [Select id,Name,PMP_Partner_Offering_Image__c 
                                                             from PMP_Partner_Offering_Resource__c  where 	PMP_Offering_Id__c = :offeringId]){
                if(resource1.PMP_Partner_Offering_Image__c!=null){
                    imageIds.add(resource1.PMP_Partner_Offering_Image__c);
                }                                 
            }
        }		
        List<ContentAsset> ca = new List<ContentAsset>();
       if(Test.isRunningTest()){
           ca = [  Select ContentDocumentId,DeveloperName from ContentAsset Where ContentDocumentId!=null limit 1 ];
        } else {
            ca = PMP_FetchAssetContent.getContentAsset(imageIds);         
          }
         if(!ca.isEmpty()){
                for (ContentAsset ca1 : ca){
                    resourceMap.put(ca1.ContentDocumentId, ca1.DeveloperName);
                }
            }
        //system.debug('language---->'+language);
        
        if(language != null){//if user language is there fetch the name field of all the taxonomy object for the user language from metadata
            localeFields = PMP_Utility.getLocaleToFieldMdtRecordsByField(language, 'Name');
        }
        
        for(PMP_Locale_To_FieldAPINm_Mapping__mdt localField : localeFields){//iterating over metadata records and getting the api field names of cat, spec and specVal
            if(localField.PMP_Object_Nm__c == 'Category'){
                localeCatNmField = localField.PMP_Field_APINm__c;
            }
            else if(localField.PMP_Object_Nm__c == 'Specification'){
                localeSpecNmField = localField.PMP_Field_APINm__c;
            }
            else if(localField.PMP_Object_Nm__c == 'Specification Value'){
                localeSpecValNmField = localField.PMP_Field_APINm__c;
            }
            
        }

        //getting offering related information from offering object and putting it into the map
        PMP_Partner_Offering__c offering;
        if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
        	offering =[Select id, (Select id,Name,PMP_External_Source_Id__c,PMP_Video_Title_Txt__c,PMP_BrightCove_Video_Extension_Txt__c,PMP_File_Size_Txt__c,PMP_Partner_Offering_Image__c,PMP_Resource_Type_Nm__c,PMP_Resource_Description_Txt__c,
              PMP_Partner_Offering_Resource_URL_Txt__c,PMP_Offering_Id__c,PMP_Resource_Sequence_Nbr__c,PMP_BrightCoveVideoAccountID__c, PMP_BrightCoveVideoId__c,PMP_BrightCoveVideoThumbnail_URL__c,PMP_Alt_Text__c,PMP_Offering_Gallery_Video_Ind__c,LastModifiedDate,PMP_Delete_BrightCove_Video_Ind__c from Offering_Resources__r ORDER by PMP_Resource_Sequence_Nbr__c),
              PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Partner_Offering_End_Dt__c,PMP_Offering_Language_Nm__c,
              PMP_Partner_Offering_Id__c,PMP_Partner_Offering_Start_Dt__c,PMP_Offering_Status_Update_Dt__c,PMP_Translated_Languages__c,
              PMP_Partner_Revision_Comment_Txt__c,PMP_Company_Id__c,PMP_Company_Id__r.Name,PMP_Working_Copy_Id__c,PMP_Is_Not_Available_On_MP_Ind__c,PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,
              PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,Name,PMP_Partner_Offering_Nm__c,
              PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__c,
              PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Is_Notified_Ind__c,PMP_Pre_Release_Check_Nm__c,PMP_Pre_Release_Item_Count_Num__c,
              PMP_Category_nm__c, PMP_Sub_Category_nm__c         
              from PMP_Partner_Offering__c where id = :offeringId];
        }
        //getting categories related to the offering and putting it into offering category wrapper
        List<PMP_Partner_Offering_Category__c> offCategories = PMP_CategoryController.getOfferingCaregories(offeringId);
        for(PMP_Partner_Offering_Category__c offCat : offCategories){
            OffCatWrapper catDataWrapper = new OffCatWrapper();
            catDataWrapper.localName = String.valueOf(offCat.PMP_Category_Id__r.get(localeCatNmField));
            catDataWrapper.ancestorId = offCat.PMP_Ancestor_Category_Cd__c;
            categoriesData.add(catDataWrapper);
            categoriesData.sort();
        }
        
        
        //getting specifications related to the offering and putting it into the map
        List<PMP_Partner_Offering_Specification__c> offSpecs = PMP_SpecificationController.getOfferingSpecifications(offeringId);
        for(PMP_Partner_Offering_Specification__c offSpec : offSpecs){
           	OffSpecWrapper specDataWrapper = new OffSpecWrapper();
            if(String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField)) != null){
            	specDataWrapper.localSpecName = String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField));
            }
            else{
                specDataWrapper.localSpecName = String.valueOf(offSpec.PMP_Specification_Id__r.get('Name'));
            }
            if(offSpec.PMP_Specification_Value_Id__r != null){
                if(String.valueOf(offSpec.PMP_Specification_Value_Id__r.get(localeSpecValNmField)) != null){
            		specDataWrapper.localSpecValueName = String.valueOf(offSpec.PMP_Specification_Value_Id__r.get(localeSpecValNmField));
                }
                else if(offSpec.PMP_Specification_Value_Id__r.get('Name') != null){
                    specDataWrapper.localSpecValueName = String.valueOf(offSpec.PMP_Specification_Value_Id__r.get('Name'));
                }
            } else {
                specDataWrapper.localSpecValueName = String.valueOf(offSpec.PMP_Specification_Value_Cd__c); 
            }
            specDataWrapper.specificationId = offSpec.PMP_Product_Specification_Cd__c;
            specDataWrapper.ancestorId = offSpec.PMP_Ancestor_Specification_Cd__c;
            specificationsData.add(specDataWrapper);
        }

        //getting resources related to the offering and putting it into offering resource wrapper
        //System.debug(offering.Offering_Resources__r);
        for(PMP_Partner_Offering_Resource__c resource : offering.Offering_Resources__r){
            //system.debug('resource-->' +resource);
            if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE || (resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && resource.PMP_Offering_Gallery_Video_Ind__c==true&&resource.PMP_Delete_BrightCove_Video_Ind__c==false)){ 
                contentAssetWrapper contWrapper = New contentAssetWrapper();
                media mediaWrapper = new media();
                mediaWrapper.placeholder1920px = System.Label.PMP_VideoUnAvailImg;
                mediaWrapper.placeholder246px = System.Label.PMP_VideoUnavailThumb;
                mediaWrapper.altText = resource.PMP_Alt_Text__c;
                if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE ){
                    //system.debug('image' +resource);
                    if(resourceMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
                        mediaWrapper.imageUrl = resourceMap.get(resource.PMP_Partner_Offering_Image__c);     
                    }else{                         
                        mediaWrapper.imageUrl = resource.id+'_'+offering.id;
                    }
                     mediaWrapperList.add(mediaWrapper);
                }
                
                else if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && (resource.PMP_BrightCoveVideoAccountID__c != null) && resource.PMP_Offering_Gallery_Video_Ind__c == true &&resource.PMP_Delete_BrightCove_Video_Ind__c==false) {
                    //system.debug('video details' +resource) ; 
                    mediaWrapper.accountId = resource.PMP_BrightCoveVideoAccountID__c;
                    mediaWrapper.videoId = resource.PMP_BrightCoveVideoId__c;
                    mediaWrapper.videoType = 'brightcove';
                    mediaWrapper.videoThumbnailUrl = resource.PMP_BrightCoveVideoThumbnail_URL__c;
                    mediaWrapper.description = resource.PMP_Resource_Description_Txt__c;
                    mediaWrapper.imageUrl = resource.PMP_BrightCoveVideoThumbnail_URL__c;
                    if(resource.PMP_BrightCoveVideoThumbnail_URL__c==''||resource.PMP_BrightCoveVideoThumbnail_URL__c==null){
                        mediaWrapper.videoId = null;
                    }
                    mediaWrapperList.add(mediaWrapper);
                    //System.debug('mediaWrapper::'+mediaWrapper);
                }
                //resource name will be the key for the contentAssetWrapperMap
                // -----populating contentAssetWrapperMap start ---
                if(contentAssetWrapperMap.containsKey(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c))){ 
                    contWrapper = contentAssetWrapperMap.get(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c));
                    if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE){
                        //system.debug('image' +resource);
                        if(resourceMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
                            contWrapper.imageUrl = resourceMap.get(resource.PMP_Partner_Offering_Image__c); 
                         }else{    
                             contWrapper.imageUrl = resource.id+'_'+offering.id;
                         }
                    }
                    contentAssetWrapperMap.put(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c),contWrapper );
                }
                else{
                    contWrapper.type = resource.PMP_Resource_Type_Nm__c;
                    if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.IMAGE){
                        //system.debug('image2' +resource);
                        if(resourceMap.containsKey(resource.PMP_Partner_Offering_Image__c)){
                            contWrapper.imageUrl = resourceMap.get(resource.PMP_Partner_Offering_Image__c); 
                         }else{    
                             contWrapper.imageUrl = resource.id+'_'+offering.id;
                         }
                    }
                    contentAssetWrapperMap.put(resource.PMP_Offering_Id__c+'_'+string.valueOf(resource.PMP_Resource_Sequence_Nbr__c),contWrapper );
                }
            }
             // -----populating contentAssetWrapperMap end ---
            else{
              if(resource.PMP_Delete_BrightCove_Video_Ind__c==false && resource.PMP_Resource_Type_Nm__c!=PMP_StaticConstants_Offering.THUMBNAIL_IMAGE){
                if(String.isNotBlank(resource.PMP_Partner_Offering_Image__c)){
                    contentDocIds.add(resource.PMP_Partner_Offering_Image__c);
                }
                OfferingResourceWrapper resourceWrapper = New OfferingResourceWrapper();
                resourceWrapper.id = resource.Id;
                resourceWrapper.externalId = resource.PMP_External_Source_Id__c;
                resourceWrapper.title = resource.name;
                resourceWrapper.resourceType = resource.PMP_Resource_Type_Nm__c;
                resourceWrapper.url = resource.PMP_Partner_Offering_Resource_URL_Txt__c;
                resourceWrapper.uploadId = resource.PMP_Partner_Offering_Image__c;
                resourceWrapper.description = String.IsNotBlank(resource.PMP_Resource_Description_Txt__c) ? resource.PMP_Resource_Description_Txt__c : '';
                resourceWrapper.publishDate = resource.LastModifiedDate.format('MMM dd, yyyy');
                resourceWrapper.altText = resource.PMP_Alt_Text__c;
                //System.debug('Add Resources: '+resourceWrapper);
                if(resource.PMP_Resource_Type_Nm__c == PMP_StaticConstants_Offering.VIDEO && resource.PMP_Offering_Gallery_Video_Ind__c==false){
                    VideoTypeWrapper videoWrapper = new VideoTypeWrapper();
                    videoWrapper.accountId = resource.PMP_BrightCoveVideoAccountID__c;
                    videoWrapper.thumbnailUrl = String.IsNotBlank(resource.PMP_BrightCoveVideoThumbnail_URL__c)?resource.PMP_BrightCoveVideoThumbnail_URL__c:'' ;
                    videoWrapper.videoId = resource.PMP_BrightCoveVideoId__c;
                    if(videoWrapper.videoId!=''){
                        videoWrapper.videoType = 'brightcove';
                    }
                    if(resource.PMP_BrightCoveVideoThumbnail_URL__c==''||resource.PMP_BrightCoveVideoThumbnail_URL__c==null){
                        videoWrapper.videoId = null;
                    }
                    resourceWrapper.videoType = videoWrapper;
                    resourceWrapper.fileSize = resource.PMP_File_Size_Txt__c;
                    String filetype = resource.PMP_BrightCove_Video_Extension_Txt__c;
                    if(filetype!=null && filetype.length()>0){
                        filetype = filetype.substring(1);
                        filetype = filetype.toUpperCase();
                    }
                    resourceWrapper.fileType = filetype;
                    resourceWrapper.uploadName = resource.PMP_Video_Title_Txt__c;
                }
                //System.debug('After resourceWrapper: '+resourceWrapper);
                resourceWrapperList.add(resourceWrapper);
            }
            offeringResources.add(resource);
        }
        if(!contentDocIds.isEmpty()){
            //Fetch the content document details for the Ids in contentDocIds list to get file size and file type
            List<ContentDocument> cdList = PMP_OfferingResourceHelper.getContentDocList(contentDocIds);
            for(ContentDocument cd : cdList){
                contentDocMap.put(cd.Id, cd);
            }
            for(OfferingResourceWrapper resourceWrap :  resourceWrapperList){
                if(String.isNotBlank(resourceWrap.uploadId) && !contentDocMap.isEmpty()){
                    if(contentDocMap.containsKey(resourceWrap.uploadId)){
                        resourceWrap.fileType = contentDocMap.get(resourceWrap.uploadId).FileType;
                        resourceWrap.fileSize = PMP_Utility.FileSizeToString(contentDocMap.get(resourceWrap.uploadId).ContentSize);
                    }
                    if(resourceWrap.resourceType!=PMP_StaticConstants_Offering.VIDEO){
                        if(resourceWrap.externalId!=null && resourceWrap.uploadId!=null){
                            //framing the download url with community url+'file-asset/'+contentasset developer name(rma_conDocId)
                            resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset +'rma_'+resourceWrap.uploadId;
                        } else {
                            //framing the download url with community url+'file-asset/'+contentasset developer name(resourceId_offeringId)
                            //resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset + resourceWrap.Id +'_'+ string.valueOf(offeringId);
                            if(resourceMap.containsKey(resourceWrap.uploadId)){
                                resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset + resourceMap.get(resourceWrap.uploadId);  
                            }else{
                                resourceWrap.downloadUrl = baseCommunityUrl + staticFileAsset + resourceWrap.Id +'_'+ string.valueOf(offeringId);
                            } 
                        }
                    }
                }
            }
        }

        if(contentAssetWrapperMap.values().size() >0){ 
            detailsByType.put('contentWrapper',contentAssetWrapperMap.values());}
            //system.debug('image3' +detailsByType.get('contentWrapper'));
            //system.debug('media**************' +mediaWrapperList);
           if(mediaWrapperList.size() >0){
            List<Media> sortedMedia = new List<Media>();
            for(Media mediaRec : mediaWrapperList){
                if(mediaRec.videoType != null && mediaRec.videoType == 'brightcove'){
                    sortedMedia.add(mediaRec);
                }
            }
            for(Media mediaRec : mediaWrapperList){
                if(mediaRec.videoType != 'brightcove'){
                    sortedMedia.add(mediaRec);
                }
            }
            detailsByType.put('media',sortedMedia);
            detailsByType.put(PMP_StaticConstants_Offering.existingURLs,offeringResources);
            detailsByType.put(PMP_StaticConstants_Offering.offeringResources,resourceWrapperList);
             }
        }
        detailsByType.put(PMP_StaticConstants_Offering.OfferingDetail, offering);
        detailsByType.put(PMP_StaticConstants_Offering.selectedCategories,categoriesData);
        detailsByType.put(PMP_StaticConstants_Offering.selectedSpecifications,specificationsData);
        return JSON.serialize(detailsByType);   
        
    }*/
}