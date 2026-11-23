/****************************************************************************************************************************************
* Class Name  : PMP_ImageResizeService 
* Version     : 1.0 
* Created Date: 08-01-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Prakash                         Aug-01-2019                    implementation class for Image resize service
* ****************************************************************************************************************************************/
	//IPA2.0:US-4497-1631_OfferingEOL
public without sharing class PMP_ImageResizeService implements PMP_RetryCalloutInterface {

    public Boolean retryCallout(Id recordId){
       return generateThumbnailImage(recordId); 
    }
    
    public map<Id,Boolean> retryCallout(List<Id> recordIds){
        return null;
    }
    
    
//    /**
//     * @description generate thumbnail images from PIM and will store in SFDC
//     * @param recordId the Id of the offering resource you are dealing with
//     * @return void
//     * Method Parameters - Id
//     */
//     //IPA2.0:US-4497-1631_OfferingEOL
       public Boolean generateThumbnailImage (Id recordId){
            return true;
       }
//     public Boolean generateThumbnailImage (Id recordId){
       
//        List<PMP_Partner_Offering_Resource__c> offeringResources = new List<PMP_Partner_Offering_Resource__c>(); 
//        Boolean isCalloutSuccess = false;
//        String contentAssetName = '';
//        String contentAssetURL = '';
//        String questionMarkSymbol = '?';       
       
//        // system.debug('recordId:->'+recordId);
       
//        if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){ 
//        		offeringResources = [SELECT Id,
//                                    PMP_Partner_Offering_Image__c,
//                                    PMP_Offering_Id__c,PMP_Resource_Sequence_Nbr__c 
//                                    FROM PMP_Partner_Offering_Resource__c
//                                    WHERE Id = :recordId];
//        }                                              
//             if(!offeringResources.isEmpty() && string.isNotBlank(offeringResources[0].PMP_Partner_Offering_Image__c)) {
//                  contentAssetName = string.valueOf(offeringResources[0].Id) +'_'+ string.valueOf(offeringResources[0].PMP_Offering_Id__c);   
//             }
            
//             HTTPResponse response;           
        
//             //fetch base community URL
//             String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
            
//             //remove '/s' from baseCommunityUrl community URL
//             if(baseCommunityUrl.endsWith('/s')){
//                 baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
//             }            
//             //fetch static text called "/file-asset" from metaData
//             String staticFileAsset = PMP_Utility.getValue('Community_File_Asset');  
            
            
//              if(string.isNotEmpty(contentAssetName)) {
//                  contentAssetURL =  baseCommunityUrl+staticFileAsset+contentAssetName+questionMarkSymbol;
//                  response = PMP_ImageResizeService.makeCalloutToPIM(contentAssetURL);// make a call out to PIM
//                  //System.debug(response.getBody());
//              }
             
             
//              //if response status is 200 means it is a success call
//              if(response != null && response.getStatusCode() == 200){
                
//                 //get the response body as blob data
//                 blob thumbNailImage = response.getBodyAsBlob();
                
//                //Create a content version instance
//                ContentVersion newVersion = createContentAssetVersion(contentAssetName,thumbNailImage);

//                //insert offering resource record with resource type as thumbnail
//                createThumbnailOfferingResource(newVersion,offeringResources[0].PMP_Offering_Id__c,Integer.valueOf(offeringResources[0].PMP_Resource_Sequence_Nbr__c));
               
//                isCalloutSuccess = true;
//              }
//              return isCalloutSuccess;
//     }

         
//    /**
//     * @description create offering resource with thumbnail image data
//     * @param content - content distribution object information
//     * @param offeringId - offering id under which the offering resources to be created
//     * @param imgSequence - sequence number for the image/Thumbnail Image
//     * @return void
//     * Method Parameters - ContentDistribution , Id, Integer
//     */
//     //IPA2.0:US-4497-1631_OfferingEOL
//     public static void createThumbnailOfferingResource (ContentVersion content,Id offeringId,Integer imgSequence) {

//         id documentId = [Select ContentDocumentId FROM ContentVersion WHERE Id =:content.Id].ContentDocumentId;

//         PMP_Partner_Offering_Resource__c offeringResource = new PMP_Partner_Offering_Resource__c(); // offering resource instance
//        	offeringResource.Name = content.Title.length()>80 ? content.Title.subString(0,80) : content.Title; // populating offering resource name
//         offeringResource.PMP_Resource_Type_Nm__c = PMP_StaticConstants_Offering.THUMBNAIL_IMAGE; // populating resource type
//         offeringResource.PMP_Offering_Id__c= offeringId; // associating offering Id
//         offeringResource.PMP_Partner_Offering_Image__c = documentId; // associating content document id
//         offeringResource.PMP_Resource_Sequence_Nbr__c = imgSequence;
        
//         if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable()){
//         	insert offeringResource; // insert offering resource
//         }    
            
//     }
    
//    /**
//     * @description create content asset with thumbnail image data
//     * @param resourceAssetId - content asset name
//     * @param thumbNailImage - thumbnail image 
//     * @return void
//     * Method Parameters - ContentDistribution , Id, Integer
//     */
//     //IPA2.0:US-4497-1631_OfferingEOL
//     public static ContentVersion createContentAssetVersion (String resourceAssetId, Blob thumbNailImage) {
//         //Network Id of Partner Solutions Market place community
//         Network psmNetwork;
       
//         psmNetwork = [SELECT Id FROM Network WHERE Name =: PMP_Utility.getValue('Marketplace_Community_Name') ];
          
//         Id networkId;
//         if(psmNetwork != null){
//             networkId = psmNetwork.Id;
//         }
//         ContentVersion contentVersion = new ContentVersion();//content version instance
//         contentVersion.Title = resourceAssetId;// title of content version
//         contentVersion.PathOnClient = resourceAssetId + Datetime.now().getTime() + '.png'; // set path on client
//         contentVersion.VersionData = thumbNailImage; // set the thumbnail image as the data
//         contentVersion.Origin = 'H'; // set the origin
//         //contentVersion.PublishStatus = 'P';//The document is published to a public library and is visible to other users
//         contentVersion.NetworkId = networkId; //ID of the community that this file originated from
        
//         insert contentVersion; // insert content version
          
//         return ContentVersion;
//     }




//     /**
//     * @description make an http call out to PIM
//     * @param imageContentAssetURL    - ContentDownloadUrl of content distribution object
//     * @return HTTPResponse - call out response
//     * Method Parameters - String , Integer
//     */

    public static HTTPResponse makeCalloutToPIM(String contentURL){

        // create http request instance
        HttpRequest request = new HttpRequest();
        String endPointURL = '?height='+PMP_Utility.getValue('Thumbnail_Height')+'&width='+PMP_Utility.getValue('Thumbnail_Width')+'&url=';   	
        request.setEndpoint('callout:PIM_ImageResizeService'+endPointURL + EncodingUtil.urlEncode(contentURL, 'UTF-8') + '.jpg');
    	request.setMethod('GET'); // set the http method as 'GET'
        request.setTimeout(60000);

        //system.debug('###contentURL:->'+contentURL);
        //system.debug('###endPointURL:->'+endPointURL);

        Http h = new Http();//http instance variable to make http callout

        HTTPResponse response = new  HTTPResponse(); // variable to store http response

        //system.debug('###request:->'+request);

        // sending the request using http instance
        response = h.send(request);
    	//system.debug('response::'+response);
        return response;
    }
   
//      /**
//     * @description make an http call out to PIM
//     * @param imageContentAssetURL    - ContentDownloadUrl of content distribution object
//     * @param retryCount    - total no of call outs
//     * @return HTTPResponse - call out response
//     * Method Parameters - String , Integer
//     */

    public static HTTPResponse makeCalloutToPIM(String imageContentAssetURL,Integer retryCount){

        // create http request instance
        HttpRequest request = new HttpRequest(); 
            
        String endPointURL = '?height='+PMP_Utility.getValue('Thumbnail_Height')+'&width='+PMP_Utility.getValue('Thumbnail_Width')+'&url=';

        //accessing user name and password from named credentials
        request.setEndpoint('callout:PIM_ImageResizeService' + endPointURL + EncodingUtil.urlEncode(imageContentAssetURL, 'UTF-8') + '.jpg');
        request.setMethod('GET'); // set the http method as 'GET'

        String apiKey = PMP_Utility.getValue('Thumbnail_API_Key'); 
        request.setHeader('API_Key', apiKey);
        request.setTimeout(60000);

        Http h = new Http();//http instance variable to make http callout

        HTTPResponse response = new  HTTPResponse(); // variable to store http response

        // sending the request using http instance
        response = h.send(request);

        return response;
    }

      
}