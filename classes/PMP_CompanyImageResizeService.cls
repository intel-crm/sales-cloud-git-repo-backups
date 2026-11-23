/****************************************************************************************************************************************
* Class Name  : PMP_CompanyImageResizeService 
* Version     : 1.0 
* Created Date: July-15-2021
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Onyx                         July-15-2021                    implementation class for Company Image resize service
* ****************************************************************************************************************************************/
public without sharing class PMP_CompanyImageResizeService implements PMP_RetryCalloutInterface {
    
    public Boolean retryCallout(Id recordId){
        return generateThumbnailImage(recordId); 
    }
    
    public map<Id,Boolean> retryCallout(List<Id> recordIds){
        return null;
    }
    
    
    /**
* @description generate thumbnail images from PIM and will store in SFDC
* @param recordId the Id of the offering resource you are dealing with
* @return void
* Method Parameters - Id
*/
    public Boolean generateThumbnailImage (Id recordId){
        
        List<PMP_Company_Resource__c> partnerResources = new List<PMP_Company_Resource__c>(); 
        Boolean isCalloutSuccess = false;
        String contentAssetName = '';
        String contentAssetURL = '';
        String questionMarkSymbol = '?';       
        
        if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){ 
            partnerResources = [SELECT id, PMP_Company_Image__c, PMP_Company_Id__c, 
                                PMP_Company_Resource_Sequence_Nbr__c
                                from PMP_Company_Resource__c WHERE Id = :recordId];
        }   
        //System.debug('..partnerResources..'+partnerResources);
        if(!partnerResources.isEmpty() && string.isNotBlank(partnerResources[0].PMP_Company_Image__c)) {
            contentAssetName = string.valueOf(partnerResources[0].Id) +'_'+ string.valueOf(partnerResources[0].PMP_Company_Id__c);   
        }
        HTTPResponse response;           
        //fetch base community URL
        String baseCommunityUrl = PMP_Utility.getBaseCommunityUrl();
        
        //remove '/s' from baseCommunityUrl community URL
        if(baseCommunityUrl.endsWith('/s')){
            baseCommunityUrl =baseCommunityUrl.removeEnd('/s');
        }            
        //fetch static text called "/file-asset" from metaData
        String staticFileAsset = PMP_Utility.getValue('Community_File_Asset');  
        

        if(string.isNotEmpty(contentAssetName)) {
            contentAssetURL =  baseCommunityUrl+staticFileAsset+contentAssetName+questionMarkSymbol;
            response = makeCalloutToPIM(contentAssetURL);// make a call out to PIM

        }
        
        //if response status is 200 means it is a success call
        if(response != null && response.getStatusCode() == 200){
            
            //get the response body as blob data
            blob thumbNailImage = response.getBodyAsBlob();
            
            //Create a content version instance
            ContentVersion newVersion = PMP_Image_Resizing.CreateContentVersionInstance(contentAssetName,thumbNailImage);
            
            //insert offering resource record with resource type as thumbnail
            PMP_Image_Resizing.insertThumbnailCompanyResource(newVersion,partnerResources[0].PMP_Company_Id__c,Integer.valueOf(partnerResources[0].PMP_Company_Resource_Sequence_Nbr__c));
            
            isCalloutSuccess = true;
        }
        return isCalloutSuccess;
    }
    
    /**
    * @description make an http call out to PIM
    * @param imageContentAssetURL    - ContentDownloadUrl of content distribution object
    * @return HTTPResponse - call out response
    * Method Parameters - String , Integer
    */

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
     /**
    * @description make an http call out to PIM
    * @param imageContentAssetURL    - ContentDownloadUrl of content distribution object
    * @param retryCount    - total no of call outs
    * @return HTTPResponse - call out response
    * Method Parameters - String , Integer
    */

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