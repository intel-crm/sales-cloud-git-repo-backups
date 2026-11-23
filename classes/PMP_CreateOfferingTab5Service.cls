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
public class PMP_CreateOfferingTab5Service {
    
    @future(callout=true)
    public static void generateThumbnailImages(Id offeringId) {
       
        try{            
            List<String> contentAssets = new List<String>();
            Map<String,Integer> imgSequenceByContentAsset = new Map<String,Integer>();//**contains imageSequenceByAsset
            //Variable to capture existing offering resource records related to thumbnail images
            List<PMP_Partner_Offering_Resource__c> existingThumbnailOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
            Map<Id,String> offeringResourceNameById = new Map<Id,String>();
            String questionMarkSymbol = '?';
        
            for(PMP_Partner_Offering_Resource__c resource : [SELECT Id,PMP_Partner_Offering_Image__c,PMP_Offering_Id__c FROM PMP_Partner_Offering_Resource__c
                                                                WHERE PMP_Offering_Id__c = :offeringId
                                                                AND PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.THUMBNAIL_IMAGE]) {
              existingThumbnailOfferingResources.add(resource);
            }
            
            //query offering resources for the current offering and add it to Map
            for(PMP_Partner_Offering_Resource__c resource : [SELECT Id,Name,PMP_Partner_Offering_Image__c,PMP_Resource_Sequence_Nbr__c FROM PMP_Partner_Offering_Resource__c
                                                               WHERE PMP_Offering_Id__c = :offeringId
                                                                AND PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.IMAGE]) {                                                                 
              if(string.isNotBlank(resource.PMP_Partner_Offering_Image__c)) {
                offeringResourceNameById.put(resource.Id,resource.Name);
                String contentAssetName = string.valueOf(resource.Id) +'_'+ string.valueOf(offeringId);                                                     
                imgSequenceByContentAsset.put(contentAssetName,Integer.valueOf(resource.PMP_Resource_Sequence_Nbr__c));
                contentAssets.add(contentAssetName);
                  
                }
            }
                     
            Map<String,Blob> thumbnailImageByContentAsset = new Map<String,Blob>();
            HTTPResponse response;
            
            //fetch base community URL
            String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
            
            //remove '/s' from baseCommunityUrl community URL
            if(baseCommunityUrl.endsWith('/s')){
                baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
            }            
            //fetch static text called "/file-asset" from metaData
            String staticFileAsset = PMP_Utility.getValue('Community_File_Asset');            
            
            //iterate over content asset data and make a call out to PIM to get auto resized url
            for(String contentAsset : contentAssets) {
               String offResourceId = contentAsset.split('_').get(0);
                //Send the string to PIM in the form of : communityURL/file-asset/AssetName? 
                String contentUrl = baseCommunityUrl+staticFileAsset+contentAsset+questionMarkSymbol;
                response = makeCalloutToPIM(contentUrl,1);// make a call out to PIM
                
                //response is not null and 200 means its a success call , so create a thumbnail image
                if(response != null && response.getStatusCode() == 200){
                  //get the response body as blob data
                    blob thumbNailImage = response.getBodyAsBlob();
                    thumbnailImageByContentAsset.put(contentAsset,thumbNailImage);
                }else {
                    //create log entry record to retry again from batch process 
                    PMP_Utility.creatFailedCalloutLogEntryRecord(offResourceId,'PMP_ImageResizeService','PMP','PMP_Partner_Offering_Resource__c');
                }
            }          
            
            if(!thumbnailImageByContentAsset.keySet().isEmpty()) {

                for(String contentAssetRec : thumbnailImageByContentAsset.keySet()) {
                    system.debug('###contentAssetRec:->'+contentAssetRec);
                    //Split the asset id to get only the resourceImageId
                    Id resourceId = contentAssetRec.split('_').get(0);                    
                    ContentVersion newVersion = PMP_ImageResizeService.createContentAssetVersion(offeringResourceNameById.get(resourceId),thumbnailImageByContentAsset.get(contentAssetRec));                   
                    //insert offering resource record with resource type as thumbnail
                    PMP_ImageResizeService.createThumbnailOfferingResource(newVersion,offeringId,imgSequenceByContentAsset.get(contentAssetRec));
                   
                }
            }
            
            //Delete existing offering records related to thumbnail , as we are inserting again those records above
            if(!existingThumbnailOfferingResources.isEmpty()){
                delete existingThumbnailOfferingResources;
            }
              
    
        }catch(Exception ex){
            system.debug('Exception while making PIM Resize callout:->'+ex);
            throw ex;
        }
    }


 public static HTTPResponse makeCalloutToPIM(String contentURL,Integer retryCount){

        // create http request instance
        HttpRequest request = new HttpRequest();

        String endPointURL = '?height='+PMP_Utility.getValue('Thumbnail_Height')+'&width='+PMP_Utility.getValue('Thumbnail_Width')+'&url=';
        String questionMarkSymbol = '?'; // for content asset to be resized we need to add this variable beofre jpg
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

}