/*************************************************************************************************************************************************************************
* Class Name  : PMP_Image_Resizing 
* Version     : 1.0 
* Created Date: 7/23/2019
* Modification Log :
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Uday              M-01    : Original version     7/23/2019                                 class for resizing the images uploaded in storefront.
**************************************************************************************************************************************************************************/
public with sharing class PMP_Image_Resizing {
    @future (callout=true)
    public static void generateThumbnailImages(Id sObjectId) {
        
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
                
                response = makeCalloutToPIM(content.ContentDownloadUrl,1);// make a call out to PIM
                
                if(response != null && response.getStatusCode() == 200){
                    string responseValue = '';
                    responseValue = response.getBody();
                    system.debug('Response Body for File: ' + responseValue);
                    
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
                        ContentVersion newVersion = CreateContentVersionInstance(content,thumbnailImageByContentId.get(contentId));
                        system.debug('newVersion = '+newVersion);
                        thumbnailContentVersions.add(newVersion);
                        //insert company resource record with resource type as thumbnail
                        insertThumbnailCompanyResource(newVersion, sObjectId, object_type);
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
/*    
    private static List<Id> getContentDocumentIds(Id sObjectId, String objectType){
        List<Id> contentDocumentIds = new List<Id>();        
        if (objectType == 'PMP_Company__c'){
            for(PMP_Company_Resource__c resource : [SELECT Id,PMP_Company_Image__c FROM PMP_Company_Resource__c WHERE PMP_Company_Id__c = :sObjectId AND PMP_Company_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.IMAGE]) {
                if(string.isNotBlank(resource.PMP_Company_Image__c)) {
                    contentDocumentIds.add(resource.PMP_Company_Image__c);
                }
            }
        } else if(objectType == 'PMP_Partner_Offering__c'){
            for(PMP_Partner_Offering_Resource__c resource : [SELECT Id,PMP_Partner_Offering_Image__c FROM PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c = :sObjectId AND PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.IMAGE]) {
                if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)) {
                    contentDocumentIds.add(resource.PMP_Partner_Offering_Image__c);
                }
            }             
        } 
        return contentDocumentIds;
    }
*/
    public static HTTPResponse makeCalloutToPIM(String contentURL,Integer retryCount){

        // create http request instance
        HttpRequest request = new HttpRequest();

        String endPointURL = '?height='+PMP_Utility.getValue('Thumbnail_Height')+'&width='+PMP_Utility.getValue('Thumbnail_Width')+'&url=';

        //accessing user name and password from named credentials
        request.setEndpoint('callout:PIM_ImageResizeService' + endPointURL + EncodingUtil.urlEncode(contentURL, 'UTF-8') + '.jpg');
        request.setMethod('GET'); // set the http method as 'GET'

        String apiKey = PMP_Utility.getValue('Thumbnail_API_Key'); 
        request.setHeader('API_Key', apiKey);
        request.setTimeout(60000);

        system.debug('###contentURL:->'+contentURL);
        system.debug('###endPointURL:->'+endPointURL);

        Http h = new Http();//http instance variable to make http callout

        HTTPResponse response = new  HTTPResponse(); // variable to store http response

        system.debug('###request:->'+request);

        // sending the request using http instance
        response = h.send(request);

        system.debug('###response:->'+response);
        //If response is not success then we have to retry two more times
        if(response.getStatusCode() != 200 && retryCount<3) {
            response = makeCalloutToPIM(contentURL,retryCount+1);//retry the callout
        }

        //Even after retrying 3 times still the call out response is not success
        if(response == null || response.getStatusCode() != 200) {
            response = null; // set the response to null
        }
        return response;
    }
    public static ContentVersion CreateContentVersionInstance (ContentDistribution content, Blob thumbNailImage) {

        //Network Id of Partner Solutions Market place community
        Network psmNetwork = [SELECT Id FROM Network WHERE Name =: PMP_Utility.getValue('Marketplace_Community_Name') ];
        Id networkId;
        if(psmNetwork != null){
            networkId = psmNetwork.Id;
        }
        ContentVersion contentVersion = new ContentVersion();//content version instance
        contentVersion.Title = content.Name;// title of content version
        contentVersion.PathOnClient = content.Name + Datetime.now().getTime() + '.png'; // set path on client
        contentVersion.VersionData = thumbNailImage; // set the thumbnail image as the data
        contentVersion.Origin = 'H'; // set the origin
        //contentVersion.PublishStatus = 'P';//The document is published to a public library and is visible to other users
        contentVersion.NetworkId = networkId; //ID of the community that this file originated from
        insert contentVersion; // insert content version
        return ContentVersion;
    }
    public static void insertThumbnailCompanyResource (ContentVersion content,Id sObjectId, String objectType) {
        
        id documentId = [Select ContentDocumentId FROM ContentVersion WHERE Id =:content.Id].ContentDocumentId;
        system.debug('documentId : '+documentId);
        PMP_Company_Resource__c companyResource = new PMP_Company_Resource__c(); // offering resource instance
        companyResource.Name = content.Title;//content.Title; // populating company name
        companyResource.PMP_Company_Resource_Type_Nm__c = PMP_StaticConstants_Partner.THUMBNAIL_IMAGE; // populating resource type
        companyResource.PMP_Company_Id__c = sObjectId; // associating company Id
        companyResource.PMP_Company_Image__c = documentId; // associating content document id
        companyResource.PMP_Company_Resource_Sequence_Nbr__c = 0;
        insert companyResource; // insert company resource
        system.debug('companyResource resized : '+companyResource);
    }    
}